import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class FirebaseMarketplaceAuthService implements AuthService {
  FirebaseMarketplaceAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const _usernameAuthDomain = 'student-marketplace.local';

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitializeFuture;

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
    final firebase_auth.UserCredential credential;
    if (kIsWeb) {
      final provider = firebase_auth.GoogleAuthProvider();
      credential = await _firebaseAuth.signInWithPopup(provider);
    } else {
      _googleInitializeFuture ??= _googleSignIn.initialize();
      await _googleInitializeFuture;

      final googleAccount = await _googleSignIn.authenticate();
      final googleAuth = googleAccount.authentication;
      final authCredential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      credential = await _firebaseAuth.signInWithCredential(authCredential);
    }

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a user.');
    }

    final username = _googleDisplayName(user);
    await _saveUserProfile(
      userId: user.uid,
      username: username,
      campus: campus,
      provider: AuthProvider.google,
    );

    return AuthSession(
      displayName: username,
      campus: campus,
      provider: AuthProvider.google,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      _googleInitializeFuture ??= _googleSignIn.initialize();
      await _googleInitializeFuture;
      await _googleSignIn.signOut();
    }
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

  String _googleDisplayName(firebase_auth.User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final emailPrefix = user.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return emailPrefix;
    }
    return 'Google Student';
  }
}
