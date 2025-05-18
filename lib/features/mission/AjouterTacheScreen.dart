import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/UserDTO.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';

class TachesParMissionScreen extends StatefulWidget {
  final int missionId;

  const TachesParMissionScreen({Key? key, required this.missionId})
    : super(key: key);

  @override
  _TachesParMissionScreenState createState() => _TachesParMissionScreenState();
}

class _TachesParMissionScreenState extends State<TachesParMissionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TacheProvider>().fetchTachesByMissionId(
        widget.missionId,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
  }

  String _getPrioriteTacheText(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return 'Basse';
      case PrioriteTache.Moyenne:
        return 'Moyenne';
      case PrioriteTache.Haute:
        return 'Haute';
      default:
        return 'Inconnue';
    }
  }

  String _getStatutTacheText(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return 'Planifié';
      case StatutTache.EN_COURS:
        return 'En cours';
      case StatutTache.TERMINEE:
        return 'Terminée';
      case StatutTache.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(24),
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
                            tache.titre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A5298),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.description,
                      title: 'Description',
                      content: tache.description,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      icon: Icons.calendar_today,
                      title: 'Date de création',
                      content: DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(tache.dateCreation),
                    ),
                    if (tache.dateRealisation != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.event_available,
                        title: 'Date de réalisation',
                        content: DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(tache.dateRealisation!),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildMetaDataCard(
                      icon: Icons.flag,
                      title: 'Statut',
                      value: _getStatutTacheText(tache.statutTache),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildMetaDataCard(
                      icon: Icons.priority_high,
                      title: 'Priorité',
                      value: _getPrioriteTacheText(tache.priorite),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildMetaDataCard(
                      icon: Icons.person,
                      title: 'Assignée à',
                      value: tache.userName ?? tache.userId,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2A5298)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaDataCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color ?? const Color(0xFF2A5298)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher le dialogue d'ajout
  void _showAddTacheDialog(
    BuildContext context,
    Function(TacheCreationDTO) onAdd,
  ) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();

    StatutTache selectedStatut =
        StatutTache.PLANIFIEE; // Peut être ignoré si non dans création
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);

    // Liste des employés disponibles à charger au démarrage
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Charge les employés disponibles une fois au début
              if (isLoading && mission != null) {
                missionProvider
                    .loadEmployesDisponibles(
                      mission.dateDebutPrevue,
                      mission.dateFinPrevue,
                    )
                    .then((_) {
                      setState(() {
                        employesDisponibles =
                            missionProvider.employesDisponibles;
                        isLoading = false;
                        error = missionProvider.error;
                        if (employesDisponibles.isNotEmpty) {
                          selectedUserId = employesDisponibles.first.id;
                        }
                      });
                    });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Nouvelle Tâche',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A5298),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: const InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ obligatoire'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: const InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                PrioriteTache.values
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(_getPrioriteTacheText(p)),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => selectedPriorite = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Text(
                              error!,
                              style: const TextStyle(color: Colors.red),
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: selectedUserId,
                              decoration: const InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  employesDisponibles
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Text('${e.prenom} ${e.nom}'),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedUserId = val;
                                });
                              },
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? 'Veuillez choisir un employé'
                                          : null,
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newTache = TacheCreationDTO(
                                  titre: _titreController.text,
                                  description: _descriptionController.text,
                                  priorite: selectedPriorite,
                                  dateCreation: DateTime.now(),
                                  userId: selectedUserId!,
                                  idMission: widget.missionId,
                                );
                                onAdd(newTache);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Ajouter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches de la mission'),
        backgroundColor: const Color(0xFF2A5298),
      ),
      body: Consumer<TacheProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A5298)),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.taches.isEmpty) {
            return const Center(
              child: Text('Aucune tâche associée à cette mission.'),
            );
          }

          return ListView.builder(
            itemCount: provider.taches.length,
            itemBuilder: (context, index) {
              final tache = provider.taches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    tache.titre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(_formatDate(tache.dateCreation)),
                  onTap: () => _showTacheDetails(context, tache),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5298),
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddTacheDialog(context, (newTache) {
            context.read<TacheProvider>().createTache(
              newTache as TacheCreationDTO,
            );
          });
        },
      ),
    );
  }
}
