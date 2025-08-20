import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api/";

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse("${baseUrl}register"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    print("REGISTER Status: ${response.statusCode}");
    print("REGISTER Body: ${response.body}");

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "error": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Invalid response format",
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("${baseUrl}login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN Status: ${response.statusCode}");
    print("LOGIN Body: ${response.body}");

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "error": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Invalid response format",
      };
    }
  }
}
