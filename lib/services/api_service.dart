import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP jika test di device fisik (pakai IP komputer, bukan localhost)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static String? _token;
  static Map<String, dynamic>? _currentUser;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isHr => _currentUser?['role_user'] == 1;
  static String get userId => _currentUser?['id_user'] ?? '';
  static String get userName => _currentUser?['nama_user'] ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String idUser, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'id_user': idUser, 'password': password}),
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Login gagal');
    }

    final body = jsonDecode(res.body);
    _token = body['token'];
    _currentUser = body['user'];
    return body;
  }

  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _headers);
    } catch (_) {}
    _token = null;
    _currentUser = null;
  }

  // ── Assessments ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAssessmentHistory({String? idUser}) async {
    final query = idUser != null ? '?id_user=$idUser' : '';
    final res = await http.get(Uri.parse('$baseUrl/assessments/history$query'), headers: _headers);
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  static Future<Map<String, dynamic>> submitAssessment({
    required int totalScore,
    required int kategoriStres,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/assessments'),
      headers: _headers,
      body: jsonEncode({'total_score': totalScore, 'kategori_stres': kategoriStres}),
    );
    return jsonDecode(res.body);
  }

  // ── Incident Reports ──────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getReports() async {
    final res = await http.get(Uri.parse('$baseUrl/reports'), headers: _headers);
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  static Future<Map<String, dynamic>> getReportDetail(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/reports/$id'), headers: _headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> submitReport({
    required int kategori,
    required String deskripsi,
    required int tingkatStres,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: _headers,
      body: jsonEncode({
        'kategori': kategori,
        'deskripsi': deskripsi,
        'tingkat_stres': tingkatStres,
      }),
    );
    return jsonDecode(res.body);
  }

  // ── Mood ──────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMoodWeekly({String? idUser}) async {
    final query = idUser != null ? '?id_user=$idUser' : '';
    final res = await http.get(Uri.parse('$baseUrl/mood/weekly$query'), headers: _headers);
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  static Future<Map<String, dynamic>> submitMood(int levelMood) async {
    final res = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: _headers,
      body: jsonEncode({'level_mood': levelMood}),
    );
    return jsonDecode(res.body);
  }

  // ── Stress (HR) ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStressDivisions() async {
    final res = await http.get(Uri.parse('$baseUrl/stress/divisions'), headers: _headers);
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  // ── Employees (HR) ────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEmployees({int? idDepartment}) async {
    final query = idDepartment != null ? '?id_department=$idDepartment' : '';
    final res = await http.get(Uri.parse('$baseUrl/employees$query'), headers: _headers);
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }
}
