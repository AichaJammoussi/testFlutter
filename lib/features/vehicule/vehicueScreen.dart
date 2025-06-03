import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';
import 'package:testfront/features/vehicule/VignetteScreen.dart';

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

  // Couleurs bleues pour le design
  final Color _primaryBlue = Color(0xFF2196F3);
  final Color _secondaryBlue = Color(0xFF64B5F6);
  final Color _accentBlue = Color(0xFF1976D2);
  final Color _backgroundBlue = Color(0xFFF8F9FA);
  final Color _textBlue = Color(0xFF37474F);

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
              color: _textBlue,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez $label',
            prefixIcon: Icon(icon, color: _accentBlue),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentBlue.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentBlue.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentBlue),
            ),
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

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 500, // Dialog plus petit
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: _backgroundBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // En-tête avec icône
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.directions_car, color: _accentBlue),
                                SizedBox(width: 10),
                                Text(
                                  isEdit
                                      ? 'Modifier véhicule'
                                      : 'Nouveau véhicule',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _textBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Formulaire
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFormField(
                                  controller: marqueController,
                                  label: 'Marque',
                                  icon: Icons.branding_watermark,
                                  errorText: fieldErrors['marque'],
                                  isRequired: true,
                                ),

                                SizedBox(height: 16),

                                _buildFormField(
                                  controller: modeleController,
                                  label: 'Modèle',
                                  icon: Icons.directions_car,
                                  errorText: fieldErrors['modele'],
                                  isRequired: true,
                                ),

                                SizedBox(height: 16),

                                _buildFormField(
                                  controller: immatriculationController,
                                  label: 'Immatriculation',
                                  icon: Icons.confirmation_number,
                                  errorText: fieldErrors['immatriculation'],
                                  isRequired: true,
                                ),

                                SizedBox(height: 16),

                                _buildFormField(
                                  controller: anneeController,
                                  label: 'Année',
                                  icon: Icons.calendar_today,
                                  keyboardType: TextInputType.number,
                                  errorText: fieldErrors['annee'],
                                  isRequired: true,
                                ),

                                SizedBox(height: 16),

                                _buildFormField(
                                  controller: kilometrageController,
                                  label: 'Kilométrage',
                                  icon: Icons.speed,
                                  keyboardType: TextInputType.number,
                                  errorText: fieldErrors['kilometrage'],
                                  isRequired: true,
                                ),

                                SizedBox(height: 16),

                                // Sélecteur de statut amélioré
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _accentBlue.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child:
                                      DropdownButtonFormField<StatutVehicule>(
                                        value: selectedStatut,
                                        decoration: InputDecoration(
                                          labelText: 'Statut',
                                          border: InputBorder.none,
                                          errorText: fieldErrors['statut'],
                                          labelStyle: TextStyle(
                                            color: _textBlue.withOpacity(0.8),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: _accentBlue,
                                        ),
                                        style: TextStyle(color: _textBlue),
                                        items:
                                            StatutVehicule.values.map((statut) {
                                              return DropdownMenuItem(
                                                value: statut,
                                                child: Row(
                                                  children: [
                                                    _buildStatutBadge(statut),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      _getStatutText(statut),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(
                                              () => selectedStatut = value,
                                            );
                                          }
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Boutons d'action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Bouton Annuler
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: _textBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: _accentBlue),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),

                              SizedBox(width: 10),

                              // Bouton Valider
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final dto = VehiculeCreationDTO(
                                      marque: marqueController.text.trim(),
                                      modele: modeleController.text.trim(),
                                      immatriculation:
                                          immatriculationController.text.trim(),
                                      anneeMiseEnCirculation:
                                          int.tryParse(
                                            anneeController.text.trim(),
                                          ) ??
                                          0,
                                      kilometrage:
                                          int.tryParse(
                                            kilometrageController.text.trim(),
                                          ) ??
                                          0,
                                      statut: selectedStatut.index,
                                    );

                                    final provider =
                                        Provider.of<VehiculeProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final response =
                                        isEdit
                                            ? await provider.updateVehicule(
                                              vehicule!.vehiculeId,
                                              dto,
                                            )
                                            : await provider.createVehicule(
                                              dto,
                                            );

                                    if (response.success) {
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    } else {
                                      handleApiErrors(response.errors);
                                    }
                                  }
                                },
                                child: Text(isEdit ? 'Modifier' : 'Ajouter'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatutBadge(StatutVehicule statut) {
    Color badgeColor;
    IconData badgeIcon;

    switch (statut) {
      case StatutVehicule.Disponible:
        badgeColor = Color(0xFF4CAF50);
        badgeIcon = Icons.check_circle;
        break;
      case StatutVehicule.EnMaintenance:
        badgeColor = Color(0xFFFF9800);
        badgeIcon = Icons.build;
        break;
      case StatutVehicule.HorsService:
        badgeColor = Color(0xFFF44336);
        badgeIcon = Icons.warning;
        break;
      case StatutVehicule.EnMission:
        badgeColor = Color(0xFF2196F3);
        badgeIcon = Icons.directions_car;
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            _getStatutText(statut),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundBlue,
      appBar: AppBar(
        title: Text(
          'Gestion des Véhicules',
          style: TextStyle(color: _textBlue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _accentBlue),
        actions: [
          Tooltip(
            message: 'Actualiser la liste',
            child: IconButton(
              icon: Icon(Icons.refresh, color: _accentBlue),
              onPressed:
                  () =>
                      Provider.of<VehiculeProvider>(
                        context,
                        listen: false,
                      ).loadVehicules(),
            ),
          ),
        ],
      ),
      body: Consumer<VehiculeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return Center(child: CircularProgressIndicator(color: _accentBlue));
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
              // Barre avec recherche, bouton ajout et tri séparés
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Bouton d'ajout à gauche

                    // Champ de recherche au centre (plus petit)
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher',
                            hintText: 'Marque, modèle...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: _accentBlue,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                            labelStyle: TextStyle(fontSize: 14),
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                          style: TextStyle(fontSize: 14),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    Tooltip(
                      message: 'Ajouter un véhicule',
                      child: Container(
                        decoration: BoxDecoration(
                          color: _accentBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.white, size: 24),
                          onPressed:
                              () => _showAddOrEditVehiculeDialog(context),
                          constraints: BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Bouton de tri à droite
                    Tooltip(
                      message:
                          _ascending
                              ? 'Tri croissant (A-Z)'
                              : 'Tri décroissant (Z-A)',
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _ascending ? _primaryBlue : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.sort_by_alpha,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed:
                              () => setState(() => _ascending = !_ascending),
                          constraints: BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    currentPageItems.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 50,
                                color: _accentBlue.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun véhicule trouvé',
                                style: TextStyle(
                                  color: _textBlue.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: 'Page précédente',
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: _accentBlue,
                              ),
                              onPressed:
                                  _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Page ${_currentPage + 1}/$totalPages',
                              style: TextStyle(color: _textBlue),
                            ),
                          ),
                          Tooltip(
                            message: 'Page suivante',
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: _accentBlue,
                              ),
                              onPressed:
                                  _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehiculeCard(BuildContext context, VehiculeDTO v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAddOrEditVehiculeDialog(context, vehicule: v),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne principale : icône + infos + statut
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: _accentBlue,
                            size: 28,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${v.marque} ${v.modele}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _textBlue,
                              ),
                            ),
                            Text(
                              v.immatriculation,
                              style: TextStyle(
                                color: _textBlue.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatutBadge(v.statut),
                  ],
                ),

                const SizedBox(height: 16),

                // Informations techniques
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildInfoItem(
                      Icons.calendar_today,
                      '${v.anneeMiseEnCirculation}',
                    ),
                    _buildInfoItem(Icons.speed, '${v.kilometrage} km'),
                  ],
                ),

                const SizedBox(height: 16),

                // Actions
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Modifier le véhicule',
                      child: IconButton(
                        icon: Icon(Icons.edit, color: _accentBlue),
                        onPressed:
                            () => _showAddOrEditVehiculeDialog(
                              context,
                              vehicule: v,
                            ),
                      ),
                    ),
                    Tooltip(
                      message: 'Supprimer le véhicule',
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFF44336),
                        ),
                        onPressed: () => _confirmDelete(context, v),
                      ),
                    ),
                    Tooltip(
                      message: 'Voir les vignettes',
                      child: IconButton(
                        icon: Icon(Icons.receipt, color: _primaryBlue),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VignetteScreen(
                                      vehiculeId: v.vehiculeId,
                                    ),
                              ),
                            ),
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _accentBlue),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: _textBlue.withOpacity(0.8))),
      ],
    );
  }

  void _confirmDelete(BuildContext context, VehiculeDTO v) async {
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
                  const Icon(Icons.warning, size: 48, color: Color(0xFFF44336)),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmer la suppression',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voulez-vous vraiment supprimer le véhicule "${v.marque} ${v.modele}" ?',
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
                          backgroundColor: const Color(0xFFF44336),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await Provider.of<VehiculeProvider>(
                              context,
                              listen: false,
                            ).deleteVehicule(v.vehiculeId);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: const Color(0xFFF44336),
                              ),
                            );
                          }
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
