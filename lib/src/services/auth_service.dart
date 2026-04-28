class AuthSession {
  const AuthSession({
    required this.displayName,
    required this.campus,
    required this.provider,
  });

  final String displayName;
  final String campus;
  final AuthProvider provider;
}

enum AuthProvider { password, google }

abstract class AuthService {
  Future<AuthSession> createAccount({
    required String username,
    required String password,
    required String campus,
  });

  Future<AuthSession> signIn({
    required String username,
    required String password,
    required String campus,
  });

  Future<AuthSession> signInWithGoogle({required String campus});

  Future<void> signOut();
}

class PrototypeAuthService implements AuthService {
  @override
  Future<AuthSession> createAccount({
    required String username,
    required String password,
    required String campus,
  }) async {
    return AuthSession(
      displayName: username,
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
    return AuthSession(
      displayName: username,
      campus: campus,
      provider: AuthProvider.password,
    );
  }

  @override
  Future<AuthSession> signInWithGoogle({required String campus}) async {
    return AuthSession(
      displayName: 'Google Student',
      campus: campus,
      provider: AuthProvider.google,
    );
  }

  @override
  Future<void> signOut() async {}
}
