import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/DepenseCreationDTO.dart';
import 'package:testfront/core/models/Depensedto.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/remboursement_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/depenseService.dart';
import 'package:testfront/core/models/TypeDepense.dart';
import 'package:testfront/core/models/MoyenPaiement.dart';
import 'package:testfront/core/config/api_config.dart';

class DepensesParTacheScreen extends StatefulWidget {
  final int tacheId;

  const DepensesParTacheScreen({Key? key, required this.tacheId})
    : super(key: key);

  @override
  State<DepensesParTacheScreen> createState() => _DepenseScreenState();
}

class _DepenseScreenState extends State<DepensesParTacheScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _montantController;
  TypeDepense? _selectedType;
  MoyenPaiement? _selectedMoyen;
  File? _selectedFile;

  List<DepenseDTO> _depenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _montantController = TextEditingController();
    _fetchDepenses();
    _updateDepenseEtTotal();
  }

  Future<void> _fetchDepenses() async {
    setState(() => _loading = true);
    final result = await DepenseService().getDepensesByTacheId(widget.tacheId);
    if (result.success && result.data != null) {
      setState(() => _depenses = result.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _updateDepenseEtTotal() async {
    final tacheProvider = Provider.of<TacheProvider>(context, listen: false);
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );
    final remboursementProvider = Provider.of<RemboursementProvider>(context, listen: false);

    final success = await tacheProvider.getTacheById(widget.tacheId);

    if (success) {
      final missionId = tacheProvider.selectedTache?.missionId;
      if (missionId != null) {
        await tacheProvider.fetchTotalDepensesMission(missionId);
        await tacheProvider.chargerTotalBudget(missionId);
        await tacheProvider.fetchTotalDepensesTache(widget.tacheId);
        // Après avoir sauvegardé les dépenses modifiées
await remboursementProvider.creerOuMettreAJourDemande(missionId);

      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitDepense({int? updateId}) async {
    if (_formKey.currentState!.validate() &&
        _selectedType != null &&
        _selectedMoyen != null) {
      final depense = DepenseCreationDTO(
        typeDepense: _selectedType!,
        description: _descriptionController.text,
        montant: double.tryParse(_montantController.text) ?? 0,
        moyenPaiement: _selectedMoyen!,
        justification: _selectedFile,
        tacheId: widget.tacheId,
      );

      bool success;
      String message;

      if (updateId != null) {
        // Appelle la méthode update avec le bon id et le DTO
        final response = await DepenseService().updateDepense(
          updateId,
          depense,
        );
        success = response.success;
        _updateDepenseEtTotal();

        message = response.message ?? '';
      } else {
        // Création
        final response = await DepenseService().createDepense(depense);
        _updateDepenseEtTotal();

        success = response.success;
        message = response.message ?? '';
      }

      if (success) {
        Navigator.pop(context);
        _fetchDepenses();
        _updateDepenseEtTotal();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updateId != null
                  ? "Dépense mise à jour"
                  : "Dépense ajoutée avec succès",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $message")));
      }
    }
  }

  void _openAddDialog({DepenseDTO? depense}) {
    if (depense != null) {
      _descriptionController.text = depense.description;
      _montantController.text = depense.montant.toString();
      _selectedType = depense.typeDepense;
      _selectedMoyen = depense.moyenPaiement;
      _selectedFile = null; // on laisse l’image actuelle
    } else {
      _descriptionController.clear();
      _montantController.clear();
      _selectedType = null;
      _selectedMoyen = null;
      _selectedFile = null;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              depense != null ? "Modifier la dépense" : "Ajouter une dépense",
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<TypeDepense>(
                      decoration: InputDecoration(labelText: "Type de dépense"),
                      items:
                          TypeDepense.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toString().split('.').last),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => _selectedType = value,
                      value: _selectedType,
                      validator:
                          (value) => value == null ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Champ requis'
                                  : null,
                    ),
                    TextFormField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Montant"),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Champ requis'
                                  : null,
                    ),
                    DropdownButtonFormField<MoyenPaiement>(
                      decoration: InputDecoration(
                        labelText: "Moyen de paiement",
                      ),
                      items:
                          MoyenPaiement.values
                              .map(
                                (moyen) => DropdownMenuItem(
                                  value: moyen,
                                  child: Text(moyen.toString().split('.').last),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => _selectedMoyen = value,
                      value: _selectedMoyen,
                      validator:
                          (value) => value == null ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text(
                        _selectedFile == null
                            ? "Choisir une image"
                            : "Image sélectionnée",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () => _submitDepense(updateId: depense?.depenseId),

                child: Text(depense != null ? "Mettre à jour" : "Valider"),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(int depenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirmer la suppression"),
            content: Text("Voulez-vous vraiment supprimer cette dépense ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),

                child: Text("Supprimer"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final response = await DepenseService().deleteDepense(depenseId);
      if (response.success) {
        _fetchDepenses();
        _updateDepenseEtTotal();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Dépense supprimée")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression")),
        );
      }
    }
  }

  String getImageUrl(String path) => "${ApiConfig.baseUrl}$path";

  Widget _buildDepenseList() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else if (_depenses.isEmpty) {
      return Center(child: Text("Aucune dépense trouvée."));
    } else {
      return ListView.builder(
        itemCount: _depenses.length,
        itemBuilder: (context, index) {
          final dep = _depenses[index];
          String typeLabel = dep.typeDepense.toString().split('.').last;
          String moyenLabel = dep.moyenPaiement.toString().split('.').last;
          String montantFormatted = dep.montant
              .toStringAsFixed(2)
              .replaceAll('.', ',');

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showDepenseDetails(dep),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Hero(
                      tag: 'depense-image-${dep.depenseId}',
                      child:
                          dep.justification.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  getImageUrl(dep.justification),
                                  width: 60,
                                  height: 60,

                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 60),
                                ),
                              )
                              : Icon(
                                Icons.receipt,
                                size: 60,
                                color: Colors.grey,
                              ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dep.description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text("Montant: $montantFormatted Dt"),
                          Text("Type: $typeLabel | Moyen: $moyenLabel"),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Modifier",
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openAddDialog(depense: dep),
                        ),
                        IconButton(
                          tooltip: "Supprimer",
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(dep.depenseId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showDepenseDetails(DepenseDTO depense) {
    String typeLabel = depense.typeDepense.toString().split('.').last;
    String moyenLabel = depense.moyenPaiement.toString().split('.').last;
    String montantFormatted = depense.montant
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Détail de la dépense",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Description: ${depense.description}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Montant: $montantFormatted Dt",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Type de dépense: $typeLabel",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Moyen de paiement: $moyenLabel",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    if (depense.justification.isNotEmpty)
                      GestureDetector(
                        onTap: () => _openImageZoom(depense),
                        child: Hero(
                          tag: 'depense-image-${depense.depenseId}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              getImageUrl(depense.justification),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                        ),
                      )
                    else
                      Text("Aucune justification fournie"),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Fermer"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _openImageZoom(DepenseDTO depense) {
    showDialog(
      context: context,
      builder:
          (context) => _ImageZoomDialog(
            imageUrl: getImageUrl(depense.justification),
            tag: 'depense-image-${depense.depenseId}',
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dépenses"),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _openAddDialog)],
      ),
      body: _buildDepenseList(),
    );
  }
}

class _ImageZoomDialog extends StatefulWidget {
  final String imageUrl;
  final String tag;

  const _ImageZoomDialog({required this.imageUrl, required this.tag});

  @override
  State<_ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<_ImageZoomDialog> {
  double _currentScale = 1.0;
  final double _minScale = 1.0;
  final double _maxScale = 4.0;

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.5).clamp(_minScale, _maxScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.5).clamp(_minScale, _maxScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.all(0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Hero(
                tag: widget.tag,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  scaleEnabled: false, // disable pinch zoom to control manually
                  child: Transform.scale(
                    scale: _currentScale,
                    child: Image.network(
                      widget.imageUrl,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 100,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              tooltip: "Fermer",
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Icon(Icons.zoom_in, color: Colors.black),
                  onPressed: _zoomIn,
                  tooltip: "Zoomer",
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Icon(Icons.zoom_out, color: Colors.black),
                  onPressed: _zoomOut,
                  tooltip: "Dézoomer",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
