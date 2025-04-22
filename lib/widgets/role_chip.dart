import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String role;
  final VoidCallback? onDeleted;

  const RoleChip({
    super.key,
    required this.role,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(role),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
    );
  }
}