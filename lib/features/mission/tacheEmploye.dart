import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/tache_provider.dart';

class TachesEmploye extends StatefulWidget {
  final int missionId;

  const TachesEmploye({Key? key, required this.missionId}) : super(key: key);

  @override
  _TachesParMissionScreenState createState() => _TachesParMissionScreenState();
}

class _TachesParMissionScreenState extends State<TachesEmploye> {
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
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    bool isReadOnly = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isReadOnly ? Colors.grey.shade100 : null,
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

  Widget _buildStatusBadge(StatutTache? statut, {bool isReadOnly = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatutColor(statut).withOpacity(isReadOnly ? 0.1 : 0.2),
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
    bool isReadOnly = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: isReadOnly ? Colors.grey.shade100 : null,
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

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(content)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user!.id;
    final isCurrentUserTask = tache.userId == userId;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              decoration: _dialogDecoration.copyWith(
                color: isCurrentUserTask ? Colors.white : Colors.grey.shade100,
              ),
              padding: const EdgeInsets.all(16),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A5298),
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

                  // Section principale réorganisée pour mobile
                  Column(
                    children: [
                      _buildDetailCard(
                        icon: Icons.description,
                        title: 'Description',
                        content: tache.description ?? 'Aucune description',
                        isReadOnly: !isCurrentUserTask,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.calendar_today,
                              title: 'Date de création',
                              content: _formatDate(tache.dateCreation),
                              isReadOnly: !isCurrentUserTask,
                            ),
                          ),
                          if (tache.dateRealisation != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.event_available,
                                title: 'Date de réalisation',
                                content: _formatDate(tache.dateRealisation!),
                                isReadOnly: !isCurrentUserTask,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Section métadonnées réorganisée
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusBadge(
                            tache.statutTache,
                            isReadOnly: !isCurrentUserTask,
                          ),
                          _buildMetaDataCard(
                            icon: Icons.priority_high,
                            title: 'Priorité',
                            value: _getPrioriteTacheText(tache.priorite),
                            color: _getPrioriteColor(tache.priorite),
                            isReadOnly: !isCurrentUserTask,
                          ),
                          _buildMetaDataCard(
                            icon: Icons.person,
                            title: 'Assignée à',
                            value: tache.userName ?? 'Non assignée',
                          ),
                          _buildMetaDataCard(
                            icon: Icons.attach_money,
                            title: 'Budget',
                            value: '${tache.budget.toStringAsFixed(2)} Dt',
                            isReadOnly: !isCurrentUserTask,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section boutons d'action unifiée
                      if (isCurrentUserTask) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A5298),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            if (tache.statutTache == StatutTache.PLANIFIEE)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Commencer'),
                                onPressed: () {
                                  _showConfirmationDialog(
                                    context: context,
                                    title: 'Confirmation',
                                    content:
                                        'Voulez-vous vraiment commencer cette tâche?',
                                    onConfirm: () {
                                      context
                                          .read<TacheProvider>()
                                          .updateStatutTache(
                                            tache.tacheId,
                                            StatutTache.ENCOURS,
                                          );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                style: _dialogButtonStyle,
                              ),
                            if (tache.statutTache == StatutTache.ENCOURS)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Terminer'),
                                onPressed: () {
                                  _showConfirmationDialog(
                                    context: context,
                                    title: 'Confirmation',
                                    content:
                                        'Voulez-vous vraiment marquer cette tâche comme terminée?',
                                    onConfirm: () {
                                      context
                                          .read<TacheProvider>()
                                          .updateStatutTache(
                                            tache.tacheId,
                                            StatutTache.TERMINEE,
                                          );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                style: _dialogButtonStyle,
                              ),
                            if (tache.statutTache != StatutTache.ANNULEE &&
                                tache.statutTache != StatutTache.TERMINEE)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('Annuler'),
                                onPressed: () {
                                  _showConfirmationDialog(
                                    context: context,
                                    title: 'Confirmation',
                                    content:
                                        'Voulez-vous vraiment annuler cette tâche?',
                                    onConfirm: () {
                                      context
                                          .read<TacheProvider>()
                                          .updateStatutTache(
                                            tache.tacheId,
                                            StatutTache.ANNULEE,
                                          );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                style: _dialogButtonStyle.copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
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
        );
      },
    );
  }

  /*  void _showTacheDetails(BuildContext context, TacheDTO tache) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user!.id;
    final isCurrentUserTask = tache.userId == userId;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
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
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section principale
                  Column(
                    children: [
                      _buildDetailCard(
                        icon: Icons.description,
                        title: 'Description',
                        content: tache.description ?? 'Aucune description',
                        isReadOnly: !isCurrentUserTask,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.calendar_today,
                              title: 'Date de création',
                              content: _formatDate(tache.dateCreation),
                              isReadOnly: !isCurrentUserTask,
                            ),
                          ),
                          if (tache.dateRealisation != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.event_available,
                                title: 'Date de réalisation',
                                content: _formatDate(tache.dateRealisation!),
                                isReadOnly: !isCurrentUserTask,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section métadonnées
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatusBadge(
                            tache.statutTache,
                            isReadOnly: !isCurrentUserTask,
                          ),
                          _buildMetaDataCard(
                            icon: Icons.priority_high,
                            title: 'Priorité',
                            value: _getPrioriteTacheText(tache.priorite),
                            color: _getPrioriteColor(tache.priorite),
                            isReadOnly: !isCurrentUserTask,
                          ),
                          _buildMetaDataCard(
                            icon: Icons.person,
                            title: 'Assignée à',
                            value: tache.userName ?? 'Non assignée',
                          ),
                          _buildMetaDataCard(
                            icon: Icons.attach_money,
                            title: 'Budget',
                            value: '${tache.budget.toStringAsFixed(2)} Dt',
                            isReadOnly: !isCurrentUserTask,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section Actions
                      if (isCurrentUserTask) ...[
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        const Text(
                          'Actions disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A5298),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (tache.statutTache == StatutTache.PLANIFIEE)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('COMMENCER LA TÂCHE'),
                              onPressed: () {
                                _showStyledConfirmationDialog(
                                  context: context,
                                  title: 'Commencer la tâche',
                                  content: 'Voulez-vous vraiment commencer cette tâche?',
                                  icon: Icons.play_arrow,
                                  iconColor: Colors.blue,
                                  onConfirm: () {
                                    context.read<TacheProvider>().updateStatutTache(
                                      tache.tacheId,
                                      StatutTache.ENCOURS,
                                    );
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              style: _actionButtonStyle,
                            ),
                          ),
                        
                        if (tache.statutTache == StatutTache.ENCOURS) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: false,
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      _showStyledConfirmationDialog(
                                        context: context,
                                        title: 'Terminer la tâche',
                                        content: 'Voulez-vous marquer cette tâche comme terminée?',
                                        icon: Icons.check_circle,
                                        iconColor: Colors.green,
                                        onConfirm: () {
                                          context.read<TacheProvider>().updateStatutTache(
                                            tache.tacheId,
                                            StatutTache.TERMINEE,
                                          );
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                  },
                                  activeColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Marquer comme terminée',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                        
                        if (tache.statutTache != StatutTache.ANNULEE &&
                            tache.statutTache != StatutTache.TERMINEE) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel, size: 20),
                              label: const Text('ANNULER LA TÂCHE'),
                              onPressed: () {
                                _showStyledConfirmationDialog(
                                  context: context,
                                  title: 'Annuler la tâche',
                                  content: 'Voulez-vous vraiment annuler cette tâche? Cette action est irréversible.',
                                  icon: Icons.warning,
                                  iconColor: Colors.red,
                                  onConfirm: () {
                                    context.read<TacheProvider>().updateStatutTache(
                                      tache.tacheId,
                                      StatutTache.ANNULEE,
                                    );
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              style: _dangerButtonStyle,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'FERMER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A5298),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    final tacheProvider = context.watch<TacheProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user!.id;
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

    // Pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedTaches = filteredTaches.sublist(
      startIndex,
      endIndex < filteredTaches.length ? endIndex : filteredTaches.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches de la mission #${widget.missionId}'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<TacheProvider>().fetchTachesByMissionId(
                widget.missionId,
              );
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
                // Ligne supérieure avec recherche
                TextField(
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
                const SizedBox(height: 16),
                // Filtres et tris - réorganisés pour mobile
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<StatutTache?>(
                            value: _selectedStatutFilter,
                            decoration: const InputDecoration(
                              labelText: 'Statut',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<StatutTache?>(
                                value: null,
                                child: Text('Tous'),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<PrioriteTache?>(
                            value: _selectedPrioriteFilter,
                            decoration: const InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<PrioriteTache?>(
                                value: null,
                                child: Text('Toutes'),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        final isCurrentUserTask = tache.userId == userId;

                        return Opacity(
                          opacity: isCurrentUserTask ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: !isCurrentUserTask,
                            child: Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tache.titre,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2A5298),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (tache.description != null &&
                                          tache.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            tache.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(),
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
                                              _getPrioriteTacheText(
                                                tache.priorite,
                                              ),
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
                    'Page $_currentPage sur ${(filteredTaches.length / _itemsPerPage).ceil()}',
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
