import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/DepenseCreationDTO.dart';
import 'package:testfront/core/models/Depensedto.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/depenseService.dart';
import 'package:testfront/core/models/TypeDepense.dart';
import 'package:testfront/core/models/MoyenPaiement.dart';

//juste affichage lel employe fel web wala admin
class DepensesParTacheScreenAdmin extends StatefulWidget {
  final int tacheId;

  const DepensesParTacheScreenAdmin({Key? key, required this.tacheId})
    : super(key: key);

  @override
  State<DepensesParTacheScreenAdmin> createState() => _DepenseScreenState();
}

class _DepenseScreenState extends State<DepensesParTacheScreenAdmin> {
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
  }

  Future<void> _fetchDepenses() async {
    setState(() => _loading = true);
    final result = await DepenseService().getDepensesByTacheId(widget.tacheId);
    if (result.success && result.data != null) {
      setState(() => _depenses = result.data!);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _updateDepenseEtTotal() async {
    final tacheProvider = Provider.of<TacheProvider>(context, listen: false);
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );

    final success = await tacheProvider.getTacheById(widget.tacheId);

    if (success) {
      final missionId = tacheProvider.selectedTache?.missionId;
      if (missionId != null) {
        await tacheProvider.fetchTotalDepensesMission(missionId);
        await tacheProvider.chargerTotalBudget(missionId);
      }
    }
  }

  Widget _buildDepenseList() {
    String getImageUrl(String path) {
      return "${ApiConfig.baseUrl}$path";
    }

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
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading:
                  dep.justification.isNotEmpty
                      ? Image.network(
                        getImageUrl(dep.justification),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.broken_image),
                      )
                      : Icon(Icons.receipt, color: Colors.grey, size: 40),
              title: Text(dep.description),
              subtitle: Text(
                "Montant: $montantFormatted Dt\nType: $typeLabel | Moyen: $moyenLabel",
              ),
              isThreeLine: true,
              onTap: () => _showDepenseDetails(dep),
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
    String getImageUrl(String path) {
      return "${ApiConfig.baseUrl}$path";
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Détail de la dépense"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description: ${depense.description}"),
                  SizedBox(height: 8),
                  Text("Montant: $montantFormatted Dt"),
                  SizedBox(height: 8),
                  Text("Type de dépense: $typeLabel"),
                  SizedBox(height: 8),
                  Text("Moyen de paiement: $moyenLabel"),
                  SizedBox(height: 8),
                  depense.justification.isNotEmpty
                      ? Image.network(
                        getImageUrl(depense.justification),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.broken_image),
                      )
                      : Text("Aucune justification fournie"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fermer"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dépenses")),
      body: _buildDepenseList(),
    );
  }
}
