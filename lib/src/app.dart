import 'package:flutter/material.dart';

import 'models/listing.dart';
import 'screens/auth_screen.dart';
import 'screens/marketplace_shell.dart';
import 'services/auth_service.dart';

class StudentMarketplaceApp extends StatefulWidget {
  const StudentMarketplaceApp({super.key});

  @override
  State<StudentMarketplaceApp> createState() => _StudentMarketplaceAppState();
}

class _StudentMarketplaceAppState extends State<StudentMarketplaceApp> {
  final MarketplaceStore store = MarketplaceStore.seeded();
  final AuthService authService = PrototypeAuthService();
  String? userName;
  String? userCampus;

  bool get isSignedIn => userName != null && userCampus != null;

  void applySession(AuthSession session) {
    setState(() {
      userName = session.displayName;
      userCampus = session.campus;
    });
  }

  void signOut() {
    setState(() {
      userName = null;
      userCampus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF356859),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F2EA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFF5F2EA),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E0D4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF356859), width: 1.6),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: isSignedIn
          ? MarketplaceShell(
              store: store,
              userName: userName!,
              userCampus: userCampus!,
              onSignOut: signOut,
            )
          : AuthScreen(authService: authService, onAuthenticated: applySession),
    );
  }
}
