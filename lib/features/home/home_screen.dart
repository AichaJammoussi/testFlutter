import 'package:flutter/material.dart';
import 'package:testfront/core/models/auth_storage.dart';  // si tu veux récupérer nom utilisateur

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  // Exemple de données fictives (tu peux les remplacer par du vrai data)
  final int missionsEnCours = 7;
  final int utilisateursActifs = 15;
  final int vehiculesDisponibles = 5;

  @override
  Widget build(BuildContext context) {
    // Exemple pour récupérer nom utilisateur (à adapter selon ton AuthStorage)
    // final username = AuthStorage.getUsername() ?? "Utilisateur";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message de bienvenue
            Text(
              'Bienvenue sur Steros-Missions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Statistiques rapides (toutes en violet comme missions)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Missions en cours', missionsEnCours.toString(), Colors.deepPurple),
                _buildStatCard('Utilisateurs actifs', utilisateursActifs.toString(), Colors.deepPurple),
                _buildStatCard('Véhicules disponibles', vehiculesDisponibles.toString(), Colors.deepPurple),
              ],
            ),
            // Suppression de la section raccourcis et notifications
          ],
        ),
      ),
    );
  }

  // Widget helper pour la carte des stats
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
