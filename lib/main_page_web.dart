/*import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/profile/profile_screen.dart';
import 'package:testfront/features/role/roleScreen.dart';
import 'package:testfront/features/role/userScreenEmploye.dart';
import 'package:testfront/features/vehicule/vehicueScreen.dart';
import 'package:testfront/features/mission/MissionPage.dart';

const Color primaryColor = Color(0xFF2A5298);

class WebMainPage extends StatefulWidget {
  final String userRole;
  const WebMainPage({super.key, required this.userRole});

  @override
  State<WebMainPage> createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  final SideMenuController sideMenu = SideMenuController();
  final PageController pageController = PageController();
  bool isMenuOpen = true;

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
    });
  }

  List<SideMenuItem> getAdminMenu() {
    return [
      _buildItem('Accueil', Icons.home, 0),
      _buildItem('Profile', Icons.account_circle, 1),
      _buildItem('Roles', Icons.security, 2),
      _buildItem('Utilisateurs', Icons.person, 3),
      _buildItem('Vehicules', Icons.directions_car, 4),
      _buildItem('Missions', Icons.gps_fixed, 5),
      _buildItem('Tâches', Icons.check_circle, 6),
      _buildItem('Rapports', Icons.description, 7),
      _buildItem('Remboursements', Icons.attach_money, 8),
      _buildItem('Déconnexion', Icons.exit_to_app, -1),
    ];
  }

  List<SideMenuItem> getUserMenu() {
    return [
      _buildItem('Accueil', Icons.home, 0),
      _buildItem('Profile', Icons.account_circle, 1),
      _buildItem('Utilisateurs', Icons.person, 3),
      _buildItem('Vehicules', Icons.directions_car, 4),
      _buildItem('Missions', Icons.gps_fixed, 5),
      _buildItem('Tâches', Icons.check_circle, 6),
      _buildItem('Rapports', Icons.description, 7),
      _buildItem('Remboursements', Icons.attach_money, 8),
      _buildItem('Déconnexion', Icons.exit_to_app, -1),
    ];
  }

  SideMenuItem _buildItem(String title, IconData icon, int index) {
    return SideMenuItem(
      title: title,
      icon: Icon(icon),
      onTap: (_, __) {
        if (index == -1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          sideMenu.changePage(index);
        }
      },
    );
  }

  Widget buildSideMenu(bool showFullMenu) {
    return SideMenu(
      controller: sideMenu,
      items: widget.userRole == 'admin' ? getAdminMenu() : getUserMenu(),
      style: SideMenuStyle(
        openSideMenuWidth: 250,
        compactSideMenuWidth: 60,
        displayMode: showFullMenu ? SideMenuDisplayMode.open : SideMenuDisplayMode.compact,
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
        title: const Text("Steros-Missions", style: TextStyle(color: Colors.white)),
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification: $value')));
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
                HomeScreen(),             // 0
                const ProfileScreen(),    // 1
                const RoleListScreen(),   // 2
                UserScreenEmploye(),      // Utilisateurs (3)
                VehiculeScreen(),         // 4
                const MissionsScreen(),   // 5
                const Placeholder(),      // Tâches (6)
                const Placeholder(),      // Rapports (7)
                const Placeholder(),      // Remboursements (8)
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/providers/UserProvider.dart';
import 'package:testfront/core/providers/notification_provider.dart';
import 'package:testfront/core/services/auth_service.dart';

// Importer tes écrans ici
import 'package:testfront/features/auth/login_screen.dart';
import 'package:testfront/features/home/home_screen.dart';
import 'package:testfront/features/home/notificationBadge.dart';
import 'package:testfront/features/home/notification.dart';
import 'package:testfront/features/mapPage.dart';
import 'package:testfront/features/mission/Calendrier.dart';
import 'package:testfront/features/mission/MissionPageEmploye.dart';
import 'package:testfront/features/mission/TacheMission.dart';
import 'package:testfront/features/mission/remboursement/adminRemboursement.dart';
import 'package:testfront/features/mission/remboursement/remboursementEmploye.dart';
import 'package:testfront/features/profile/profile_screen.dart';
import 'package:testfront/features/role/roleScreen.dart';
import 'package:testfront/features/role/userScreenEmploye.dart';
import 'package:testfront/features/vehicule/vehicueScreen.dart';
import 'package:testfront/features/mission/MissionPage.dart';
import 'package:testfront/features/vehicule/vehiculeScreenEmploye.dart';

const Color primaryColor = Color(0xFF2A5298);

class WebMainPage extends StatefulWidget {
  final String userRole; 

  const WebMainPage({super.key, required this.userRole});
  @override
  State<WebMainPage> createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  final SideMenuController sideMenu = SideMenuController();
  final PageController pageController = PageController();
  bool isMenuOpen = true;

  @override
  void initState() {
    super.initState();
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.loadNotifications();
    });
  }

  // Menu Admin
  List<SideMenuItem> getAdminMenu() {
    return [
      _buildItem('Accueil', Icons.home, 0),
      _buildItem('Profile', Icons.account_circle, 1),
      _buildItem('Roles', Icons.security, 2),
      _buildItem('Utilisateurs', Icons.person, 3),
      _buildItem('Véhicules', Icons.directions_car, 4),
      _buildItem('Missions', Icons.task_rounded, 5),
      _buildItem('Rapports', Icons.description, 6),
      _buildItem('Remboursements', Icons.attach_money, 7),
            _buildItem('Roles', Icons.supervised_user_circle_outlined,8),

      _buildItem('Déconnexion', Icons.exit_to_app, -1),
    ];
  }

  // Menu Employé
  List<SideMenuItem> getUserMenu() {
    return [
      _buildItem('Accueil', Icons.home, 0),
      _buildItem('Profile', Icons.account_circle, 1),
      _buildItem('Utilisateurs', Icons.supervised_user_circle_outlined, 2),
      _buildItem('Véhicules', Icons.directions_car, 3),
      _buildItem('Missions', Icons.task_rounded, 4),
      _buildItem('Rapports', Icons.description, 6),
      _buildItem('Remboursements', Icons.attach_money, 5),
      _buildItem('Déconnexion', Icons.exit_to_app, -1),
    ];
  }
  List<SideMenuItem> getNotUserMenu() {
    return [
      _buildItem('Accueil', Icons.home, 0),
      _buildItem('Profile', Icons.account_circle, 1),
     
      _buildItem('Déconnexion', Icons.exit_to_app, -1),
    ];
  }

  final authService = AuthService();
  // Création d'un item de menu
  SideMenuItem _buildItem(String title, IconData icon, int index) {
    return SideMenuItem(
      title: title,
      icon: Icon(icon),
      onTap: (_, __) {
        if (index == -1) {
          authService.logout();

          // Déconnexion : revenir à l'écran login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          sideMenu.changePage(index);
        }
      },
    );
  }

  // Widget menu latéral
  Widget buildSideMenu(bool showFullMenu) {
    return SideMenu(
      controller: sideMenu,
items: () {
  if (widget.userRole == 'admin') {
    return getAdminMenu();
  } else if (widget.userRole != 'admin') {
    return getUserMenu();
  } else {
    return getNotUserMenu();
  }
}(),
      style: SideMenuStyle(
        openSideMenuWidth: 250,
        compactSideMenuWidth: 60,
        displayMode:
            showFullMenu
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
    final notificationProvider = Provider.of<NotificationProvider>(context);

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
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'Calendrier',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              final user = UserProvider().user;
                                              final roles =
                                                  user?.roles ??
                                                  []; // Fournit une liste vide si roles est null
                                              return MissionCalendarScreen(
                                              );
                                            },
                                          ),
                                        );
                                      },
                      ),
                     
IconButton(
                                      icon: const Icon(
                                        Icons.map,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'map',
                                      onPressed: () {
                                       Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MapPage()),
    );})
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
    children: () {
      if (widget.userRole == 'admin') {
        return [
          HomeScreen(), // 0
          const ProfileScreen(), // 1
          const RoleListScreen(), // 2
          EmployesPage(), // 3 Utilisateurs
          VehiculeScreen(), // 4
          const MissionsScreen(), // 5
          const AdminRemboursementsScreen(), // 8 Remboursements
        ];
      } else if (widget.userRole != null && widget.userRole != 'admin') {
        return [
          HomeScreen(), // 0
          const ProfileScreen(), // 1
          EmployesPage(), // 2
          VehiculeScreenEmploye(), // 3
          MissionsScreenEmploye(), // 4
          const MesRemboursementsScreen(), // 5
        //  const Placeholder(), // 6 Rapports
          //const Placeholder(), // 7 Remboursements
        ];
      } else {
        return [
          HomeScreen(), // 0
          const ProfileScreen(), // 1
        ];
      }
    }(),
  ),
),

        ],
      ),
    );
  }
}
