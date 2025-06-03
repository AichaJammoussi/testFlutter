/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId != null) {
      final profile = await Provider.of<ProfileService>(context, listen: false)
          .getUserProfile(userId);
      setState(() {
        _nomController.text = profile.nom;
        _prenomController.text = profile.prenom;
        _phoneController.text = profile.phoneNumber;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        await Provider.of<ProfileService>(context, listen: false).updateProfile(
          userId: userId,
          nom: _nomController.text,
          prenom: _prenomController.text,
          phoneNumber: _phoneController.text,
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}*/
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/profile_model.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/update_profile_dto.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/services/profile_service.dart';
import 'package:testfront/features/profile/change_email_screen.dart';
import 'package:testfront/features/profile/change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileDTO userProfile;

  const EditProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final Color primaryColor = const Color(0xFF2A5298);

  File? _pickedImageFile;
  Uint8List? _webImageBytes;
  String? _pickedImageName;
  bool _imageChanged = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.userProfile.nom);
    _prenomController = TextEditingController(text: widget.userProfile.prenom);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fonction utilitaire pour construire les URLs d'images
  String? _buildImageUrl(String? imagePath, {bool addCacheBuster = false}) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // Gérer le cas où c'est déjà une URL complète
    final String baseUrl = imagePath.startsWith('http') 
        ? imagePath 
        : ApiConfig.baseUrl + imagePath;
        
    return addCacheBuster 
        ? '$baseUrl?cache=${DateTime.now().millisecondsSinceEpoch}'
        : baseUrl;
  }

  Future<void> _pickImage() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _pickedImageFile = null;
            _imageChanged = true;
          });
        } else {
          setState(() {
            _pickedImageFile = File(pickedFile.path);
            _webImageBytes = null;
            _imageChanged = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo sélectionnée avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Appareil photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<ResponseDTO<String>> _updateProfilePhoto(String userId) async {
    try {
      if (kIsWeb && _webImageBytes != null) {
        return await _profileService.updateProfilePhoto(
          userId: userId,
          imageBytes: _webImageBytes!,
          fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (!kIsWeb && _pickedImageFile != null) {
        return await _profileService.updateProfilePhoto(
          userId: userId,
          imageFile: _pickedImageFile!,
        );
      }
      return ResponseDTO(success: false, message: 'Aucune image sélectionnée');
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      return ResponseDTO(success: false, message: 'Erreur lors de la mise à jour de la photo');
    }
  }

  Future<void> _updateProfile() async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
      setState(() => _isUpdating = false);
      return;
    }

    try {
      // 1. Mise à jour des informations de base
      final updatedProfile = UpdateProfileDto(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      final response = await _profileService.updateProfile(
        updatedProfile, 
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Échec de la mise à jour du profil');
      }

      // 2. Mise à jour de la photo si elle a changé
      if (_imageChanged) {
        final photoResponse = await _updateProfilePhoto(userId);
        if (!photoResponse.success) {
          throw Exception(photoResponse.message ?? 'Échec de la mise à jour de la photo');
        }
        // Réinitialiser le flag après succès
        _imageChanged = false;
      }

      // 3. Afficher le succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildProfileImage() {
    ImageProvider? imageProvider;
    
    try {
      if (kIsWeb && _webImageBytes != null) {
        imageProvider = MemoryImage(_webImageBytes!);
      } else if (!kIsWeb && _pickedImageFile != null) {
        imageProvider = FileImage(_pickedImageFile!);
      } else {
        // Utiliser le lien de test ou l'image du profil
        String? imageUrl;
        
        // Vérifier si nous avons une photoDeProfil dans le profil utilisateur
        final photoProfile = widget.userProfile.photoDeProfil ?? 
                           widget.userProfile.photoDeProfil; // fallback vers photoUrl si elle existe
        
        if (photoProfile != null && photoProfile.isNotEmpty) {
          imageUrl = _buildImageUrl(photoProfile, addCacheBuster: true);
          debugPrint('Loading profile image from: $imageUrl');
        }
        
        if (imageUrl != null) {
          imageProvider = NetworkImage(imageUrl);
        }
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Network image error: $error');
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (_imageChanged)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Nouveau',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: primaryColor),
                labelText: 'Email',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailScreen(),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Text(
              'Changer',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: primaryColor),
                labelText: 'Mot de passe',
                hintText: '••••••••',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(email: '', token: ''),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Text(
              'Changer',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: required ? '$label *' : label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Modifier Profil'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PopScope(
        canPop: !_isUpdating,
        onPopInvoked: (didPop) {
          if (_isUpdating) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Veuillez patienter pendant la sauvegarde')),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProfileImage(),
                      
                      if (_imageChanged)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Photo modifiée',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      _buildTextField('Nom', _nomController, Icons.person, required: true),
                      _buildTextField('Prénom', _prenomController, Icons.person_outline, required: true),
                      _buildEmailField(),
                      _buildTextField('Téléphone', _phoneController, Icons.phone),
                      _buildPasswordField(),
                      
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : _updateProfile,
                          icon: _isUpdating 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isUpdating ? 'Enregistrement...' : 'Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
     ),
);
}
}
