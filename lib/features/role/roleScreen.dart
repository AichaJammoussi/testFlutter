import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/RoleDto.dart';
import 'package:testfront/core/models/RoleProvider.dart';
import 'package:testfront/features/role/EmployeeListScreen.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
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
        title: const Text('Gestion des Rôles'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    Provider.of<RoleProvider>(
                      context,
                      listen: false,
                    ).fetchRoles(),
          ),
        ],
      ),
      body: Consumer<RoleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var filtered =
              provider.roles
                  .where(
                    (r) => r.name.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
                  )
                  .toList();

          filtered.sort(
            (a, b) =>
                _ascending
                    ? a.name.compareTo(b.name)
                    : b.name.compareTo(a.name),
          );

          final totalPages = (filtered.length / _itemsPerPage).ceil();
          final start = _currentPage * _itemsPerPage;
          final end = (start + _itemsPerPage).clamp(0, filtered.length);
          final currentPageItems = filtered.sublist(start, end);

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
                          labelText: 'Rechercher un rôle',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bouton de tri avec icône comme dans EmployeeListScreen
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.sort_by_alpha,
                          color:
                              _ascending
                                  ? const Color(0xFF2A5298)
                                  : Colors.grey.shade400,
                        ),
                        tooltip: 'Trier par nom',
                        onPressed:
                            () => setState(() => _ascending = !_ascending),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add_moderator_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Ajouter",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () => _showAddOrEditDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF2A5298),
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
                  onRefresh: () => provider.fetchRoles(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentPageItems.length,
                    itemBuilder: (context, index) {
                      return _buildRoleCard(context, currentPageItems[index]);
                    },
                  ),
                ),
              ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            _currentPage > 0
                                ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                                : null,
                      ),
                      Text("Page ${_currentPage + 1}"),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            (_currentPage + 1) * _itemsPerPage < filtered.length
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

  Widget _buildRoleCard(BuildContext context, RoleDTO role) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        title: Text(
          role.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Voir employés',
              icon: const Icon(Icons.group, color: Color(0xFF2A5298)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeListScreen(roleName: role.name),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit, color: Color(0xFF2A5298)),
              onPressed: () => _showAddOrEditDialog(context, role: role),
            ),
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete, color: Color(0xFF2A5298)),
              onPressed: () => _confirmDelete(context, role),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddOrEditDialog(
    BuildContext context, {
    RoleDTO? role,
  }) async {
    final controller = TextEditingController(text: role?.name ?? '');
    final isEdit = role != null;

    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Modifier le rôle' : 'Nouveau rôle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Nom du rôle',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.pop(context);
                            final provider = Provider.of<RoleProvider>(
                              context,
                              listen: false,
                            );
                            if (isEdit) {
                              await provider.updateRole(role!.id, name);
                            } else {
                              await provider.addRole(name);
                            }
                          }
                        },
                        child: Text(
                          isEdit ? 'Modifier' : 'Ajouter',
                          style: const TextStyle(color: Colors.white),
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

  void _confirmDelete(BuildContext context, RoleDTO role) async {
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, size: 48, color: Color(0xFF2A5298)),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmer la suppression',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voulez-vous vraiment supprimer le rôle "${role.name}" ?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await Provider.of<RoleProvider>(
                            context,
                            listen: false,
                          ).deleteRole(role.id);
                        },
                        child: const Text(
                          'Supprimer',
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
