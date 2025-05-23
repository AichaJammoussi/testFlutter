import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/StatutRemboursement.dart';
import 'package:testfront/core/providers/remboursement_provider.dart';
import 'package:testfront/core/providers/mission_provider.dart';

class MesRemboursementsScreen extends StatefulWidget {
  const MesRemboursementsScreen({super.key});

  @override
  State<MesRemboursementsScreen> createState() =>
      _MesRemboursementsScreenState();
}

class _MesRemboursementsScreenState extends State<MesRemboursementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RemboursementProvider>(
        context,
        listen: false,
      ).loadMesRemboursements();
      Provider.of<MissionProvider>(
        context,
        listen: false,
      ).loadMissions(); // Assure que la liste des missions est chargée
    });
  }

  Color _getStatusColor(StatutRemboursement statut) {
    switch (statut) {
      case StatutRemboursement.APPROUVE:
        return Colors.green.shade600;
      case StatutRemboursement.REJETE:
        return Colors.red.shade600;
      case StatutRemboursement.ENATTENTE:
      default:
        return Colors.orange.shade600;
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
        return Icons.hourglass_empty;
    }
  }

  String _getTypeDemandeMessage(double montant) {
    if (montant > 0) {
      return "Demande de remboursement ";
    } else if (montant < 0) {
      return "Retour d'argent à effectuer";
    } else {
      return "Budget égal aux dépenses, aucun remboursement nécessaire";
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );
    final remboursementProvider = Provider.of<RemboursementProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Remboursements'),
        backgroundColor: const Color.fromARGB(255, 253, 254, 255),
      ),
      body: Consumer<RemboursementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                'Erreur : ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (provider.remboursements.isEmpty) {
            return const Center(
              child: Text('Aucune demande de remboursement.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await remboursementProvider.loadMesRemboursements();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.remboursements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final remb = provider.remboursements[index];

                // Récupérer la mission via missionId
                final mission = missionProvider.getMissionById(remb.missionId);
                final titreMission = mission?.titre ?? 'Mission inconnue';
                final descriptionMission = mission?.description ?? '';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(
                        remb.statut,
                      ).withOpacity(0.2),
                      child: Icon(
                        _getStatusIcon(remb.statut),
                        color: _getStatusColor(remb.statut),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      titreMission,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (descriptionMission.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              descriptionMission,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Text(
                          '${_getTypeDemandeMessage(remb.montant)}\n'
                          'Montant : ${remb.montant.abs().toStringAsFixed(2)} DT\n'
                          'Demandé le : ${DateFormat('dd/MM/yyyy– HH:mm').format(remb.dateDemande)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: Text(
                      remb.statut.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(remb.statut),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
