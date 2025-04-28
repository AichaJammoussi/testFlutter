import 'package:flutter/material.dart';

class ConditionsScreen extends StatelessWidget {
  const ConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conditions d'utilisation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              "Conditions d'utilisation",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "1. Acceptation des conditions\n"
              "En utilisant cette application, vous acceptez les présentes conditions d'utilisation. "
              "Veuillez les lire attentivement.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "2. Protection des données\n"
              "Nous nous engageons à protéger vos données personnelles conformément aux lois en vigueur.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "3. Comportement des utilisateurs\n"
              "Vous vous engagez à utiliser l'application de manière responsable, sans nuire aux autres utilisateurs.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "4. Modification des conditions\n"
              "Nous nous réservons le droit de modifier ces conditions à tout moment.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "5. Contact\n"
              "Pour toute question, veuillez nous contacter à steros@gmail.com",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
