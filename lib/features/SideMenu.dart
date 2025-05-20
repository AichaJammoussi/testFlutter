/*import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/mission/MissionPage.dart';
import 'package:testfront/features/profile/profile_screen.dart';
import 'package:testfront/features/role/roleScreen.dart';
import 'package:testfront/features/vehicule/vehicueScreen.dart';

void main() {
  runApp(const MyApp());
}

const Color primaryColor = Color(0xFF2A5298);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SideMenuController sideMenu = SideMenuController();
  final PageController pageController = PageController();

  bool isMenuOpen = false; // Le menu commence fermé (icônes seules)

  // Exemple notifications (tu peux remplacer par les tiennes)
  final List<String> notifications = [
    'Mission A assignée à Jean.',
    'Nouvelle mise à jour disponible.',
    'Véhicule X a besoin d\'entretien.',
  ];

  @override
  void initState() {
    super.initState();

    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
      // Pas besoin de Navigator.pop car pas de drawer
    });
  }

  List<SideMenuItem> getSideMenuItems() {
    return [
      SideMenuItem(
        title: 'Accueil',
        icon: const Icon(Icons.home),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Profile',
        icon: const Icon(Icons.account_circle),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Roles',
        icon: const Icon(Icons.security),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Utilisateurs',
        icon: const Icon(Icons.person),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Vehicules',
        icon: const Icon(Icons.directions_car),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Missions',
        icon: const Icon(Icons.gps_fixed),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Taches',
        icon: const Icon(Icons.check_circle),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Rapports',
        icon: const Icon(Icons.description),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Remboursements',
        icon: const Icon(Icons.attach_money),
        onTap: (index, _) => sideMenu.changePage(index),
      ),
      SideMenuItem(
        title: 'Déconnexion',
        icon: const Icon(Icons.exit_to_app),
        onTap: (index, _) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      ),
    ];
  }

  Widget buildSideMenu(bool showFullMenu) {
    return SideMenu(
      controller: sideMenu,
      items: getSideMenuItems(),
      style: SideMenuStyle(
        openSideMenuWidth: 250,
        compactSideMenuWidth: 60,
        displayMode: showFullMenu
            ? SideMenuDisplayMode.open
            : SideMenuDisplayMode.compact,
        hoverColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        selectedTitleTextStyle: const TextStyle(color: Colors.white),
        selectedIconColor: Colors.white,
        backgroundColor: primaryColor.withOpacity(0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Steros-Missions",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            setState(() {
              isMenuOpen = !isMenuOpen;
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'Notifications',
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification sélectionnée: $value')),
              );
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
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isMenuOpen ? 250 : 60,
            child: buildSideMenu(isMenuOpen),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomeScreen(),
                const ProfileScreen(),
                const RoleListScreen(),
                VehiculeScreen(),
                const MissionsScreen(),
                const Placeholder(), // Taches
                const Placeholder(), // Rapports
                const Placeholder(), // Remboursements
                const LoginScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
