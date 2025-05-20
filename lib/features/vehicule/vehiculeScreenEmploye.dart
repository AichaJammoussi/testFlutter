import 'package:flutter/material.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/services/VehiculeService.dart';

class VehiculeScreenEmploye extends StatefulWidget {
  const VehiculeScreenEmploye({Key? key}) : super(key: key);

  @override
  _VehiculeScreenEmployeState createState() => _VehiculeScreenEmployeState();
}

class _VehiculeScreenEmployeState extends State<VehiculeScreenEmploye> {
  final VehiculeService _vehiculeService = VehiculeService();
  List<VehiculeDTO> _vehicules = [];
  List<VehiculeDTO> _filteredVehicules = [];
  String _searchQuery = "";

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadVehicules();
  }

  void _loadVehicules() async {
    final response = await _vehiculeService.fetchVehicules();
    if (response.success && response.data != null) {
      setState(() {
        _vehicules = response.data!;
        _filteredVehicules = _vehicules;
      });
    } else {
      // Gestion d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Erreur inconnue")),
      );
    }
  }

  void _filterVehicules(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredVehicules = _vehicules.where((vehicule) {
        return vehicule.marque.toLowerCase().contains(_searchQuery) ||
            vehicule.modele.toLowerCase().contains(_searchQuery) ||
            vehicule.immatriculation.toLowerCase().contains(_searchQuery);
      }).toList();
      _currentPage = 1; // Reset page to 1 after filtering
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcul du nombre total de pages
    int totalPages = (_filteredVehicules.length / _itemsPerPage).ceil();

    // Calcul des véhicules à afficher sur la page courante
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    List<VehiculeDTO> currentPageVehicules = _filteredVehicules.sublist(
      startIndex,
      endIndex > _filteredVehicules.length ? _filteredVehicules.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Liste des véhicules")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterVehicules,
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: currentPageVehicules.isEmpty
                ? const Center(child: Text("Aucun véhicule trouvé."))
                : ListView.builder(
                    itemCount: currentPageVehicules.length,
                    itemBuilder: (context, index) {
                      final vehicule = currentPageVehicules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text("${vehicule.marque} ${vehicule.modele}"),
                          subtitle: Text("Matricule : ${vehicule.immatriculation}"),
                        ),
                      );
                    },
                  ),
          ),
          // Pagination en bas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                ),
                Row(
                  children: List.generate(totalPages, (index) {
                    final pageNumber = index + 1;
                    final isCurrent = pageNumber == _currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentPage = pageNumber;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         
                          child: Text(
                            "Page $pageNumber",
                            style: TextStyle(
                              color: isCurrent ? Colors.grey : Colors.black,
                              fontWeight: isCurrent ? FontWeight.normal : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages
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
      ),
    );
  }
}
