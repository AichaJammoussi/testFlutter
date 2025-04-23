import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testfront/core/models/auth_storage.dart';
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/auth/register_screen.dart';
import 'package:testfront/features/home/home_screen.dart';

void main() {
  // Active le contournement SSL contrôlé
  HttpOverrides.global = DevHttpOverrides();
  // Configuration initiale
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquer l'orientation en portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) => runApp(const MyApp()));
}
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        // Autorise uniquement le certificat de dev pour ces hôtes
        return host == "localhost" || host == "10.0.2.2";
      };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) =>   LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await AuthStorage.getToken();
      setState(() => _isLoggedIn = token != null);
    } catch (e) {
      await AuthStorage.clear();
      if (kDebugMode) print('Erreur vérification auth: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _isLoggedIn ? const HomeScreen() :  LoginScreen();
  }
}