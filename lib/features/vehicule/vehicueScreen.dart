import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';

class VehiculeScreen extends StatefulWidget {
  const VehiculeScreen({Key? key}) : super(key: key);

  @override
  State<VehiculeScreen> createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<VehiculeProvider>(context, listen: false).loadVehicules();
  }

  final _formKey = GlobalKey<FormState>();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _anneeController = TextEditingController();
  final _kilometrageController = TextEditingController();
  StatutVehicule _selectedStatut = StatutVehicule.Disponible;

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un véhicule'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _marqueController,
                    decoration: const InputDecoration(labelText: 'Marque'),
                    validator:
                        (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _modeleController,
                    decoration: const InputDecoration(labelText: 'Modèle'),
                    validator:
                        (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _immatriculationController,
                    decoration: const InputDecoration(
                      labelText: 'Immatriculation',
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _anneeController,
                    decoration: const InputDecoration(labelText: 'Année'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _kilometrageController,
                    decoration: const InputDecoration(labelText: 'Kilométrage'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  DropdownButtonFormField<StatutVehicule>(
                    value: _selectedStatut,
                    items:
                        StatutVehicule.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatut = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Statut'),
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
                    marque: _marqueController.text,
                    modele: _modeleController.text,
                    immatriculation: _immatriculationController.text,
                    anneeMiseEnCirculation: int.parse(
                      _anneeController.text.trim(),
                    ),
                    kilometrage: int.parse(_kilometrageController.text.trim()),
                    statut: _selectedStatut,
                  );

                  await Provider.of<VehiculeProvider>(
                    context,
                    listen: false,
                  ).createVehicule(dto);

                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Véhicules')),
      body: Consumer<VehiculeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: provider.vehicules.length,
            itemBuilder: (context, index) {
              final vehicule = provider.vehicules[index];
              return ListTile(
                title: Text('${vehicule.marque} ${vehicule.modele}'),
                subtitle: Text(
                  'Immat: ${vehicule.immatriculation}, Statut: ${vehicule.statut.name}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
