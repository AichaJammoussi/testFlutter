import 'package:flutter/material.dart';
import 'package:testfront/core/services/profile_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un email valide.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Crée une instance de ProfileService
      final profileService = ProfileService();

      // Appelle la méthode forgotPassword avec l'email saisi
      await profileService.forgotPassword(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Un lien de réinitialisation a été envoyé."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Envoyer le lien"),
                ),
          ],
        ),
      ),
    );
  }
}
