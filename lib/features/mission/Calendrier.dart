/*import 'package:flutter/material.dart';
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
}*/
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

  // Définition des couleurs
  static const Color _lateColor = Color(0xFFE57373);    // Rouge
  static const Color _activeColor = Color(0xFF64B5F6);  // Bleu
  static const Color _futureColor = Color(0xFF81C784);  // Vert
  static const Color _todayColor = Color(0xFFFFB74D);   // Orange
  static const Color _selectedColor = Color(0xFF9575CD); // Violet
  static const Color _textColor = Color(0xFF333333);
  static const Color _lightBackground = Color(0xFFFAFAFA);
  String _monthName(int month) {
  const months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return months[month - 1];
}


  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) throw Exception('Utilisateur non connecté');

      setState(() => _isLoading = true);

      await (user.roles.contains('admin') 
          ? missionProvider.loadMissions() 
          : missionProvider.loadMissionsByUserId(user.id));

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
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      
      await (user?.isAdmin ?? false 
          ? missionProvider.loadMissions() 
          : missionProvider.loadMissionsByUserId(user?.id ?? ''));
      
      if (!mounted) return;
      
      setState(() => _allMissions = missionProvider.missions);
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleError(dynamic error) {
    if (!mounted) return;
    
    setState(() => _hasError = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${error.toString()}'),
        backgroundColor: _lateColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<MissionDTO> _getMissionsForDay(DateTime day) {
    return _allMissions.where((mission) {
      final start = mission.dateDebutReelle ?? mission.dateDebutPrevue;
      final end = mission.dateFinReelle ?? mission.dateFinPrevue;
      if (start == null || end == null) return false;

      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final missionStart = DateTime(start.year, start.month, start.day);
      final missionEnd = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));

      return (dayStart.isBefore(missionEnd) && dayEnd.isAfter(missionStart));
    }).toList();
  }

  Color _getDayColor(DateTime day) {
    final now = DateTime.now();
    final missions = _getMissionsForDay(day);
    
    if (missions.isEmpty) return Colors.transparent;

    final hasLate = missions.any((m) {
      final end = m.dateFinReelle ?? m.dateFinPrevue;
      return end != null && now.isAfter(end);
    });

    if (hasLate) return _lateColor.withOpacity(0.3);

    final hasActive = missions.any((m) {
      final start = m.dateDebutReelle ?? m.dateDebutPrevue;
      final end = m.dateFinReelle ?? m.dateFinPrevue;
      return start != null && end != null && now.isAfter(start) && now.isBefore(end);
    });

    return hasActive ? _activeColor.withOpacity(0.3) : _futureColor.withOpacity(0.3);
  }

  Widget _buildCalendar() {
  final isEmpty = _allMissions.isEmpty;

  return Card(
    margin: const EdgeInsets.all(12),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: TableCalendar<MissionDTO>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) => setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        }),
        onFormatChanged: (format) => setState(() => _calendarFormat = format),

        // Si aucune mission : pas de loader
        eventLoader: isEmpty ? null : _getMissionsForDay,

        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final hasEvents = !isEmpty && _getMissionsForDay(day).isNotEmpty;
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasEvents ? _getDayColor(day) : _lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasEvents ? Colors.white : _textColor,
                  ),
                ),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(
          defaultDecoration: BoxDecoration(
            color: _lightBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          weekendDecoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          outsideDecoration: const BoxDecoration(shape: BoxShape.rectangle),
          markerDecoration: const BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          todayDecoration: BoxDecoration(
            color: _todayColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: _selectedColor,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(color: _textColor),
          weekendTextStyle: const TextStyle(color: _textColor),
          selectedTextStyle: const TextStyle(color: Colors.white),
          todayTextStyle: const TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonShowsNext: false,
          titleTextFormatter: (date, locale) =>
              '${_monthName(date.month)} ${date.year}',
          titleTextStyle: const TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: _selectedColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: _selectedColor),
          formatButtonDecoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: _textColor),
          weekendStyle: TextStyle(color: _textColor),
        ),
      ),
    ),
  );
}


 Widget _buildColorLegend() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLegendItem(_lateColor, 'Passée'),
          const SizedBox(width: 12),
          _buildLegendItem(_activeColor, 'En cours'),
          const SizedBox(width: 12),
          _buildLegendItem(_futureColor, 'Planifiée'),
          const SizedBox(width: 12),
          _buildLegendItem(_todayColor, "Aujourd'hui"),
        ],
      ),
    ),
  );
}

Widget _buildLegendItem(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    ],
  );
}


  Widget _buildMissionCard(MissionDTO mission) {
    final now = DateTime.now();
    final start = mission.dateDebutReelle ?? mission.dateDebutPrevue;
    final end = mission.dateFinReelle ?? mission.dateFinPrevue;
    final isActive = start != null && end != null && now.isAfter(start) && now.isBefore(end);
    final isLate = end != null && now.isAfter(end);
    final statusColor = isLate ? _lateColor : (isActive ? _activeColor : _futureColor);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                isLate ? Icons.history_edu : (isActive ? Icons.timelapse : Icons.schedule),
                color: statusColor,
                size: 24,
              ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mission.titre ?? 'Mission sans nom',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isLate ? 'Passée' : (isActive ? 'En cours' : 'Planifiée'),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (start != null && end != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(start)} - ${_formatDate(end)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            if (mission.employes?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Employés: ${mission.employes!.map((e) => '${e.prenom} ${e.nom}').join(', ')}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildMissionList() {
    final missions = _getMissionsForDay(_selectedDay ?? DateTime.now());

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucune mission pour cette date',
              style: TextStyle(color: _textColor.withOpacity(0.6)),
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

  Widget _buildContent() {
    if (_isLoading && !_initialLoadComplete) {
      return Center(child: CircularProgressIndicator(color: _selectedColor));
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Actualiser', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildCalendar(),
        _buildColorLegend(),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Missions pour le ${_formatDate(_selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
      backgroundColor: _lightBackground,
      appBar: AppBar(
        title: const Text('Calendrier des Missions'),
        backgroundColor: _selectedColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
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
