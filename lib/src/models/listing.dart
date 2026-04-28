import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

const campuses = <String>[
  'Michigan State University',
  'University of Michigan',
  'Wayne State University',
  'Central Michigan University',
];

const categories = <String>[
  'Books',
  'Electronics',
  'Furniture',
  'Housing',
  'Services',
  'Other',
];

enum ListingStatus { active, sold }

class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.campus,
    required this.sellerName,
    required this.sellerId,
    required this.createdAt,
    this.imageUrl,
    this.imagePath,
    this.distanceMiles,
    this.status = ListingStatus.active,
  });

  factory Listing.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    return Listing(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      campus: data['campus'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? 'Student',
      sellerId: data['sellerId'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      imagePath: data['imagePath'] as String?,
      distanceMiles: (data['distanceMiles'] as num?)?.toDouble(),
      status: ListingStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ListingStatus.active,
      ),
    );
  }

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String campus;
  final String sellerName;
  final String sellerId;
  final DateTime createdAt;
  final String? imageUrl;
  final String? imagePath;
  final double? distanceMiles;
  ListingStatus status;

  bool get isSold => status == ListingStatus.sold;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'campus': campus,
      'sellerName': sellerName,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'distanceMiles': distanceMiles,
      'status': status.name,
    };
  }
}

class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore._(
    this._listings, {
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore,
       _storage = storage;

  factory MarketplaceStore.firestore({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) {
    return MarketplaceStore._(
      [],
      firestore: firestore ?? FirebaseFirestore.instance,
      storage: storage ?? FirebaseStorage.instance,
    );
  }

  factory MarketplaceStore.seeded() {
    return MarketplaceStore._([
      Listing(
        id: '1',
        title: 'Mini fridge',
        description:
            'Clean dorm-size fridge with a small freezer compartment. Pickup near campus.',
        price: 65,
        category: 'Furniture',
        campus: 'Michigan State University',
        sellerName: 'Alex',
        sellerId: MarketplaceAuthIds.prototypeUserId,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        distanceMiles: 0.8,
      ),
      Listing(
        id: '2',
        title: 'Calculus textbook',
        description:
            'Used Stewart Calculus book. Highlighting in the first three chapters.',
        price: 35,
        category: 'Books',
        campus: 'Michigan State University',
        sellerName: 'Maya',
        sellerId: 'seller-2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        distanceMiles: 1.4,
      ),
      Listing(
        id: '3',
        title: 'Desk lamp',
        description: 'Adjustable LED desk lamp with USB charging port.',
        price: 18,
        category: 'Electronics',
        campus: 'University of Michigan',
        sellerName: 'Jordan',
        sellerId: 'seller-3',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        distanceMiles: 52,
      ),
      Listing(
        id: '4',
        title: 'Move-out cleaning',
        description:
            'Two students available for apartment cleaning before lease turnover.',
        price: 90,
        category: 'Services',
        campus: 'Michigan State University',
        sellerName: 'Chris',
        sellerId: 'seller-4',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        distanceMiles: 2.1,
      ),
    ]);
  }

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final List<Listing> _listings;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String currentUserId = MarketplaceAuthIds.prototypeUserId;

  bool get isFirestoreBacked => _firestore != null;
  List<Listing> get listings => List.unmodifiable(_listings);

  void startListening({required String userId, required String campus}) {
    currentUserId = userId;
    if (_firestore == null) {
      notifyListeners();
      return;
    }

    _subscription?.cancel();
    _subscription = _firestore
        .collection('listings')
        .where('campus', isEqualTo: campus)
        .snapshots()
        .listen(
          (snapshot) {
            _listings
              ..clear()
              ..addAll(snapshot.docs.map(Listing.fromFirestore));
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Listing subscription failed: $error');
          },
        );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_firestore != null) {
      _listings.clear();
    }
    notifyListeners();
  }

  int activeCountForCampus(String campus) {
    return _listings
        .where(
          (listing) =>
              listing.campus == campus &&
              listing.status == ListingStatus.active,
        )
        .length;
  }

  List<Listing> activeListings({
    required String campus,
    String? category,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _listings.where((listing) {
      final campusMatches = listing.campus == campus;
      final categoryMatches = category == null || listing.category == category;
      final searchMatches =
          normalizedQuery.isEmpty ||
          listing.title.toLowerCase().contains(normalizedQuery) ||
          listing.description.toLowerCase().contains(normalizedQuery);
      return campusMatches &&
          categoryMatches &&
          searchMatches &&
          listing.status == ListingStatus.active;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Listing> myListings() {
    return _listings
        .where((listing) => listing.sellerId == currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String campus,
    required String sellerName,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    final listingId = DateTime.now().microsecondsSinceEpoch.toString();
    final uploadedImage = imageBytes == null
        ? null
        : await _uploadListingImage(
            listingId: listingId,
            imageBytes: imageBytes,
            imageExtension: imageExtension,
          );
    final listing = Listing(
      id: listingId,
      title: title,
      description: description,
      price: price,
      category: category,
      campus: campus,
      sellerName: sellerName,
      sellerId: currentUserId,
      createdAt: DateTime.now(),
      imageUrl: uploadedImage?.url,
      imagePath: uploadedImage?.path,
      distanceMiles: 0.2,
    );

    if (_firestore != null) {
      await _firestore.collection('listings').add(listing.toFirestore());
      return;
    }

    _listings.insert(0, listing);
    notifyListeners();
  }

  Future<void> markSold(String listingId) async {
    if (_firestore != null) {
      await _firestore.collection('listings').doc(listingId).update({
        'status': ListingStatus.sold.name,
      });
      return;
    }

    final listing = _listings.firstWhere((item) => item.id == listingId);
    listing.status = ListingStatus.sold;
    notifyListeners();
  }

  Future<void> deleteListing(String listingId) async {
    if (_firestore != null) {
      final snapshot = await _firestore
          .collection('listings')
          .doc(listingId)
          .get();
      final imagePath = snapshot.data()?['imagePath'] as String?;
      await _firestore.collection('listings').doc(listingId).delete();
      if (imagePath != null && _storage != null) {
        await _storage.ref(imagePath).delete().catchError((Object error) {
          debugPrint('Listing image delete skipped: $error');
        });
      }
      return;
    }

    _listings.removeWhere((listing) => listing.id == listingId);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<_UploadedListingImage> _uploadListingImage({
    required String listingId,
    required Uint8List imageBytes,
    String? imageExtension,
  }) async {
    final storage = _storage;
    if (storage == null) {
      return _UploadedListingImage(url: '', path: '');
    }

    final extension = _normalizedImageExtension(imageExtension);
    final path = 'listing-images/$currentUserId/$listingId.$extension';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final ref = storage.ref(path);
    await ref.putData(imageBytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    return _UploadedListingImage(url: url, path: path);
  }

  String _normalizedImageExtension(String? imageExtension) {
    final extension = imageExtension?.toLowerCase().replaceAll('.', '');
    if (extension == 'png') {
      return 'png';
    }
    return 'jpg';
  }
}

class _UploadedListingImage {
  const _UploadedListingImage({required this.url, required this.path});

  final String url;
  final String path;
}
