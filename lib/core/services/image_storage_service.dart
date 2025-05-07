import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ImageStorageService {
  static Future<String?> downloadAndSaveImage(String imageUrl) async {
    try {
      if (kIsWeb) {
        return _handleWebDownload(imageUrl);
      } else {
        return _handleMobileDownload(imageUrl);
      }
    } catch (e) {
      print('Erreur de téléchargement: $e');
      return null;
    }
  }

  static Future<String?> _handleMobileDownload(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/profile_images');
    
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final filename = p.basename(imageUrl);
    final filePath = '${imageDir.path}/$filename';

    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }
    return null;
  }

  static Future<String?> _handleWebDownload(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        return url;
      }
    } catch (e) {
      print('Erreur web: $e');
    }
    return null;
  }

  static Future<String?> getLocalImagePath(String imageUrl) async {
    if (kIsWeb) {
      return imageUrl; // Retourne directement l'URL sur le web
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = p.basename(imageUrl);
      final filePath = '${directory.path}/profile_images/$filename';

      if (await File(filePath).exists()) {
        return filePath;
      }
    } catch (e) {
      print('Erreur de vérification: $e');
    }
    return null;
  }

  static Future<String> getRelativePath(String absolutePath) async {
    if (kIsWeb) return absolutePath;
    
    final dir = await getApplicationDocumentsDirectory();
    return p.relative(absolutePath, from: dir.path);
  }
}