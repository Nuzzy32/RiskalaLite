import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Base URL bisa di-override via:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.x:8000/api
  /// Default = localhost (cocok untuk iOS Simulator & Android emulator dengan adb reverse).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const _timeout = Duration(seconds: 10);
  static const _kTokenKey = 'auth_token';
  static const _kUserKey = 'auth_user';

  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static String? _activeCompanyCode;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get activeCompanyCode => _activeCompanyCode;
  static bool get isHr => _currentUser?['role_user'] == 1;
  static String get userId => _currentUser?['id_user'] ?? '';
  static String get userName => _currentUser?['nama_user'] ?? '';
  static String get userDepartment => _currentUser?['department'] ?? '';
  static String get userEmail => _currentUser?['email_user'] ?? '';

  /// Restore token & user dari SharedPreferences. Panggil di app startup.
  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    final userStr = prefs.getString(_kUserKey);
    if (userStr != null) {
      try {
        _currentUser = Map<String, dynamic>.from(jsonDecode(userStr));
      } catch (e) {
        debugPrint('[ApiService] Failed to restore user from prefs: $e');
      }
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

  static Future<Map<String, dynamic>> login(
    String idUser,
    String password, {
    String? companyCode,
  }) async {
    final payload = <String, dynamic>{
      'id_user': idUser,
      'password': password,
      if (companyCode != null && companyCode.isNotEmpty)
        'company_code': companyCode,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Login gagal');
    }

    final body = jsonDecode(res.body);
    _token = body['token'];
    _currentUser = body['user'];
    _activeCompanyCode = companyCode;
    await _persistSession();
    return body;
  }

  static Future<void> logout() async {
    try {
      await _post(Uri.parse('$baseUrl/auth/logout'));
    } catch (e) {
      debugPrint('[ApiService] Logout API call failed (ignoring): $e');
    }
    _token = null;
    _currentUser = null;
    _activeCompanyCode = null;
    await _clearSession();
  }

  // ── Company (multi-tenant) ────────────────────────────────────────────────

  /// Validates a company code (e.g., RSK-A1B2C3).
  /// Returns `{company_id, company_name}` on success, throws on failure.
  static Future<Map<String, dynamic>> validateCompanyCode(String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/companies/validate-code'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'company_code': code}),
    ).timeout(_timeout);

    if (res.statusCode == 404) {
      throw Exception('Kode perusahaan tidak ditemukan');
    }
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Kode perusahaan tidak valid');
    }
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  /// Registers a new company, provisions the first HR admin, and returns
  /// `{company_code, message}`.
  static Future<Map<String, dynamic>> registerCompany({
    required String companyName,
    required String companyEmail,
    required String industry,
    required String employeeRange,
    required String hrName,
    required String hrNip,
    required String hrPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/companies/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'company_name': companyName,
        'email': companyEmail,
        'industry': industry,
        'employee_range': employeeRange,
        'admin_name': hrName,
        'admin_nip': hrNip,
        'admin_password': hrPassword,
      }),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201) {
      final b = jsonDecode(res.body);
      final errors = b['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first is List
            ? errors.values.first[0]
            : errors.values.first);
      }
      throw Exception(b['message'] ?? 'Gagal mendaftarkan perusahaan');
    }
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  static Future<void> requestPasswordResetOtp(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(_timeout);
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(b['message'] ?? 'Gagal mengirim kode OTP');
    }
  }

  static Future<Map<String, dynamic>> verifyResetOtp(
      String email, String otpCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otpCode}),
    ).timeout(_timeout);
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(b['message'] ?? 'Kode OTP tidak valid');
    }
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  static Future<void> resetPassword(
      String email, String otp, String newPassword) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': newPassword,
      }),
    ).timeout(_timeout);
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(b['message'] ?? 'Gagal mengatur ulang kata sandi');
    }
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
  }) async {
    // kategori_stres is now a generated column on the server — only total_score is sent
    final res = await _post(
      Uri.parse('$baseUrl/assessments'),
      body: jsonEncode({'total_score': totalScore}),
    );
    return jsonDecode(res.body);
  }

  // ── Kategori Laporan ──────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getKategoriLaporan() async {
    final res = await _get(Uri.parse('$baseUrl/kategori-laporan'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
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

  static Future<List<Map<String, dynamic>>> getStressDivisions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, String>{};
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (startDate != null) params['start_date'] = fmt(startDate);
    if (endDate != null) params['end_date'] = fmt(endDate);

    final uri = Uri.parse('$baseUrl/stress/divisions')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await _get(uri);
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

  static Future<Map<String, dynamic>> updateEmployee(
    String idUser, {
    String? namaUser,
    String? emailUser,
    String? passwdUser,
    int? idDepartment,
    int? roleUser,
  }) async {
    final body = <String, dynamic>{};
    if (namaUser != null) body['nama_user'] = namaUser;
    if (emailUser != null) body['email_user'] = emailUser;
    if (passwdUser != null && passwdUser.isNotEmpty) body['passwd_user'] = passwdUser;
    if (idDepartment != null) body['id_department'] = idDepartment;
    if (roleUser != null) body['role_user'] = roleUser;

    final res = await _patch(
      Uri.parse('$baseUrl/employees/$idUser'),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      final errors = b['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first[0]);
      }
      throw Exception(b['message'] ?? 'Gagal memperbarui employee');
    }
    return jsonDecode(res.body);
  }

  static Future<void> deleteEmployee(String idUser) async {
    final res = await http
        .delete(Uri.parse('$baseUrl/employees/$idUser'), headers: _headers)
        .timeout(_timeout);
    _checkAuth(res);
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menghapus employee');
    }
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

  // ── Psikolog (HR) ─────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getPsikologs() async {
    final res = await _get(Uri.parse('$baseUrl/psikologs'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> createPsikolog({
    required String nama,
    required String email,
    String? spesialisasi,
    String? noTelp,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/psikologs'),
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'spesialisasi': spesialisasi,
        'no_telp': noTelp,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final b = jsonDecode(res.body);
      final errors = b['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first[0]);
      }
      throw Exception(b['message'] ?? 'Gagal menambah psikolog');
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updatePsikolog(
    int id, {
    required String nama,
    required String email,
    String? spesialisasi,
    String? noTelp,
  }) async {
    final res = await _patch(
      Uri.parse('$baseUrl/psikologs/$id'),
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'spesialisasi': spesialisasi,
        'no_telp': noTelp,
      }),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      final errors = b['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first[0]);
      }
      throw Exception(b['message'] ?? 'Gagal memperbarui psikolog');
    }
    return jsonDecode(res.body);
  }

  static Future<void> deletePsikolog(int id) async {
    final res = await http
        .delete(Uri.parse('$baseUrl/psikologs/$id'), headers: _headers)
        .timeout(_timeout);
    _checkAuth(res);
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menghapus psikolog');
    }
  }

  static Future<Map<String, dynamic>> assignPsikolog(
      String reportId, int psikologId) async {
    final res = await _patch(
      Uri.parse('$baseUrl/reports/$reportId'),
      body: jsonEncode({'psikolog_id': psikologId}),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menugaskan psikolog');
    }
    return jsonDecode(res.body);
  }

  // ── Bulk Import ───────────────────────────────────────────────────────────

  /// Mengunggah file CSV/XLSX ke endpoint import pegawai.
  /// Mengembalikan map: { imported, skipped, errors[] }
  static Future<Map<String, dynamic>> importEmployeeDatabase(File file) async {
    if (_token == null) throw Exception('Sesi tidak valid, silakan login ulang');

    final uri = Uri.parse('$baseUrl/employees/import');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..headers['Accept'] = 'application/json'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);

    _checkAuth(res);

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Gagal mengimpor data pegawai');
    }

    return body;
  }
}
