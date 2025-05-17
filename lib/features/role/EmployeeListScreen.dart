import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/NotificationCreateDTO.dart';
import 'package:testfront/core/models/RoleProvider.dart';
import 'package:flutter/services.dart';
import 'package:testfront/core/providers/notification_provider.dart';

class EmployeeListScreen extends StatefulWidget {
  final String roleName;

  const EmployeeListScreen({Key? key, required this.roleName})
    : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAscending = true;
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    Provider.of<RoleProvider>(
      context,
      listen: false,
    ).fetchUsersByRole(widget.roleName);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employés – ${widget.roleName}'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RoleProvider>(
                context,
                listen: false,
              ).fetchUsersByRole(widget.roleName);
            },
          ),
        ],
      ),
      body: Consumer<RoleProvider>(
        builder: (context, provider, _) {
          if (provider.isUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users =
              provider.usersByRole
                  .where(
                    (user) =>
                        user.userName.toLowerCase().contains(_searchQuery) ||
                        user.email.toLowerCase().contains(_searchQuery),
                  )
                  .toList();

          users.sort((a, b) {
            int comparison = a.userName.toLowerCase().compareTo(
              b.userName.toLowerCase(),
            );
            return _isAscending ? comparison : -comparison;
          });

          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage;
          final paginatedUsers = users.sublist(
            startIndex,
            endIndex < users.length ? endIndex : users.length,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher par nom ou email',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        _isAscending ? Icons.sort_by_alpha : Icons.sort,
                      ),
                      tooltip:
                          _isAscending
                              ? 'Trier par ordre croissant'
                              : 'Trier par ordre décroissant',
                      onPressed: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Assigner un employé",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _showUnassignedUsersDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A5298),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchUsersByRole(widget.roleName),
                  child:
                      paginatedUsers.isEmpty
                          ? const Center(child: Text("Aucun employé trouvé."))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: paginatedUsers.length,
                            itemBuilder: (context, index) {
                              final user = paginatedUsers[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: SelectableText(user.userName),
                                  subtitle: SelectableText(user.email),
                                  trailing: IconButton(
                                    tooltip: 'Supprimer',

                                    icon: const Icon(
                                      Icons.delete,

                                      color: Color(0xFF2A5298),
                                    ),
                                    onPressed:
                                        () => _confirmRemoveRole(
                                          context,
                                          user.userId,
                                          widget.roleName,
                                        ),
                                  ),
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: user.email),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Email copié : ${user.email}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          _currentPage > 1
                              ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                              : null,
                    ),
                    Text("Page $_currentPage"),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          _currentPage * _itemsPerPage < users.length
                              ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                              : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showUnassignedUsersDialog() async {
    final provider = Provider.of<RoleProvider>(context, listen: false);
    final allUsers = await provider.getAllUsersWithRoles();
    final unassigned =
        allUsers.where((u) => !u.roles.contains(widget.roleName)).toList();
    final Set<String> selected = {};

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Assigner un utilisateur au rôle ${(widget.roleName)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: unassigned.length,
                            itemBuilder: (context, i) {
                              final user = unassigned[i];
                              return CheckboxListTile(
                                title: Text(user.userName),
                                value: selected.contains(user.userId),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selected.add(user.userId!);
                                    } else {
                                      selected.remove(user.userId);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A5298),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final success = await provider
                                    .assignRolesToMultipleUsers(
                                      selected.toList(),
                                      [widget.roleName],
                                    );
                                if (success) {
                                  // Récupérer le provider de notifications
                                  final notifProvider =
                                      Provider.of<NotificationProvider>(
                                        context,
                                        listen: false,
                                      );

                                  // Envoyer une notification à chaque utilisateur assigné
                                  for (final userId in selected) {
                                    final dto = NotificationCreateDTO(
                                      userId: userId,
                                      title: 'Nouveau rôle assigné',
                                      message:
                                          'Vous avez été ajouté au rôle ${widget.roleName}',
                                    );

                                    final notifSuccess = await notifProvider
                                        .createNotification(dto);

                                    if (!notifSuccess) {
                                      print(
                                        '⚠️ Échec notification pour user $userId',
                                      );
                                      // Optionnel : gérer l’erreur (afficher un message, etc.)
                                    }
                                  }

                                  Navigator.pop(context);
                                  provider.fetchUsersByRole(widget.roleName);
                                } else {
                                  // Gérer l’erreur d'assignation (ex: afficher un message)
                                }
                              },

                              child: const Text(
                                "Assigner",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Future<void> _confirmRemoveRole(
    BuildContext context,
    String? userId,
    String roleName,
  ) async {
    if (userId == null) return;

    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Color(0xFF2A5298), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Confirmer la suppression",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text('Supprimer le rôle "$roleName" de cet utilisateur ?'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          final provider = Provider.of<RoleProvider>(
                            context,
                            listen: false,
                          );
                          final success = await provider.removeRoleFromUser(
                            userId,
                            roleName,
                          );
                          if (success) {
                            provider.fetchUsersByRole(roleName);
                          }
                        },
                        child: const Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
