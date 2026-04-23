import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get headers {
    final Map<String, String> h = {
      'Content-Type': 'application/json',
    };
    if (authTokenNotifier.value != null) {
      h['Authorization'] = 'Bearer ${authTokenNotifier.value}';
    }
    return h;
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${KApi.baseUrl}$endpoint');
      final response = await http.get(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Request failed');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check your server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${KApi.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Request failed');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check your server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${KApi.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Request failed');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check your server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${KApi.baseUrl}$endpoint');
      final response = await http.delete(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Request failed');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check your server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
