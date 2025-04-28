import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testfront/core/models/Auth_response.dart';
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
    final rememberedEmail = prefs.getString('user_email');
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
        await _saveUserData(authResponse);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _fieldErrors = authResponse.errors?.map<String, String>(
            (key, value) => MapEntry(key, value.toString()),
          ) ?? {};
          _generalError = authResponse.message;
        });

        if (_fieldErrors.isEmpty && _generalError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_generalError!)),
          );
        }
      }
    } catch (e) {
      setState(() => _generalError = 'Erreur inattendue: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_generalError!)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', response.token!);
    await prefs.setString('user_email', response.email!);
    if (response.expiration != null) {
      await prefs.setString('token_expiration', response.expiration!.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: Stack(
        children: [
          // Éléments décoratifs
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

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Changé de center à start
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40), // Espace ajouté en haut
                      _buildAppLogo(),
                      const SizedBox(height: 30), // Espace réduit
                      _buildLoginForm(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildAppLogo() {
  return Column(
    children: [
      Container(
        height: 120,
        width: 120,
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
          child: Image.asset(
            'lib/core/images/steros.jpg',
            fit: BoxFit.cover, 
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Bienvenue',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF172B5A),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Connectez-vous pour continuer',
        style: TextStyle(fontSize: 16, color: Color(0xFF7A869A)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
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
              if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
        ),
        if (_fieldErrors.containsKey('email'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _fieldErrors['email']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
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
              if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
              return null;
            },
          ),
        ),
        if (_fieldErrors.containsKey('password'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _fieldErrors['password']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberMe,
            activeColor: const Color(0xFF2A5298),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Se souvenir de moi',
          style: TextStyle(color: Color(0xFF7A869A)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/reset-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
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
      child: _isLoading
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
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('S\'inscrire'),
        ),
      ],
    );
  }
}