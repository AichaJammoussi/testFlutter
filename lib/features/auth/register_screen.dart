import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testfront/core/models/register_data.dart';
import 'package:testfront/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _image;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, String> _fieldErrors = {};
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.red;
  String? _generalError;

  bool _galleryPermissionAsked = false;
  bool _cameraPermissionAsked = false;

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
    _passwordController.addListener(_updatePasswordStrength);
    _loadPermissionStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _galleryPermissionAsked = prefs.getBool('gallery_asked') ?? false;
      _cameraPermissionAsked = prefs.getBool('camera_asked') ?? false;
    });
  }

  Future<void> _savePermissionStatus(ImageSource source) async {
    final prefs = await SharedPreferences.getInstance();
    if (source == ImageSource.gallery) {
      await prefs.setBool('gallery_asked', true);
      setState(() => _galleryPermissionAsked = true);
    } else {
      await prefs.setBool('camera_asked', true);
      setState(() => _cameraPermissionAsked = true);
    }
  }

  String _getPasswordStrength(String password) {
    if (password.length >= 12 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\\$%^&*(),.?":{}|<>]'))) {
      return 'Très fort';
    } else if (password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return 'Fort';
    } else if (password.length >= 6) {
      return 'Moyenne';
    }
    return 'Faible';
  }

  Color _getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Très fort':
        return Colors.green;
      case 'Fort':
        return Colors.blue;
      case 'Moyenne':
        return Colors.orange;
      case 'Faible':
      default:
        return Colors.red;
    }
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = _getPasswordStrength(_passwordController.text);
      _passwordStrengthColor = _getPasswordStrengthColor(_passwordStrength);
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choisir une photo de profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Galerie photos'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  const Divider(height: 30, thickness: 0.5),
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Prendre une photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final alreadyAsked =
          source == ImageSource.gallery
              ? _galleryPermissionAsked
              : _cameraPermissionAsked;

      if (!alreadyAsked) {
        final permissionGranted = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Accès requis'),
                content: Text(
                  source == ImageSource.gallery
                      ? 'Autoriser l\'accès à votre galerie pour sélectionner une image ?'
                      : 'Autoriser l\'accès à votre appareil photo pour prendre une photo ?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Refuser'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Autoriser'),
                    onPressed: () {
                      _savePermissionStatus(source);
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
        );

        if (permissionGranted != true) return;
      }

      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _fieldErrors.remove('photo');
        });
      }
    } on PlatformException catch (e) {
      _showErrorMessage("Erreur: ${e.message}");
    } catch (e) {
      _showErrorMessage("Erreur lors de la sélection de l'image");
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorMessage("Veuillez accepter les conditions d'utilisation");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await AuthService().register(
        RegisterData(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nom: _nameController.text.trim(),
          prenom: _prenomController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
          photoFile: _image,
        ),
      );

      if (authResponse.success) {
        _showSuccessMessage(authResponse.message ?? 'Inscription réussie');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          if (authResponse.errors != null) {
            _fieldErrors = Map<String, String>.from(
              authResponse.errors!.map(
                (key, value) => MapEntry(key, value ?? 'Erreur inconnue'),
              ),
            );
          }
          _generalError = authResponse.message;
        });

        _formKey.currentState?.validate();

        if (_fieldErrors.isEmpty && _generalError != null) {
          _showErrorMessage(_generalError!);
        }
      }
    } catch (e) {
      _showErrorMessage('Erreur technique: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 1200 : double.infinity,
                ),
                child:
                    isWeb
                        ? _buildWebLayout()
                        : SingleChildScrollView(child: _buildMobileLayout()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildAppLogo(large: true)),
          const SizedBox(width: 60),
          Expanded(child: SingleChildScrollView(child: _buildRegisterForm())),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B5A),
            ),
          ),
          const SizedBox(height: 30),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildAppLogo({bool large = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Espacement accru au-dessus de l'image
      SizedBox(height: large ? 50 : 30),  // 50px pour web, 30px pour mobile
      
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
          child: Image.asset(
            'lib/core/images/steros.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      
      // Espacement réduit sous l'image pour compenser
      const SizedBox(height: 16),  // Réduit de 24 à 16
      
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
        'Rejoignez notre communauté',
        style: TextStyle(
          fontSize: large ? 18 : 16,
          color: const Color(0xFF7A869A),
        ),
      ),
    ],
  );
}
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child:
                        _image != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            )
                            : Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                  ),
                ),
              ),
              if (_fieldErrors.containsKey('photo'))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _fieldErrors['photo']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nameController,
                  fieldKey: 'nom',
                  hintText: 'Nom',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _prenomController,
                  fieldKey: 'prenom',
                  hintText: 'Prénom',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            fieldKey: 'email',
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 16),
          _buildTermsCheckbox(),
          const SizedBox(height: 30),
          _buildRegisterButton(),
          const SizedBox(height: 24),
          _buildLoginRow(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
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
        controller: _phoneController,
        decoration: InputDecoration(
          hintText: 'Numéro de téléphone',
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: Color(0xFF2A5298),
          ),
          errorText: _fieldErrors['phoneNumber'],
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+]'))],
        validator: (value) {
          if (_fieldErrors.containsKey('phoneNumber')) {
            return _fieldErrors['phoneNumber'];
          }
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer votre numéro';
          }
          if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
            return 'Numéro invalide (8-15 chiffres)';
          }
          return null;
        },
      ),
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
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Mot de passe',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF2A5298),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF2A5298),
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              errorText: _fieldErrors['password'],
            ),
            onChanged: (value) => _updatePasswordStrength(),
            validator: (value) {
              if (_fieldErrors.containsKey('password')) {
                return _fieldErrors['password'];
              }
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Force du mot de passe: $_passwordStrength',
          style: TextStyle(color: _passwordStrengthColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
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
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          hintText: 'Confirmer le mot de passe',
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2A5298)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF2A5298),
            ),
            onPressed:
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
          ),
          errorText: _fieldErrors['confirmPassword'],
        ),
        validator: (value) {
          if (_fieldErrors.containsKey('confirmPassword')) {
            return _fieldErrors['confirmPassword'];
          }
          if (value == null || value.isEmpty) {
            return 'Veuillez confirmer votre mot de passe';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            activeColor: const Color(0xFF2A5298),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged:
                (value) => setState(() => _agreeToTerms = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            children: [
              const Text('J\'accepte les '),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/conditions'),
                child: const Text(
                  'conditions d\'utilisation',
                  style: TextStyle(
                    color: Color(0xFF2A5298),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
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
                'S\'INSCRIRE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Vous avez déjà un compte ? ',
          style: TextStyle(color: Color(0xFF7A869A)),
        ),
        TextButton(
          onPressed:
              _isLoading ? null : () => Navigator.pushNamed(context, '/login'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String fieldKey,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFF2A5298)),
          suffixIcon: suffix,
          errorText: _fieldErrors[fieldKey],
        ),
        validator: (value) {
          if (_fieldErrors.containsKey(fieldKey)) {
            return _fieldErrors[fieldKey];
          }
          if (value == null || value.isEmpty) {
            return 'Ce champ est obligatoire';
          }
          return null;
        },
      ),
    );
  }
}
