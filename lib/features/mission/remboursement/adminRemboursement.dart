import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/StatutRemboursement.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/providers/remboursement_provider.dart';

class AdminRemboursementsScreen extends StatefulWidget {
  const AdminRemboursementsScreen({super.key});

  @override
  State<AdminRemboursementsScreen> createState() =>
      _AdminRemboursementsScreenState();
}

class _AdminRemboursementsScreenState extends State<AdminRemboursementsScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  String _searchQuery = '';
  StatutRemboursement? _selectedStatut;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final remboursementProvider = Provider.of<RemboursementProvider>(
      context,
      listen: false,
    );
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );

    await remboursementProvider.loadTousLesRemboursements();
    await missionProvider.loadMissions();
  }

  Color _getStatusColor(StatutRemboursement statut) {
    switch (statut) {
      case StatutRemboursement.APPROUVE:
        return Colors.green.shade300;
      case StatutRemboursement.REJETE:
        return Colors.red.shade300;
      case StatutRemboursement.ENATTENTE:
      default:
        return Colors.orange.shade300;
    }
  }

  IconData _getStatusIcon(StatutRemboursement statut) {
    switch (statut) {
      case StatutRemboursement.APPROUVE:
        return Icons.check_circle_outline;
      case StatutRemboursement.REJETE:
        return Icons.cancel_outlined;
      case StatutRemboursement.ENATTENTE:
      default:
        return Icons.hourglass_bottom;
    }
  }

  Future<void> _confirmerChangementStatut(
    int id,
    StatutRemboursement nouveauStatut,
  ) async {
    final message =
        nouveauStatut == StatutRemboursement.REJETE
            ? 'Voulez-vous vraiment rejeter le remboursement ?'
            : 'Voulez-vous vraiment approuver le remboursement ?';

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Confirmer le changement',
              style: TextStyle(
                color: Colors.blueGrey.shade800,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.blueGrey.shade700),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 187, 204, 234),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5298),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _changerStatut(id, nouveauStatut);
    }
  }

  Future<void> _changerStatut(int id, StatutRemboursement nouveauStatut) async {
    final provider = Provider.of<RemboursementProvider>(context, listen: false);

    try {
      await provider.changerStatut(id, nouveauStatut);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande remboursement mise à jour avec succès'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    }
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une mission',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    ),
                    filled: true,
                    fillColor: Colors.blueGrey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged:
                      (value) => setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      }),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey.shade200),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.blueGrey.shade50,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StatutRemboursement?>(
                    value: _selectedStatut,
                    hint: Text(
                      'Statut',
                      style: TextStyle(color: Colors.blueGrey.shade600),
                    ),
                    onChanged:
                        (value) => setState(() {
                          _selectedStatut = value;
                          _currentPage = 1;
                        }),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous')),
                      ...StatutRemboursement.values.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color:
                  _currentPage > 1
                      ? Colors.blueGrey.shade400
                      : Colors.blueGrey.shade200,
            ),
            onPressed:
                _currentPage > 1 ? () => setState(() => _currentPage--) : null,
            tooltip: 'Page précédente',
          ),
          const SizedBox(width: 8),
          Text(
            'Page $_currentPage / $totalPages',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color:
                  _currentPage < totalPages
                      ? Colors.blueGrey.shade400
                      : Colors.blueGrey.shade200,
            ),
            onPressed:
                _currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
            tooltip: 'Page suivante',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remboursementProvider = Provider.of<RemboursementProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);

    final filteredRemboursements =
        remboursementProvider.remboursements.where((r) {
          final missionTitre =
              missionProvider
                  .getMissionById(r.missionId)
                  ?.titre
                  ?.toLowerCase() ??
              '';
          final matchesStatut =
              _selectedStatut == null || r.statut == _selectedStatut;
          final matchesSearch = missionTitre.contains(
            _searchQuery.toLowerCase(),
          );
          return matchesStatut && matchesSearch;
        }).toList();

    final total = filteredRemboursements.length;
    final totalPages = (total / _itemsPerPage).ceil();
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (_currentPage * _itemsPerPage).clamp(0, total);
    final paginated = filteredRemboursements.sublist(start, end);

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: const Text("Remboursements - Admin"),
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder:
              (context, constraints) => Column(
                children: [
                  _buildFilterSection(),
                  Expanded(
                    child:
                        remboursementProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : paginated.isEmpty
                            ? Center(
                              child: Text(
                                'Aucun remboursement trouvé',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: paginated.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final remb = paginated[index];
                                final mission = missionProvider.getMissionById(
                                  remb.missionId,
                                );
                                final titre =
                                    mission?.titre ?? 'Mission inconnue';
                                final description = mission?.description ?? '';

                                final remboursementOuRendre =
                                    remb.montant >= 0
                                        ? '💰 À REMBOURSER à l’employé'
                                        : '↩️ À REMETTRE à l’entreprise';

                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: _getStatusColor(
                                        remb.statut,
                                      ).withOpacity(0.3),
                                      child: Icon(
                                        _getStatusIcon(remb.statut),
                                        color: _getStatusColor(remb.statut),
                                      ),
                                    ),
                                    title: Text(
                                      titre,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey.shade900,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              description,
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 13,
                                                color: Colors.blueGrey.shade600,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Montant : ${remb.montant.abs().toStringAsFixed(2)} DT',
                                          style: TextStyle(
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                        Text(
                                          'Demandé le : ${DateFormat('dd/MM/yyyy HH:mm').format(remb.dateDemande)}',
                                          style: TextStyle(
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                        if (remb.dateValidation != null)
                                          Text(
                                            'Validé le : ${DateFormat('dd/MM/yyyy HH:mm').format(remb.dateValidation!)}',
                                            style: TextStyle(
                                              color: Colors.blueGrey.shade700,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          remboursementOuRendre,
                                          style: TextStyle(
                                            color:
                                                remb.montant >= 0
                                                    ? Colors.green.shade300
                                                    : Colors.red.shade300,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Statut actuel : ${remb.statut.name}',
                                          style: TextStyle(
                                            color: _getStatusColor(remb.statut),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        remb.statut ==
                                                StatutRemboursement.ENATTENTE
                                            ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.check,
                                                    color:
                                                        Colors.green.shade300,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _confirmerChangementStatut(
                                                            remb.remboursementId,
                                                            StatutRemboursement
                                                                .APPROUVE,
                                                          ),
                                                  tooltip: 'Approuver',
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.red.shade300,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _confirmerChangementStatut(
                                                            remb.remboursementId,
                                                            StatutRemboursement
                                                                .REJETE,
                                                          ),
                                                  tooltip: 'Rejeter',
                                                ),
                                              ],
                                            )
                                            : null,
                                  ),
                                );
                              },
                            ),
                  ),
                  if (totalPages > 1) _buildPaginationControls(totalPages),
                ],
              ),
        ),
      ),
    );
  }
}
