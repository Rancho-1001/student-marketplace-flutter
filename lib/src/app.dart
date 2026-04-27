import 'package:flutter/material.dart';

import 'models/listing.dart';
import 'screens/auth_screen.dart';
import 'screens/marketplace_shell.dart';

class StudentMarketplaceApp extends StatefulWidget {
  const StudentMarketplaceApp({super.key});

  @override
  State<StudentMarketplaceApp> createState() => _StudentMarketplaceAppState();
}

class _StudentMarketplaceAppState extends State<StudentMarketplaceApp> {
  final MarketplaceStore store = MarketplaceStore.seeded();
  String? userName;
  String? userCampus;

  bool get isSignedIn => userName != null && userCampus != null;

  void signIn(String name, String campus) {
    setState(() {
      userName = name;
      userCampus = campus;
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
          seedColor: const Color(0xFF2F6F5E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
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
          : AuthScreen(onContinue: signIn),
    );
  }
}
