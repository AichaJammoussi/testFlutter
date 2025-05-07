import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF2A5298)),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? const Color(0xFF172B5A),
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A869A)),
      onTap: onTap,
    );
  }
}