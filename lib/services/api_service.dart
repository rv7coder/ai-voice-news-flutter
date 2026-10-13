import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiService {
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse(
      "${AppConstants.baseUrl}$endpoint",
    );
    return await http.get(url);
  }
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
    ) async {
      final url = Uri.parse(
        "${AppConstants.baseUrl}$endpoint",
      );
      return await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    }
    static Future<http.Response> delete(
    String endpoint,
  ) async {
    final url = Uri.parse(
        "${AppConstants.baseUrl}$endpoint");

    return await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
  }
  static String getMediaUrl(String path) {
    return "${AppConstants.baseUrl}$path";
  }
  static Future<http.Response> put(
  String endpoint,
  Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      "${AppConstants.baseUrl}$endpoint",
    );
    return await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }
}