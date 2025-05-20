import 'package:flutter/material.dart';

import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
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

  List<String> notifications = [
    'Mission A assignée à Jean.',
    'Nouvelle mise à jour disponible.',
    'Véhicule X a besoin d\'entretien.',
  ];

  List<Widget> getPages() {
    if (widget.userRole == 'admin') {
      return [
        HomeScreen(),
        const ProfileScreen(),
        UserScreenEmploye(),
        VehiculeScreenEmploye(),
        const MissionsScreen(),
        const Placeholder(),
        const Placeholder(),
        const Placeholder(),
      ];
    } else {
      return [
        HomeScreen(),
        const ProfileScreen(),
        UserScreenEmploye(),
        VehiculeScreenEmploye(),
        const MissionsScreen(),
        const Placeholder(),
        const Placeholder(),
        const Placeholder(),
      ];
    }
  }

  List<Widget> getMenuItems() {
    if (widget.userRole == 'admin') {
      return [
       _buildDrawerItem(Icons.home, 'Accueil', 0),
        _buildDrawerItem(Icons.account_circle, 'Profil', 1),
        _buildDrawerItem(Icons.person, 'Utilisateurs', 2),
        _buildDrawerItem(Icons.directions_car, 'Véhicules', 3),
        _buildDrawerItem(Icons.gps_fixed, 'Missions', 4),
        _buildDrawerItem(Icons.check_circle, 'Tâches', 5),
        _buildDrawerItem(Icons.description, 'Rapports', 6),
        _buildDrawerItem(Icons.attach_money, 'Remboursements', 7),
        _buildDrawerItem(Icons.exit_to_app, 'Déconnexion', -1),
      ];
    } else {
      return [
        _buildDrawerItem(Icons.home, 'Accueil', 0),
        _buildDrawerItem(Icons.account_circle, 'Profil', 1),
        _buildDrawerItem(Icons.person, 'Utilisateurs', 2),
        _buildDrawerItem(Icons.directions_car, 'Véhicules', 3),
        _buildDrawerItem(Icons.gps_fixed, 'Missions', 4),
        _buildDrawerItem(Icons.check_circle, 'Tâches', 5),
        _buildDrawerItem(Icons.description, 'Rapports', 6),
        _buildDrawerItem(Icons.attach_money, 'Remboursements', 7),
        _buildDrawerItem(Icons.exit_to_app, 'Déconnexion', -1),
      ];
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: index == selectedIndex ? primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: index == selectedIndex ? primaryColor : null,
          fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Fermer le drawer
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
    List<IconData> icons;
    if (widget.userRole == 'admin') {
      icons = [
        Icons.home,
        Icons.account_circle,
        Icons.person,
        Icons.directions_car,
        Icons.gps_fixed,
        Icons.check_circle,
        Icons.description,
        Icons.attach_money,
      ];
    } else {
      icons = [
        Icons.home,
        Icons.account_circle,
        Icons.person,
        Icons.directions_car,
        Icons.gps_fixed,
        Icons.check_circle,
        Icons.description,
        Icons.attach_money,
      ];
    }

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
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Steros-Missions', style: TextStyle(color: Colors.white)),
      backgroundColor: primaryColor,
      iconTheme: const IconThemeData(color: Colors.white), // sidebar button en blanc
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.notifications, color: Colors.white),
          tooltip: 'Notifications',
          onSelected: (value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Notification: $value')));
          },
          itemBuilder: (context) {
            if (notifications.isEmpty) {
              return [
                const PopupMenuItem<String>(
                  value: 'Aucune notification',
                  child: Text('Aucune notification'),
                ),
              ];
            }
            return notifications.map((notif) {
              return PopupMenuItem<String>(
                value: notif,
                child: Text(notif),
              );
            }).toList();
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
        Expanded(
          child: getPages()[selectedIndex],
        ),
      ],
    ),
  );
}

}
