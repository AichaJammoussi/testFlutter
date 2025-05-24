import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/MissionCreationDTO.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/MoyenTransport.dart';
import 'package:testfront/core/models/PrioriteMission.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/rapportProvider.dart';
import 'package:testfront/core/providers/tache_provider.dart';
import 'package:testfront/core/services/generatePdf.dart';
import 'package:testfront/features/mission/TacheMission.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _itemsPerPage = 3;

  // Variables pour les filtres et tris
  StatutMission? _selectedStatutFilter;
  PrioriteMission? _selectedPrioriteFilter;
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
      context.read<MissionProvider>().loadMissions();
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

    final missionId = tacheProvider.selectedTache?.missionId;
    if (missionId != null) {
      await tacheProvider.fetchTotalDepensesMission(missionId);
      await tacheProvider.chargerTotalBudget(missionId);
      await tacheProvider.fetchTotalDepensesTache(
        tacheProvider.selectedTache!.tacheId,
      );
    }
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
        title: const Text('Gestion des Missions'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 7, 7, 7),
            ),
            onPressed: () => context.read<MissionProvider>().loadMissions(),
          ),
        ],
      ),
      body: Consumer<MissionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A5298)),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadMissions(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A5298),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.missions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Color(0xFF2A5298),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune mission enregistrée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddMissionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A5298),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Créer une mission',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Filtrage des missions
          final missions =
              provider.missions
                  .where(
                    (mission) =>
                        mission.titre.toLowerCase().contains(_searchQuery) ||
                        mission.description.toLowerCase().contains(
                          _searchQuery,
                        ),
                  )
                  .where(
                    (mission) =>
                        _selectedStatutFilter == null ||
                        mission.statut == _selectedStatutFilter,
                  )
                  .where(
                    (mission) =>
                        _selectedPrioriteFilter == null ||
                        mission.priorite == _selectedPrioriteFilter,
                  )
                  .toList();

          // Tri principal par statut (Planifiée > En cours > Terminée > Annulée)
          missions.sort((a, b) => a.statut.index.compareTo(b.statut.index));

          // Ensuite par priorité (Urgente > Haute > Moyenne > Basse)
          missions.sort((a, b) => b.priorite.index.compareTo(a.priorite.index));

          // Tri optionnel par titre ou date
          if (_sortAlphabetically) {
            missions.sort((a, b) {
              final titleComparison = a.titre.compareTo(b.titre);
              return _ascending ? titleComparison : -titleComparison;
            });
          } else {
            missions.sort((a, b) {
              final dateComparison = a.dateDebutPrevue.compareTo(
                b.dateDebutPrevue,
              );
              return _sortByDateAsc ? dateComparison : -dateComparison;
            });
          }

          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage;
          final paginatedMissions = missions.sublist(
            startIndex,
            endIndex < missions.length ? endIndex : missions.length,
          );

          return Column(
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
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Bouton Ajouter avec icône et texte
                        ElevatedButton.icon(
                          onPressed: () => _showAddMissionDialog(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
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
                            "Ajouter Mission",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Ligne des filtres et boutons de tri
                    Wrap(
                      spacing: 20, // espace horizontal entre chaque enfant
                      runSpacing: 10, // espace vertical si à la ligne
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<StatutMission>(
                            value: _selectedStatutFilter,
                            decoration: InputDecoration(
                              labelText: 'Filtrer par statut',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Tous les statuts'),
                              ),
                              ...StatutMission.values.map((statut) {
                                return DropdownMenuItem(
                                  value: statut,
                                  child: Text(_getStatutText(statut)),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatutFilter = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DropdownButtonFormField<PrioriteMission>(
                            value: _selectedPrioriteFilter,

                            decoration: InputDecoration(
                              labelText: 'Filtrer par priorité',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Toutes priorités'),
                              ),
                              ...PrioriteMission.values.map((priorite) {
                                return DropdownMenuItem(
                                  value: priorite,
                                  child: Text(_getPrioriteText(priorite)),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPrioriteFilter = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Boutons de tri alignés avec les filtres
                        IconButton(
                          icon: Icon(
                            Icons.sort_by_alpha,
                            color:
                                _sortAlphabetically
                                    ? (_ascending ? Colors.blue : Colors.grey)
                                    : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _sortAlphabetically = true;
                              _ascending = !_ascending;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _sortByDateAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color:
                                !_sortAlphabetically
                                    ? const Color(0xFF2A5298)
                                    : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _sortAlphabetically = false;
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
                child: RefreshIndicator(
                  onRefresh: () => provider.loadMissions(),
                  color: const Color(0xFF2A5298),
                  child:
                      paginatedMissions.isEmpty
                          ? const Center(
                            child: Text(
                              "Aucune mission trouvée.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: paginatedMissions.length,
                            itemBuilder: (context, index) {
                              final mission = paginatedMissions[index];
                              return _buildMissionItem(context, mission);
                            },
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Page $_currentPage",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionItem(BuildContext context, MissionDTO mission) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMissionDetails(context, mission),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mission.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A5298),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatutColor(mission.statut).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatutText(mission.statut),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatutColor(mission.statut),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Wrap(
                direction: Axis.vertical,
                spacing: 4, // espace entre les lignes
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(mission.dateDebutPrevue),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(mission.dateFinPrevue),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Wrap(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: _getPriorityColor(mission.priorite),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPrioriteText(mission.priorite),
                    style: TextStyle(
                      color: _getPriorityColor(mission.priorite),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (mission.vehicules?.isNotEmpty ?? false) ...[
                    Icon(
                      Icons.directions_car,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${mission.vehicules?.length ?? 0}',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${mission.employes.length}',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionIcon(
                    icon: Icons.edit,
                    color: const Color(0xFF2A5298),
                    tooltip: 'Modifier',
                    onPressed: () => _showEditMissionDialog(context, mission),
                  ),
                  const SizedBox(width: 8),
                  _buildActionIcon(
                    icon: Icons.delete,
                    color: Colors.red,
                    tooltip: 'Supprimer',
                    onPressed: () => _showDeleteDialog(context, mission),
                  ),
                  IconButton(
                    icon: const Icon(Icons.task, color: Color(0xFF2A5298)),
                    tooltip: 'Voir les tâches',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TachesParMissionScreen(
                                missionId: mission.missionId,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  Future<void> _prendreDecision(
    BuildContext context,
    int missionId,
    bool accepte,
  ) async {
    final rapportProvider = Provider.of<RapportProvider>(
      context,
      listen: false,
    );
    final success = await rapportProvider.validerParAdmin(missionId, accepte);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (accepte ? 'Mission acceptée.' : 'Mission refusée.')
              : 'Échec lors de la validation par l\'admin.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showMissionDetails(BuildContext context, MissionDTO mission) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userRoles = userProvider.user?.roles ?? [];

    final isAdmin = userRoles.contains('admin');
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
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
                    // ── En-tête ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mission.titre,
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

                    // ── Contenu principal responsive ────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        return isSmall
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLeftDetails(mission),
                                const SizedBox(height: 16),
                                _buildRightDetails(mission),
                              ],
                            )
                            : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildLeftDetails(mission),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: _buildRightDetails(mission),
                                ),
                              ],
                            );
                      },
                    ),

                    // ── Véhicules assignés ─────────────────────────────
                    if (mission.vehicules != null &&
                        mission.vehicules!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Véhicules assignés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A5298),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            mission.vehicules!
                                .map(
                                  (v) => Chip(
                                    backgroundColor: Colors.blue.shade50,
                                    label: Text(
                                      '${v.marque} ${v.modele} (${v.immatriculation})',
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    avatar: const Icon(
                                      Icons.directions_car,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],

                    // ── Employés assignés ─────────────────────────────
                    const SizedBox(height: 16),
                    const Text(
                      'Employés assignés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A5298),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          mission.employes
                              .map(
                                (e) => Chip(
                                  backgroundColor: Colors.green.shade50,
                                  label: Text(
                                    '${e.prenom} ${e.nom}',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  avatar: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              )
                              .toList(),
                    ),

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
                              content: Text(
                                '📄 Rapport PDF généré avec succès',
                              ),
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
                    const SizedBox(height: 16),
                    const Text(
                      'Validation du rapport par l\'administrateur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A5298),
                      ),
                    ),
                    const SizedBox(height: 8),

                    StatefulBuilder(
                      builder: (context, setState) {
                        // Variable d’état déclarée une seule fois grâce à une variable locale en closure
                        bool _adminDecision = false;

                        // On déplace _adminDecision en variable mutable capturée
                        // On doit créer une variable mutable en closure (ex: via un List ou Wrapper)
                        final adminDecisionWrapper = [false];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  tooltip: "Accepter le rapport",
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 36,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text("Confirmer"),
                                            content: const Text(
                                              "Voulez-vous accepter ce rapport ?",
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text("Annuler"),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                              ),
                                              ElevatedButton(
                                                child: const Text("Confirmer"),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      adminDecisionWrapper[0] = true;
                                      setState(
                                        () {},
                                      ); // rafraîchir si tu as des UI liées à cette variable

                                      final success =
                                          await Provider.of<RapportProvider>(
                                            context,
                                            listen: false,
                                          ).validerParAdmin(
                                            mission.missionId,
                                            true,
                                          );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? "Rapport accepté"
                                                : "Erreur lors de la validation",
                                          ),
                                          backgroundColor:
                                              success
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      );
                                      if (success) Navigator.pop(context);
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: "Refuser le rapport",
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text("Confirmer"),
                                            content: const Text(
                                              "Voulez-vous refuser ce rapport ?",
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text("Annuler"),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                              ),
                                              ElevatedButton(
                                                child: const Text("Confirmer"),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      adminDecisionWrapper[0] = false;
                                      setState(
                                        () {},
                                      ); // rafraîchir UI si besoin

                                      final success =
                                          await Provider.of<RapportProvider>(
                                            context,
                                            listen: false,
                                          ).validerParAdmin(
                                            mission.missionId,
                                            false,
                                          );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? "Rapport refusé"
                                                : "Erreur lors du refus",
                                          ),
                                          backgroundColor:
                                              success
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                      );
                                      if (success) Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            ElevatedButton(
                              onPressed: () async {
                                final success =
                                    await Provider.of<RapportProvider>(
                                      context,
                                      listen: false,
                                    ).validerParAdmin(
                                      mission.missionId,
                                      adminDecisionWrapper[0],
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? (adminDecisionWrapper[0]
                                              ? "Rapport accepté"
                                              : "Rapport refusé")
                                          : "Erreur lors de la soumission",
                                    ),
                                    backgroundColor:
                                        success ? Colors.green : Colors.red,
                                  ),
                                );

                                if (success) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text("Soumettre la décision"),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
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

  Widget _buildLeftDetails(MissionDTO mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBadge(mission),
        const SizedBox(height: 16),

        _buildDetailCard(
          icon: Icons.description,
          title: 'Description',
          content: mission.description,
        ),

        const SizedBox(height: 12),
        // Dates prévues sur deux lignes
        _buildDetailCard(
          icon: Icons.calendar_today,
          title: 'Date début prévue',
          content: _formatDate(mission.dateDebutPrevue),
        ),
        const SizedBox(height: 8),
        _buildDetailCard(
          icon: Icons.calendar_today,
          title: 'Date fin prévue',
          content: _formatDate(mission.dateFinPrevue),
        ),

        if (mission.dateDebutReelle != null &&
            mission.dateFinReelle != null) ...[
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.event_available,
            title: 'Date début réelle',
            content: _formatDate(mission.dateDebutReelle!),
          ),
          const SizedBox(height: 8),
          _buildDetailCard(
            icon: Icons.event_available,
            title: 'Date fin réelle',
            content: _formatDate(mission.dateFinReelle!),
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.attach_money,
                title: 'Budget',
                content: '${mission.budget.toStringAsFixed(2)} Dt',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.money_off,
                title: 'Dépenses',
                content:
                    mission.depenses != null
                        ? '${mission.depenses!.toStringAsFixed(2)} Dt'
                        : 'Non spécifié',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Colonne droite : statut, priorité, transport, créateur, date création
  Widget _buildRightDetails(MissionDTO mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMetaDataCard(
          icon: Icons.priority_high,
          title: 'Priorité',
          value: _getPrioriteText(mission.priorite),
          color: _getPriorityColor(mission.priorite),
        ),

        const SizedBox(height: 8),
        _buildMetaDataCard(
          icon: Icons.directions_car,
          title: 'Transport',
          value: MoyenTransport.asString(mission.typeMoyenTransport),
        ),
        const SizedBox(height: 8),
        _buildMetaDataCard(
          icon: Icons.person,
          title: 'Créée par',
          value: mission.creePar,
        ),
        const SizedBox(height: 8),
        _buildMetaDataCard(
          icon: Icons.date_range,
          title: 'Date création',
          value: DateFormat('dd/MM/yyyy – HH:mm').format(mission.dateCreation),
        ),
      ],
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

  Widget _buildStatusBadge(MissionDTO mission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatutColor(mission.statut).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatutColor(mission.statut), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatutIcon(mission.statut),
            size: 18,
            color: _getStatutColor(mission.statut),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatutText(mission.statut),
            style: TextStyle(
              color: _getStatutColor(mission.statut),
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

  void _showAddMissionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();

    DateTime? _dateDebutPrevue;
    DateTime? _dateFinPrevue;
    MoyenTransport _typeTransport = MoyenTransport.Vehicule;
    List<int> _selectedVehiculeIds = [];
    Map<String, String> _fieldErrors = {};
    PrioriteMission selectedPriorite = PrioriteMission.Moyenne;
    List<VehiculeDTO> _vehiculesExistants = [];

    Future<void> _loadDisponibilites() async {
      if (_dateDebutPrevue == null || _dateFinPrevue == null) return;

      if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
        setState(() {
          _fieldErrors['dates'] =
              'La date de début doit être antérieure à la date de fin';
        });
        return;
      } else {
        setState(() => _fieldErrors.remove('dates'));
      }

      final provider = context.read<MissionProvider>();
      try {
        if (_typeTransport == MoyenTransport.Vehicule) {
          await provider.loadVehiculesDisponibles(
            _dateDebutPrevue!,
            _dateFinPrevue!,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nouvelle Mission',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A5298),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildDialogTextField(
                              controller: _titreController,
                              label: 'Titre *',
                              icon: Icons.title,
                              errorText: _fieldErrors['titre'],
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _dateDebutPrevue != null
                                                  ? TimeOfDay.fromDateTime(
                                                    _dateDebutPrevue!,
                                                  )
                                                  : TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          final fullDateTime = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            time.hour,
                                            time.minute,
                                          );
                                          setState(() {
                                            _dateDebutPrevue = fullDateTime;
                                            _selectedVehiculeIds = [];
                                          });
                                          await _loadDisponibilites();
                                        }
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date début *',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                        ),
                                        border: const OutlineInputBorder(),
                                        errorText: _fieldErrors['dates'],
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      child: Text(
                                        _dateDebutPrevue != null
                                            ? DateFormat(
                                              'dd/MM/yyyy HH:mm',
                                            ).format(_dateDebutPrevue!)
                                            : 'Sélectionner',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _dateDebutPrevue ?? DateTime.now(),
                                        firstDate:
                                            _dateDebutPrevue ?? DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _dateDebutPrevue != null
                                                  ? TimeOfDay.fromDateTime(
                                                    _dateDebutPrevue!,
                                                  )
                                                  : TimeOfDay.now(),
                                        );

                                        if (time != null) {
                                          final fullDateTime = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            time.hour,
                                            time.minute,
                                          );

                                          setState(() {
                                            _dateFinPrevue = fullDateTime;
                                            _selectedVehiculeIds = [];
                                          });

                                          await _loadDisponibilites();
                                        }
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date fin *',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                        ),
                                        border: const OutlineInputBorder(),
                                        errorText: _fieldErrors['dates'],
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      child: Text(
                                        _dateFinPrevue != null
                                            ? DateFormat(
                                              'dd/MM/yyyy HH:mm',
                                            ).format(_dateFinPrevue!)
                                            : 'Sélectionner',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_fieldErrors.containsKey('dates'))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _fieldErrors['dates']!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),
                            DropdownButtonFormField<PrioriteMission>(
                              value: selectedPriorite,
                              decoration: InputDecoration(
                                labelText: 'Priorité *',
                                prefixIcon: const Icon(Icons.priority_high),
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['priorite'],
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items:
                                  PrioriteMission.values.map((priorite) {
                                    return DropdownMenuItem(
                                      value: priorite,
                                      child: Text(_getPrioriteText(priorite)),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedPriorite = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<MoyenTransport>(
                              value: _typeTransport,
                              decoration: InputDecoration(
                                labelText: 'Type transport *',
                                prefixIcon: const Icon(Icons.directions_car),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items:
                                  MoyenTransport.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        MoyenTransport.asString(type),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _typeTransport = value;
                                    _selectedVehiculeIds = [];
                                  });
                                  if (value == MoyenTransport.Vehicule &&
                                      _dateDebutPrevue != null &&
                                      _dateFinPrevue != null) {
                                    _loadDisponibilites();
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_typeTransport == MoyenTransport.Vehicule) ...[
                              const SizedBox(height: 16),
                              if (_fieldErrors.containsKey('vehicules'))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _fieldErrors['vehicules']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Consumer<MissionProvider>(
                                builder: (context, provider, _) {
                                  // Afficher d'abord les véhicules existants
                                  return Column(
                                    children: [
                                      if (_vehiculesExistants.isNotEmpty)
                                        Column(
                                          children: [
                                            const Text(
                                              'Véhicule(s) actuel(s):',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ..._vehiculesExistants.map((
                                              vehicle,
                                            ) {
                                              return CheckboxListTile(
                                                title: Text(
                                                  '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                                  style: TextStyle(
                                                    color:
                                                        provider.vehiculesDisponibles.any(
                                                              (v) =>
                                                                  v.vehiculeeId ==
                                                                  vehicle
                                                                      .vehiculeId,
                                                            )
                                                            ? null
                                                            : Colors
                                                                .grey, // Grisé si indisponible
                                                  ),
                                                ),
                                                value: _selectedVehiculeIds
                                                    .contains(
                                                      vehicle.vehiculeId,
                                                    ),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedVehiculeIds.add(
                                                        vehicle.vehiculeId,
                                                      );
                                                    } else {
                                                      _selectedVehiculeIds
                                                          .remove(
                                                            vehicle.vehiculeId,
                                                          );
                                                    }
                                                  });
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            }),
                                          ],
                                        ),

                                      // Séparateur
                                      if (_vehiculesExistants.isNotEmpty &&
                                          provider
                                              .vehiculesDisponibles
                                              .isNotEmpty)
                                        const Divider(),

                                      // Afficher les véhicules disponibles
                                      if (provider
                                          .vehiculesDisponibles
                                          .isNotEmpty)
                                        Column(
                                          children: [
                                            const Text(
                                              'Autres véhicules disponibles:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ...provider.vehiculesDisponibles
                                                .where(
                                                  (v) =>
                                                      !_vehiculesExistants.any(
                                                        (exist) =>
                                                            exist.vehiculeId ==
                                                            v.vehiculeeId,
                                                      ),
                                                )
                                                .map((vehicle) {
                                                  return CheckboxListTile(
                                                    title: Text(
                                                      '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                                    ),
                                                    value: _selectedVehiculeIds
                                                        .contains(
                                                          vehicle.vehiculeeId,
                                                        ),
                                                    onChanged: (
                                                      bool? selected,
                                                    ) {
                                                      setState(() {
                                                        if (selected == true) {
                                                          _selectedVehiculeIds
                                                              .add(
                                                                vehicle
                                                                    .vehiculeeId,
                                                              );
                                                        } else {
                                                          _selectedVehiculeIds
                                                              .remove(
                                                                vehicle
                                                                    .vehiculeeId,
                                                              );
                                                        }
                                                        if (_selectedVehiculeIds
                                                            .isNotEmpty) {
                                                          _fieldErrors.remove(
                                                            'vehicules',
                                                          );
                                                        }
                                                      });
                                                    },
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  );
                                                }),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: _dialogButtonStyle,
                            onPressed: () async {
                              _fieldErrors = {};

                              // Validation
                              if (_titreController.text.isEmpty) {
                                _fieldErrors['titre'] = 'Champ obligatoire';
                              }
                              if (_dateDebutPrevue == null ||
                                  _dateFinPrevue == null) {
                                _fieldErrors['dates'] = 'Dates obligatoires';
                              } else if (_dateDebutPrevue!.isAfter(
                                _dateFinPrevue!,
                              )) {
                                _fieldErrors['dates'] = 'Date début > date fin';
                              }

                              if (_typeTransport == MoyenTransport.Vehicule &&
                                  _selectedVehiculeIds.isEmpty) {
                                _fieldErrors['vehicules'] =
                                    'Veuillez sélectionner au moins un véhicule';
                              }

                              setState(() {});

                              if (_fieldErrors.isEmpty) {
                                final missionDTO = MissionCreationDTO(
                                  titre: _titreController.text,
                                  description: _descriptionController.text,
                                  dateDebutPrevue: _dateDebutPrevue!,
                                  dateFinPrevue: _dateFinPrevue!,
                                  priorite: selectedPriorite.index,
                                  typeMoyenTransport: _typeTransport.index,
                                  vehiculeeIds:
                                      _typeTransport == MoyenTransport.Vehicule
                                          ? _selectedVehiculeIds
                                          : [],
                                );

                                try {
                                  final success = await context
                                      .read<MissionProvider>()
                                      .createMission(missionDTO);

                                  if (success && mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Mission créée avec succès',
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${e.toString()}'),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Enregistrer',
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
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2A5298)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorText: errorText,
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  void _showEditMissionDialog(BuildContext context, MissionDTO mission) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: mission.titre);
    final _descriptionController = TextEditingController(
      text: mission.description,
    );
    DateTime? _dateDebutPrevue = mission.dateDebutPrevue;
    DateTime? _dateFinPrevue = mission.dateFinPrevue;
    MoyenTransport _typeTransport = MoyenTransport.fromInt(
      mission.typeMoyenTransport.index,
    );
    PrioriteMission selectedPriorite = mission.priorite;
    List<int> _selectedVehiculeIds =
        mission.vehicules?.map((v) => v.vehiculeId).toList() ?? [];
    Map<String, String> _fieldErrors = {};
    List<VehiculeDTO> _vehiculesExistants = mission.vehicules ?? [];

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  insetPadding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // En-tête
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Modifier ${mission.titre}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A5298),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Formulaire
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildDialogTextField(
                                  controller: _titreController,
                                  label: 'Titre *',
                                  icon: Icons.title,
                                  errorText: _fieldErrors['titre'],
                                ),
                                const SizedBox(height: 16),
                                _buildDialogTextField(
                                  controller: _descriptionController,
                                  label: 'Description',
                                  icon: Icons.description,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),

                                // Sélection des dates
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _dateDebutPrevue ??
                                                DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  _dateDebutPrevue != null
                                                      ? TimeOfDay.fromDateTime(
                                                        _dateDebutPrevue!,
                                                      )
                                                      : TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _dateDebutPrevue = DateTime(
                                                  date.year,
                                                  date.month,
                                                  date.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                              });
                                            }
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Date début *',
                                            prefixIcon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            border: const OutlineInputBorder(),
                                            errorText: _fieldErrors['dates'],
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          child: Text(
                                            _dateDebutPrevue != null
                                                ? DateFormat(
                                                  'dd/MM/yyyy – HH:mm',
                                                ).format(_dateDebutPrevue!)
                                                : 'Sélectionner',
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _dateFinPrevue ??
                                                _dateDebutPrevue ??
                                                DateTime.now(),
                                            firstDate:
                                                _dateDebutPrevue ??
                                                DateTime.now(),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  _dateFinPrevue != null
                                                      ? TimeOfDay.fromDateTime(
                                                        _dateFinPrevue!,
                                                      )
                                                      : TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _dateFinPrevue = DateTime(
                                                  date.year,
                                                  date.month,
                                                  date.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                              });
                                            }
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Date fin *',
                                            prefixIcon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            border: const OutlineInputBorder(),
                                            errorText: _fieldErrors['dates'],
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          child: Text(
                                            _dateFinPrevue != null
                                                ? DateFormat(
                                                  'dd/MM/yyyy – HH:mm',
                                                ).format(_dateFinPrevue!)
                                                : 'Sélectionner',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_fieldErrors.containsKey('dates'))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _fieldErrors['dates']!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Priorité
                                DropdownButtonFormField<PrioriteMission>(
                                  value: selectedPriorite,
                                  decoration: InputDecoration(
                                    labelText: 'Priorité *',
                                    prefixIcon: const Icon(Icons.priority_high),
                                    border: const OutlineInputBorder(),
                                    errorText: _fieldErrors['priorite'],
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  items:
                                      PrioriteMission.values
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(_getPrioriteText(p)),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) => setState(() {
                                        if (v != null) selectedPriorite = v;
                                      }),
                                ),
                                const SizedBox(height: 16),

                                // Moyen de transport
                                DropdownButtonFormField<MoyenTransport>(
                                  value: _typeTransport,
                                  decoration: InputDecoration(
                                    labelText: 'Type transport *',
                                    prefixIcon: const Icon(
                                      Icons.directions_car,
                                    ),
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  items:
                                      MoyenTransport.values
                                          .map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(
                                                MoyenTransport.asString(t),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) => setState(() {
                                        if (v != null) {
                                          _typeTransport = v;
                                        }
                                      }),
                                ),

                                // Véhicules
                                if (_typeTransport ==
                                    MoyenTransport.Vehicule) ...[
                                  const SizedBox(height: 16),
                                  Consumer<MissionProvider>(
                                    builder: (ctx, provider, _) {
                                      final dispo =
                                          provider.vehiculesDisponibles;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_vehiculesExistants
                                              .isNotEmpty) ...[
                                            const Text(
                                              'Véhicule(s) actuel(s):',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ..._vehiculesExistants.map((veh) {
                                              return CheckboxListTile(
                                                title: Text(
                                                  '${veh.marque} ${veh.modele} (${veh.immatriculation})',
                                                ),
                                                value: _selectedVehiculeIds
                                                    .contains(veh.vehiculeId),
                                                onChanged:
                                                    (sel) => setState(() {
                                                      if (sel == true) {
                                                        _selectedVehiculeIds
                                                            .add(
                                                              veh.vehiculeId,
                                                            );
                                                      } else {
                                                        _selectedVehiculeIds
                                                            .remove(
                                                              veh.vehiculeId,
                                                            );
                                                      }
                                                    }),
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            }),
                                            if (dispo.isNotEmpty)
                                              const Divider(),
                                          ],
                                          if (dispo
                                              .where(
                                                (v) =>
                                                    !_vehiculesExistants.any(
                                                      (e) =>
                                                          e.vehiculeId ==
                                                          v.vehiculeeId,
                                                    ),
                                              )
                                              .isNotEmpty) ...[
                                            const Text(
                                              'Véhicules disponibles:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ...dispo
                                                .where(
                                                  (v) =>
                                                      !_vehiculesExistants.any(
                                                        (e) =>
                                                            e.vehiculeId ==
                                                            v.vehiculeeId,
                                                      ),
                                                )
                                                .map((veh) {
                                                  return CheckboxListTile(
                                                    title: Text(
                                                      '${veh.marque} ${veh.modele} (${veh.immatriculation})',
                                                    ),
                                                    value: _selectedVehiculeIds
                                                        .contains(
                                                          veh.vehiculeeId,
                                                        ),
                                                    onChanged:
                                                        (sel) => setState(() {
                                                          if (sel == true) {
                                                            _selectedVehiculeIds
                                                                .add(
                                                                  veh.vehiculeeId,
                                                                );
                                                          } else {
                                                            _selectedVehiculeIds
                                                                .remove(
                                                                  veh.vehiculeeId,
                                                                );
                                                          }
                                                        }),
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                  );
                                                }),
                                          ],
                                          if (_fieldErrors.containsKey(
                                            'vehicules',
                                          ))
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                _fieldErrors['vehicules']!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],

                                const SizedBox(height: 24),

                                // Boutons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () async {
                                        _fieldErrors.clear();
                                        if (_titreController.text.isEmpty) {
                                          _fieldErrors['titre'] =
                                              'Champ obligatoire';
                                        }
                                        if (_dateDebutPrevue == null ||
                                            _dateFinPrevue == null) {
                                          _fieldErrors['dates'] =
                                              'Dates obligatoires';
                                        } else if (_dateDebutPrevue!.isAfter(
                                          _dateFinPrevue!,
                                        )) {
                                          _fieldErrors['dates'] =
                                              'Date début > date fin';
                                        }
                                        if (_typeTransport ==
                                                MoyenTransport.Vehicule &&
                                            _selectedVehiculeIds.isEmpty) {
                                          _fieldErrors['vehicules'] =
                                              'Sélectionnez au moins un véhicule';
                                        }
                                        setState(() {});
                                        if (_fieldErrors.isEmpty) {
                                          final dto = MissionCreationDTO(
                                            titre: _titreController.text,
                                            description:
                                                _descriptionController.text,
                                            dateDebutPrevue: _dateDebutPrevue!,
                                            dateFinPrevue: _dateFinPrevue!,
                                            priorite: selectedPriorite.index,
                                            typeMoyenTransport:
                                                _typeTransport.index,
                                            vehiculeeIds:
                                                _typeTransport ==
                                                        MoyenTransport.Vehicule
                                                    ? _selectedVehiculeIds
                                                    : [],
                                          );
                                          try {
                                            final success = await context
                                                .read<MissionProvider>()
                                                .updateMission(
                                                  mission.missionId,
                                                  dto,
                                                );
                                            if (success && mounted) {
                                              Navigator.pop(context);
                                              _updateDepenseEtTotal();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Mission mise à jour avec succès',
                                                  ),
                                                  backgroundColor:
                                                      Colors.green.shade600,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Erreur: $e'),
                                                backgroundColor:
                                                    Colors.red.shade600,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.save,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Sauvegarder',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, MissionDTO mission) {
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
                  Text(
                    'Voulez-vous vraiment supprimer la mission "${mission.titre}" ?',
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
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: _dialogButtonStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.red,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            final success = await context
                                .read<MissionProvider>()
                                .deleteMission(mission.missionId);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Mission supprimée avec succès',
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              context.read<MissionProvider>().loadMissions();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
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
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
  }

  String _getStatutText(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return 'Planifiée';
      case StatutMission.EN_COURS:
        return 'En cours';
      case StatutMission.TERMINEE:
        return 'Terminée';
      case StatutMission.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Color _getStatutColor(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return Colors.blue;
      case StatutMission.EN_COURS:
        return Colors.orange;
      case StatutMission.TERMINEE:
        return Colors.green;
      case StatutMission.ANNULEE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPrioriteText(PrioriteMission priorite) {
    switch (priorite) {
      case PrioriteMission.Basse:
        return 'Basse';
      case PrioriteMission.Moyenne:
        return 'Moyenne';
      case PrioriteMission.Haute:
        return 'Haute';
      case PrioriteMission.Urgente:
        return 'Urgente';
      default:
        return 'Inconnue';
    }
  }
}
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/MoyenTransport.dart';
import 'package:testfront/core/models/PrioriteMission.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/providers/mission_provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().loadMissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Missions'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MissionProvider>().loadMissions(),
          ),
        ],
      ),
      body: Consumer<MissionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMissions(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.missions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune mission enregistrée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Implémentation de création mission
                    },
                    child: const Text('Créer une mission'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une mission...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    // Filtrage si nécessaire
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadMissions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.missions.length,
                    itemBuilder:
                        (ctx, index) => _buildMissionItem(
                          context,
                          provider.missions[index],
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5298),
        child: const Icon(Icons.add),

              onPressed:
                  () =>_showAddMissionDialog(context),
           
      ),
    );
  }

  Widget _buildMissionItem(BuildContext context, MissionDTO mission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showMissionDetails(context, mission),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mission.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatutColor(mission.statut).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatutText(mission.statut),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(mission.dateDebutPrevue)} - ${_formatDate(mission.dateFinPrevue)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${mission.budget.toStringAsFixed(2)} €'),
                  const Spacer(),
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${mission.employes.length} employé(s)'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Modifier la mission
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Supprimer la mission
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetails(BuildContext context, MissionDTO mission) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la mission: ${mission.titre}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Description:', mission.description),
                _buildDetailRow(
                  'Dates prévues:',
                  '${_formatDate(mission.dateDebutPrevue)} - ${_formatDate(mission.dateFinPrevue)}',
                ),
                _buildDetailRow(
                  'Dates réelles:',
                  mission.dateDebutReelle != null &&
                          mission.dateFinReelle != null
                      ? '${_formatDate(mission.dateDebutReelle!)} - ${_formatDate(mission.dateFinReelle!)}'
                      : 'Non spécifié',
                ),
                _buildDetailRow(
                  'Date de création:',
                  _formatDate(mission.dateCreation),
                ),
                _buildDetailRow('Créée par:', mission.creePar),
                _buildDetailRow('Statut:', _getStatutText(mission.statut)),
                _buildDetailRow(
                  'Budget:',
                  '${mission.budget.toStringAsFixed(2)} €',
                ),
                _buildDetailRow(
                  'Dépenses:',
                  mission.depenses != null
                      ? '${mission.depenses!.toStringAsFixed(2)} €'
                      : 'Non spécifié',
                ),
                _buildDetailRow('Priorité:', mission.priorite.asString()),

                _buildDetailRow(
                  'Type transport:',
                  MoyenTransport.asString(mission.typeMoyenTransport),
                ),
                if (mission.vehicules != null && mission.vehicules!.isNotEmpty)
                  _buildDetailRow(
                    'Véhicules:',
                    mission.vehicules!
                        .map(
                          (v) =>
                              '${v.marque} ${v.modele} (${v.immatriculation})',
                        )
                        .join('\n'),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Employés assignés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...mission.employes.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${e.prenom} ${e.nom} (${e.userName})'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? 'Non spécifié')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatutText(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return 'Planifiée';
      case StatutMission.EN_COURS:
        return 'En cours';
      case StatutMission.TERMINEE:
        return 'Terminée';
      case StatutMission.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Color _getStatutColor(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return Colors.green;
      case StatutMission.EN_COURS:
        return Colors.orange;
      case StatutMission.TERMINEE:
        return Colors.red;
      case StatutMission.ANNULEE:
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }
}

  void _showAddMissionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    DateTime? _dateDebutPrevue;
    DateTime? _dateFinPrevue;
    int? _priorite = 1;
    String? _typeTransport;
    int? _selectedVehiculeId;
    List<String> _selectedEmployeIds = [];
    Map<String, String> _fieldErrors = {};

    Future<void> _loadDisponibilites() async {
      if (_dateDebutPrevue == null || _dateFinPrevue == null) return;

      if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
        setState(() {
          _fieldErrors['dates'] =
              'La date de début doit être antérieure à la date de fin';
        });
        return;
      } else {
        setState(() => _fieldErrors.remove('dates'));
      }

      final provider = context.read<MissionProvider>();

      try {
        await provider.loadEmployesDisponibles(
          _dateDebutPrevue!,
          _dateFinPrevue!,
        );

        if (_typeTransport == 'Véhicule') {
          await provider.loadVehiculesDisponibles(
            _dateDebutPrevue!,
            _dateFinPrevue!,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle Mission'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateDebutPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date début *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateDebutPrevue != null
                                      ? _formatDate(_dateDebutPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateDebutPrevue ?? DateTime.now(),
                                  firstDate: _dateDebutPrevue ?? DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateFinPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date fin *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateFinPrevue != null
                                      ? _formatDate(_dateFinPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_fieldErrors.containsKey('dates'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _fieldErrors['dates']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _priorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Faible')),
                          DropdownMenuItem(value: 2, child: Text('Moyenne')),
                          DropdownMenuItem(value: 3, child: Text('Haute')),
                        ],
                        onChanged: (value) {
                          setState(() => _priorite = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: const OutlineInputBorder(),
                          suffixText: '€',
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeTransport,
                        decoration: InputDecoration(
                          labelText: 'Type transport *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['typeTransport'],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Véhicule',
                            child: Text('Véhicule'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            _typeTransport = value;
                            _selectedVehiculeId = null;
                          });
                          if (value == 'Véhicule' &&
                              _dateDebutPrevue != null &&
                              _dateFinPrevue != null) {
                            await _loadDisponibilites();
                          }
                        },
                      ),
                      if (_typeTransport == 'Véhicule') ...[
                        const SizedBox(height: 16),
                        Consumer<MissionProvider>(
                          builder: (context, provider, _) {
                            if (provider.vehiculesDisponibles.isEmpty &&
                                _dateDebutPrevue != null &&
                                _dateFinPrevue != null) {
                              return const Text(
                                'Aucun véhicule disponible pour cette période',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedVehiculeId,
                              decoration: InputDecoration(
                                labelText: 'Véhicule *',
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['vehicule'],
                              ),
                              items:
                                  provider.vehiculesDisponibles.map((vehicle) {
                                    return DropdownMenuItem<int>(
                                      value: vehicle.vehiculeeId,
                                      child: Text(
                                        '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedVehiculeId = value);
                              },
                              validator: (value) {
                                if (_typeTransport == 'Véhicule' &&
                                    value == null) {
                                  return 'Champ obligatoire';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Employés assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Consumer<MissionProvider>(
                        builder: (context, provider, _) {
                          if (_dateDebutPrevue == null ||
                              _dateFinPrevue == null) {
                            return const Text(
                              'Sélectionnez d\'abord les dates',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          if (provider.employesDisponibles.isEmpty) {
                            return const Text(
                              'Aucun employé disponible pour cette période',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          return Column(
                            children: [
                              ...provider.employesDisponibles.map((employee) {
                                return CheckboxListTile(
                                  title: Text(
                                    '${employee.nom} ${employee.prenom}',
                                  ),
                                  value: _selectedEmployeIds.contains(
                                    employee.id,
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedEmployeIds.add(employee.id!);
                                      } else {
                                        _selectedEmployeIds.remove(employee.id);
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                              if (_fieldErrors.containsKey('employes'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fieldErrors['employes']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
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
                    _fieldErrors = {};

                    // Validation manuelle
                    if (_titreController.text.isEmpty) {
                      _fieldErrors['titre'] = 'Champ obligatoire';
                    }
                    if (_descriptionController.text.isEmpty) {
                      _fieldErrors['description'] = 'Champ obligatoire';
                    }
                    if (_dateDebutPrevue == null || _dateFinPrevue == null) {
                      _fieldErrors['dates'] = 'Dates obligatoires';
                    } else if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
                      _fieldErrors['dates'] = 'Date début > date fin';
                    }
                    if (_budgetController.text.isEmpty) {
                      _fieldErrors['budget'] = 'Champ obligatoire';
                    } else if (double.tryParse(_budgetController.text) ==
                        null) {
                      _fieldErrors['budget'] = 'Nombre invalide';
                    }
                    if (_typeTransport == null) {
                      _fieldErrors['typeTransport'] = 'Champ obligatoire';
                    }
                    if (_typeTransport == 'Véhicule' &&
                        _selectedVehiculeId == null) {
                      _fieldErrors['vehicule'] = 'Champ obligatoire';
                    }
                    if (_selectedEmployeIds.isEmpty) {
                      _fieldErrors['employes'] =
                          'Sélectionnez au moins un employé';
                    }

                    setState(() {});

                    if (_fieldErrors.isEmpty) {
                      final missionDTO = MissionCreationDTO(
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        dateDebutPrevue: _dateDebutPrevue!,
                        dateFinPrevue: _dateFinPrevue!,
                        priorite: _priorite!,
                        typeMoyenTransport: _typeTransport!,
                        vehiculeId:
                            _typeTransport == 'Véhicule'
                                ? _selectedVehiculeId
                                : null,
                        budget: double.parse(_budgetController.text),
                        employeIds: _selectedEmployeIds,
                      );

                      try {
                        final success = await context
                            .read<MissionProvider>()
                            .createMission(missionDTO);

                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mission créée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMissionDialog(BuildContext context, MissionDTO mission) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: mission.titre);
    final _descriptionController = TextEditingController(
      text: mission.description,
    );
    final _budgetController = TextEditingController(
      text: mission.budget.toString(),
    );

    DateTime? _dateDebutPrevue = mission.dateDebutPrevue;
    DateTime? _dateFinPrevue = mission.dateFinPrevue;
    int? _priorite = mission.priorite.index;
    String? _typeTransport = mission.typeMoyenTransport;
    int? _selectedVehiculeId;
    List<String> _selectedEmployeIds =
        mission.employes.map((e) => e.userName!).toList();
    Map<String, String> _fieldErrors = {};

    Future<void> _loadDisponibilites() async {
      if (_dateDebutPrevue == null || _dateFinPrevue == null) return;

      if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
        setState(() {
          _fieldErrors['dates'] =
              'La date de début doit être antérieure à la date de fin';
        });
        return;
      } else {
        setState(() => _fieldErrors.remove('dates'));
      }

      final provider = context.read<MissionProvider>();

      try {
        await provider.loadEmployesDisponibles(
          _dateDebutPrevue!,
          _dateFinPrevue!,
        );

        if (_typeTransport == 'Véhicule') {
          await provider.loadVehiculesDisponibles(
            _dateDebutPrevue!,
            _dateFinPrevue!,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier Mission'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateDebutPrevue ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateDebutPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date début *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateDebutPrevue != null
                                      ? _formatDate(_dateDebutPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateFinPrevue ??
                                      _dateDebutPrevue ??
                                      DateTime.now(),
                                  firstDate: _dateDebutPrevue ?? DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateFinPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date fin *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateFinPrevue != null
                                      ? _formatDate(_dateFinPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_fieldErrors.containsKey('dates'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _fieldErrors['dates']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _priorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Faible')),
                          DropdownMenuItem(value: 2, child: Text('Moyenne')),
                          DropdownMenuItem(value: 3, child: Text('Haute')),
                        ],
                        onChanged: (value) {
                          setState(() => _priorite = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: const OutlineInputBorder(),
                          suffixText: '€',
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeTransport,
                        decoration: InputDecoration(
                          labelText: 'Type transport *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['typeTransport'],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Véhicule',
                            child: Text('Véhicule'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            _typeTransport = value;
                            _selectedVehiculeId = null;
                          });
                          if (value == 'Véhicule' &&
                              _dateDebutPrevue != null &&
                              _dateFinPrevue != null) {
                            await _loadDisponibilites();
                          }
                        },
                      ),
                      if (_typeTransport == 'Véhicule') ...[
                        const SizedBox(height: 16),
                        Consumer<MissionProvider>(
                          builder: (context, provider, _) {
                            if (provider.vehiculesDisponibles.isEmpty &&
                                _dateDebutPrevue != null &&
                                _dateFinPrevue != null) {
                              return const Text(
                                'Aucun véhicule disponible pour cette période',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedVehiculeId,
                              decoration: InputDecoration(
                                labelText: 'Véhicule *',
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['vehicule'],
                              ),
                              items:
                                  provider.vehiculesDisponibles.map((vehicle) {
                                    return DropdownMenuItem<int>(
                                      value: vehicle.vehiculeeId,
                                      child: Text(
                                        '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedVehiculeId = value);
                              },
                              validator: (value) {
                                if (_typeTransport == 'Véhicule' &&
                                    value == null) {
                                  return 'Champ obligatoire';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Employés assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Consumer<MissionProvider>(
                        builder: (context, provider, _) {
                          if (_dateDebutPrevue == null ||
                              _dateFinPrevue == null) {
                            return const Text(
                              'Sélectionnez d\'abord les dates',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          if (provider.employesDisponibles.isEmpty) {
                            return const Text(
                              'Aucun employé disponible pour cette période',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          return Column(
                            children: [
                              ...provider.employesDisponibles.map((employee) {
                                return CheckboxListTile(
                                  title: Text(
                                    '${employee.nom} ${employee.prenom}',
                                  ),
                                  value: _selectedEmployeIds.contains(
                                    employee.userName,
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedEmployeIds.add(
                                          employee.userName!,
                                        );
                                      } else {
                                        _selectedEmployeIds.remove(
                                          employee.userName,
                                        );
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                              if (_fieldErrors.containsKey('employes'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fieldErrors['employes']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
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
                    _fieldErrors = {};

                    // Validation manuelle
                    if (_titreController.text.isEmpty) {
                      _fieldErrors['titre'] = 'Champ obligatoire';
                    }
                    if (_descriptionController.text.isEmpty) {
                      _fieldErrors['description'] = 'Champ obligatoire';
                    }
                    if (_dateDebutPrevue == null || _dateFinPrevue == null) {
                      _fieldErrors['dates'] = 'Dates obligatoires';
                    } else if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
                      _fieldErrors['dates'] = 'Date début > date fin';
                    }
                    if (_budgetController.text.isEmpty) {
                      _fieldErrors['budget'] = 'Champ obligatoire';
                    } else if (double.tryParse(_budgetController.text) ==
                        null) {
                      _fieldErrors['budget'] = 'Nombre invalide';
                    }
                    if (_typeTransport == null) {
                      _fieldErrors['typeTransport'] = 'Champ obligatoire';
                    }
                    if (_typeTransport == 'Véhicule' &&
                        _selectedVehiculeId == null) {
                      _fieldErrors['vehicule'] = 'Champ obligatoire';
                    }
                    if (_selectedEmployeIds.isEmpty) {
                      _fieldErrors['employes'] =
                          'Sélectionnez au moins un employé';
                    }

                    setState(() {});

                    if (_fieldErrors.isEmpty) {
                      final missionDTO = MissionCreationDTO(
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        dateDebutPrevue: _dateDebutPrevue!,
                        dateFinPrevue: _dateFinPrevue!,
                        priorite: _priorite!,
                        typeMoyenTransport: _typeTransport!,
                        vehiculeId:
                            _typeTransport == 'Véhicule'
                                ? _selectedVehiculeId
                                : null,
                        budget: double.parse(_budgetController.text),
                        employeIds: _selectedEmployeIds,
                      );

                      try {
                        final success = await context
                            .read<MissionProvider>()
                            .updateMission(mission.missionId, missionDTO);

                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mission mise à jour avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          context.read<MissionProvider>().loadMissions();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, MissionDTO mission) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text('Supprimer la mission "${mission.titre}" ?'),
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
                    final success = await context
                        .read<MissionProvider>()
                        .deleteMission(mission.missionId);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mission supprimée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.read<MissionProvider>().loadMissions();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/MoyenTransport.dart';
import 'package:testfront/core/models/PrioriteMission.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/providers/mission_provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().loadMissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Missions'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MissionProvider>().loadMissions(),
          ),
        ],
      ),
      body: Consumer<MissionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMissions(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.missions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune mission enregistrée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Implémentation de création mission
                    },
                    child: const Text('Créer une mission'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une mission...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    // Filtrage si nécessaire
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadMissions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.missions.length,
                    itemBuilder:
                        (ctx, index) => _buildMissionItem(
                          context,
                          provider.missions[index],
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5298),
        child: const Icon(Icons.add),

              onPressed:
                  () =>_showAddMissionDialog(context),
           
      ),
    );
  }

  Widget _buildMissionItem(BuildContext context, MissionDTO mission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showMissionDetails(context, mission),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mission.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatutColor(mission.statut).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatutText(mission.statut),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(mission.dateDebutPrevue)} - ${_formatDate(mission.dateFinPrevue)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${mission.budget.toStringAsFixed(2)} €'),
                  const Spacer(),
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${mission.employes.length} employé(s)'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Modifier la mission
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Supprimer la mission
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetails(BuildContext context, MissionDTO mission) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la mission: ${mission.titre}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Description:', mission.description),
                _buildDetailRow(
                  'Dates prévues:',
                  '${_formatDate(mission.dateDebutPrevue)} - ${_formatDate(mission.dateFinPrevue)}',
                ),
                _buildDetailRow(
                  'Dates réelles:',
                  mission.dateDebutReelle != null &&
                          mission.dateFinReelle != null
                      ? '${_formatDate(mission.dateDebutReelle!)} - ${_formatDate(mission.dateFinReelle!)}'
                      : 'Non spécifié',
                ),
                _buildDetailRow(
                  'Date de création:',
                  _formatDate(mission.dateCreation),
                ),
                _buildDetailRow('Créée par:', mission.creePar),
                _buildDetailRow('Statut:', _getStatutText(mission.statut)),
                _buildDetailRow(
                  'Budget:',
                  '${mission.budget.toStringAsFixed(2)} €',
                ),
                _buildDetailRow(
                  'Dépenses:',
                  mission.depenses != null
                      ? '${mission.depenses!.toStringAsFixed(2)} €'
                      : 'Non spécifié',
                ),
                _buildDetailRow('Priorité:', mission.priorite.asString()),

                _buildDetailRow(
                  'Type transport:',
                  MoyenTransport.asString(mission.typeMoyenTransport),
                ),
                if (mission.vehicules != null && mission.vehicules!.isNotEmpty)
                  _buildDetailRow(
                    'Véhicules:',
                    mission.vehicules!
                        .map(
                          (v) =>
                              '${v.marque} ${v.modele} (${v.immatriculation})',
                        )
                        .join('\n'),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Employés assignés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...mission.employes.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${e.prenom} ${e.nom} (${e.userName})'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? 'Non spécifié')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatutText(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return 'Planifiée';
      case StatutMission.EN_COURS:
        return 'En cours';
      case StatutMission.TERMINEE:
        return 'Terminée';
      case StatutMission.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Color _getStatutColor(StatutMission statut) {
    switch (statut) {
      case StatutMission.PLANIFIEE:
        return Colors.green;
      case StatutMission.EN_COURS:
        return Colors.orange;
      case StatutMission.TERMINEE:
        return Colors.red;
      case StatutMission.ANNULEE:
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }
}

  void _showAddMissionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();

    DateTime? _dateDebutPrevue;
    DateTime? _dateFinPrevue;
    int? _priorite = 1;
    String? _typeTransport;
    int? _selectedVehiculeId;
    List<String> _selectedEmployeIds = [];
    Map<String, String> _fieldErrors = {};

    Future<void> _loadDisponibilites() async {
      if (_dateDebutPrevue == null || _dateFinPrevue == null) return;

      if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
        setState(() {
          _fieldErrors['dates'] =
              'La date de début doit être antérieure à la date de fin';
        });
        return;
      } else {
        setState(() => _fieldErrors.remove('dates'));
      }

      final provider = context.read<MissionProvider>();

      try {
        await provider.loadEmployesDisponibles(
          _dateDebutPrevue!,
          _dateFinPrevue!,
        );

        if (_typeTransport == 'Véhicule') {
          await provider.loadVehiculesDisponibles(
            _dateDebutPrevue!,
            _dateFinPrevue!,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle Mission'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateDebutPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date début *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateDebutPrevue != null
                                      ? _formatDate(_dateDebutPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateDebutPrevue ?? DateTime.now(),
                                  firstDate: _dateDebutPrevue ?? DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateFinPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date fin *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateFinPrevue != null
                                      ? _formatDate(_dateFinPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_fieldErrors.containsKey('dates'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _fieldErrors['dates']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _priorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Faible')),
                          DropdownMenuItem(value: 2, child: Text('Moyenne')),
                          DropdownMenuItem(value: 3, child: Text('Haute')),
                        ],
                        onChanged: (value) {
                          setState(() => _priorite = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: const OutlineInputBorder(),
                          suffixText: '€',
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeTransport,
                        decoration: InputDecoration(
                          labelText: 'Type transport *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['typeTransport'],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Véhicule',
                            child: Text('Véhicule'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            _typeTransport = value;
                            _selectedVehiculeId = null;
                          });
                          if (value == 'Véhicule' &&
                              _dateDebutPrevue != null &&
                              _dateFinPrevue != null) {
                            await _loadDisponibilites();
                          }
                        },
                      ),
                      if (_typeTransport == 'Véhicule') ...[
                        const SizedBox(height: 16),
                        Consumer<MissionProvider>(
                          builder: (context, provider, _) {
                            if (provider.vehiculesDisponibles.isEmpty &&
                                _dateDebutPrevue != null &&
                                _dateFinPrevue != null) {
                              return const Text(
                                'Aucun véhicule disponible pour cette période',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedVehiculeId,
                              decoration: InputDecoration(
                                labelText: 'Véhicule *',
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['vehicule'],
                              ),
                              items:
                                  provider.vehiculesDisponibles.map((vehicle) {
                                    return DropdownMenuItem<int>(
                                      value: vehicle.vehiculeeId,
                                      child: Text(
                                        '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedVehiculeId = value);
                              },
                              validator: (value) {
                                if (_typeTransport == 'Véhicule' &&
                                    value == null) {
                                  return 'Champ obligatoire';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Employés assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Consumer<MissionProvider>(
                        builder: (context, provider, _) {
                          if (_dateDebutPrevue == null ||
                              _dateFinPrevue == null) {
                            return const Text(
                              'Sélectionnez d\'abord les dates',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          if (provider.employesDisponibles.isEmpty) {
                            return const Text(
                              'Aucun employé disponible pour cette période',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          return Column(
                            children: [
                              ...provider.employesDisponibles.map((employee) {
                                return CheckboxListTile(
                                  title: Text(
                                    '${employee.nom} ${employee.prenom}',
                                  ),
                                  value: _selectedEmployeIds.contains(
                                    employee.id,
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedEmployeIds.add(employee.id!);
                                      } else {
                                        _selectedEmployeIds.remove(employee.id);
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                              if (_fieldErrors.containsKey('employes'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fieldErrors['employes']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
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
                    _fieldErrors = {};

                    // Validation manuelle
                    if (_titreController.text.isEmpty) {
                      _fieldErrors['titre'] = 'Champ obligatoire';
                    }
                    if (_descriptionController.text.isEmpty) {
                      _fieldErrors['description'] = 'Champ obligatoire';
                    }
                    if (_dateDebutPrevue == null || _dateFinPrevue == null) {
                      _fieldErrors['dates'] = 'Dates obligatoires';
                    } else if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
                      _fieldErrors['dates'] = 'Date début > date fin';
                    }
                    if (_budgetController.text.isEmpty) {
                      _fieldErrors['budget'] = 'Champ obligatoire';
                    } else if (double.tryParse(_budgetController.text) ==
                        null) {
                      _fieldErrors['budget'] = 'Nombre invalide';
                    }
                    if (_typeTransport == null) {
                      _fieldErrors['typeTransport'] = 'Champ obligatoire';
                    }
                    if (_typeTransport == 'Véhicule' &&
                        _selectedVehiculeId == null) {
                      _fieldErrors['vehicule'] = 'Champ obligatoire';
                    }
                    if (_selectedEmployeIds.isEmpty) {
                      _fieldErrors['employes'] =
                          'Sélectionnez au moins un employé';
                    }

                    setState(() {});

                    if (_fieldErrors.isEmpty) {
                      final missionDTO = MissionCreationDTO(
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        dateDebutPrevue: _dateDebutPrevue!,
                        dateFinPrevue: _dateFinPrevue!,
                        priorite: _priorite!,
                        typeMoyenTransport: _typeTransport!,
                        vehiculeId:
                            _typeTransport == 'Véhicule'
                                ? _selectedVehiculeId
                                : null,
                        budget: double.parse(_budgetController.text),
                        employeIds: _selectedEmployeIds,
                      );

                      try {
                        final success = await context
                            .read<MissionProvider>()
                            .createMission(missionDTO);

                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mission créée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMissionDialog(BuildContext context, MissionDTO mission) {
    final _formKey = GlobalKey<FormState>();
    final _titreController = TextEditingController(text: mission.titre);
    final _descriptionController = TextEditingController(
      text: mission.description,
    );
    final _budgetController = TextEditingController(
      text: mission.budget.toString(),
    );

    DateTime? _dateDebutPrevue = mission.dateDebutPrevue;
    DateTime? _dateFinPrevue = mission.dateFinPrevue;
    int? _priorite = mission.priorite.index;
    String? _typeTransport = mission.typeMoyenTransport;
    int? _selectedVehiculeId;
    List<String> _selectedEmployeIds =
        mission.employes.map((e) => e.userName!).toList();
    Map<String, String> _fieldErrors = {};

    Future<void> _loadDisponibilites() async {
      if (_dateDebutPrevue == null || _dateFinPrevue == null) return;

      if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
        setState(() {
          _fieldErrors['dates'] =
              'La date de début doit être antérieure à la date de fin';
        });
        return;
      } else {
        setState(() => _fieldErrors.remove('dates'));
      }

      final provider = context.read<MissionProvider>();

      try {
        await provider.loadEmployesDisponibles(
          _dateDebutPrevue!,
          _dateFinPrevue!,
        );

        if (_typeTransport == 'Véhicule') {
          await provider.loadVehiculesDisponibles(
            _dateDebutPrevue!,
            _dateFinPrevue!,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier Mission'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['titre'],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['description'],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateDebutPrevue ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateDebutPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date début *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateDebutPrevue != null
                                      ? _formatDate(_dateDebutPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dateFinPrevue ??
                                      _dateDebutPrevue ??
                                      DateTime.now(),
                                  firstDate: _dateDebutPrevue ?? DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateFinPrevue = date;
                                    _selectedEmployeIds = [];
                                    _selectedVehiculeId = null;
                                  });
                                  await _loadDisponibilites();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date fin *',
                                  border: const OutlineInputBorder(),
                                  errorText: _fieldErrors['dates'],
                                ),
                                child: Text(
                                  _dateFinPrevue != null
                                      ? _formatDate(_dateFinPrevue!)
                                      : 'Sélectionner',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_fieldErrors.containsKey('dates'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _fieldErrors['dates']!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _priorite,
                        decoration: const InputDecoration(
                          labelText: 'Priorité *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Faible')),
                          DropdownMenuItem(value: 2, child: Text('Moyenne')),
                          DropdownMenuItem(value: 3, child: Text('Haute')),
                        ],
                        onChanged: (value) {
                          setState(() => _priorite = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget *',
                          border: const OutlineInputBorder(),
                          suffixText: '€',
                          errorText: _fieldErrors['budget'],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeTransport,
                        decoration: InputDecoration(
                          labelText: 'Type transport *',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['typeTransport'],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Véhicule',
                            child: Text('Véhicule'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            _typeTransport = value;
                            _selectedVehiculeId = null;
                          });
                          if (value == 'Véhicule' &&
                              _dateDebutPrevue != null &&
                              _dateFinPrevue != null) {
                            await _loadDisponibilites();
                          }
                        },
                      ),
                      if (_typeTransport == 'Véhicule') ...[
                        const SizedBox(height: 16),
                        Consumer<MissionProvider>(
                          builder: (context, provider, _) {
                            if (provider.vehiculesDisponibles.isEmpty &&
                                _dateDebutPrevue != null &&
                                _dateFinPrevue != null) {
                              return const Text(
                                'Aucun véhicule disponible pour cette période',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedVehiculeId,
                              decoration: InputDecoration(
                                labelText: 'Véhicule *',
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['vehicule'],
                              ),
                              items:
                                  provider.vehiculesDisponibles.map((vehicle) {
                                    return DropdownMenuItem<int>(
                                      value: vehicle.vehiculeeId,
                                      child: Text(
                                        '${vehicle.marque} ${vehicle.modele} (${vehicle.immatriculation})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedVehiculeId = value);
                              },
                              validator: (value) {
                                if (_typeTransport == 'Véhicule' &&
                                    value == null) {
                                  return 'Champ obligatoire';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Employés assignés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Consumer<MissionProvider>(
                        builder: (context, provider, _) {
                          if (_dateDebutPrevue == null ||
                              _dateFinPrevue == null) {
                            return const Text(
                              'Sélectionnez d\'abord les dates',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          if (provider.employesDisponibles.isEmpty) {
                            return const Text(
                              'Aucun employé disponible pour cette période',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          return Column(
                            children: [
                              ...provider.employesDisponibles.map((employee) {
                                return CheckboxListTile(
                                  title: Text(
                                    '${employee.nom} ${employee.prenom}',
                                  ),
                                  value: _selectedEmployeIds.contains(
                                    employee.userName,
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedEmployeIds.add(
                                          employee.userName!,
                                        );
                                      } else {
                                        _selectedEmployeIds.remove(
                                          employee.userName,
                                        );
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                              if (_fieldErrors.containsKey('employes'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fieldErrors['employes']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
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
                    _fieldErrors = {};

                    // Validation manuelle
                    if (_titreController.text.isEmpty) {
                      _fieldErrors['titre'] = 'Champ obligatoire';
                    }
                    if (_descriptionController.text.isEmpty) {
                      _fieldErrors['description'] = 'Champ obligatoire';
                    }
                    if (_dateDebutPrevue == null || _dateFinPrevue == null) {
                      _fieldErrors['dates'] = 'Dates obligatoires';
                    } else if (_dateDebutPrevue!.isAfter(_dateFinPrevue!)) {
                      _fieldErrors['dates'] = 'Date début > date fin';
                    }
                    if (_budgetController.text.isEmpty) {
                      _fieldErrors['budget'] = 'Champ obligatoire';
                    } else if (double.tryParse(_budgetController.text) ==
                        null) {
                      _fieldErrors['budget'] = 'Nombre invalide';
                    }
                    if (_typeTransport == null) {
                      _fieldErrors['typeTransport'] = 'Champ obligatoire';
                    }
                    if (_typeTransport == 'Véhicule' &&
                        _selectedVehiculeId == null) {
                      _fieldErrors['vehicule'] = 'Champ obligatoire';
                    }
                    if (_selectedEmployeIds.isEmpty) {
                      _fieldErrors['employes'] =
                          'Sélectionnez au moins un employé';
                    }

                    setState(() {});

                    if (_fieldErrors.isEmpty) {
                      final missionDTO = MissionCreationDTO(
                        titre: _titreController.text,
                        description: _descriptionController.text,
                        dateDebutPrevue: _dateDebutPrevue!,
                        dateFinPrevue: _dateFinPrevue!,
                        priorite: _priorite!,
                        typeMoyenTransport: _typeTransport!,
                        vehiculeId:
                            _typeTransport == 'Véhicule'
                                ? _selectedVehiculeId
                                : null,
                        budget: double.parse(_budgetController.text),
                        employeIds: _selectedEmployeIds,
                      );

                      try {
                        final success = await context
                            .read<MissionProvider>()
                            .updateMission(mission.missionId, missionDTO);

                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mission mise à jour avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          context.read<MissionProvider>().loadMissions();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, MissionDTO mission) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text('Supprimer la mission "${mission.titre}" ?'),
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
                    final success = await context
                        .read<MissionProvider>()
                        .deleteMission(mission.missionId);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mission supprimée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.read<MissionProvider>().loadMissions();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}
*/