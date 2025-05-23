/*import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/RoleProvider.dart';
import 'package:testfront/core/models/auth_storage.dart';
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/auth/register_screen.dart';
import 'package:testfront/features/auth/conditions_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/profile/profile_screen.dart';

import 'package:testfront/features/role/roleScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/conditions': (context) => const ConditionsScreen(),
        '/admin': (context) => const HomeScreen(),
        '/employee': (context) => const HomeScreen(),
       '/profile': (context) => const ProfileScreen(),
        '/role': (context) => const RoleListScreen(),


      },
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        : _isLoggedIn
        ? const HomeScreen()
        : LoginScreen();
  }
}
*/
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/RoleProvider.dart';
import 'package:testfront/core/models/auth_storage.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/VignetteProvider.dart';
import 'package:testfront/core/providers/depenseProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart'
    show MissionProvider;
import 'package:testfront/core/providers/notification_provider.dart';
import 'package:testfront/core/providers/rapportProvider.dart';
import 'package:testfront/core/providers/remboursement_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';
import 'package:testfront/core/services/VehiculeService.dart';
import 'package:testfront/core/services/auth_service.dart';
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/auth/register_screen.dart';
import 'package:testfront/features/auth/conditions_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/mission/MissionPage.dart';
import 'package:testfront/features/mission/MissionPageEmploye.dart';
import 'package:testfront/features/mission/remboursement/adminRemboursement.dart';
import 'package:testfront/features/mission/remboursement/remboursementEmploye.dart';
import 'package:testfront/features/profile/ForgotPasswordScreen.dart';
import 'package:testfront/features/profile/change_password_screen.dart';
import 'package:testfront/features/profile/profile_screen.dart';
import 'package:testfront/features/role/roleScreen.dart';
import 'package:app_links/app_links.dart'; // Pour gérer le deep linking

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:testfront/features/vehicule/vehicueScreen.dart';

void main() {
 // Initialisation des services
  final authService = AuthService();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => VehiculeProvider()),
        ChangeNotifierProvider(create: (_) => VignetteProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
 Provider<AuthService>(create: (_) => authService),
       ChangeNotifierProvider(
  create: (_) => NotificationProvider(),
),

               ChangeNotifierProvider(create: (_) => TacheProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DepenseProvider()),
        ChangeNotifierProvider(create: (_) => RemboursementProvider()),
                ChangeNotifierProvider(create: (_) => RapportProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

bool isMobile() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

bool isWeb() => kIsWeb;

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
        '/login': (_) => LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/conditions': (_) => const ConditionsScreen(),
        '/admin': (_) => HomeScreen(),
        '/employee': (_) => HomeScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/role': (_) => const RoleListScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/vehicule': (_) => VehiculeScreen(),
        '/mission': (_) => MissionsScreen(),
        '/missionEmploye': (_) => MissionsScreenEmploye(),
        '/mesRemboursements': (_) => MesRemboursementsScreen(),
                '/remboursementAdmin': (_) => AdminRemboursementsScreen(),
               // '/noti': (_) => noti(),


        //'/dashbord': (_) => PizzaMailApp(),
        /*'/home':
            (_) => MainLayout(currentRoute: '/home', child: const HomeScreen()),*/
        // Ajoute une route nommée si nécessaire pour reset
      },
      /* onGenerateRoute: (settings) {
        if (settings.name == '/web-dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;

          final isAdmin = args != null && args['isAdmin'] == true;

          return MaterialPageRoute(
            builder: (_) => WebDashboard(isAdmin: isAdmin),
          );
        }
      },*/
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _initDeepLinkListener();
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

  void _initDeepLinkListener() {
    final appLinks = AppLinks();
    _deepLinkSubscription = appLinks.uriLinkStream.listen(
      (uri) {
        if (uri.queryParameters.containsKey('email') &&
            uri.queryParameters.containsKey('token')) {
          final email = uri.queryParameters['email']!;
          final token = uri.queryParameters['token']!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: email, token: token),
            ),
          );
        }
      },
      onError: (err) {
        if (kDebugMode) print('Erreur deep link: $err');
      },
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _isLoggedIn
        ? HomeScreen()
        : const LoginScreen();
  }
}
