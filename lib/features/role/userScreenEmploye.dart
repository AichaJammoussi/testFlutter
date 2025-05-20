import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserScreenEmploye extends StatefulWidget {
  @override
  _UserScreenEmployeState createState() => _UserScreenEmployeState();
}

class _UserScreenEmployeState extends State<UserScreenEmploye> {
  late Future<List<dynamic>> _futureUsers;

  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:8080/api/roles/users-with-roles'),
        headers: {'Authorization': 'Bearer ton_token'}, // Adapte ici
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Supposons que la liste est sous "data"
        if (jsonResponse.containsKey('data')) {
          return jsonResponse['data'] as List<dynamic>;
        } else {
          throw Exception('Clé "data" non trouvée dans la réponse');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text('Aucun utilisateur trouvé'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index] as Map<String, dynamic>;

              final userName = user['userName'] ?? 'Nom inconnu';
              final email = user['email'] ?? 'Email inconnu';

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(userName),
                subtitle: Text(email),
                // On ne montre pas les rôles ici
              );
            },
          );
        },
      ),
    );
  }
}
