import 'dart:convert';  // Importé pour jsonDecode
import 'dart:io';
import 'dart:html' as html;  // Pour le Web
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/models/update_profile_dto.dart';
import '../../core/models/profile_model.dart';
import '../../core/services/profile_service.dart';
import '../../core/config/api_config.dart';
import 'change_email_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  final UserProfileDTO profile;

  const UpdateProfileScreen({super.key, required this.profile});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _phoneController;

  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profile.nom);
    _prenomController = TextEditingController(text: widget.profile.prenom);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
  }

  // Fonction de sélection d'image pour mobile et web
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Flutter Web
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((event) {
        final file = input.files!.first;
        final reader = html.FileReader();

        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) async {
          final encoded = reader.result as String;
          final bytes = base64Decode(encoded.split(',').last);

          // Préparer la requête d'upload
          final request = http.MultipartRequest("POST", Uri.parse("${ApiConfig.baseUrl}/api/Auth/upload-photo"));
          request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));

          try {
            final response = await request.send();

            // Vérifier si la réponse est un succès
            if (response.statusCode == 200) {
              print("Upload réussi");
              setState(() {
                _imageFile = File(file.name); // Mettre à jour l'image après téléchargement
              });
            } else {
              print("Erreur de téléchargement: ${response.statusCode}");
            }
          } catch (e) {
            print("Erreur lors de l'upload de l'image: $e");
          }
        });
      });
    } else {
      // Flutter Mobile
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final request = http.MultipartRequest("POST", Uri.parse("${ApiConfig.baseUrl}/api/Auth/upload-photo"));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      try {
        final response = await request.send();

        // Vérifier si la réponse est un succès
        if (response.statusCode == 200) {
          print("Upload réussi");
          setState(() {
            _imageFile = file; // Mettre à jour l'image après téléchargement
          });
        } else {
          print("Erreur de téléchargement: ${response.statusCode}");
        }
      } catch (e) {
        print("Erreur lors de l'upload de l'image: $e");
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final dto = UpdateProfileDto(
      nom: _nomController.text,
      prenom: _prenomController.text,
      phoneNumber: _phoneController.text,
    );

    final response = await ProfileService().updateProfile(dto);
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Erreur')),
    );

    if (response.success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConfig.baseUrl;
    final imageUrl = widget.profile.photoDeProfil != null
        ? '$baseUrl${widget.profile.photoDeProfil}'
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage('lib/core/images/user.png')) as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_nomController, 'Nom'),
              const SizedBox(height: 10),
              _buildTextField(_prenomController, 'Prénom'),
              const SizedBox(height: 10),
              _buildTextField(_phoneController, 'Téléphone'),
              const SizedBox(height: 30),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                      onPressed: _submit,
                    ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(widget.profile.email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) => (value == null || value.isEmpty) ? 'Ce champ est requis' : null,
    );
  }
}
