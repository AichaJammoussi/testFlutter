import 'package:flutter/material.dart';
import 'package:testfront/core/models/change_email.dart';
import 'package:testfront/core/services/profile_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final response = await ProfileService().requestEmailChange(
      ChangeEmailRequestDTO(
        newEmail: _emailController.text.trim(),
        currentPassword: _passwordController.text,
      ),
    );

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Erreur inconnue')),
    );

    if (response.success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer l’Email')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Nouvel Email'),
                validator:
                    (value) =>
                        value == null || !value.contains('@')
                            ? 'Email invalide'
                            : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
                validator:
                    (value) =>
                        value == null || value.length < 6
                            ? 'Mot de passe requis'
                            : null,
              ),
              const SizedBox(height: 30),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('envoyer un email de confirmation'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
