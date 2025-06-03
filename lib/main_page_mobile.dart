import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/notification_provider.dart';
import 'package:testfront/core/services/auth_service.dart';

import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/home/notification.dart';
import 'package:testfront/features/home/notificationBadge.dart';
import 'package:testfront/features/mapPage.dart';
import 'package:testfront/features/mission/Calendrier.dart';
import 'package:testfront/features/mission/MissionPageEmploye.dart';
import 'package:testfront/features/mission/remboursement/adminRemboursement.dart';
import 'package:testfront/features/mission/remboursement/remboursementEmploye.dart';
import 'package:testfront/features/notePage.dart';
import 'package:testfront/features/profile/profile_screen.dart';
import 'package:testfront/features/role/roleScreen.dart';
import 'package:testfront/features/role/userScreenEmploye.dart';
import 'package:testfront/features/vehicule/vehicueScreen.dart';
import 'package:testfront/features/vehicule/vehiculeScreenEmploye.dart';
import 'package:testfront/features/mission/MissionPage.dart';

const Color primaryColor = Color(0xFF2A5298);

class MainPageMobile extends StatefulWidget {
  final String userRole;
  const MainPageMobile({Key? key, required this.userRole}) : super(key: key);

  @override
  State<MainPageMobile> createState() => _MainPageMobileState();
}

class _MainPageMobileState extends State<MainPageMobile> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.loadNotifications();
  }

  List<Widget> getPages() {
    if (widget.userRole == 'admin') {
      return [
        HomeScreen(),
        const ProfileScreen(),
        EmployesPage(),
        VehiculeScreen(),
        const MissionsScreen(),
        AdminRemboursementsScreen(),
        NotesApp(),
      ];
    } else if (widget.userRole != null && widget.userRole != 'admin') {
      return [
        HomeScreen(),
        const ProfileScreen(),
        EmployesPage(),
        VehiculeScreenEmploye(),

        const MissionsScreenEmploye(),
        const MesRemboursementsScreen(),
        NotesApp(),
      ];
    } else {
      return[

      ];
    }
  }

  List<Widget> getMenuItems() {
    if (widget.userRole == 'admin') {
      return [
        _buildDrawerItem(Icons.home, 'Accueil', 0),
        _buildDrawerItem(Icons.account_circle, 'Profil', 1),
        _buildDrawerItem(Icons.person, 'Utilisateurs', 2),
        _buildDrawerItem(Icons.directions_car, 'Véhicule', 3),

        _buildDrawerItem(Icons.task_rounded, 'Mission', 4),
        _buildDrawerItem(Icons.attach_money, 'Remboursements', 5),

        _buildDrawerItem(Icons.description, 'Notes', 6),
        _buildDrawerItem(Icons.exit_to_app, 'Déconnexion', -1),
      ];
    } else if (widget.userRole != null && widget.userRole != 'admin') {
      return [
        _buildDrawerItem(Icons.home, 'Accueil', 0),
        _buildDrawerItem(Icons.account_circle, 'Profil', 1),
        _buildDrawerItem(Icons.person, 'Utilisateurs', 2),
        _buildDrawerItem(Icons.directions_car, 'Véhicule', 3),

        _buildDrawerItem(Icons.task_rounded, 'Mission', 4),
        _buildDrawerItem(Icons.attach_money, 'Remboursements', 5),

        _buildDrawerItem(Icons.description, 'Notes', 6),
        _buildDrawerItem(Icons.exit_to_app, 'Déconnexion', -1),
      ];
    } else {
      return[

      ];
    }
  }

  final authService = AuthService();
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: index == selectedIndex ? primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: index == selectedIndex ? primaryColor : null,
          fontWeight:
              index == selectedIndex ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Fermer le drawer
        authService.logout();

        if (index == -1) {
          // Déconnexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          setState(() {
            selectedIndex = index;
          });
        }
      },
    );
  }

  List<Widget> getMenuIconsOnly() {
    List<IconData> icons = [
      Icons.home,
      Icons.account_circle,
      Icons.person,
      Icons.directions_car,
      Icons.task_rounded,
      Icons.attach_money,
      Icons.description,
    ];

    return List.generate(icons.length, (index) {
      return IconButton(
        icon: Icon(
          icons[index],
          color: index == selectedIndex ? primaryColor : Colors.grey[700],
        ),
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },
        tooltip: 'Menu ${index + 1}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Steros-Missions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // sidebar button en blanc
        actions: [
          NotificationBadge(
            unreadCount: notificationProvider.unreadCount,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            tooltip: 'Calendrier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MissionCalendarScreen()),
              );
              // Fournit une liste vide si roles est null
            },
          ),

          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: 'map',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => MapPage()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 120,
              decoration: BoxDecoration(color: primaryColor),
              child: Stack(
                children: [
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            ...getMenuItems(),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getMenuIconsOnly(),
            ),
          ),
          Expanded(child: getPages()[selectedIndex]),
        ],
      ),
    );
  }
}
