import 'package:flutter/foundation.dart';

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
    this.distanceMiles,
    this.status = ListingStatus.active,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String campus;
  final String sellerName;
  final String sellerId;
  final DateTime createdAt;
  final double? distanceMiles;
  ListingStatus status;

  bool get isSold => status == ListingStatus.sold;
}

class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore(this._listings);

  factory MarketplaceStore.seeded() {
    return MarketplaceStore([
      Listing(
        id: '1',
        title: 'Mini fridge',
        description:
            'Clean dorm-size fridge with a small freezer compartment. Pickup near campus.',
        price: 65,
        category: 'Furniture',
        campus: 'Michigan State University',
        sellerName: 'Alex',
        sellerId: demoUserId,
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
    ]);
  }

  static const demoUserId = 'current-user';
  final List<Listing> _listings;

  List<Listing> get listings => List.unmodifiable(_listings);

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
    return _listings.where((listing) => listing.sellerId == demoUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String campus,
    required String sellerName,
  }) {
    _listings.insert(
      0,
      Listing(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: description,
        price: price,
        category: category,
        campus: campus,
        sellerName: sellerName,
        sellerId: demoUserId,
        createdAt: DateTime.now(),
        distanceMiles: 0.2,
      ),
    );
    notifyListeners();
  }

  void markSold(String listingId) {
    final listing = _listings.firstWhere((item) => item.id == listingId);
    listing.status = ListingStatus.sold;
    notifyListeners();
  }

  void deleteListing(String listingId) {
    _listings.removeWhere((listing) => listing.id == listingId);
    notifyListeners();
  }
}
