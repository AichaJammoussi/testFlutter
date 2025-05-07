import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/profile_model.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/profile_service.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Mon Profil", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
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
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.black87, Colors.grey[900]!]
                        : [Colors.blue[50]!, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : const AssetImage('lib/core/images/user.png')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${profile.nom} ${profile.prenom}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            profile.email,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            profile.phoneNumber ?? "Téléphone non renseigné",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.logout),
                            label: const Text("Déconnexion"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          )
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
