import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/PrioriteMission.dart';
import 'package:testfront/core/models/RemboursementDTO.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/rapportProvider.dart';
import 'package:testfront/core/providers/remboursement_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/generatePdf.dart';
import 'package:testfront/features/mission/TacheMission.dart';
import 'package:testfront/features/mission/tacheEmploye.dart';
import 'package:collection/collection.dart';

//missionet l employe el connecte
class MissionsScreenEmploye extends StatefulWidget {
  const MissionsScreenEmploye({Key? key}) : super(key: key);

  @override
  State<MissionsScreenEmploye> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreenEmploye> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _itemsPerPage = 3;

  StatutMission? _selectedStatutFilter;
  PrioriteMission? _selectedPrioriteFilter;
  bool _sortByDateAsc = true;
  bool _ascending = true;
  bool _sortAlphabetically = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      final missionProvider = context.read<MissionProvider>();
      Future.microtask(
        () => context.read<RemboursementProvider>().loadMesRemboursements(),
      );

      // Boucle d'attente tant que user == null
      while (userProvider.user == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final userId = userProvider.user!.id;
      await missionProvider.loadMissionsByUserId(userId);
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1; // reset page on search/filter change
      });
    });
  }

  Future<void> _updateDepenseEtTotal() async {
    final tacheProvider = Provider.of<TacheProvider>(context, listen: false);
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );
    final remboursementProvider = Provider.of<RemboursementProvider>(
      context,
      listen: false,
    );

    //final success = await tacheProvider.getTacheById(widget.tacheId);

    final missionId = tacheProvider.selectedTache?.missionId;
    if (missionId != null) {
      await tacheProvider.fetchTotalDepensesMission(missionId);
      await tacheProvider.chargerTotalBudget(missionId);
      await remboursementProvider.creerOuMettreAJourDemande(missionId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getStatutIcon(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return Icons.schedule;
      case StatutMission.EN_COURS:
        return Icons.timelapse;
      case StatutMission.TERMINEE:
        return Icons.check_circle;
      case StatutMission.ANNULEE:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatutColor(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return Colors.teal;
      case StatutMission.EN_COURS:
        return Colors.amber;
      case StatutMission.TERMINEE:
        return Colors.green;
      case StatutMission.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(PrioriteMission priorite) {
    switch (priorite) {
      case PrioriteMission.Urgente:
        return Colors.red;
      case PrioriteMission.Haute:
        return Colors.orange;
      case PrioriteMission.Moyenne:
        return Colors.blue;
      case PrioriteMission.Basse:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Missions'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              final userId = userProvider.user?.id;
              if (userId != null) {
                await context.read<MissionProvider>().loadMissionsByUserId(
                  userId,
                );
                setState(() {
                  _currentPage = 1;
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<MissionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.missions.isEmpty) {
            return const Center(child: Text('Aucune mission trouvée.'));
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          var missions =
              provider.missions
                  .where(
                    (m) =>
                        m.titre.toLowerCase().contains(_searchQuery) ||
                        m.description.toLowerCase().contains(_searchQuery),
                  )
                  .where(
                    (m) =>
                        _selectedStatutFilter == null ||
                        m.statut == _selectedStatutFilter,
                  )
                  .where(
                    (m) =>
                        _selectedPrioriteFilter == null ||
                        m.priorite == _selectedPrioriteFilter,
                  )
                  .toList();

          missions.sort((a, b) => a.statut.index.compareTo(b.statut.index));
          missions.sort((a, b) => b.priorite.index.compareTo(a.priorite.index));

          if (_sortAlphabetically) {
            missions.sort(
              (a, b) =>
                  _ascending
                      ? a.titre.compareTo(b.titre)
                      : b.titre.compareTo(a.titre),
            );
          } else {
            missions.sort(
              (a, b) =>
                  _sortByDateAsc
                      ? a.dateDebutPrevue.compareTo(b.dateDebutPrevue)
                      : b.dateDebutPrevue.compareTo(a.dateDebutPrevue),
            );
          }

          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(
            0,
            missions.length,
          );
          final paginatedMissions = missions.sublist(startIndex, endIndex);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Rechercher une mission',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20, // espace horizontal entre les widgets
                      runSpacing: 10, // espace vertical si retour à la ligne
                      alignment: WrapAlignment.center,
                      children: [
                        // Statut
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 150,
                            maxWidth: 200,
                          ),
                          child: DropdownButton<StatutMission?>(
                            isExpanded: true,
                            hint: const Text("Tous les statuts"),
                            value: _selectedStatutFilter,
                            items: [
                              const DropdownMenuItem<StatutMission?>(
                                value: null,
                                child: Text('Tous les statuts'),
                              ),
                              ...StatutMission.values.map(
                                (statut) => DropdownMenuItem(
                                  value: statut,
                                  child: Text(statut.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatutFilter = value;
                                _currentPage = 1;
                              });
                            },
                          ),
                        ),

                        // Priorité
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 150,
                            maxWidth: 200,
                          ),
                          child: DropdownButton<PrioriteMission?>(
                            isExpanded: true,
                            hint: const Text("Toutes les priorités"),
                            value: _selectedPrioriteFilter,
                            items: [
                              const DropdownMenuItem<PrioriteMission?>(
                                value: null,
                                child: Text('Toutes les priorités'),
                              ),
                              ...PrioriteMission.values.map(
                                (priorite) => DropdownMenuItem(
                                  value: priorite,
                                  child: Text(priorite.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPrioriteFilter = value;
                                _currentPage = 1;
                              });
                            },
                          ),
                        ),

                        // Bouton de tri par date
                        IconButton(
                          icon: Icon(
                            _sortByDateAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          ),
                          tooltip: "Trier par date",
                          onPressed: () {
                            setState(() {
                              _sortByDateAsc = !_sortByDateAsc;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    missions.isEmpty
                        ? const Center(child: Text('Aucune mission trouvée.'))
                        : ListView.builder(
                          itemCount: paginatedMissions.length,
                          itemBuilder: (context, index) {
                            final mission = paginatedMissions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  _getStatutIcon(mission.statut),
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  mission.titre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatDate(mission.dateDebutPrevue)} → ${_formatDate(mission.dateFinPrevue)}',
                                    ),
                                    Text(
                                      'Créée le : ${DateFormat('dd/MM/yyyy– HH:mm').format(mission.dateCreation)}',
                                    ),
                                  ],
                                ),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.task,
                                        color: Color(0xFF2A5298),
                                      ),
                                      tooltip: 'Voir les tâches',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => TachesEmploye(
                                                  missionId: mission.missionId,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: _getPriorityColor(
                                        mission.priorite,
                                      ),
                                      size: 14,
                                    ),
                                  ],
                                ),

                                onTap:
                                    () => _showMissionDetails(context, mission),
                              ),
                            );
                          },
                        ),
              ),
              if (missions.isNotEmpty)
                Row(
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
                    Text('Page $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          _currentPage * _itemsPerPage < missions.length
                              ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy- – HH:mm').format(date);
  }

  void _showMissionDetails(BuildContext context, MissionDTO mission) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mission.titre,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A5298),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            mission.statut.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatutColor(mission.statut),
                          avatar: Icon(
                            _getStatutIcon(mission.statut),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(
                            mission.priorite.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getPriorityColor(mission.priorite),
                          avatar: const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (mission.statut == StatutMission.TERMINEE) ...[
                      const SizedBox(height: 20),
                      Consumer<RemboursementProvider>(
                        builder: (context, remboursementProvider, _) {
                          final isLoading = remboursementProvider.isLoading;

                          // Recherche demande associée
                          final RemboursementDTO? demandeExistante =
                              remboursementProvider.remboursements
                                  .firstWhereOrNull(
                                    (r) => r.missionId == mission.missionId,
                                  );

                          final bool demandeDejaFaite =
                              demandeExistante != null;

                          String labelButton;
                          if (demandeDejaFaite) {
                            if (demandeExistante!.montant < 0) {
                              labelButton =
                                  'Demande de retour d\'argent : ${demandeExistante.montant.abs().toStringAsFixed(2)} DT';
                            } else if (demandeExistante.montant > 0) {
                              labelButton =
                                  'Demande de remboursement : ${demandeExistante.montant.toStringAsFixed(2)} DT';
                            } else {
                              labelButton =
                                  'Montant nul, aucune demande nécessaire';
                            }
                          } else if (isLoading) {
                            labelButton = '⏳ Envoi en cours...';
                          } else {
                            labelButton = '💸 Demander un remboursement';
                          }

                          return ElevatedButton.icon(
                            onPressed:
                                (demandeDejaFaite || isLoading)
                                    ? null
                                    : () async {
                                      await remboursementProvider
                                          .creerOuMettreAJourDemande(
                                            mission.missionId,
                                          );

                                      if (context.mounted) {
                                        final error =
                                            remboursementProvider.error;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              error != null
                                                  ? '❌ Erreur : $error'
                                                  : '✅ Demande envoyée avec succès',
                                            ),
                                            backgroundColor:
                                                error != null
                                                    ? Colors.red
                                                    : Colors.green,
                                          ),
                                        );
                                      }

                                      Navigator.pop(context);
                                    },
                            icon: const Icon(Icons.request_page),
                            label: Text(labelButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A5298),
                              disabledBackgroundColor: Colors.grey,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          );
                        },
                      ),
                      ...[
                        const SizedBox(height: 20),

ElevatedButton.icon(
  onPressed: () async {
    final rapportProvider = context.read<RapportProvider>();

    // Chargement du rapport
    await rapportProvider.loadRapport(mission.missionId);

    if (!context.mounted) return;

    final rapport = rapportProvider.rapport;
    if (rapport != null) {
      // Génération PDF
      await generateMissionRapportPdf(rapport);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 Rapport PDF généré avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Échec de génération : ${rapportProvider.error ?? "rapport non disponible"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  icon: const Icon(Icons.picture_as_pdf),
  label: const Text("📄 Générer le rapport PDF"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.indigo,
    minimumSize: const Size(double.infinity, 48),
  ),
),

                        const SizedBox(height: 20),

                
                         
                      ],

                    _buildDetailRow('📄 Description', mission.description),
                    _buildDetailRow(
                      '📆 Dates prévues',
                      '${_formatDate(mission.dateDebutPrevue)} - ${_formatDate(mission.dateFinPrevue)}',
                    ),
                    if (mission.dateDebutReelle != null &&
                        mission.dateFinReelle != null)
                      _buildDetailRow(
                        '🕓 Dates réelles',
                        '${_formatDate(mission.dateDebutReelle!)} - ${_formatDate(mission.dateFinReelle!)}',
                      ),

                    _buildDetailRow(
                      '💰 Budget',
                      '${mission.budget.toStringAsFixed(2)} Dt',
                    ),
                    if (mission.depenses != null)
                      _buildDetailRow(
                        '💸 Dépenses',
                        '${mission.depenses!.toStringAsFixed(2)} Dt',
                      ),
                    _buildDetailRow('👤 Créée par', mission.creePar),
                    _buildDetailRow(
                      '🗓️ Créée le',
                      DateFormat(
                        'dd/MM/yyyy – HH:mm',
                      ).format(mission.dateCreation),
                    ),
                    const SizedBox(height: 16),
                    if (mission.vehicules != null &&
                        mission.vehicules!.isNotEmpty) ...[
                      const Text(
                        '🚗 Véhicules assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children:
                            mission.vehicules!
                                .map(
                                  (v) => Chip(
                                    label: Text(
                                      '${v.marque} ${v.modele} (${v.immatriculation})',
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (mission.employes.isNotEmpty) ...[
                      const Text(
                        '👥 Employés assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children:
                            mission.employes
                                .map(
                                  (e) =>
                                      Chip(label: Text('${e.prenom} ${e.nom}')),
                                )
                                .toList(),
                      ),
                    ],
                   ] ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}
