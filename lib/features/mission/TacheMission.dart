/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
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

  Color _getPrioriteColor(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return Colors.green;
      case PrioriteTache.Moyenne:
        return Colors.orange;
      case PrioriteTache.Haute:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutColor(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Colors.blue;
      case StatutTache.EN_COURS:
        return Colors.orange;
      case StatutTache.TERMINEE:
        return Colors.green;
      case StatutTache.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
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
                      color: _getStatutColor(tache.statutTache),
                    ),
                    const SizedBox(height: 12),
                    _buildMetaDataCard(
                      icon: Icons.priority_high,
                      title: 'Priorité',
                      value: _getPrioriteTacheText(tache.priorite),
                      color: _getPrioriteColor(tache.priorite),
                    ),
                    _buildMetaDataCard(
                      icon: Icons.attach_money,
                      title: 'Budget',
                      value:
                          '${tache.budget?.toStringAsFixed(2) ?? 'Non défini'} Dt',
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5298),
                        ),
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

  void _showAddTacheDialog(
    BuildContext context,
    Function(TacheCreationDTO) onAdd,
  ) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    StatutTache selectedStatut = StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;
    Map<String, String> _fieldErrors = {};

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
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
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['titre'],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['description'],
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['budget'],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: const InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                PrioriteTache.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(_getPrioriteTacheText(p)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedPriorite = val);
                              }
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
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(),
                                errorText: _fieldErrors['user'],
                              ),
                              items:
                                  employesDisponibles.map((e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text('${e.prenom} ${e.nom}'),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() => selectedUserId = val);
                              },
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A5298),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _fieldErrors = {};

                                if (_titreController.text.trim().isEmpty) {
                                  _fieldErrors['titre'] = 'Champ obligatoire';
                                }
                                if (_descriptionController.text
                                    .trim()
                                    .isEmpty) {
                                  _fieldErrors['description'] =
                                      'Champ obligatoire';
                                }
                                if (_budgetController.text.trim().isEmpty) {
                                  _fieldErrors['budget'] = 'Champ obligatoire';
                                } else if (double.tryParse(
                                      _budgetController.text,
                                    ) ==
                                    null) {
                                  _fieldErrors['budget'] = 'Nombre invalide';
                                } else if (double.parse(
                                      _budgetController.text,
                                    ) <=
                                    0) {
                                  _fieldErrors['budget'] =
                                      'Le budget doit être positif';
                                }
                                if (selectedUserId == null ||
                                    selectedUserId!.isEmpty) {
                                  _fieldErrors['user'] =
                                      'Veuillez choisir un employé';
                                }

                                if (_fieldErrors.isEmpty) {
                                  final newTache = TacheCreationDTO(
                                    titre: _titreController.text.trim(),
                                    description:
                                        _descriptionController.text.trim(),
                                    priorite: selectedPriorite,
                                    dateCreation: DateTime.now(),
                                    userId: selectedUserId!,
                                    idMission: widget.missionId,
                                    budget: double.parse(
                                      _budgetController.text.trim(),
                                    ),
                                  );
                                  onAdd(newTache);
                                  Navigator.pop(context);
                                }
                              });
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

  void _showUpdateTacheDialog(
    BuildContext context,
    TacheDTO tache,
    Function(TacheUpdateDTO) onUpdate,
  ) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: tache.titre);
    final _descriptionController = TextEditingController(
      text: tache.description,
    );
    final _budgetController = TextEditingController(
      text: tache.budget?.toString() ?? '',
    );

    StatutTache selectedStatut = tache.statutTache ?? StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = tache.priorite ?? PrioriteTache.Moyenne;
    String? selectedUserId = tache.userId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;
    Map<String, String> _fieldErrors = {};

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
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
                        if (employesDisponibles.isNotEmpty &&
                            selectedUserId == null) {
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
                            'Modifier Tâche',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A5298),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['titre'],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['description'],
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                              errorText: _fieldErrors['budget'],
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: const InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                PrioriteTache.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(_getPrioriteTacheText(p)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedPriorite = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<StatutTache>(
                            value: selectedStatut,
                            decoration: const InputDecoration(
                              labelText: 'Statut',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                StatutTache.values.map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(_getStatutTacheText(s)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedStatut = val);
                              }
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
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(),
                                errorText: _fieldErrors['user'],
                              ),
                              items:
                                  employesDisponibles.map((e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text('${e.prenom} ${e.nom}'),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() => selectedUserId = val);
                              },
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A5298),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _fieldErrors = {};

                                if (_titreController.text.trim().isEmpty) {
                                  _fieldErrors['titre'] = 'Champ obligatoire';
                                }
                                if (_descriptionController.text
                                    .trim()
                                    .isEmpty) {
                                  _fieldErrors['description'] =
                                      'Champ obligatoire';
                                }
                                if (double.tryParse(_budgetController.text) ==
                                    null) {
                                  _fieldErrors['budget'] = 'Nombre invalide';
                                } else if (double.parse(
                                      _budgetController.text,
                                    ) <=
                                    0) {
                                  _fieldErrors['budget'] =
                                      'Le budget doit être positif';
                                }
                                if (selectedUserId == null ||
                                    selectedUserId!.isEmpty) {
                                  _fieldErrors['user'] =
                                      'Veuillez choisir un employé';
                                }

                                if (_fieldErrors.isEmpty) {
                                  final updatedTache = TacheUpdateDTO(
                                    titre: _titreController.text.trim(),
                                    description:
                                        _descriptionController.text.trim(),
                                    priorite: selectedPriorite,
                                    userId: selectedUserId!,
                                    budget: double.parse(
                                      _budgetController.text.trim(),
                                    ),
                                    statut: StatutTache.ANNULEE,
                                  );
                                  onUpdate(updatedTache);
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: const Text('Mettre à jour'),
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
    final tacheProvider = context.watch<TacheProvider>();
    final taches = tacheProvider.taches;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches de la mission ${widget.missionId}'),
        backgroundColor: const Color(0xFF2A5298),
      ),
      body:
          taches.isEmpty
              ? const Center(child: Text('Aucune tâche trouvée.'))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                itemCount: taches.length,
                itemBuilder: (context, index) {
                  final tache = taches[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    elevation: 2,
                    child: ListTile(
                      onTap: () => _showTacheDetails(context, tache),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      title: Text(
                        tache.titre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2A5298),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tache.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 16,
                                color: _getPrioriteColor(tache.priorite),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getPrioriteTacheText(tache.priorite),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _getPrioriteColor(tache.priorite),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.info,
                                size: 16,
                                color: _getStatutColor(tache.statutTache),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatutTacheText(tache.statutTache),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _getStatutColor(tache.statutTache),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionIcon(
                            icon: Icons.edit,
                            color: const Color(0xFF2A5298),
                            tooltip: 'Modifier',
                            onPressed:
                                () => _showUpdateTacheDialog(context, tache, (
                                  updatedTache,
                                ) {
                                  tacheProvider.updateTache(
                                    tache.tacheId,
                                    updatedTache,
                                  );
                                }),
                          ),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                            icon: Icons.delete,
                            color: Colors.red,
                            tooltip: 'Supprimer',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'Confirmer la suppression',
                                      ),
                                      content: const Text(
                                        'Voulez-vous vraiment supprimer cette tâche ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Annuler'),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'Supprimer',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirmed == true) {
                                tacheProvider.deleteTache(tache.tacheId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5298),
        onPressed:
            () => _showAddTacheDialog(context, (newTache) {
              tacheProvider.createTache(newTache);
            }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAlphabetically = false;
  bool _ascending = true;
  bool _sortByDateAsc = true;
  StatutTache? _selectedStatutFilter;
  PrioriteTache? _selectedPrioriteFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(() {
      context.read<TacheProvider>().fetchTachesByMissionId(widget.missionId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Color _getPrioriteColor(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return Colors.green;
      case PrioriteTache.Moyenne:
        return Colors.orange;
      case PrioriteTache.Haute:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutColor(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Colors.blue;
      case StatutTache.EN_COURS:
        return Colors.orange;
      case StatutTache.TERMINEE:
        return Colors.green;
      case StatutTache.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tache.titre,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(tache.description),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statut:'),
                  Text(_getStatutTacheText(tache.statutTache),
                      style:
                          TextStyle(color: _getStatutColor(tache.statutTache))),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priorité:'),
                  Text(_getPrioriteTacheText(tache.priorite),
                      style: TextStyle(color: _getPrioriteColor(tache.priorite))),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTache(BuildContext context, TacheDTO tache) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer suppression'),
        content: Text('Supprimer cette tâche ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final tacheProvider = context.read<TacheProvider>();
      await tacheProvider.deleteTache(tache.tacheId);
      await tacheProvider.updateEmployes(widget.missionId);

      if (tacheProvider.updateSuccess == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur mise à jour employés")),
        );
      }
    }
  }

  Future<void> _showAddTacheDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    StatutTache selectedStatut = StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;
    Map<String, String> _fieldErrors = {};

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          if (isLoading && mission != null) {
            missionProvider
                .loadEmployesDisponibles(
                  mission.dateDebutPrevue,
                  mission.dateFinPrevue,
                )
                .then((_) {
              setState(() {
                employesDisponibles = missionProvider.employesDisponibles;
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
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Le budget doit être positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PrioriteTache>(
                        value: selectedPriorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                        ),
                        items: PrioriteTache.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(_getPrioriteTacheText(p)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedPriorite = val);
                          }
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
                          decoration: InputDecoration(
                            labelText: 'Employé assigné *',
                            border: OutlineInputBorder(),
                            errorText: _fieldErrors['user'],
                          ),
                          items: employesDisponibles.map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              child: Text('${e.prenom} ${e.nom}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedUserId = val);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un employé';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5298),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newTache = TacheCreationDTO(
                              titre: _titreController.text.trim(),
                              description: _descriptionController.text.trim(),
                              priorite: selectedPriorite,
                              dateCreation: DateTime.now(),
                              userId: selectedUserId!,
                              idMission: widget.missionId,
                              budget: double.parse(
                                _budgetController.text.trim(),
                              ),
                            );
                            
                            try {
                              await context
                                  .read<TacheProvider>()
                                  .createTache(newTache);
                              await context
                                  .read<TacheProvider>()
                                  .updateEmployes(widget.missionId);

                              if (context
                                      .read<TacheProvider>()
                                      .updateSuccess ==
                                  false) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Erreur lors de la mise à jour des employés"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erreur: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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

    if (result == true) {
      final tacheProvider = context.read<TacheProvider>();
      await tacheProvider.updateEmployes(widget.missionId);
      if (tacheProvider.updateSuccess == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur mise à jour employés")),
        );
      }
    }
  }

  Future<void> _showUpdateTacheDialog(BuildContext context, TacheDTO tache) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: tache.titre);
    final _descriptionController = TextEditingController(text: tache.description);
    final _budgetController = TextEditingController(
      text: tache.budget?.toString() ?? '',
    );

    StatutTache selectedStatut = tache.statutTache ?? StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = tache.priorite ?? PrioriteTache.Moyenne;
    String? selectedUserId = tache.userId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);

    List<UserDTO> employesDisponibles = [];
    bool isLoading = true;
    String? error;
    Map<String, String> _fieldErrors = {};

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          if (isLoading && mission != null) {
            missionProvider
                .loadEmployesDisponibles(
                  mission.dateDebutPrevue,
                  mission.dateFinPrevue,
                )
                .then((_) {
              setState(() {
                employesDisponibles = missionProvider.employesDisponibles;

                // Inclure l'employé déjà assigné même s'il n'est pas dans les disponibles
                if (selectedUserId != null &&
                    !employesDisponibles.any((e) => e.id == selectedUserId)) {
                  final currentUser = mission.employes.firstWhere(
                    (e) => e.id == selectedUserId,
                    orElse: () => UserDTO(
                      id: selectedUserId!,
                      nom: 'Utilisateur actuel',
                      prenom: '',
                      
                      userName: ''
                    ),
                  );
                  if (currentUser != null) {
                    employesDisponibles = [currentUser, ...employesDisponibles];
                  }
                }

                isLoading = false;
                error = missionProvider.error;

                if (employesDisponibles.isNotEmpty && selectedUserId == null) {
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
                        'Modifier Tâche',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A5298),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: OutlineInputBorder(),
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Le budget doit être positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PrioriteTache>(
                        value: selectedPriorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                        ),
                        items: PrioriteTache.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(_getPrioriteTacheText(p)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedPriorite = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<StatutTache>(
                        value: selectedStatut,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                        ),
                        items: StatutTache.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(_getStatutTacheText(s)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedStatut = val);
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
                          decoration: InputDecoration(
                            labelText: 'Employé assigné *',
                            border: OutlineInputBorder(),
                            errorText: _fieldErrors['user'],
                          ),
                          items: employesDisponibles.map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              child: Text('${e.prenom} ${e.nom}'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedUserId = val),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un employé';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5298),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updatedTache = TacheUpdateDTO(
                              titre: _titreController.text.trim(),
                              description: _descriptionController.text.trim(),
                              priorite: selectedPriorite,
                              statut: selectedStatut,
                              userId: selectedUserId!,
                              budget: double.parse(
                                _budgetController.text.trim(),
                              ),
                            );
                            
                            try {
                              await context
                                  .read<TacheProvider>()
                                  .updateTache(tache.tacheId, updatedTache);
                              await context
                                  .read<TacheProvider>()
                                  .updateEmployes(widget.missionId);

                              if (context
                                      .read<TacheProvider>()
                                      .updateSuccess ==
                                  false) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Erreur lors de la mise à jour des employés"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erreur: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Mettre à jour'),
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

    if (result == true) {
      final tacheProvider = context.read<TacheProvider>();
      await tacheProvider.updateEmployes(widget.missionId);
      if (tacheProvider.updateSuccess == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur mise à jour employés")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tacheProvider = context.watch<TacheProvider>();
    final taches = tacheProvider.taches;

    // Filtrage et tri
    final filteredTaches = taches.where((tache) {
      final matchesSearch = _searchQuery.isEmpty ||
          tache.titre.toLowerCase().contains(_searchQuery) ||
          tache.description.toLowerCase().contains(_searchQuery);

      final matchesStatut = _selectedStatutFilter == null ||
          tache.statutTache == _selectedStatutFilter;

      final matchesPriorite = _selectedPrioriteFilter == null ||
          tache.priorite == _selectedPrioriteFilter;

      return matchesSearch && matchesStatut && matchesPriorite;
    }).toList();

    if (_sortAlphabetically) {
      filteredTaches.sort((a, b) =>
          _ascending ? a.titre.compareTo(b.titre) : b.titre.compareTo(a.titre));
    } else {
      filteredTaches.sort((a, b) => _sortByDateAsc
          ? a.dateCreation.compareTo(b.dateCreation)
          : b.dateCreation.compareTo(a.dateCreation));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches Mission #${widget.missionId}'),
        backgroundColor: const Color(0xFF2A5298),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.sort_by_alpha,
                          color: _sortAlphabetically ? Colors.blue : Colors.grey),
                      onPressed: () => setState(() {
                        _sortAlphabetically = true;
                        _ascending = !_ascending;
                      }),
                    ),
                    IconButton(
                      icon: Icon(Icons.date_range,
                          color: !_sortAlphabetically ? Colors.blue : Colors.grey),
                      onPressed: () => setState(() {
                        _sortAlphabetically = false;
                        _sortByDateAsc = !_sortByDateAsc;
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<StatutTache>(
                        value: _selectedStatutFilter,
                        items: [
                          DropdownMenuItem(child: Text('Tous statuts'), value: null),
                          ...StatutTache.values.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(_getStatutTacheText(s)),
                              ))
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStatutFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Filtrer par statut',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<PrioriteTache>(
                        value: _selectedPrioriteFilter,
                        items: [
                          DropdownMenuItem(child: Text('Toutes priorités'), value: null),
                          ...PrioriteTache.values.map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(_getPrioriteTacheText(p)),
                              ))
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedPrioriteFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Filtrer par priorité',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: tacheProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredTaches.isEmpty
                    ? Center(child: Text('Aucune tâche trouvée'))
                    : ListView.builder(
                        itemCount: filteredTaches.length,
                        itemBuilder: (context, index) {
                          final tache = filteredTaches[index];
                          return Card(
                            margin:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(tache.titre),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tache.description,
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(_getStatutTacheText(
                                            tache.statutTache)),
                                        backgroundColor: _getStatutColor(
                                                tache.statutTache)
                                            .withOpacity(0.1),
                                        labelStyle: TextStyle(
                                            color: _getStatutColor(
                                                tache.statutTache)),
                                      ),
                                      SizedBox(width: 8),
                                      Chip(
                                        label: Text(
                                            _getPrioriteTacheText(tache.priorite)),
                                        backgroundColor: _getPrioriteColor(
                                                tache.priorite)
                                            .withOpacity(0.1),
                                        labelStyle: TextStyle(
                                            color:
                                                _getPrioriteColor(tache.priorite)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionIcon(
                                    icon: Icons.edit,
                                    color: Colors.blue,
                                    tooltip: 'Modifier',
                                    onPressed: () =>
                                        _showUpdateTacheDialog(context, tache),
                                  ),
                                  _buildActionIcon(
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    tooltip: 'Supprimer',
                                    onPressed: () =>
                                        _confirmDeleteTache(context, tache),
                                  ),
                                ],
                              ),
                              onTap: () => _showTacheDetails(context, tache),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5298),
        onPressed: () => _showAddTacheDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAlphabetically = false;
  bool _ascending = true;
  bool _sortByDateAsc = true;
  StatutTache? _selectedStatutFilter;
  PrioriteTache? _selectedPrioriteFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTaches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadTaches() async {
    await context.read<TacheProvider>().fetchTachesByMissionId(
      widget.missionId,
    );
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

  Color _getPrioriteColor(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return Colors.green;
      case PrioriteTache.Moyenne:
        return Colors.orange;
      case PrioriteTache.Haute:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutColor(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Colors.blue;
      case StatutTache.EN_COURS:
        return Colors.orange;
      case StatutTache.TERMINEE:
        return Colors.green;
      case StatutTache.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tache.titre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(tache.description),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Statut:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Chip(
                        label: Text(_getStatutTacheText(tache.statutTache)),
                        backgroundColor: _getStatutColor(
                          tache.statutTache,
                        ).withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: _getStatutColor(tache.statutTache),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Priorité:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Chip(
                        label: Text(_getPrioriteTacheText(tache.priorite)),
                        backgroundColor: _getPrioriteColor(
                          tache.priorite,
                        ).withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: _getPrioriteColor(tache.priorite),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _confirmDeleteTache(BuildContext context, TacheDTO tache) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer suppression'),
            content: Text('Voulez-vous vraiment supprimer cette tâche ?'),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final tacheProvider = context.read<TacheProvider>();
      await tacheProvider.deleteTache(tache.tacheId);
      await _loadTaches();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tacheProvider.errorMessage ?? 'Tâche supprimée avec succès'),
            backgroundColor:
                tacheProvider.errorMessage != null ? Colors.red : Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showAddTacheDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    StatutTache selectedStatut = StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              if (isLoading && mission != null) {
                missionProvider
                    .loadEmployesDisponibles(
                      mission.dateDebutPrevue,
                      mission.dateFinPrevue,
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          employesDisponibles =
                              missionProvider.employesDisponibles;
                          isLoading = false;
                          error = missionProvider.error;
                          if (employesDisponibles.isNotEmpty) {
                            selectedUserId = employesDisponibles.first.id;
                          }
                        });
                      }
                    });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle Tâche',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Champ obligatoire'
                                        : null,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Champ obligatoire';
                              final num = double.tryParse(value!);
                              if (num == null) return 'Nombre invalide';
                              if (num <= 0) return 'Doit être positif';
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
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
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedPriorite = val)
                                        : null,
                          ),
                          SizedBox(height: 12),
                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Text(error!, style: TextStyle(color: Colors.red))
                          else
                            DropdownButtonFormField<String>(
                              value: selectedUserId,
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
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
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Choisir un employé'
                                          : null,
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final newTache = TacheCreationDTO(
                                      titre: _titreController.text.trim(),
                                      description:
                                          _descriptionController.text.trim(),
                                      priorite: selectedPriorite,
                                      dateCreation: DateTime.now(),
                                      userId: selectedUserId!,
                                      idMission: widget.missionId,
                                      budget: double.parse(
                                        _budgetController.text.trim(),
                                      ),
                                    );

                                    try {
                                      await context
                                          .read<TacheProvider>()
                                          .createTache(newTache);
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        setState(
                                          () =>
                                              error = 'Erreur: ${e.toString()}',
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2A5298),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text('Ajouter'),
                              ),
                            ],
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

    if (result == true && mounted) {
      await _loadTaches();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tâche créée avec succès')));
      }
    }
  }

  Future<void> _showUpdateTacheDialog(
    BuildContext context,
    TacheDTO tache,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: tache.titre);
    final _descriptionController = TextEditingController(
      text: tache.description,
    );
    final _budgetController = TextEditingController(
      text: tache.budget?.toString() ?? '',
    );

    StatutTache selectedStatut = tache.statutTache ?? StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = tache.priorite ?? PrioriteTache.Moyenne;
    String? selectedUserId = tache.userId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];
    bool isLoading = true;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              if (isLoading && mission != null) {
                missionProvider
                    .loadEmployesDisponibles(
                      mission.dateDebutPrevue,
                      mission.dateFinPrevue,
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          employesDisponibles =
                              missionProvider.employesDisponibles;

                          // Inclure l'employé actuel même s'il n'est plus disponible
                          if (selectedUserId != null &&
                              !employesDisponibles.any(
                                (e) => e.id == selectedUserId,
                              )) {
                            final currentUser = mission.employes.firstWhere(
                              (e) => e.id == selectedUserId,
                              orElse:
                                  () => UserDTO(
                                    id: selectedUserId!,
                                    nom: 'Utilisateur actuel',
                                    prenom: '',
                                    userName: '',
                                  ),
                            );
                            employesDisponibles.insert(0, currentUser);
                          }

                          isLoading = false;
                          error = missionProvider.error;
                        });
                      }
                    });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modifier Tâche',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Champ obligatoire'
                                        : null,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Champ obligatoire';
                              final num = double.tryParse(value!);
                              if (num == null) return 'Nombre invalide';
                              if (num <= 0) return 'Doit être positif';
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
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
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedPriorite = val)
                                        : null,
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<StatutTache>(
                            value: selectedStatut,
                            decoration: InputDecoration(
                              labelText: 'Statut',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items:
                                StatutTache.values
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(_getStatutTacheText(s)),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedStatut = val)
                                        : null,
                          ),
                          SizedBox(height: 12),
                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Text(error!, style: TextStyle(color: Colors.red))
                          else
                            DropdownButtonFormField<String>(
                              value: selectedUserId,
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
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
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Choisir un employé'
                                          : null,
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final updatedTache = TacheUpdateDTO(
                                      titre: _titreController.text.trim(),
                                      description:
                                          _descriptionController.text.trim(),
                                      priorite: selectedPriorite,
                                      statut: selectedStatut,
                                      userId: selectedUserId!,
                                      budget: double.parse(
                                        _budgetController.text.trim(),
                                      ),
                                    );

                                    try {
                                      await context
                                          .read<TacheProvider>()
                                          .updateTache(
                                            tache.tacheId,
                                            updatedTache,
                                          );
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        setState(
                                          () =>
                                              error = 'Erreur: ${e.toString()}',
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2A5298),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text('Mettre à jour'),
                              ),
                            ],
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

    if (result == true && mounted) {
      await _loadTaches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tâche mise à jour avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tacheProvider = context.watch<TacheProvider>();
    final taches = tacheProvider.taches;

    // Filtrage et tri
    final filteredTaches =
        taches.where((tache) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              tache.titre.toLowerCase().contains(_searchQuery) ||
              tache.description.toLowerCase().contains(_searchQuery);

          final matchesStatut =
              _selectedStatutFilter == null ||
              tache.statutTache == _selectedStatutFilter;

          final matchesPriorite =
              _selectedPrioriteFilter == null ||
              tache.priorite == _selectedPrioriteFilter;

          return matchesSearch && matchesStatut && matchesPriorite;
        }).toList();

    if (_sortAlphabetically) {
      filteredTaches.sort(
        (a, b) =>
            _ascending
                ? a.titre.compareTo(b.titre)
                : b.titre.compareTo(a.titre),
      );
    } else {
      filteredTaches.sort(
        (a, b) =>
            _sortByDateAsc
                ? a.dateCreation.compareTo(b.dateCreation)
                : b.dateCreation.compareTo(a.dateCreation),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches Mission #${widget.missionId}'),
        backgroundColor: Color(0xFF2A5298),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher',
                          hintText: 'Rechercher par titre ou description',
                          prefixIcon: Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Tooltip(
                      message: 'Ajouter une tâche',
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () => _showAddTacheDialog(context),
                        child: Icon(Icons.add, size: 20),
                        backgroundColor: Color(0xFF2A5298),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message:
                            'Trier par ${_sortAlphabetically ? 'titre' : 'date'} ${_sortAlphabetically ? (_ascending ? 'A-Z' : 'Z-A') : (_sortByDateAsc ? 'anciennes' : 'récentes')}',
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              if (_sortAlphabetically) {
                                _ascending = !_ascending;
                              } else {
                                _sortByDateAsc = !_sortByDateAsc;
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _sortAlphabetically
                                    ? Icons.sort_by_alpha
                                    : Icons.date_range,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _sortAlphabetically
                                    ? (_ascending ? 'A-Z' : 'Z-A')
                                    : (_sortByDateAsc
                                        ? 'Anciennes'
                                        : 'Récentes'),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<StatutTache>(
                        value: _selectedStatutFilter,
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'Tous statuts',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: null,
                          ),
                          ...StatutTache.values.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                _getStatutTacheText(s),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _selectedStatutFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 12),
                        iconSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<PrioriteTache>(
                        value: _selectedPrioriteFilter,
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'Toutes priorités',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: null,
                          ),
                          ...PrioriteTache.values.map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                _getPrioriteTacheText(p),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _selectedPrioriteFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 12),
                        iconSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                tacheProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredTaches.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Aucune tâche trouvée'),
                          if (_searchQuery.isNotEmpty ||
                              _selectedStatutFilter != null ||
                              _selectedPrioriteFilter != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedStatutFilter = null;
                                  _selectedPrioriteFilter = null;
                                });
                              },
                              child: Text('Réinitialiser les filtres'),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(bottom: 80),
                      itemCount: filteredTaches.length,
                      itemBuilder: (context, index) {
                        final tache = filteredTaches[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _showTacheDetails(context, tache),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tache.titre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildActionIcon(
                                            icon: Icons.edit,
                                            color: Colors.blue.shade600,
                                            tooltip: 'Modifier',
                                            onPressed:
                                                () => _showUpdateTacheDialog(
                                                  context,
                                                  tache,
                                                ),
                                          ),
                                          _buildActionIcon(
                                            icon: Icons.delete,
                                            color: Colors.red.shade600,
                                            tooltip: 'Supprimer',
                                            onPressed:
                                                () => _confirmDeleteTache(
                                                  context,
                                                  tache,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  if (tache.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        tache.description,
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          _getStatutTacheText(
                                            tache.statutTache,
                                          ),
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: _getStatutColor(
                                          tache.statutTache,
                                        ).withOpacity(0.1),
                                        labelStyle: TextStyle(
                                          color: _getStatutColor(
                                            tache.statutTache,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 0,
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      SizedBox(width: 6),
                                      Chip(
                                        label: Text(
                                          _getPrioriteTacheText(tache.priorite),
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: _getPrioriteColor(
                                          tache.priorite,
                                        ).withOpacity(0.1),
                                        labelStyle: TextStyle(
                                          color: _getPrioriteColor(
                                            tache.priorite,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 0,
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Spacer(),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(tache.dateCreation),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StatutTache? _selectedStatutFilter;
  PrioriteTache? _selectedPrioriteFilter;
  bool _sortAscending = true;
  String _sortColumn = 'dateCreation';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadTaches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTaches() async {
    await context.read<TacheProvider>().fetchTachesByMissionId(
      widget.missionId,
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

  Color _getPrioriteColor(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return Colors.green;
      case PrioriteTache.Moyenne:
        return Colors.orange;
      case PrioriteTache.Haute:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutColor(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Colors.blue;
      case StatutTache.EN_COURS:
        return Colors.orange;
      case StatutTache.TERMINEE:
        return Colors.green;
      case StatutTache.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tache.titre,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.description,
                    'Description',
                    tache.description,
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date création',
                    _formatDate(tache.dateCreation),
                  ),
                  if (tache.dateRealisation != null) ...[
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event_available,
                      'Date réalisation',
                      _formatDate(tache.dateRealisation!),
                    ),
                  ],
                  SizedBox(height: 12),
                  _buildStatusRow(tache),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2A5298),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(TacheDTO tache) {
    return Row(
      children: [
        _buildStatusChip(
          icon: Icons.flag,
          label: _getStatutTacheText(tache.statutTache),
          color: _getStatutColor(tache.statutTache),
        ),
        SizedBox(width: 12),
        _buildStatusChip(
          icon: Icons.priority_high,
          label: _getPrioriteTacheText(tache.priorite),
          color: _getPrioriteColor(tache.priorite),
        ),
        Spacer(),
        if (tache.budget != null)
          Chip(
            label: Text('${tache.budget!.toStringAsFixed(2)} Dt'),
            backgroundColor: Colors.grey.shade100,
          ),
      ],
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Future<void> _showAddTacheDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    StatutTache selectedStatut = StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];

    bool isLoading = true;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              if (isLoading && mission != null) {
                missionProvider
                    .loadEmployesDisponibles(
                      mission.dateDebutPrevue,
                      mission.dateFinPrevue,
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          employesDisponibles =
                              missionProvider.employesDisponibles;
                          isLoading = false;
                          error = missionProvider.error;
                          if (employesDisponibles.isNotEmpty) {
                            selectedUserId = employesDisponibles.first.id;
                          }
                        });
                      }
                    });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle Tâche',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Ce champ est obligatoire'
                                        : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Ce champ est obligatoire';
                              final num = double.tryParse(value!);
                              if (num == null) return 'Nombre invalide';
                              if (num <= 0) return 'Doit être positif';
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
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
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedPriorite = val)
                                        : null,
                          ),
                          SizedBox(height: 16),
                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Text(error!, style: TextStyle(color: Colors.red))
                          else
                            DropdownButtonFormField<String>(
                              value: selectedUserId,
                              decoration: InputDecoration(
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
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Choisir un employé'
                                          : null,
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final newTache = TacheCreationDTO(
                                      titre: _titreController.text.trim(),
                                      description:
                                          _descriptionController.text.trim(),
                                      priorite: selectedPriorite,
                                      dateCreation: DateTime.now(),
                                      userId: selectedUserId!,
                                      idMission: widget.missionId,
                                      budget: double.parse(
                                        _budgetController.text.trim(),
                                      ),
                                    );

                                    try {
                                      await context
                                          .read<TacheProvider>()
                                          .createTache(newTache);
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        setState(
                                          () =>
                                              error = 'Erreur: ${e.toString()}',
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2A5298),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text('Ajouter'),
                              ),
                            ],
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

    if (result == true && mounted) {
      await _loadTaches();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tâche créée avec succès')));
      }
    }
  }

  Future<void> _showUpdateTacheDialog(
    BuildContext context,
    TacheDTO tache,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: tache.titre);
    final _descriptionController = TextEditingController(
      text: tache.description,
    );
    final _budgetController = TextEditingController(
      text: tache.budget?.toString() ?? '',
    );

    StatutTache selectedStatut = tache.statutTache ?? StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = tache.priorite ?? PrioriteTache.Moyenne;
    String? selectedUserId = tache.userId;

    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = [];
    bool isLoading = true;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              if (isLoading && mission != null) {
                missionProvider
                    .loadEmployesDisponibles(
                      mission.dateDebutPrevue,
                      mission.dateFinPrevue,
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          employesDisponibles =
                              missionProvider.employesDisponibles;

                          // Inclure l'employé actuel même s'il n'est plus disponible
                          if (selectedUserId != null &&
                              !employesDisponibles.any(
                                (e) => e.id == selectedUserId,
                              )) {
                            final currentUser = mission.employes.firstWhere(
                              (e) => e.id == selectedUserId,
                              orElse:
                                  () => UserDTO(
                                    id: selectedUserId!,
                                    nom: 'Utilisateur actuel',
                                    prenom: '',
                                    userName: '',
                                  ),
                            );
                            employesDisponibles.insert(0, currentUser);
                          }

                          isLoading = false;
                          error = missionProvider.error;
                        });
                      }
                    });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modifier Tâche',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Ce champ est obligatoire'
                                        : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Ce champ est obligatoire';
                              final num = double.tryParse(value!);
                              if (num == null) return 'Nombre invalide';
                              if (num <= 0) return 'Doit être positif';
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
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
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedPriorite = val)
                                        : null,
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<StatutTache>(
                            value: selectedStatut,
                            decoration: InputDecoration(
                              labelText: 'Statut',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                StatutTache.values
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(_getStatutTacheText(s)),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) =>
                                    val != null
                                        ? setState(() => selectedStatut = val)
                                        : null,
                          ),
                          SizedBox(height: 16),
                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Text(error!, style: TextStyle(color: Colors.red))
                          else
                            DropdownButtonFormField<String>(
                              value: selectedUserId,
                              decoration: InputDecoration(
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
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Choisir un employé'
                                          : null,
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final updatedTache = TacheUpdateDTO(
                                      titre: _titreController.text.trim(),
                                      description:
                                          _descriptionController.text.trim(),
                                      priorite: selectedPriorite,
                                      statut: selectedStatut,
                                      userId: selectedUserId!,
                                      budget: double.parse(
                                        _budgetController.text.trim(),
                                      ),
                                    );

                                    try {
                                      await context
                                          .read<TacheProvider>()
                                          .updateTache(
                                            tache.tacheId,
                                            updatedTache,
                                          );
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        setState(
                                          () =>
                                              error = 'Erreur: ${e.toString()}',
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2A5298),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text('Mettre à jour'),
                              ),
                            ],
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

    if (result == true && mounted) {
      await _loadTaches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tâche mise à jour avec succès')),
        );
      }
    }
  }

  List<TacheDTO> _filterAndSortTaches(List<TacheDTO> taches) {
    // Filtrage
    var filtered =
        taches.where((tache) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              tache.titre.toLowerCase().contains(_searchQuery) ||
              tache.description.toLowerCase().contains(_searchQuery);

          final matchesStatut =
              _selectedStatutFilter == null ||
              tache.statutTache == _selectedStatutFilter;

          final matchesPriorite =
              _selectedPrioriteFilter == null ||
              tache.priorite == _selectedPrioriteFilter;

          return matchesSearch && matchesStatut && matchesPriorite;
        }).toList();

    // Tri
    filtered.sort((a, b) {
      var aValue, bValue;
      switch (_sortColumn) {
        case 'titre':
          aValue = a.titre.toLowerCase();
          bValue = b.titre.toLowerCase();
          break;
        case 'dateCreation':
          aValue = a.dateCreation;
          bValue = b.dateCreation;
          break;
        case 'priorite':
          aValue = a.priorite?.index ?? 0;
          bValue = b.priorite?.index ?? 0;
          break;
        case 'statut':
          aValue = a.statutTache?.index ?? 0;
          bValue = b.statutTache?.index ?? 0;
          break;
        default:
          aValue = a.dateCreation;
          bValue = b.dateCreation;
      }

      if (aValue == bValue) return 0;
      if (_sortAscending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });

    return filtered;
  }

  Widget _buildHeaderCell(String label, String columnName) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_sortColumn == columnName) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumn = columnName;
            _sortAscending = true;
          }
        });
      },
      child: Row(
        children: [
          Text(label),
          if (_sortColumn == columnName)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tacheProvider = context.watch<TacheProvider>();
    final taches = _filterAndSortTaches(tacheProvider.taches);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches Mission #${widget.missionId}'),
        backgroundColor: Color(0xFF2A5298),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    FloatingActionButton(
                      heroTag: 'addTache',
                      mini: true,
                      onPressed: () => _showAddTacheDialog(context),
                      child: Icon(Icons.add),
                      backgroundColor: Color(0xFF2A5298),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<StatutTache>(
                        value: _selectedStatutFilter,
                        items: [
                          DropdownMenuItem(
                            child: Text('Tous statuts'),
                            value: null,
                          ),
                          ...StatutTache.values.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_getStatutTacheText(s)),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _selectedStatutFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Filtrer par statut',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PrioriteTache>(
                        value: _selectedPrioriteFilter,
                        items: [
                          DropdownMenuItem(
                            child: Text('Toutes priorités'),
                            value: null,
                          ),
                          ...PrioriteTache.values.map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(_getPrioriteTacheText(p)),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _selectedPrioriteFilter = value),
                        decoration: InputDecoration(
                          labelText: 'Filtrer par priorité',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                tacheProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : taches.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucune tâche trouvée'),
                          if (_searchQuery.isNotEmpty ||
                              _selectedStatutFilter != null ||
                              _selectedPrioriteFilter != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedStatutFilter = null;
                                  _selectedPrioriteFilter = null;
                                });
                              },
                              child: Text('Réinitialiser les filtres'),
                            ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: _buildHeaderCell('Titre', 'titre')),
                          DataColumn(
                            label: _buildHeaderCell('Statut', 'statut'),
                          ),
                          DataColumn(
                            label: _buildHeaderCell('Priorité', 'priorite'),
                          ),
                          DataColumn(
                            label: _buildHeaderCell(
                              'Date création',
                              'dateCreation',
                            ),
                          ),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows:
                            taches.map((tache) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Tooltip(
                                      message: tache.titre,
                                      child: Text(
                                        tache.titre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onTap:
                                        () => _showTacheDetails(context, tache),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        _getStatutTacheText(tache.statutTache),
                                        style: TextStyle(
                                          color: _getStatutColor(
                                            tache.statutTache,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: _getStatutColor(
                                        tache.statutTache,
                                      ).withOpacity(0.1),
                                    ),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        _getPrioriteTacheText(tache.priorite),
                                        style: TextStyle(
                                          color: _getPrioriteColor(
                                            tache.priorite,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: _getPrioriteColor(
                                        tache.priorite,
                                      ).withOpacity(0.1),
                                    ),
                                  ),
                                  DataCell(
                                    Text(_formatDate(tache.dateCreation)),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        _buildActionIcon(
                                          icon: Icons.edit,
                                          color: Colors.blue,
                                          tooltip: 'Modifier',
                                          onPressed:
                                              () => _showUpdateTacheDialog(
                                                context,
                                                tache,
                                              ),
                                        ),
                                        _buildActionIcon(
                                          icon: Icons.delete,
                                          color: Colors.red,
                                          tooltip: 'Supprimer',
                                          onPressed: () => (context, tache),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}*/ */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/NotificationCreateDTO.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/UserDto.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/NotificationService.dart';
import 'package:testfront/core/services/signalr_client.dart';
import 'package:testfront/features/mission/DepensesParTacheScreen.dart';
import 'package:testfront/features/mission/web/DepensePartacheEmployeWeb.dart';

class TachesParMissionScreen extends StatefulWidget {
  final int missionId;

  const TachesParMissionScreen({Key? key, required this.missionId})
    : super(key: key);

  @override
  _TachesParMissionScreenState createState() => _TachesParMissionScreenState();
}

class _TachesParMissionScreenState extends State<TachesParMissionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _itemsPerPage = 2;

  // Variables pour les filtres et tris
  StatutTache? _selectedStatutFilter;
  PrioriteTache? _selectedPrioriteFilter;
  bool _sortByDateAsc = true;
  bool _ascending = true;
  bool _sortAlphabetically = false;

  // Styles constants
  final _dialogButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2A5298),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  final _dialogDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TacheProvider>().fetchTachesByMissionId(widget.missionId);

      // Charger les employés disponibles
      _loadEmployesDisponibles();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _updateDepenseEtTotal() async {
    final tacheProvider = Provider.of<TacheProvider>(context, listen: false);
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );

    //final missionId = tacheProvider.selectedTache?.missionId;
    await tacheProvider.fetchTotalDepensesMission(widget.missionId);
    await tacheProvider.chargerTotalBudget(widget.missionId);
    await tacheProvider.fetchTotalDepensesTache(
      tacheProvider.selectedTache!.tacheId,
    );
  }

  Future<void> _loadEmployesDisponibles() async {
    final mission = await context.read<MissionProvider>().getMissionById(
      widget.missionId,
    );
    if (mission != null &&
        mission.dateDebutPrevue != null &&
        mission.dateFinPrevue != null) {
      await context.read<TacheProvider>().loadEmployesDisponibles(
        mission.dateDebutPrevue!,
        mission.dateFinPrevue!,
        missionId: widget.missionId,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      case StatutTache.ENCOURS:
        return 'En cours';
      case StatutTache.TERMINEE:
        return 'Terminée';
      case StatutTache.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Color _getPrioriteColor(PrioriteTache? priorite) {
    switch (priorite) {
      case PrioriteTache.Basse:
        return Colors.green;
      case PrioriteTache.Moyenne:
        return Colors.orange;
      case PrioriteTache.Haute:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutColor(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Colors.blue;
      case StatutTache.ENCOURS:
        return Colors.orange;
      case StatutTache.TERMINEE:
        return Colors.green;
      case StatutTache.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatutIcon(StatutTache? statut) {
    switch (statut) {
      case StatutTache.PLANIFIEE:
        return Icons.schedule;
      case StatutTache.ENCOURS:
        return Icons.timelapse;
      case StatutTache.TERMINEE:
        return Icons.check_circle;
      case StatutTache.ANNULEE:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getNomEmploye(String? employeId) {
    final employes = context.read<TacheProvider>().employesDisponibles;
    final user = employes.firstWhere(
      (e) => e.id == employeId,
      orElse: () => UserDTO(id: '', nom: 'Inconnu', prenom: '', userName: ""),
    );
    return '${user.prenom} ${user.nom}';
  }

  Future<void> _handleAddTache(TacheCreationDTO dto) async {
    final tacheProvider = context.read<TacheProvider>();
    await tacheProvider.createTache(dto);
    await tacheProvider.fetchTachesByMissionId(widget.missionId);
    await tacheProvider.updateEmployes(widget.missionId);
  }

  Future<void> _handleEditTache(TacheDTO tache, TacheUpdateDTO update) async {
    final tacheProvider = context.read<TacheProvider>();
    await tacheProvider.updateTache(tache.tacheId, update);
    await tacheProvider.fetchTachesByMissionId(widget.missionId);
    await tacheProvider.updateEmployes(widget.missionId);
  }

  Future<void> _handleDeleteTache(int idTache) async {
    final tacheProvider = context.read<TacheProvider>();
    await tacheProvider.deleteTache(idTache);
    await tacheProvider.fetchTachesByMissionId(widget.missionId);
    await tacheProvider.updateEmployes(widget.missionId);
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

  Widget _buildStatusBadge(StatutTache? statut) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatutColor(statut).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatutColor(statut), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatutIcon(statut),
            size: 18,
            color: _getStatutColor(statut),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatutTacheText(statut),
            style: TextStyle(
              color: _getStatutColor(statut),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  void _showDeleteDialog(int idTache) {
    showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: _dialogDecoration,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmer la suppression',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Voulez-vous vraiment supprimer cette tâche ?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: _dialogButtonStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.red,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final tacheProvider = context.read<TacheProvider>();
        final success = await tacheProvider.deleteTache(idTache);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche supprimée avec succès')),
          );
          // Recharger les tâches après suppression
          await tacheProvider.fetchTachesByMissionId(widget.missionId);
          _updateDepenseEtTotal();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la suppression')),
          );
        }
      }
    });
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
              decoration: _dialogDecoration,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
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

                    // Contenu responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;

                        if (isSmallScreen) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeftColumn(tache),
                              const SizedBox(height: 16),
                              _buildRightColumn(tache),
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildLeftColumn(tache)),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: _buildRightColumn(tache),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Bouton Fermer
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: _dialogButtonStyle.copyWith(
                          minimumSize: MaterialStateProperty.all(
                            const Size(150, 50),
                          ),
                        ),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLeftColumn(TacheDTO tache) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBadge(tache.statutTache),
        const SizedBox(height: 20, width: 10),
        _buildMetaDataCard(
          icon: Icons.priority_high,
          title: 'Priorité',
          value: _getPrioriteTacheText(tache.priorite),
          color: _getPrioriteColor(tache.priorite),
        ),
        _buildDetailCard(
          icon: Icons.description,
          title: 'Description',
          content: tache.description ?? 'Aucune description',
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.calendar_today,
          title: 'Date de création',
          content: _formatDate(tache.dateCreation),
        ),
        if (tache.dateRealisation != null) ...[
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.event_available,
            title: 'Date de réalisation',
            content: _formatDate(tache.dateRealisation!),
          ),
        ],
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.attach_money,
          title: 'Budget',
          content: '${tache.budget.toStringAsFixed(3)} Dt',
        ),
        if (tache.depenses != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              // Carte des dépenses
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.mobile_friendly_rounded,
                  title: 'Dépenses',
                  content: '${tache.depenses?.toStringAsFixed(3)} Dt',
                ),
              ),
              const SizedBox(width: 8),
              // Icône vers DepensesParTacheScreen
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Voir les détails des dépenses',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DepensesParTacheScreenAdmin(
                            tacheId: tache.tacheId,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRightColumn(TacheDTO tache) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildMetaDataCard(
          icon: Icons.person,
          title: 'Assignée à',
          value: _getNomEmploye(tache.userId),
        ),
      ],
    );
  }

  Future<void> _showAddTacheDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    StatutTache selectedStatut = StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = PrioriteTache.Moyenne;
    String? selectedUserId;

    final tacheProvider = context.read<TacheProvider>();
    final missionProvider = context.read<MissionProvider>();
    final mission = await missionProvider.getMissionById(widget.missionId);
    List<UserDTO> employesDisponibles = tacheProvider.employesDisponibles;

    bool isLoading = false;
    String? error;
    Map<String, String> _fieldErrors = {};

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final isMobile = MediaQuery.of(context).size.width < 600;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                child: Container(
                  width:
                      isMobile
                          ? double.infinity
                          : 400, // limite largeur sur grand écran
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nouvelle Tâche',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2A5298),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Titre
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['titre'],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['description'],
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Budget
                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['budget'],
                              prefixIcon: const Icon(Icons.attach_money),
                              suffixText: 'DT',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Priorité
                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items:
                                PrioriteTache.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(_getPrioriteTacheText(p)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => selectedPriorite = val);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Employé assigné
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
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorText: _fieldErrors['user'],
                              ),
                              items:
                                  employesDisponibles.map((e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text('${e.prenom} ${e.nom}'),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A5298),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.blue.withOpacity(0.3),
                                  ),
                                  onPressed: () {
                                    _updateDepenseEtTotal();

                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Annuler',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A5298),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.blue.withOpacity(0.3),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _fieldErrors = {};

                                      if (_titreController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['titre'] =
                                            'Champ obligatoire';
                                      }
                                      if (_descriptionController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['description'] =
                                            'Champ obligatoire';
                                      }
                                      if (_budgetController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['budget'] =
                                            'Champ obligatoire';
                                      } else if (double.tryParse(
                                            _budgetController.text,
                                          ) ==
                                          null) {
                                        _fieldErrors['budget'] =
                                            'Nombre invalide';
                                      } else if (double.parse(
                                            _budgetController.text,
                                          ) <=
                                          0) {
                                        _fieldErrors['budget'] =
                                            'Le budget doit être positif';
                                      }
                                      if (selectedUserId == null ||
                                          selectedUserId!.isEmpty) {
                                        _fieldErrors['user'] =
                                            'Veuillez choisir un employé';
                                      }

                                      if (_fieldErrors.isEmpty) {
                                        final newTache = TacheCreationDTO(
                                          titre: _titreController.text.trim(),
                                          description:
                                              _descriptionController.text
                                                  .trim(),
                                          priorite: selectedPriorite,
                                          dateCreation: DateTime.now(),
                                          userId: selectedUserId!,
                                          idMission: widget.missionId,
                                          budget: double.parse(
                                            _budgetController.text.trim(),
                                          ),
                                        );
                                        _handleAddTache(newTache);
                                        Navigator.pop(context);

                                        tacheProvider.updateEmployes(
                                          widget.missionId,
                                        );
                                        _updateDepenseEtTotal();

                                        missionProvider.loadMissions();
                                        _updateDepenseEtTotal();
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.save,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ajouter',
                                        style: GoogleFonts.poppins(
                                          color:
                                              Colors
                                                  .white, // important si le bouton est foncé
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
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
            },
          ),
    );
  }

  Future<void> _showUpdateTacheDialog(
    BuildContext context,
    TacheDTO tache,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: tache.titre);
    final _descriptionController = TextEditingController(
      text: tache.description ?? '',
    );
    final _budgetController = TextEditingController(
      text: tache.budget.toString(),
    );

    StatutTache selectedStatut = tache.statutTache ?? StatutTache.PLANIFIEE;
    PrioriteTache selectedPriorite = tache.priorite ?? PrioriteTache.Moyenne;
    String? selectedUserId = tache.userId;

    final tacheProvider = context.read<TacheProvider>();
    List<UserDTO> employesDisponibles = tacheProvider.employesDisponibles;

    bool isLoading = false;
    String? error;
    Map<String, String> _fieldErrors = {};
    final missionProvider = context.read<MissionProvider>();
    final mission = await missionProvider.getMissionById(widget.missionId);

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final isMobile = MediaQuery.of(context).size.width < 600;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                child: Container(
                  width: isMobile ? double.infinity : 400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Modifier Tâche',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2A5298),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // CHAMPS FORMULAIRES
                          TextFormField(
                            controller: _titreController,
                            decoration: InputDecoration(
                              labelText: 'Titre *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['titre'],
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['description'],
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _fieldErrors['budget'],
                              prefixIcon: const Icon(Icons.attach_money),
                              suffixText: 'DT',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<PrioriteTache>(
                            value: selectedPriorite,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items:
                                PrioriteTache.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(_getPrioriteTacheText(p)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => selectedPriorite = val);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Sélection employé
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
                              decoration: InputDecoration(
                                labelText: 'Employé assigné *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorText: _fieldErrors['user'],
                              ),
                              items:
                                  employesDisponibles.map((e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text('${e.prenom} ${e.nom}'),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) => setState(() => selectedUserId = val),
                            ),

                          const SizedBox(height: 24),

                          // BOUTONS ACTION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A5298),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Annuler',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A5298),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.blue.withOpacity(0.3),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _fieldErrors = {};
                                      if (_titreController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['titre'] =
                                            'Champ obligatoire';
                                      }
                                      if (_descriptionController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['description'] =
                                            'Champ obligatoire';
                                      }
                                      if (_budgetController.text
                                          .trim()
                                          .isEmpty) {
                                        _fieldErrors['budget'] =
                                            'Champ obligatoire';
                                      } else if (double.tryParse(
                                            _budgetController.text,
                                          ) ==
                                          null) {
                                        _fieldErrors['budget'] =
                                            'Nombre invalide';
                                      } else if (double.parse(
                                            _budgetController.text,
                                          ) <=
                                          0) {
                                        _fieldErrors['budget'] =
                                            'Le budget doit être positif';
                                      }
                                      if (selectedUserId == null ||
                                          selectedUserId!.isEmpty) {
                                        _fieldErrors['user'] =
                                            'Veuillez choisir un employé';
                                      }
                                    });

                                    if (_fieldErrors.isEmpty) {
                                      final updatedTache = TacheUpdateDTO(
                                        titre: _titreController.text.trim(),
                                        description:
                                            _descriptionController.text.trim(),
                                        priorite: selectedPriorite,
                                        statut: selectedStatut,
                                        userId: selectedUserId!,
                                        budget: double.parse(
                                          _budgetController.text.trim(),
                                        ),
                                      );

                                      _handleEditTache(tache, updatedTache);
                                      Navigator.pop(context);

                                      tacheProvider.loadDepensesMission(
                                        widget.missionId,
                                      );
                                      tacheProvider.updateEmployes(
                                        widget.missionId,
                                      );
                                      _updateDepenseEtTotal();
                                      tacheProvider.chargerTotalBudget(
                                        widget.missionId,
                                      );
                                      missionProvider.loadMissions();

                                      final notificationDTO = NotificationCreateDTO(
                                        title: 'Tâche mise à jour',
                                        message:
                                            'Votre tâche "${updatedTache.titre}" a été modifiée.',
                                        userId: updatedTache.userId.toString(),
                                      );

                                      /* final createResponse =
                                  await notificationService.createNotification(notificationDTO);

                              if (createResponse.success && createResponse.data != null) {
                                await signalRService.sendNotification(
                                  notificationDTO.userId,
                                  createResponse.data!,
                                );
                              }*/
                                    }
                                  },
                                  child: Text(
                                    'Mettre à jour',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
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
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tacheProvider = context.watch<TacheProvider>();
    final taches = tacheProvider.taches;

    // Filtrage des tâches
    final filteredTaches =
        taches
            .where(
              (tache) =>
                  tache.titre.toLowerCase().contains(_searchQuery) ||
                  (tache.description?.toLowerCase().contains(_searchQuery) ??
                      false),
            )
            .where(
              (tache) =>
                  _selectedStatutFilter == null ||
                  tache.statutTache == _selectedStatutFilter,
            )
            .where(
              (tache) =>
                  _selectedPrioriteFilter == null ||
                  tache.priorite == _selectedPrioriteFilter,
            )
            .toList();

    // Tri principal par statut
    filteredTaches.sort(
      (a, b) =>
          (a.statutTache?.index ?? 0).compareTo(b.statutTache?.index ?? 0),
    );

    // Ensuite par priorité
    filteredTaches.sort(
      (a, b) => (b.priorite?.index ?? 0).compareTo(a.priorite?.index ?? 0),
    );

    // Tri optionnel par titre ou date
    if (_sortAlphabetically) {
      filteredTaches.sort((a, b) {
        final titleComparison = a.titre.compareTo(b.titre);
        return _ascending ? titleComparison : -titleComparison;
      });
    } else {
      filteredTaches.sort((a, b) {
        final dateComparison = a.dateCreation.compareTo(b.dateCreation);
        return _sortByDateAsc ? dateComparison : -dateComparison;
      });
    }
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );
    final MissionDTO? m = missionProvider.getMissionById(widget.missionId);

    // Pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedTaches = filteredTaches.sublist(
      startIndex,
      endIndex < filteredTaches.length ? endIndex : filteredTaches.length,
    );
    if (m == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mission introuvable')),
        body: const Center(child: Text('Aucune mission trouvée avec cet ID')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches de la mission ${m.titre}'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<TacheProvider>().fetchTachesByMissionId(
                widget.missionId,
              );
              _loadEmployesDisponibles();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Ligne supérieure avec recherche et bouton Ajouter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Champ de recherche avec largeur fixe
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Rechercher',
                          labelStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Bouton Ajouter avec icône et texte
                    ElevatedButton.icon(
                      onPressed:
                          (m.statut == StatutMission.TERMINEE ||
                                  m.statut == StatutMission.ANNULEE)
                              ? null
                              : () => _showAddTacheDialog(context),
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
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Ajouter Tâche",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Filtres et tris
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 150,
                        maxWidth: 400,
                      ),
                      child: DropdownButtonFormField<StatutTache?>(
                        value: _selectedStatutFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filtrer par statut',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<StatutTache?>(
                            value: null,
                            child: Text('Tous les statuts'),
                          ),
                          ...StatutTache.values.map((statut) {
                            return DropdownMenuItem<StatutTache?>(
                              value: statut,
                              child: Text(_getStatutTacheText(statut)),
                            );
                          }).toList(),
                        ],
                        onChanged: (StatutTache? value) {
                          setState(() {
                            _selectedStatutFilter = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 150,
                        maxWidth: 400,
                      ),
                      child: DropdownButtonFormField<PrioriteTache?>(
                        value: _selectedPrioriteFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filtrer par priorité',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<PrioriteTache?>(
                            value: null,
                            child: Text('Toutes les priorités'),
                          ),
                          ...PrioriteTache.values.map((priorite) {
                            return DropdownMenuItem<PrioriteTache?>(
                              value: priorite,
                              child: Text(_getPrioriteTacheText(priorite)),
                            );
                          }).toList(),
                        ],
                        onChanged: (PrioriteTache? value) {
                          setState(() {
                            _selectedPrioriteFilter = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.sort_by_alpha,
                        color:
                            _sortAlphabetically
                                ? const Color(0xFF2A5298)
                                : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAlphabetically = true;
                          _ascending = !_ascending;
                          _currentPage = 1;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.date_range,
                        color:
                            !_sortAlphabetically
                                ? const Color(0xFF2A5298)
                                : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAlphabetically = false;
                          _sortByDateAsc = !_sortByDateAsc;
                          _currentPage = 1;
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
                tacheProvider.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2A5298),
                        ),
                      ),
                    )
                    : filteredTaches.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.task,
                            size: 64,
                            color: Color(0xFF2A5298),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune tâche trouvée',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedStatutFilter != null ||
                              _selectedPrioriteFilter != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedStatutFilter = null;
                                  _selectedPrioriteFilter = null;
                                });
                              },
                              child: const Text('Réinitialiser les filtres'),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: paginatedTaches.length,
                      itemBuilder: (context, index) {
                        final tache = paginatedTaches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showTacheDetails(context, tache),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tache.titre,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2A5298),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: Colors.blue,
                                            onPressed:
                                                () => _showUpdateTacheDialog(
                                                  context,
                                                  tache,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _showDeleteDialog(
                                                  tache.tacheId,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (tache.description != null &&
                                      tache.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        tache.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          _getStatutTacheText(
                                            tache.statutTache,
                                          ),
                                          style: TextStyle(
                                            color: _getStatutColor(
                                              tache.statutTache,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: _getStatutColor(
                                          tache.statutTache,
                                        ).withOpacity(0.1),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(
                                          _getPrioriteTacheText(tache.priorite),
                                          style: TextStyle(
                                            color: _getPrioriteColor(
                                              tache.priorite,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: _getPrioriteColor(
                                          tache.priorite,
                                        ).withOpacity(0.1),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDate(tache.dateCreation),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (filteredTaches.length > _itemsPerPage)
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  Text(
                    'Page $_currentPage',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _currentPage <
                                (filteredTaches.length / _itemsPerPage).ceil()
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
