import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'auth_service.dart';

class FirebaseMarketplaceAuthService implements AuthService {
  FirebaseMarketplaceAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  static const _usernameAuthDomain = 'student-marketplace.local';

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<AuthSession> createAccount({
    required String username,
    required String password,
    required String campus,
  }) async {
    final normalizedUsername = _normalizeUsername(username);
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: _usernameToEmail(normalizedUsername),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a user.');
    }

    await user.updateDisplayName(normalizedUsername);
    await _saveUserProfile(
      userId: user.uid,
      username: normalizedUsername,
      campus: campus,
      provider: AuthProvider.password,
    );

    return AuthSession(
      displayName: normalizedUsername,
      campus: campus,
      provider: AuthProvider.password,
    );
  }

  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
    required String campus,
  }) async {
    final normalizedUsername = _normalizeUsername(username);
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: _usernameToEmail(normalizedUsername),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a user.');
    }

    final profile = await _firestore.collection('users').doc(user.uid).get();
    final savedCampus = profile.data()?['campus'] as String?;

    return AuthSession(
      displayName: normalizedUsername,
      campus: savedCampus ?? campus,
      provider: AuthProvider.password,
    );
  }

  @override
  Future<AuthSession> signInWithGoogle({required String campus}) async {
    throw UnimplementedError(
      'Google sign-in needs platform Firebase config before it can be wired.',
    );
  }

  Future<void> _saveUserProfile({
    required String userId,
    required String username,
    required String campus,
    required AuthProvider provider,
  }) {
    return _firestore.collection('users').doc(userId).set({
      'username': username,
      'campus': campus,
      'provider': provider.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _normalizeUsername(String username) {
    return username.trim().toLowerCase();
  }

  String _usernameToEmail(String username) {
    return '$username@$_usernameAuthDomain';
  }
}
