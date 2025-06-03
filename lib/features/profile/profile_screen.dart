import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/profile_model.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/profile_service.dart';
import 'package:testfront/features/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<ResponseDTO<UserProfileDTO>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder<ResponseDTO<UserProfileDTO>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final profile = snapshot.data?.data;
          if (profile == null) {
            return const Center(child: Text('Profil non trouvé'));
          }

          final baseUrl = ApiConfig.baseUrl;
          final imageUrl = profile.photoDeProfil != null
              ? '$baseUrl${profile.photoDeProfil}'
              : null;

          return Stack(
            children: [
              // Fond dégradé pastel foncé
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF1E293B), Color(0xFF334155)]
                        : [Color(0xFFcbd5e1), Color(0xFFe2e8f0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // AppBar transparente avec bouton edit
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // pour équilibrer
                    Text(
                      "Mon Profil",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: isDark ? Colors.white70 : Colors.blueGrey[700],
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              userProfile: profile,
                            ),
                          ),
                        );
                        if (updated == true) {
                          setState(() {
                            _profileFuture = _profileService.getUserProfile();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Carte profil
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 380,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 28,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.blueGrey.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.4)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : const AssetImage('lib/core/images/user.png')
                                    as ImageProvider,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          const SizedBox(height: 25),
                          Text(
                            '${profile.nom} ${profile.prenom}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey[900],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            profile.email,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.blueGrey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            profile.phoneNumber ?? "Téléphone non renseigné",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.blueGrey[700],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
