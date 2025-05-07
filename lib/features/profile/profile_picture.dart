import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfilePicture({Key? key, this.imageUrl, this.size = 80})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A5298), width: 2),
      ),
      child: ClipOval(
        child:
            imageUrl != null
                ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE0E6ED),
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: const Color(0xFF2A5298),
        ),
      ),
    );
  }
}
