import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  static const String baseUrl = "http://localhost:4000"; // Flutter Web

  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: "token");
  }

  static Future<void> logout() async {
    await _storage.delete(key: "token");
  }

  static Future<void> register(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      throw Exception("Register failed ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body);
    await saveToken(data["token"]);
  }

  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      throw Exception("Login failed ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body);
    await saveToken(data["token"]);
  }

  static Future<void> saveWorkout({
    required String bodyPart,
    required String difficulty,
    required String equipment,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("Not logged in");

    final res = await http.post(
      Uri.parse("$baseUrl/workouts"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "bodyPart": bodyPart,
        "difficulty": difficulty,
        "equipment": equipment,
        "exercises": exercises,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Save workout failed ${res.statusCode}: ${res.body}");
    }
  }

  static Future<List<dynamic>> getMyWorkouts() async {
    final token = await getToken();
    if (token == null) throw Exception("Not logged in");

    final res = await http.get(
      Uri.parse("$baseUrl/workouts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Get workouts failed ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body) as List<dynamic>;
  }
}
