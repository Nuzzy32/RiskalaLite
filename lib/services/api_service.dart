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
  static const _kPsikologKey = 'auth_psikolog';

  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static Map<String, dynamic>? _psikolog;
  static String? _activeCompanyCode;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get activeCompanyCode => _activeCompanyCode;
  static bool get isHr => _currentUser?['role_user'] == 1;

  // ── Psikolog actor ──
  static bool get isPsikolog => _psikolog != null;
  static Map<String, dynamic>? get psikolog => _psikolog;
  static String get psikologName => _psikolog?['nama'] ?? '';
  static String get psikologSpesialisasi => _psikolog?['spesialisasi'] ?? '';
  static int get psikologCaseload => (_psikolog?['active_caseload'] as num?)?.toInt() ?? 0;
  static String get userId => _currentUser?['id_user'] ?? ''; // internal surrogate
  static String get userNip => _currentUser?['nip'] ?? _currentUser?['id_user'] ?? ''; // human-facing
  static String get userName => _currentUser?['nama_user'] ?? '';
  static String get userDepartment => _currentUser?['department'] ?? '';
  static String get userCompany => _currentUser?['company'] ?? '';
  static String get companyCode => _currentUser?['company_code'] ?? '';
  static String get userEmail => _currentUser?['email_user'] ?? '';
  static bool get notifHighStress => _currentUser?['notif_high_stress'] != false;
  static bool get notifNewReport => _currentUser?['notif_new_report'] != false;
  static bool get notifWeeklySummary => _currentUser?['notif_weekly_summary'] == true;

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
    final psiStr = prefs.getString(_kPsikologKey);
    if (psiStr != null) {
      try {
        _psikolog = Map<String, dynamic>.from(jsonDecode(psiStr));
      } catch (e) {
        debugPrint('[ApiService] Failed to restore psikolog from prefs: $e');
      }
    }
  }

  static Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_kTokenKey, _token!);
    if (_currentUser != null) {
      await prefs.setString(_kUserKey, jsonEncode(_currentUser));
    }
    if (_psikolog != null) {
      await prefs.setString(_kPsikologKey, jsonEncode(_psikolog));
    }
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
    await prefs.remove(_kPsikologKey);
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

  static Future<http.Response> _delete(Uri url) async {
    final res = await http.delete(url, headers: _headers).timeout(_timeout);
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
    String nip,
    String password, {
    required String companyCode,
  }) async {
    final payload = <String, dynamic>{
      'company_code': companyCode,
      'nip': nip,
      'password': password,
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

  static bool get wellnessConsent => _currentUser?['wellness_consent'] == true;

  /// Toggle whether the wellness team may see this employee's name on alerts.
  static Future<bool> updateWellnessConsent(bool consent) async {
    final res = await _patch(
      Uri.parse('$baseUrl/me/consent'),
      body: jsonEncode({'wellness_consent': consent}),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal memperbarui preferensi');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final value = body['wellness_consent'] == true;
    // Keep the cached user in sync so the UI reflects it after reload.
    if (_currentUser != null) {
      _currentUser!['wellness_consent'] = value;
      await _persistSession();
    }
    return value;
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

  // ── Psikolog portal ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> psikologLogin(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/psikolog/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Login psikolog gagal');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    _token = body['token'];
    _psikolog = Map<String, dynamic>.from(body['psikolog']);
    _currentUser = null; // ensure single active actor
    await _persistSession();
    return body;
  }

  static Future<void> psikologLogout() async {
    try {
      await _post(Uri.parse('$baseUrl/psikolog/logout'));
    } catch (e) {
      debugPrint('[ApiService] Psikolog logout failed (ignoring): $e');
    }
    _token = null;
    _psikolog = null;
    await _clearSession();
  }

  /// Refresh the cached psikolog profile (e.g. caseload count).
  static Future<void> refreshPsikolog() async {
    final res = await _get(Uri.parse('$baseUrl/psikolog/me'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    _psikolog = Map<String, dynamic>.from(body['psikolog']);
    await _persistSession();
  }

  static Future<List<Map<String, dynamic>>> getPsikologCases({String? status}) async {
    final q = status != null ? '?status=$status' : '';
    final res = await _get(Uri.parse('$baseUrl/psikolog/cases$q'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> updatePsikologCase(
    String idReport, {
    String? status,
    String? psikologNote,
    String? sessionAt,
  }) async {
    final payload = <String, dynamic>{};
    if (status != null) payload['status'] = status;
    if (psikologNote != null) payload['psikolog_note'] = psikologNote;
    if (sessionAt != null) payload['session_at'] = sessionAt;

    final res = await _patch(
      Uri.parse('$baseUrl/psikolog/cases/$idReport'),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal memperbarui kasus');
    }
    final body = jsonDecode(res.body);
    return Map<String, dynamic>.from(body['data'] ?? body);
  }

  // ── Counseling bookings ───────────────────────────────────────────────────

  /// Psikologs the employee may book (own company, active). Each:
  /// `{id, nama, spesialisasi, is_available, active_caseload}`.
  static Future<List<Map<String, dynamic>>> getAvailablePsikologs() async {
    final res = await _get(Uri.parse('$baseUrl/counseling/psikologs'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  /// The employee's own confidential bookings.
  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    final res = await _get(Uri.parse('$baseUrl/bookings'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<Map<String, dynamic>> createBooking({
    required int psikologId,
    String? preferredAt,
    String? note,
  }) async {
    final payload = <String, dynamic>{'psikolog_id': psikologId};
    if (preferredAt != null) payload['preferred_at'] = preferredAt;
    if (note != null && note.isNotEmpty) payload['note'] = note;
    final res = await _post(Uri.parse('$baseUrl/bookings'), body: jsonEncode(payload));
    if (res.statusCode != 201 && res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal mengajukan sesi');
    }
    final body = jsonDecode(res.body);
    return Map<String, dynamic>.from(body['data'] ?? body);
  }

  static Future<void> cancelBooking(int id) async {
    final res = await _patch(Uri.parse('$baseUrl/bookings/$id/cancel'));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal membatalkan');
    }
  }

  /// Bookings requested with the authenticated psikolog.
  static Future<List<Map<String, dynamic>>> getPsikologBookings() async {
    final res = await _get(Uri.parse('$baseUrl/psikolog/bookings'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
  }

  static Future<void> updatePsikologBooking(
    int id, {
    String? status,
    String? scheduledAt,
    String? psikologNote,
  }) async {
    final payload = <String, dynamic>{};
    if (status != null) payload['status'] = status;
    if (scheduledAt != null) payload['scheduled_at'] = scheduledAt;
    if (psikologNote != null) payload['psikolog_note'] = psikologNote;
    final res = await _patch(
      Uri.parse('$baseUrl/psikolog/bookings/$id'),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal memperbarui booking');
    }
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
    int? riskScore,
  }) async {
    // kategori_stres is a generated column on the server; risk_score is the
    // separate clinical screen (0–3) and is never exposed to HR.
    final payload = <String, dynamic>{'total_score': totalScore};
    if (riskScore != null) payload['risk_score'] = riskScore;
    final res = await _post(
      Uri.parse('$baseUrl/assessments'),
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }

  /// Clinical risk-screening signals for the psikolog's company (last 30 days).
  static Future<List<Map<String, dynamic>>> getPsikologRiskScreenings() async {
    final res = await _get(Uri.parse('$baseUrl/psikolog/risk-screenings'));
    final body = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(body['data'] ?? []);
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

  /// Mood check-in streak: {current_streak, longest_streak, checked_in_today, total_checkins}.
  static Future<Map<String, dynamic>> getMoodStreak({String? idUser}) async {
    final query = idUser != null ? '?id_user=$idUser' : '';
    final res = await _get(Uri.parse('$baseUrl/mood/streak$query'));
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> submitMood(int levelMood) async {
    final res = await _post(
      Uri.parse('$baseUrl/mood'),
      body: jsonEncode({'level_mood': levelMood}),
    );
    return jsonDecode(res.body);
  }

  /// Week-to-date recap aggregate:
  /// `{ range:{start,end}, mood:{count,average,active_days},
  ///    activities:{count,active_days,top_key,top_count} }`.
  static Future<Map<String, dynamic>> getWeeklyRecap() async {
    final res = await _get(Uri.parse('$baseUrl/recap/weekly'));
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  // ── Activities ("Your Plan") ──────────────────────────────────────────────

  /// One call for the home plan section:
  /// `{ routine: [...], completed_today: [...], streak: {...}, context: {...} }`.
  static Future<Map<String, dynamic>> getActivities() async {
    final res = await _get(Uri.parse('$baseUrl/activities'));
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  /// Add an activity (by catalog key) to the user's routine.
  static Future<void> addRoutineActivity(String activityKey) async {
    final res = await _post(
      Uri.parse('$baseUrl/activities/routine'),
      body: jsonEncode({'activity_key': activityKey}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menambah aktivitas');
    }
  }

  /// Remove a routine activity by its row id.
  static Future<void> removeRoutineActivity(int id) async {
    final res = await _delete(Uri.parse('$baseUrl/activities/routine/$id'));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menghapus aktivitas');
    }
  }

  /// Log a completed activity. Returns the refreshed streak payload.
  static Future<Map<String, dynamic>> completeActivity(String activityKey) async {
    final res = await _post(
      Uri.parse('$baseUrl/activities/complete'),
      body: jsonEncode({'activity_key': activityKey}),
    );
    return Map<String, dynamic>.from(jsonDecode(res.body));
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

  /// Early Warning System — employees with a sustained high-stress pattern.
  /// Each item: id_user, nama_user, division, latest_score, latest_date,
  /// consecutive_high, high_in_last3, severity ('critical' | 'warning').
  static Future<List<Map<String, dynamic>>> getStressAlerts() async {
    final res = await _get(Uri.parse('$baseUrl/stress/alerts'));
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

  static Future<void> createDepartment(String name) async {
    final res = await _post(Uri.parse('$baseUrl/departments'),
        body: jsonEncode({'nama_department': name}));
    if (res.statusCode != 200 && res.statusCode != 201) {
      final b = jsonDecode(res.body);
      throw Exception(_firstError(b) ?? 'Gagal menambah departemen');
    }
  }

  static Future<void> updateDepartment(int id, String name) async {
    final res = await _patch(Uri.parse('$baseUrl/departments/$id'),
        body: jsonEncode({'nama_department': name}));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(_firstError(b) ?? 'Gagal memperbarui departemen');
    }
  }

  static Future<void> deleteDepartment(int id) async {
    final res = await _delete(Uri.parse('$baseUrl/departments/$id'));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menghapus departemen');
    }
  }

  // ── Company profile (HR) ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCompany() async {
    final res = await _get(Uri.parse('$baseUrl/company'));
    final body = jsonDecode(res.body);
    return Map<String, dynamic>.from(body['data'] ?? {});
  }

  static Future<Map<String, dynamic>> updateCompany({
    String? name,
    String? email,
    String? industry,
    String? employeeRange,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (industry != null) payload['industry'] = industry;
    if (employeeRange != null) payload['employee_range'] = employeeRange;

    final res = await _patch(Uri.parse('$baseUrl/company'), body: jsonEncode(payload));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(_firstError(b) ?? 'Gagal memperbarui perusahaan');
    }
    final data = Map<String, dynamic>.from(jsonDecode(res.body)['data'] ?? {});
    // Keep cached company name in sync for the profile header.
    if (_currentUser != null && data['name'] != null) {
      _currentUser!['company'] = data['name'];
      await _persistSession();
    }
    return data;
  }

  /// Update HR notification preferences; syncs the cached user.
  static Future<void> updateHrNotifications({
    bool? highStress,
    bool? newReport,
    bool? weeklySummary,
  }) async {
    final payload = <String, dynamic>{};
    if (highStress != null) payload['notif_high_stress'] = highStress;
    if (newReport != null) payload['notif_new_report'] = newReport;
    if (weeklySummary != null) payload['notif_weekly_summary'] = weeklySummary;

    final res = await _patch(Uri.parse('$baseUrl/me/notifications'), body: jsonEncode(payload));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['message'] ?? 'Gagal menyimpan preferensi');
    }
    final b = jsonDecode(res.body) as Map<String, dynamic>;
    if (_currentUser != null) {
      _currentUser!['notif_high_stress'] = b['notif_high_stress'];
      _currentUser!['notif_new_report'] = b['notif_new_report'];
      _currentUser!['notif_weekly_summary'] = b['notif_weekly_summary'];
      await _persistSession();
    }
  }

  static String? _firstError(Map<String, dynamic> body) {
    final errors = body['errors'] as Map?;
    if (errors != null && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return body['message'] as String?;
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
    required String nip,
    required String namaUser,
    required String emailUser,
    required String passwdUser,
    required int idDepartment,
    required int roleUser,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/employees'),
      body: jsonEncode({
        'nip': nip,
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
