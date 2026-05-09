import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const _timeout = Duration(seconds: 10);
  static const _kTokenKey = 'auth_token';
  static const _kUserKey = 'auth_user';

  static String? _token;
  static Map<String, dynamic>? _currentUser;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isHr => _currentUser?['role_user'] == 1;
  static String get userId => _currentUser?['id_user'] ?? '';
  static String get userName => _currentUser?['nama_user'] ?? '';

  /// Restore token & user dari SharedPreferences. Panggil di app startup.
  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    final userStr = prefs.getString(_kUserKey);
    if (userStr != null) {
      try {
        _currentUser = Map<String, dynamic>.from(jsonDecode(userStr));
      } catch (_) {}
    }
  }

  static Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_kTokenKey, _token!);
    if (_currentUser != null) {
      await prefs.setString(_kUserKey, jsonEncode(_currentUser));
    }
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<http.Response> _get(Uri url) async {
    final res = await http.get(url, headers: _headers).timeout(_timeout);
    _checkAuth(res);
    return res;
  }

  static Future<http.Response> _post(Uri url, {Object? body}) async {
    final res = await http.post(url, headers: _headers, body: body).timeout(_timeout);
    _checkAuth(res);
    return res;
  }

  static Future<http.Response> _patch(Uri url, {Object? body}) async {
    final res = await http.patch(url, headers: _headers, body: body).timeout(_timeout);
    _checkAuth(res);
    return res;
  }

  static void _checkAuth(http.Response res) {
    if (res.statusCode == 401) {
      _token = null;
      _currentUser = null;
      _clearSession();
      throw Exception('Sesi habis, silakan login ulang');
    }
    if (res.statusCode == 403) {
      throw Exception('Akses ditolak');
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String idUser, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'id_user': idUser, 'password': password}),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Login gagal');
    }

    final body = jsonDecode(res.body);
    _token = body['token'];
    _currentUser = body['user'];
    await _persistSession();
    return body;
  }

  static Future<void> logout() async {
    try {
      await _post(Uri.parse('$baseUrl/auth/logout'));
    } catch (_) {}
    _token = null;
    _currentUser = null;
    await _clearSession();
  }

  // ── Assessments ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAssessmentHistory({String? idUser}) async {
    final query = idUser != null ? '?id_user=$idUser' : '';
    final res = await _get(Uri.parse('$baseUrl/assessments/history$query'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> submitAssessment({
    required int totalScore,
    required int kategoriStres,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/assessments'),
      body: jsonEncode({'total_score': totalScore, 'kategori_stres': kategoriStres}),
    );
    return jsonDecode(res.body);
  }

  // ── Incident Reports ──────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getReports() async {
    final res = await _get(Uri.parse('$baseUrl/reports'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> getReportDetail(String id) async {
    final res = await _get(Uri.parse('$baseUrl/reports/$id'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> submitReport({
    required int kategori,
    required String deskripsi,
    required int tingkatStres,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/reports'),
      body: jsonEncode({
        'kategori': kategori,
        'deskripsi': deskripsi,
        'tingkat_stres': tingkatStres,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal mengirim laporan');
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateReport(
    String id, {
    String? status,
    String? hrResponse,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (hrResponse != null) body['hr_response'] = hrResponse;

    final res = await _patch(
      Uri.parse('$baseUrl/reports/$id'),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal memperbarui laporan');
    }
    return jsonDecode(res.body);
  }

  // ── Mood ──────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMoodWeekly({String? idUser}) async {
    final query = idUser != null ? '?id_user=$idUser' : '';
    final res = await _get(Uri.parse('$baseUrl/mood/weekly$query'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> submitMood(int levelMood) async {
    final res = await _post(
      Uri.parse('$baseUrl/mood'),
      body: jsonEncode({'level_mood': levelMood}),
    );
    return jsonDecode(res.body);
  }

  // ── Stress (HR) ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStressDivisions() async {
    final res = await _get(Uri.parse('$baseUrl/stress/divisions'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  // ── Employees (HR) ────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEmployees({int? idDepartment}) async {
    final query = idDepartment != null ? '?id_department=$idDepartment' : '';
    final res = await _get(Uri.parse('$baseUrl/employees$query'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getDepartments() async {
    final res = await _get(Uri.parse('$baseUrl/departments'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> createEmployee({
    required String idUser,
    required String namaUser,
    required String emailUser,
    required String passwdUser,
    required int idDepartment,
    required int roleUser,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/employees'),
      body: jsonEncode({
        'id_user': idUser,
        'nama_user': namaUser,
        'email_user': emailUser,
        'passwd_user': passwdUser,
        'id_department': idDepartment,
        'role_user': roleUser,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final b = jsonDecode(res.body);
      final errors = b['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first[0]);
      }
      throw Exception(b['message'] ?? 'Gagal menambah employee');
    }
    return jsonDecode(res.body);
  }
}
