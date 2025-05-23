import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/mission_provider.dart';

class MissionCalendarScreen extends StatefulWidget {
  const MissionCalendarScreen({Key? key}) : super(key: key);

  @override
  State<MissionCalendarScreen> createState() => _MissionCalendarScreenState();
}

class _MissionCalendarScreenState extends State<MissionCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<MissionDTO> _allMissions = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    // Charger les missions après le premier rendu du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) throw Exception('Utilisateur non connecté');

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (user.roles.contains('admin')) {
        await missionProvider.loadMissions();
      } else if(!user.roles.contains('admin')){
        await missionProvider.loadMissionsByUserId(user.id);
      }else{}

      if (!mounted) return;

      setState(() {
        _allMissions = missionProvider.missions;
        _isLoading = false;
        _initialLoadComplete = true;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _loadMissions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) throw Exception('Utilisateur non connecté');

      if (user.isAdmin) {
        await missionProvider.loadMissions();
      } else {
        await missionProvider.loadMissionsByUserId(user.id);
      }

      if (!mounted) return;

      setState(() {
        _allMissions = missionProvider.missions;
        _isLoading = false;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<MissionDTO> _getMissionsForDay(DateTime day) {
    return _allMissions.where((mission) {
      final start = mission.dateDebutReelle ?? mission.dateDebutPrevue;
      final end = mission.dateFinReelle ?? mission.dateFinPrevue;
      if (start == null || end == null) return false;

      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
      final missionStart = DateTime(start.year, start.month, start.day);
      final missionEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

      return (dayStart.isAtSameMomentAs(missionStart) || dayStart.isAfter(missionStart)) &&
          (dayEnd.isAtSameMomentAs(missionEnd) || dayEnd.isBefore(missionEnd));
    }).toList();
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<MissionDTO>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!mounted) return;
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            if (!mounted) return;
            setState(() => _calendarFormat = format);
          },
          eventLoader: _getMissionsForDay,
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
      ),
    );
  }

  Widget _buildMissionList() {
    final missions = _getMissionsForDay(_selectedDay ?? DateTime.now());

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune mission pour cette date',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missions.length,
      itemBuilder: (context, index) => _buildMissionCard(missions[index]),
    );
  }

  Widget _buildMissionCard(MissionDTO mission) {
    final now = DateTime.now();
    final start = mission.dateDebutReelle ?? mission.dateDebutPrevue;
    final end = mission.dateFinReelle ?? mission.dateFinPrevue;
    final isActive = start != null && end != null && now.isAfter(start) && now.isBefore(end);
    final isLate = end != null && now.isAfter(end);
    final statusColor = isLate ? Colors.red : (isActive ? Colors.green : Colors.blue);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLate ? Icons.warning : Icons.assignment,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mission.titre ?? 'Mission sans nom',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  backgroundColor: statusColor.withOpacity(0.2),
                  label: Text(
                    isLate ? 'Passée' : (isActive ? 'En cours' : 'Planifiée'),
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (start != null && end != null)
              Text(
                '${start.toLocal().toString().split(' ')[0]} - ${end.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (mission.employes?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Employés: ${mission.employes!.map((e) => '${e.prenom} ${e.nom}').join(', ')}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && !_initialLoadComplete) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erreur de chargement'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMissions,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_allMissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucune mission disponible'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMissions,
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildCalendar(),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Missions pour le ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildMissionList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des Missions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMissions,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
