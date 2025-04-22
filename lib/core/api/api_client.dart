import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  final String baseUrl;
  final String? Function()? getToken;

  ApiClient({required this.baseUrl, this.getToken});

  Future<dynamic> request({
    required String method,
    required String endpoint,
    dynamic data,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(requiresAuth);
      final response = await _sendRequest(method, endpoint, headers, data);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && getToken != null) {
      final token = getToken!();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> _sendRequest(
    String method,
    String endpoint,
    Map<String, String> headers,
    dynamic data,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final body = data != null ? jsonEncode(data) : null;

    switch (method) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: body);
      case 'PUT':
        return await http.put(uri, headers: headers, body: body);
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Méthode HTTP non supportée: $method');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = json.decode(utf8.decode(response.bodyBytes));
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Erreur API (${response.statusCode})');
    }
  }
}