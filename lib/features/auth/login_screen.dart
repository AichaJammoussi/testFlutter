import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testfront/core/models/auth_response.dart';
import 'package:testfront/core/models/user.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, String> _fieldErrors = {};
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null && mounted) {
      setState(() {
        _emailController.text = rememberedEmail;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _isLoading = true;
      _fieldErrors = {};
      _generalError = null;
    });

    try {
      final authResponse = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (authResponse.success) {
        // Verify required fields are present
        if (authResponse.token == null ||
            authResponse.email == null ||
            authResponse.userId == null) {
          throw Exception('Required authentication data missing in response');
        }

        await _saveUserData(authResponse);
        _showSuccessMessage(authResponse.message ?? 'Connexion réussie');
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(
          User(
            id: authResponse.userId!,
            email: authResponse.email!,
            name: authResponse.userName ?? '',
            roles: authResponse.roles ?? [],
          ),
        );
        _redirectBasedOnRole(authResponse.roles ?? []);
      } else {
        setState(() {
          if (authResponse.errors != null) {
            _fieldErrors = Map<String, String>.from(
              authResponse.errors!.map(
                (key, value) =>
                    MapEntry(key, value?.toString() ?? 'Erreur inconnue'),
              ),
            );
          }
        });

        if (_fieldErrors.isEmpty) {
          _showErrorMessage(_generalError!);
        }
      }
    } catch (e) {
      _showErrorMessage('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    // Required fields
    await prefs.setString('auth_token', response.token!);
    await prefs.setString('user_email', response.email!);
    await prefs.setString('user_id', response.userId!);

    // Optional fields
    if (response.userName != null) {
      await prefs.setString('user_name', response.userName!);
    }
    if (response.refreshToken != null) {
      await prefs.setString('refresh_token', response.refreshToken!);
    }
    if (response.expiration != null) {
      await prefs.setString(
        'token_expiration',
        response.expiration!.toIso8601String(),
      );
    }
    if (response.roles != null && response.roles!.isNotEmpty) {
      await prefs.setStringList('user_roles', response.roles!);
    }

    // Remember me functionality
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text.trim());
    } else {
      await prefs.remove('remembered_email');
    }
  }

  /*
  void _redirectBasedOnRole(List<String> roles) {
    final isAdmin = roles.contains('Admin');
    final hasOtherRoles = roles.isNotEmpty && !isAdmin;

    if (kIsWeb) {
      if (isAdmin) {
        Navigator.pushReplacementNamed(
          
          context,
          '/web-dashboard',
          arguments: {'isAdmin': true},
        );
      } else if (hasOtherRoles) {
        Navigator.pushReplacementNamed(
          context,
          '/web-dashboard',
          arguments: {'isAdmin': false},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/no-role',
        ); // page vide ou erreur
      }
    } else {
      if (isAdmin) {
        Navigator.pushReplacementNamed(
          context,
          '/mobile-dashboard',
          arguments: {'isAdmin': true},
        );
      } else if (hasOtherRoles) {
        Navigator.pushReplacementNamed(
          context,
          '/mobile-dashboard',
          arguments: {'isAdmin': false},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/no-role',
        ); // page vide ou erreur
      }
    }
  }*/
  void _redirectBasedOnRole(List<String> roles) {
    if (roles.contains('admin')) {
      Navigator.pushReplacementNamed(context, '/mission');
    } else if (roles.contains('Employe')) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      Navigator.pushReplacementNamed(context, '/missionEmploye');
    }
  }
  /*
void _redirectBasedOnRole(List<String> roles) {
  if (roles.contains('admin')) {
    // Cas admin
    if (isWeb()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WebMainPage(userRole: 'admin'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPageMobile(userRole: 'admin'),
        ),
      );
    }
  } else if (!roles.contains('admin')) { 
    // Cas autre que admin => Employe
    if (isWeb()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WebMainPage(userRole: 'Employe'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPageMobile(userRole: 'Employe'),
        ),
      );
    }
  } else {
    // Aucun rôle connu
    Navigator.pushReplacementNamed(context, '/profile');
}
}
*/
  /*void _redirectBasedOnRole(List<String> roles) {
  final isAdmin = roles.contains('Admin');
  final hasOtherRoles = roles.isNotEmpty && !isAdmin;

  if (isAdmin) {
    // Admin web vs mobile
    if (kIsWeb) {
      Navigator.pushReplacementNamed(context, '/web-admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/mobile-admin-dashboard');
    }
  } else if (hasOtherRoles) {
    // Employé web vs mobile
    if (kIsWeb) {
      Navigator.pushReplacementNamed(context, '/web-employe-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/mobile-employe-dashboard');
    }
  } else {
    Navigator.pushReplacementNamed(context, '/homepage');
  }
  
  
  
  
  final isAdmin = roles.contains('Admin');
final hasOtherRoles = roles.isNotEmpty && !isAdmin;

if (kIsWeb) {
  if (isAdmin) {
    Navigator.pushReplacementNamed(context, '/web-dashboard', arguments: {'isAdmin': true});
  } else if (hasOtherRoles) {
    Navigator.pushReplacementNamed(context, '/web-dashboard', arguments: {'isAdmin': false});
  } else {
    Navigator.pushReplacementNamed(context, '/no-role'); // page vide ou erreur
  }
} else {
  if (isAdmin) {
    Navigator.pushReplacementNamed(context, '/mobile-dashboard', arguments: {'isAdmin': true});
  } else if (hasOtherRoles) {
    Navigator.pushReplacementNamed(context, '/mobile-dashboard', arguments: {'isAdmin': false});
  } else {
    Navigator.pushReplacementNamed(context, '/no-role'); // page vide ou erreur
  }
}

  
  */

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0x204FB6FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              height: 180,
              width: 180,
              decoration: const BoxDecoration(
                color: Color(0x302A5298),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
            ),
          ),
        ],
      ),
    );
  }

  // Rest of your existing UI building methods remain the same...
  // (_buildMobileLayout, _buildWebLayout, _buildAppLogo, _buildLoginForm, etc.)
  // Keep all your existing UI code as is, just update the logic parts above

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildAppLogo(),
            const SizedBox(height: 30),
            _buildLoginForm(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: _buildAppLogo(large: true)),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(child: _buildLoginForm()),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo({bool large = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Espacement accru au-dessus de l'image
        SizedBox(height: large ? 50 : 30), // 50px pour web, 30px pour mobile

        Container(
          height: large ? 250 : 200,
          width: large ? 250 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A5298).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset('lib/core/images/steros.jpg', fit: BoxFit.cover),
          ),
        ),

        // Espacement réduit sous l'image pour compenser
        const SizedBox(height: 16), // Réduit de 24 à 16

        Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: large ? 36 : 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B5A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            fontSize: large ? 18 : 16,
            color: const Color(0xFF7A869A),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 8),
          _buildRememberMeRow(),
          if (_fieldErrors.containsKey('account') || _generalError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _fieldErrors['account'] ?? _generalError ?? '',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildRegisterRow(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2A5298)),
        errorText: _fieldErrors['email'],
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (_fieldErrors.containsKey('email')) return null;
        if (value == null || value.isEmpty)
          return 'Veuillez entrer votre email';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Veuillez entrer un email valide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2A5298)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF2A5298),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        errorText: _fieldErrors['password'],
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (_fieldErrors.containsKey('password')) return null;
        if (value == null || value.isEmpty)
          return 'Veuillez entrer votre mot de passe';
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          activeColor: const Color(0xFF2A5298),
          onChanged: (value) => setState(() => _rememberMe = value ?? false),
        ),
        const Text('Se souvenir de moi'),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
          child: const Text('Mot de passe oublié ?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF2A5298),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child:
          _isLoading
              ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
              : const Text(
                'CONNEXION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Vous n\'avez pas de compte ? ',
          style: TextStyle(color: Color(0xFF7A869A)),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: const Text('S\'inscrire'),
        ),
      ],
    );
  }
}
