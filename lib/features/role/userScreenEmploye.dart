import 'package:flutter/material.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/UserRolesDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/userDTOUser.dart';
import 'package:testfront/core/services/UserService.dart';
import 'package:testfront/core/services/role_service.dart';

class EmployesPage extends StatefulWidget {
  const EmployesPage({Key? key}) : super(key: key);

  @override
  State<EmployesPage> createState() => _EmployesPageState();
}

class _EmployesPageState extends State<EmployesPage> {
  final RoleService _roleService = RoleService();
  final UserService _userService = UserService();

  late Future<ResponseDTO<List<UserRolesDTO>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _roleService.getAllUsersWithRoles();
  }

void _showUserDetailsDialog(Userdtouser user) {
  // Construction de l'URL complète pour la photo
  final String? photoUrl = user.photoDeProfil != null
      ? ApiConfig.baseUrl + user.photoDeProfil!
      : null;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${user.nom} ${user.prenom}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 12),
          Text('Email : ${user.email}'),
          const SizedBox(height: 8),
          Text('Téléphone : ${user.phoneNumber}'),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer')),
      ],
    ),
  );
}

  Future<void> _loadAndShowUser(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await _userService.getUserByIdUser(userId);

    Navigator.pop(context); // Fermer le loader

    if (response.success && response.data != null) {
      _showUserDetailsDialog(response.data!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Erreur inconnue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des employés')),
      body: FutureBuilder<ResponseDTO<List<UserRolesDTO>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.success) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.data?.message ?? "Impossible de charger les employés"}',
              ),
            );
          }

          final users = snapshot.data!.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.userName),
                subtitle: Text(user.email),
                onTap: () => _loadAndShowUser(user.userId),
              );
            },
          );
        },
      ),
    );
  }
}
