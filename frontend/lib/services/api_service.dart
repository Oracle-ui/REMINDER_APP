import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static String? token;
  static int? userId;
  static String? fullName;

  static Map<String, String> getHeaders() {
    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    userId = prefs.getInt("user_id");
    fullName = prefs.getString("full_name");
  }

  static Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      await prefs.setString("token", token!);
    }

    if (userId != null) {
      await prefs.setInt("user_id", userId!);
    }

    if (fullName != null) {
      await prefs.setString("full_name", fullName!);
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("user_id");
    await prefs.remove("full_name");
  }

  static Future<bool> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      token = data["access_token"];
      userId = data["user_id"];
      fullName = data["full_name"];

      await saveSession();

      return true;
    }

    return false;
  }

  static Future<void> logout() async {
    token = null;
    userId = null;
    fullName = null;

    await clearSession();
  }

  static Future<List<dynamic>> getSchedules() async {
    final response = await http.get(
      Uri.parse("$baseUrl/schedules/"),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  static Future<bool> addSchedule(Schedule schedule) async {
    final response = await http.post(
      Uri.parse("$baseUrl/schedules/"),
      headers: getHeaders(),
      body: jsonEncode(schedule.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateSchedule(
    int scheduleId,
    Schedule schedule,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/schedules/$scheduleId"),
      headers: getHeaders(),
      body: jsonEncode(schedule.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteSchedule(int scheduleId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/schedules/$scheduleId"),
      headers: getHeaders(),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteRecurringGroup(String groupId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/schedules/recurring/$groupId"),
      headers: getHeaders(),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> uploadTimetable(
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload/timetable"),
    );

    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        filePath,
        contentType: MediaType("application", "octet-stream"),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    }

    return {
      "message": "Upload failed",
      "gemini_schedules": [],
      "extracted_text": "",
      "gemini_error": responseBody,
    };
  }

  static Future<bool> saveExtractedSchedules(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/upload/save-extracted"),
      headers: getHeaders(),
      body: jsonEncode({
        "text": text,
        "user_id": userId,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> saveGeminiSchedules(List schedules) async {
    final response = await http.post(
      Uri.parse("$baseUrl/upload/save-gemini"),
      headers: getHeaders(),
      body: jsonEncode({
        "user_id": userId,
        "schedules": schedules,
      }),
    );

    return response.statusCode == 200;
  }
}