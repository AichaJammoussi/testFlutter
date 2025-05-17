import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';
import 'package:testfront/features/vehicule/VignetteScreen.dart';

class VehiculeScreen extends StatefulWidget {
  @override
  _VehiculeScreenState createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehiculeProvider>(context, listen: false).loadVehicules();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            isRequired ? '$label *' : label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez $label',
            prefixIcon: Icon(icon, color: const Color(0xFF2A5298)),
            errorText: errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: keyboardType,
          validator:
              isRequired
                  ? (value) =>
                      value == null || value.isEmpty
                          ? 'Ce champ est obligatoire'
                          : null
                  : null,
        ),
      ],
    );
  }

  Future<void> _showAddOrEditVehiculeDialog(
    BuildContext context, {
    VehiculeDTO? vehicule,
  }) async {
    final isEdit = vehicule != null;
    final _formKey = GlobalKey<FormState>();
    Map<String, String> fieldErrors = {};

    final marqueController = TextEditingController(
      text: vehicule?.marque ?? '',
    );
    final modeleController = TextEditingController(
      text: vehicule?.modele ?? '',
    );
    final immatriculationController = TextEditingController(
      text: vehicule?.immatriculation ?? '',
    );
    final anneeController = TextEditingController(
      text: vehicule?.anneeMiseEnCirculation.toString() ?? '',
    );
    final kilometrageController = TextEditingController(
      text: vehicule?.kilometrage.toString() ?? '',
    );
    StatutVehicule selectedStatut =
        vehicule?.statut ?? StatutVehicule.Disponible;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void handleApiErrors(Map<String, dynamic>? apiErrors) {
              if (apiErrors == null) return;

              setState(() {
                fieldErrors.clear();
                apiErrors.forEach((key, value) {
                  switch (key) {
                    case 'Immatriculation':
                      fieldErrors['immatriculation'] =
                          value?.toString() ?? 'Erreur inconnue';
                      break;
                    case 'AnneeMiseEnCirculation':
                      fieldErrors['annee'] =
                          value?.toString() ?? 'Erreur inconnue';
                      break;
                    case 'Kilometrage':
                      fieldErrors['kilometrage'] =
                          value?.toString() ?? 'Erreur inconnue';
                      break;
                    case 'Marque':
                      fieldErrors['marque'] =
                          value?.toString() ?? 'Erreur inconnue';
                      break;
                    case 'Modele':
                      fieldErrors['modele'] =
                          value?.toString() ?? 'Erreur inconnue';
                      break;
                    default:
                      fieldErrors[key.toLowerCase()] =
                          value?.toString() ?? 'Erreur inconnue';
                  }
                });
              });
            }

            return AlertDialog(
              title: Text(isEdit ? 'Modifier véhicule' : 'Nouveau véhicule'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Champ Marque
                      _buildFormField(
                        controller: marqueController,
                        label: 'Marque',
                        icon: Icons.branding_watermark,
                        errorText: fieldErrors['marque'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ Modèle
                      _buildFormField(
                        controller: modeleController,
                        label: 'Modèle',
                        icon: Icons.directions_car,
                        errorText: fieldErrors['modele'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ Immatriculation
                      _buildFormField(
                        controller: immatriculationController,
                        label: 'Immatriculation',
                        icon: Icons.confirmation_number,
                        errorText: fieldErrors['immatriculation'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ Année
                      _buildFormField(
                        controller: anneeController,
                        label: 'Année',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        errorText: fieldErrors['annee'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ Kilométrage
                      _buildFormField(
                        controller: kilometrageController,
                        label: 'Kilométrage',
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                        errorText: fieldErrors['kilometrage'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ Statut
                      DropdownButtonFormField<StatutVehicule>(
                        value: selectedStatut,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          errorText: fieldErrors['statut'],
                        ),
                        items:
                            StatutVehicule.values.map((statut) {
                              return DropdownMenuItem(
                                value: statut,
                                child: Text(_getStatutText(statut)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatut = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final dto = VehiculeCreationDTO(
                        marque: marqueController.text.trim(),
                        modele: modeleController.text.trim(),
                        immatriculation: immatriculationController.text.trim(),
                        anneeMiseEnCirculation:
                            int.tryParse(anneeController.text.trim()) ?? 0,
                        kilometrage:
                            int.tryParse(kilometrageController.text.trim()) ??
                            0,
                        statut: selectedStatut.index,
                      );

                      final provider = Provider.of<VehiculeProvider>(
                        context,
                        listen: false,
                      );
                      final response =
                          isEdit
                              ? await provider.updateVehicule(
                                vehicule!.vehiculeId,
                                dto,
                              )
                              : await provider.createVehicule(dto);

                      if (response.success) {
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        handleApiErrors(response.errors);
                      }
                    }
                  },
                  child: Text(isEdit ? 'Modifier' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Véhicules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    Provider.of<VehiculeProvider>(
                      context,
                      listen: false,
                    ).loadVehicules(),
          ),
        ],
      ),
      body: Consumer<VehiculeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (provider.error != null)
            return Center(child: Text(provider.error!));

          var filtered =
              provider.vehicules
                  .where(
                    (v) => '${v.marque} ${v.modele}'.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
                  )
                  .toList();

          filtered.sort(
            (a, b) =>
                _ascending
                    ? a.marque.compareTo(b.marque)
                    : b.marque.compareTo(a.marque),
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
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.sort_by_alpha,
                        color: _ascending ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () => setState(() => _ascending = !_ascending),
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddOrEditVehiculeDialog(context),
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    currentPageItems.isEmpty
                        ? Center(child: Text('Aucun véhicule trouvé'))
                        : ListView.builder(
                          itemCount: currentPageItems.length,
                          itemBuilder:
                              (context, index) => _buildVehiculeCard(
                                context,
                                currentPageItems[index],
                              ),
                        ),
              ),
              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                    ),
                    Text('Page ${_currentPage + 1}/$totalPages'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehiculeCard(BuildContext context, VehiculeDTO v) {
    return Card(
      child: ListTile(
        title: Text('${v.marque} ${v.modele}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Immatriculation: ${v.immatriculation}'),
            Text('Année: ${v.anneeMiseEnCirculation}'),
            Text('Kilométrage: ${v.kilometrage} km'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed:
                  () => _showAddOrEditVehiculeDialog(context, vehicule: v),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, v),
            ),
            IconButton(
              icon: const Icon(Icons.receipt),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VignetteScreen(vehiculeId: v.vehiculeId),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehiculeDTO v) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text('Supprimer le véhicule ${v.marque} ${v.modele} ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<VehiculeProvider>(
                      context,
                      listen: false,
                    ).deleteVehicule(v.vehiculeId);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  String _getStatutText(StatutVehicule statut) {
    switch (statut) {
      case StatutVehicule.Disponible:
        return 'Disponible';
      case StatutVehicule.EnMaintenance:
        return 'En maintenance';
      case StatutVehicule.HorsService:
        return 'Hors service';
      case StatutVehicule.EnMission:
        return 'En mission';
      default:
        return 'Inconnu';
    }
  }
}

/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';

class VehiculeScreen extends StatefulWidget {
  @override
  _VehiculeScreenState createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    // Charger les véhicules lorsque l'écran est prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehiculeProvider>(context, listen: false).loadVehicules();
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
        title: const Text('Gestion des Véhicules'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<VehiculeProvider>(context, listen: false).loadVehicules();
            },
          ),
        ],
      ),
      body: Consumer<VehiculeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var filteredVehicules = provider.vehicules.where(
            (v) => '${v.marque} ${v.modele}'.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          ).toList();

          // Trier par marque
          filteredVehicules.sort(
            (a, b) => _ascending
                ? a.marque.compareTo(b.marque)
                : b.marque.compareTo(a.marque),
          );

          final totalPages = (filteredVehicules.length / _itemsPerPage).ceil();
          final start = _currentPage * _itemsPerPage;
          final end = (start + _itemsPerPage).clamp(0, filteredVehicules.length);
          final currentPageItems = filteredVehicules.sublist(start, end);

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
                          labelText: 'Rechercher un véhicule',
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
                    IconButton(
                      icon: Icon(
                        Icons.sort_by_alpha,
                        color: _ascending
                            ? const Color(0xFF2A5298)
                            : Colors.grey.shade400,
                      ),
                      tooltip: 'Trier par marque',
                      onPressed: () => setState(() => _ascending = !_ascending),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.directions_car, color: Colors.white),
                      label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A5298),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showAddOrEditVehiculeDialog(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Provider.of<VehiculeProvider>(context, listen: false)
                      .loadVehicules(),
                  child: filteredVehicules.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_crash_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text('Aucun véhicule trouvé', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: currentPageItems.length,
                          itemBuilder: (context, index) {
                            return _buildVehiculeCard(context, currentPageItems[index]);
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
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text("Page ${_currentPage + 1} / $totalPages"),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: (_currentPage + 1) < totalPages
                            ? () => setState(() => _currentPage++)
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

  Widget _buildVehiculeCard(BuildContext context, VehiculeDTO v) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text('${v.marque} ${v.modele}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Immatriculation: ${v.immatriculation}'),
            Text('Année: ${v.anneeMiseEnCirculation}'),
            Text('Kilométrage: ${v.kilometrage} km'),
          ],
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2A5298)),
              tooltip: 'Modifier',
              onPressed: () => _showAddOrEditVehiculeDialog(context, vehicule: v),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Supprimer',
              onPressed: () => _confirmDelete(context, v),
            ),
            Chip(
              backgroundColor: _getStatutColor(v.statut),
              label: Text(_getStatutText(v.statut), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehiculeDTO v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer ${v.marque} ${v.modele} ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
            onPressed: () {
              Provider.of<VehiculeProvider>(context, listen: false)
                  .deleteVehicule(v.id)
                  .then((_) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddOrEditVehiculeDialog(BuildContext context, {VehiculeDTO? vehicule}) {
    final isEditMode = vehicule != null;
    final formKey = GlobalKey<FormState>();
    final controllerMarque = TextEditingController(text: vehicule?.marque);
    final controllerModele = TextEditingController(text: vehicule?.modele);
    final controllerKilometrage = TextEditingController(text: vehicule?.kilometrage.toString());
    final controllerImmatriculation = TextEditingController(text: vehicule?.immatriculation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditMode ? 'Modifier Véhicule' : 'Ajouter Véhicule'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controllerMarque,
                  decoration: const InputDecoration(labelText: 'Marque'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une marque';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: controllerModele,
                  decoration: const InputDecoration(labelText: 'Modèle'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un modèle';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: controllerKilometrage,
                  decoration: const InputDecoration(labelText: 'Kilométrage'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un kilométrage';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: controllerImmatriculation,
                  decoration: const InputDecoration(labelText: 'Immatriculation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro d\'immatriculation';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(isEditMode ? 'Modifier' : 'Ajouter'),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final vehicule = VehiculeCreationDTO(
                    marque: controllerMarque.text,
                    modele: controllerModele.text,
                    kilometrage: int.tryParse(controllerKilometrage.text) ?? 0,
                    immatriculation: controllerImmatriculation.text,
                    statut: StatutVehicule.Actif,
                  );

                  if (isEditMode) {
                    Provider.of<VehiculeProvider>(context, listen: false)
                        .updateVehicule(vehicule, vehicule.id!);
                  } else {
                    Provider.of<VehiculeProvider>(context, listen: false)
                        .addVehicule(vehicule);
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatutColor(StatutVehicule statut) {
    switch (statut) {
      case StatutVehicule.Actif:
        return Colors.green;
      case StatutVehicule.Inactif:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatutText(StatutVehicule statut) {
    switch (statut) {
      case StatutVehicule.Actif:
        return 'Actif';
      case StatutVehicule.Inactif:
        return 'Inactif';
      default:
        return 'Inconnu';
    }
  }
}
*/
