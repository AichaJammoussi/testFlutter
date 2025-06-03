import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/services/VehiculeProvider.dart';

class MissionStatsScreen extends StatefulWidget {
  final List<MissionDTO> missions;

  const MissionStatsScreen({Key? key, required this.missions})
    : super(key: key);

  @override
  State<MissionStatsScreen> createState() => _MissionStatsScreenState();
}

class _MissionStatsScreenState extends State<MissionStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehiculeProvider>(context, listen: false).loadVehicules();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiculeProvider = Provider.of<VehiculeProvider>(context);
    final vehicules = vehiculeProvider.vehicules;

    if (widget.missions.isEmpty) {
      return _buildLoadingScreen();
    }

    final statsData = _calculateStatsData();
    final vehiculeStats = _calculateVehiculeStats(vehicules);

    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.all(20.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildMetricsOverview(
                              statsData.completionRate,
                              statsData.urgentMissions,
                            ),
                            const SizedBox(height: 24),
                            if (vehicules.isNotEmpty) ...[
                              _buildVehiculeStatsOverview(vehiculeStats),
                              const SizedBox(height: 24),
                            ],
                            _buildStatusChart(statsData.byStatut),
                            const SizedBox(height: 24),
                            if (vehicules.isNotEmpty) ...[
                              _buildVehiculeStatusChart(vehiculeStats.byStatus),
                              const SizedBox(height: 24),
                            ],
                            _buildPriorityChart(statsData.byPriorite),
                            const SizedBox(height: 24),
                            _buildTrendAnalysis(),
                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement des statistiques...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Tableau de Bord',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            _animationController.reset();
            _animationController.forward();
            Provider.of<VehiculeProvider>(
              context,
              listen: false,
            ).loadVehicules();
          },
        ),
      ],
    );
  }

  Widget _buildMetricsOverview(double completionRate, int urgentMissions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.blue.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Vue d\'ensemble des missions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total',
                  widget.missions.length.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Taux de completion',
                  '${completionRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Urgentes',
                  urgentMissions.toString(),
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'En cours',
                  _countInProgress().toString(),
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculeStatsOverview(VehiculeStatsData stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Statistiques du parc automobile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildVehiculeMetricCard(
                  'Véhicules total',
                  stats.totalVehicules.toString(),
                  Icons.directions_car,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVehiculeMetricCard(
                  'Disponibles',
                  stats.disponibles.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVehiculeMetricCard(
                  'En mission',
                  stats.enMission.toString(),
                  Icons.assignment,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVehiculeMetricCard(
                  'En maintenance',
                  stats.enMaintenance.toString(),
                  Icons.build,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculeMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart(Map<String, int> byStatut) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.donut_large, color: Colors.purple.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Répartition par statut',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildPieChart(byStatut)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildLegend(byStatut)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculeStatusChart(Map<String, int> byStatus) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Colors.deepOrange.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Statut des véhicules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 300, child: _buildVehiculeDonutChart(byStatus)),
        ],
      ),
    );
  }

  Widget _buildVehiculeDonutChart(Map<String, int> data) {
    final colors = {
      'disponible': Colors.green.shade400,
      'en_mission': Colors.blue.shade400,
      'maintenance': Colors.orange.shade400,
      'hors_service': Colors.red.shade400,
    };

    final sections =
        data.entries.map((entry) {
          final color = colors[entry.key.toLowerCase()] ?? Colors.grey.shade400;
          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 60, sectionsSpace: 4),
    );
  }

  Widget _buildPriorityChart(Map<String, int> byPriorite) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.indigo.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Répartition par priorité',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 280, child: _buildEnhancedBarChart(byPriorite)),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.teal.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Analyse des tendances',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildLineChart(widget.missions),
          ), 
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
    ];

    int colorIndex = 0;
    final sections =
        data.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;

          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: entry.value.toString(),
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          );
        }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> data) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
    ];

    int colorIndex = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          data.entries.map((entry) {
            final color = colors[colorIndex % colors.length];
            colorIndex++;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEnhancedBarChart(Map<String, int> data) {
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    final colors = [
      Colors.indigo.shade400,
      Colors.cyan.shade400,
      Colors.amber.shade400,
      Colors.pink.shade400,
    ];

    int index = 0;
    data.forEach((label, value) {
      labels.add(label);
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: colors[index % colors.length],
              width: 30,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              gradient: LinearGradient(
                colors: [
                  colors[index % colors.length].withOpacity(0.7),
                  colors[index % colors.length],
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: (data.values.reduce((a, b) => a > b ? a : b).toDouble()) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${labels[group.x.toInt()]}\n${rod.toY.round()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            tooltipMargin: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBorder: const BorderSide(color: Colors.white, width: 1),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildLineChart(List<MissionDTO> missions) {
    // 1. Préparation des données mensuelles
    final monthlyData = <String, int>{};

    for (final mission in missions) {
      final monthKey = DateFormat('yyyy-MM').format(mission.dateDebutPrevue);
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
    }

    // 2. Tri des mois chronologiquement
    final sortedMonths =
        monthlyData.keys.toList()..sort((a, b) => a.compareTo(b));

    // 3. Création des points pour le graphique
    final spots =
        sortedMonths.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            monthlyData[entry.value]!.toDouble(),
          );
        }).toList();

    // 4. Calcul des valeurs max pour l'axe Y
    final maxY =
        monthlyData.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedMonths.length)
                  return const SizedBox();
                final month = sortedMonths[value.toInt()].substring(5, 7);
                return Text(
                  DateFormat('MMM').format(DateTime(0, int.parse(month))),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: sortedMonths.length > 0 ? sortedMonths.length.toDouble() - 1 : 0,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.3),
                  Colors.blueAccent.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blueAccent,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {},
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot touchedSpot) => Colors.blueGrey,
            tooltipPadding: const EdgeInsets.all(8),
            maxContentWidth: 200,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((spot) {
                final month = sortedMonths[spot.x.toInt()];
                final count = monthlyData[month]!;
                return LineTooltipItem(
                  '${DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'))}\n$count missions',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  _StatsData _calculateStatsData() {
    return _StatsData(
      byStatut: _countBy((m) => m.statut.name),
      byPriorite: _countBy((m) => m.priorite.name),
      completionRate: _calculateCompletionRate(),
      urgentMissions: _countUrgentMissions(),
    );
  }

  VehiculeStatsData _calculateVehiculeStats(List<VehiculeDTO> vehicules) {
    final byStatus = <String, int>{};
    int disponibles = 0;
    int enMission = 0;
    int enMaintenance = 0;

    for (final vehicule in vehicules) {
      final status = vehicule.statut.name.toLowerCase();
      byStatus[status] = (byStatus[status] ?? 0) + 1;

      if (status == 'disponible') {
        disponibles++;
      } else if (status == 'en_mission') {
        enMission++;
      } else if (status == 'maintenance') {
        enMaintenance++;
      }
    }

    return VehiculeStatsData(
      totalVehicules: vehicules.length,
      disponibles: disponibles,
      enMission: enMission,
      enMaintenance: enMaintenance,
      byStatus: byStatus,
    );
  }

  Map<String, int> _countBy(String Function(MissionDTO) keySelector) {
    final map = <String, int>{};
    for (final mission in widget.missions) {
      final key = keySelector(mission);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  double _calculateCompletionRate() {
    if (widget.missions.isEmpty) return 0.0;
    final completed =
        widget.missions
            .where(
              (m) =>
                  m.statut.name.toLowerCase() == 'terminée' ||
                  m.statut.name.toLowerCase() == 'completed',
            )
            .length;
    return (completed / widget.missions.length) * 100;
  }

  int _countUrgentMissions() {
    return widget.missions
        .where(
          (m) =>
              m.priorite.name.toLowerCase() == 'urgent' ||
              m.priorite.name.toLowerCase() == 'haute',
        )
        .length;
  }

  int _countInProgress() {
    return widget.missions
        .where(
          (m) =>
              m.statut.name.toLowerCase() == 'en cours' ||
              m.statut.name.toLowerCase() == 'in progress',
        )
        .length;
  }
}

class _StatsData {
  final Map<String, int> byStatut;
  final Map<String, int> byPriorite;
  final double completionRate;
  final int urgentMissions;

  _StatsData({
    required this.byStatut,
    required this.byPriorite,
    required this.completionRate,
    required this.urgentMissions,
  });
}

class VehiculeStatsData {
  final int totalVehicules;
  final int disponibles;
  final int enMission;
  final int enMaintenance;
  final Map<String, int> byStatus;

  VehiculeStatsData({
    required this.totalVehicules,
    required this.disponibles,
    required this.enMission,
    required this.enMaintenance,
    required this.byStatus,
  });
}
