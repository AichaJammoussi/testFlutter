import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testfront/main_page_mobile.dart';
import 'package:testfront/main_page_web.dart';


class ResponsiveMainPage extends StatelessWidget {
  final String userRole;

  const ResponsiveMainPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebMainPage(userRole: userRole);
    } else {
      return MainPageMobile(userRole: userRole);
    }
  }
}
