import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';

class MissionCalendarScreen extends StatefulWidget {
  final List<String> userRoles;

  const MissionCalendarScreen({super.key, required this.userRoles});

  @override
  State<MissionCalendarScreen> createState() => _MissionCalendarScreenState();
}

class _MissionCalendarScreenState extends State<MissionCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<MissionDTO> _allMissions = [];

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final missionProvider = Provider.of<MissionProvider>(
      context,
      listen: false,
    );

    while (userProvider.user == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final user = userProvider.user!;
    final roles = widget.userRoles;

    if (roles.contains('admin')) {
      await missionProvider.loadMissions();
      print('Admin: toutes les missions chargées');
    } else {
      await missionProvider.loadMissionsByUserId(user.id);
      print('Utilisateur: missions chargées pour userId=${user.id}');
    }

    setState(() {
      _allMissions = missionProvider.missions;
    });
  }

  List<MissionDTO> _getMissionsForDay(DateTime day) {
    return _allMissions.where((mission) {
      final dateDebut = mission.dateDebutReelle ?? mission.dateDebutPrevue;
      final dateFin = mission.dateFinReelle ?? mission.dateFinPrevue;
      if (dateDebut == null || dateFin == null) return false;
      return !day.isBefore(dateDebut) && !day.isAfter(dateFin);
    }).toList();
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier des Missions')),
      body:
          _allMissions.isEmpty
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TableCalendar<MissionDTO>(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2050),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: (day) => _getMissionsForDay(day),
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: Colors.blue[400],
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                    ),

                    // Légende
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(Colors.green, 'Active'),
                          _buildLegendItem(Colors.red, 'En retard'),
                          _buildLegendItem(Colors.blue[400]!, 'Planifiée'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_selectedDay != null) ...[
                      Text(
                        'Missions pour le ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            _getMissionsForDay(_selectedDay!).isEmpty
                                ? Center(
                                  child: Text(
                                    'Aucune mission pour cette date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount:
                                      _getMissionsForDay(_selectedDay!).length,
                                  itemBuilder: (context, index) {
                                    final mission =
                                        _getMissionsForDay(
                                          _selectedDay!,
                                        )[index];

                                    final now = DateTime.now();
                                    final start =
                                        mission.dateDebutReelle ??
                                        mission.dateDebutPrevue;
                                    final end =
                                        mission.dateFinReelle ??
                                        mission.dateFinPrevue;
                                    final isActive =
                                        (start != null &&
                                            end != null &&
                                            now.isAfter(start) &&
                                            now.isBefore(end));
                                    final isLate =
                                        (end != null && now.isAfter(end));

                                    return Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                        leading: Icon(
                                          isLate
                                              ? Icons.error
                                              : Icons.check_circle,
                                          color:
                                              isLate
                                                  ? Colors.red
                                                  : (isActive
                                                      ? Colors.green
                                                      : Colors.grey),
                                          size: 32,
                                        ),
                                        title: Text(
                                          mission.titre ?? 'Mission sans nom',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.people,
                                                    size: 16,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      'Employés: ${mission.employes?.map((e) => e.nom).join('') ?? 'Non assigné'}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.directions_car,
                                                    size: 16,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      'Véhicules: ${mission.vehicules?.map((v) => v.immatriculation).join(', ') ?? 'Non assigné'}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    size: 16,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Période: ${start?.toLocal().toString().split(' ')[0] ?? 'Non définie'} - ${end?.toLocal().toString().split(' ')[0] ?? 'Non définie'}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.info_outline,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            // TODO: Ajouter action détails mission
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
