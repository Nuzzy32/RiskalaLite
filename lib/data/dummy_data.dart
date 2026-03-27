import 'package:flutter/material.dart';

// =============================================================================
// DUMMY DATA — ganti file ini dengan API calls dari backend nanti
// =============================================================================

// -- User & Auth ---------------------------------------------------------------

class UserAccount {
  final String nip;
  final String name;
  final String role; // 'employee' atau 'hr'
  final String division;
  final String jobTitle;
  final String password; // dummy, nanti diganti auth backend

  const UserAccount({
    required this.nip,
    required this.name,
    required this.role,
    required this.division,
    required this.jobTitle,
    this.password = '123456',
  });

  bool get isHr => role == 'hr';
}

class DummyAuth {
  static const List<UserAccount> allUsers = [
    // ── HR Employees ──
    UserAccount(nip: 'HR001', name: 'Dewi Kartika', role: 'hr', division: 'HR', jobTitle: 'HR Manager'),
    UserAccount(nip: 'HR002', name: 'Fajar Nugroho', role: 'hr', division: 'HR', jobTitle: 'HR Lead'),
    UserAccount(nip: 'HR003', name: 'Gita Pramesti', role: 'hr', division: 'HR', jobTitle: 'People Ops'),

    // ── Regular Employees ──
    // Engineering
    UserAccount(nip: 'ENG001', name: 'Tony Wijaya', role: 'employee', division: 'Engineering', jobTitle: 'Senior Architect'),
    UserAccount(nip: 'ENG002', name: 'Budi Santoso', role: 'employee', division: 'Engineering', jobTitle: 'DevOps Lead'),
    UserAccount(nip: 'ENG003', name: 'Rina Permata', role: 'employee', division: 'Engineering', jobTitle: 'Backend Dev'),
    UserAccount(nip: 'ENG004', name: 'Sari Dewi', role: 'employee', division: 'Engineering', jobTitle: 'Security Eng'),
    UserAccount(nip: 'ENG005', name: 'Dani Pratama', role: 'employee', division: 'Engineering', jobTitle: 'Frontend Dev'),
    UserAccount(nip: 'ENG006', name: 'Eka Saputra', role: 'employee', division: 'Engineering', jobTitle: 'QA Engineer'),
    UserAccount(nip: 'ENG007', name: 'Fitra Ramadhan', role: 'employee', division: 'Engineering', jobTitle: 'Mobile Dev'),

    // Marketing
    UserAccount(nip: 'MKT001', name: 'Andi Kurniawan', role: 'employee', division: 'Marketing', jobTitle: 'Brand Manager'),
    UserAccount(nip: 'MKT002', name: 'Maya Sari', role: 'employee', division: 'Marketing', jobTitle: 'Content Lead'),
    UserAccount(nip: 'MKT003', name: 'Putri Handayani', role: 'employee', division: 'Marketing', jobTitle: 'Social Media'),
    UserAccount(nip: 'MKT004', name: 'Riko Aditya', role: 'employee', division: 'Marketing', jobTitle: 'SEO Specialist'),
    UserAccount(nip: 'MKT005', name: 'Lestari Wulan', role: 'employee', division: 'Marketing', jobTitle: 'Graphic Designer'),

    // Finance
    UserAccount(nip: 'FIN001', name: 'Hadi Purnomo', role: 'employee', division: 'Finance', jobTitle: 'Finance Lead'),
    UserAccount(nip: 'FIN002', name: 'Indah Lestari', role: 'employee', division: 'Finance', jobTitle: 'Accountant'),
    UserAccount(nip: 'FIN003', name: 'Joko Susilo', role: 'employee', division: 'Finance', jobTitle: 'Tax Analyst'),
    UserAccount(nip: 'FIN004', name: 'Kiki Amelia', role: 'employee', division: 'Finance', jobTitle: 'Auditor'),

    // Operations
    UserAccount(nip: 'OPS001', name: 'Lina Marlina', role: 'employee', division: 'Operations', jobTitle: 'Ops Manager'),
    UserAccount(nip: 'OPS002', name: 'Miko Setiawan', role: 'employee', division: 'Operations', jobTitle: 'Logistics Lead'),
    UserAccount(nip: 'OPS003', name: 'Nita Anggraeni', role: 'employee', division: 'Operations', jobTitle: 'Supply Chain'),
    UserAccount(nip: 'OPS004', name: 'Omar Faruk', role: 'employee', division: 'Operations', jobTitle: 'QA Lead'),
    UserAccount(nip: 'OPS005', name: 'Peni Rahayu', role: 'employee', division: 'Operations', jobTitle: 'Warehouse Mgr'),
    UserAccount(nip: 'OPS006', name: 'Qori Ismail', role: 'employee', division: 'Operations', jobTitle: 'Fleet Manager'),

    // Sales
    UserAccount(nip: 'SAL001', name: 'Reza Mahendra', role: 'employee', division: 'Sales', jobTitle: 'Sales Manager'),
    UserAccount(nip: 'SAL002', name: 'Sinta Dewi', role: 'employee', division: 'Sales', jobTitle: 'Account Exec'),
    UserAccount(nip: 'SAL003', name: 'Toni Hermawan', role: 'employee', division: 'Sales', jobTitle: 'Business Dev'),
    UserAccount(nip: 'SAL004', name: 'Udin Syarifudin', role: 'employee', division: 'Sales', jobTitle: 'Sales Rep'),
    UserAccount(nip: 'SAL005', name: 'Vina Oktaviani', role: 'employee', division: 'Sales', jobTitle: 'Key Account'),
  ];

  /// Cari user by NIP (case-insensitive)
  static UserAccount? findByNip(String nip) {
    final upper = nip.trim().toUpperCase();
    try {
      return allUsers.firstWhere((u) => u.nip == upper);
    } catch (_) {
      return null;
    }
  }

  /// Cek apakah NIP adalah HR
  static bool isHrNip(String nip) => findByNip(nip)?.isHr ?? false;
}

// -- Stress Data ---------------------------------------------------------------

class EmployeeStressData {
  final String nip;
  final String name;
  final String division;
  final String jobTitle;
  final String stressLevel; // 'low', 'moderate', 'high'
  final int stressScore; // 0-100

  const EmployeeStressData({
    required this.nip,
    required this.name,
    required this.division,
    required this.jobTitle,
    required this.stressLevel,
    required this.stressScore,
  });
}

class DummyStressData {
  static const List<EmployeeStressData> allStressData = [
    // Engineering
    EmployeeStressData(nip: 'ENG001', name: 'Tony Wijaya', division: 'Engineering', jobTitle: 'Senior Architect', stressLevel: 'low', stressScore: 25),
    EmployeeStressData(nip: 'ENG002', name: 'Budi Santoso', division: 'Engineering', jobTitle: 'DevOps Lead', stressLevel: 'moderate', stressScore: 55),
    EmployeeStressData(nip: 'ENG003', name: 'Rina Permata', division: 'Engineering', jobTitle: 'Backend Dev', stressLevel: 'high', stressScore: 82),
    EmployeeStressData(nip: 'ENG004', name: 'Sari Dewi', division: 'Engineering', jobTitle: 'Security Eng', stressLevel: 'low', stressScore: 20),
    EmployeeStressData(nip: 'ENG005', name: 'Dani Pratama', division: 'Engineering', jobTitle: 'Frontend Dev', stressLevel: 'moderate', stressScore: 48),
    EmployeeStressData(nip: 'ENG006', name: 'Eka Saputra', division: 'Engineering', jobTitle: 'QA Engineer', stressLevel: 'low', stressScore: 30),
    EmployeeStressData(nip: 'ENG007', name: 'Fitra Ramadhan', division: 'Engineering', jobTitle: 'Mobile Dev', stressLevel: 'moderate', stressScore: 52),

    // Marketing
    EmployeeStressData(nip: 'MKT001', name: 'Andi Kurniawan', division: 'Marketing', jobTitle: 'Brand Manager', stressLevel: 'low', stressScore: 22),
    EmployeeStressData(nip: 'MKT002', name: 'Maya Sari', division: 'Marketing', jobTitle: 'Content Lead', stressLevel: 'moderate', stressScore: 45),
    EmployeeStressData(nip: 'MKT003', name: 'Putri Handayani', division: 'Marketing', jobTitle: 'Social Media', stressLevel: 'low', stressScore: 18),
    EmployeeStressData(nip: 'MKT004', name: 'Riko Aditya', division: 'Marketing', jobTitle: 'SEO Specialist', stressLevel: 'high', stressScore: 78),
    EmployeeStressData(nip: 'MKT005', name: 'Lestari Wulan', division: 'Marketing', jobTitle: 'Graphic Designer', stressLevel: 'moderate', stressScore: 42),

    // HR
    EmployeeStressData(nip: 'HR001', name: 'Dewi Kartika', division: 'HR', jobTitle: 'HR Manager', stressLevel: 'low', stressScore: 15),
    EmployeeStressData(nip: 'HR002', name: 'Fajar Nugroho', division: 'HR', jobTitle: 'HR Lead', stressLevel: 'moderate', stressScore: 40),
    EmployeeStressData(nip: 'HR003', name: 'Gita Pramesti', division: 'HR', jobTitle: 'People Ops', stressLevel: 'low', stressScore: 28),

    // Finance
    EmployeeStressData(nip: 'FIN001', name: 'Hadi Purnomo', division: 'Finance', jobTitle: 'Finance Lead', stressLevel: 'moderate', stressScore: 50),
    EmployeeStressData(nip: 'FIN002', name: 'Indah Lestari', division: 'Finance', jobTitle: 'Accountant', stressLevel: 'low', stressScore: 22),
    EmployeeStressData(nip: 'FIN003', name: 'Joko Susilo', division: 'Finance', jobTitle: 'Tax Analyst', stressLevel: 'high', stressScore: 75),
    EmployeeStressData(nip: 'FIN004', name: 'Kiki Amelia', division: 'Finance', jobTitle: 'Auditor', stressLevel: 'low', stressScore: 30),

    // Operations
    EmployeeStressData(nip: 'OPS001', name: 'Lina Marlina', division: 'Operations', jobTitle: 'Ops Manager', stressLevel: 'high', stressScore: 85),
    EmployeeStressData(nip: 'OPS002', name: 'Miko Setiawan', division: 'Operations', jobTitle: 'Logistics Lead', stressLevel: 'moderate', stressScore: 58),
    EmployeeStressData(nip: 'OPS003', name: 'Nita Anggraeni', division: 'Operations', jobTitle: 'Supply Chain', stressLevel: 'moderate', stressScore: 52),
    EmployeeStressData(nip: 'OPS004', name: 'Omar Faruk', division: 'Operations', jobTitle: 'QA Lead', stressLevel: 'low', stressScore: 28),
    EmployeeStressData(nip: 'OPS005', name: 'Peni Rahayu', division: 'Operations', jobTitle: 'Warehouse Mgr', stressLevel: 'high', stressScore: 80),
    EmployeeStressData(nip: 'OPS006', name: 'Qori Ismail', division: 'Operations', jobTitle: 'Fleet Manager', stressLevel: 'moderate', stressScore: 48),

    // Sales
    EmployeeStressData(nip: 'SAL001', name: 'Reza Mahendra', division: 'Sales', jobTitle: 'Sales Manager', stressLevel: 'moderate', stressScore: 55),
    EmployeeStressData(nip: 'SAL002', name: 'Sinta Dewi', division: 'Sales', jobTitle: 'Account Exec', stressLevel: 'low', stressScore: 20),
    EmployeeStressData(nip: 'SAL003', name: 'Toni Hermawan', division: 'Sales', jobTitle: 'Business Dev', stressLevel: 'high', stressScore: 72),
    EmployeeStressData(nip: 'SAL004', name: 'Udin Syarifudin', division: 'Sales', jobTitle: 'Sales Rep', stressLevel: 'moderate', stressScore: 50),
    EmployeeStressData(nip: 'SAL005', name: 'Vina Oktaviani', division: 'Sales', jobTitle: 'Key Account', stressLevel: 'low', stressScore: 25),
  ];

  /// Get employees by division
  static List<EmployeeStressData> byDivision(String division) =>
      allStressData.where((e) => e.division == division).toList();

  /// Get all division names
  static List<String> get divisions =>
      allStressData.map((e) => e.division).toSet().toList();

  /// Get employee count per division
  static Map<String, int> get divisionCounts {
    final map = <String, int>{};
    for (final e in allStressData) {
      map[e.division] = (map[e.division] ?? 0) + 1;
    }
    return map;
  }

  /// Get average stress score per division (0-100)
  static Map<String, double> get divisionAvgStress {
    final totals = <String, int>{};
    final counts = <String, int>{};
    for (final e in allStressData) {
      totals[e.division] = (totals[e.division] ?? 0) + e.stressScore;
      counts[e.division] = (counts[e.division] ?? 0) + 1;
    }
    return totals.map((k, v) => MapEntry(k, v / counts[k]!));
  }

  /// Company-wide average stress score
  static double get companyAvgStress {
    if (allStressData.isEmpty) return 0;
    final total = allStressData.fold(0, (sum, e) => sum + e.stressScore);
    return total / allStressData.length;
  }

  /// Total employees
  static int get totalEmployees => allStressData.length;
}

// -- Division Info (for icons) -------------------------------------------------

class DivisionInfo {
  final String name;
  final IconData icon;
  const DivisionInfo(this.name, this.icon);
}

const List<DivisionInfo> divisionInfoList = [
  DivisionInfo('Engineering', Icons.settings_outlined),
  DivisionInfo('Marketing', Icons.campaign_outlined),
  DivisionInfo('HR', Icons.groups_outlined),
  DivisionInfo('Finance', Icons.account_balance_outlined),
  DivisionInfo('Operations', Icons.business_outlined),
  DivisionInfo('Sales', Icons.storefront_outlined),
];

IconData divisionIcon(String name) {
  try {
    return divisionInfoList.firstWhere((d) => d.name == name).icon;
  } catch (_) {
    return Icons.business_outlined;
  }
}

// -- Assessment History --------------------------------------------------------

class AssessmentRecord {
  final DateTime date;
  final int score;
  final int maxScore;
  final String stressLevel; // 'low', 'moderate', 'high'

  const AssessmentRecord({
    required this.date,
    required this.score,
    this.maxScore = 50,
    required this.stressLevel,
  });
}

class DummyAssessmentHistory {
  static final List<AssessmentRecord> records = [
    AssessmentRecord(date: DateTime(2026, 3, 25), score: 18, stressLevel: 'low'),
    AssessmentRecord(date: DateTime(2026, 3, 18), score: 32, stressLevel: 'moderate'),
    AssessmentRecord(date: DateTime(2026, 3, 11), score: 38, stressLevel: 'high'),
    AssessmentRecord(date: DateTime(2026, 3, 4), score: 28, stressLevel: 'moderate'),
    AssessmentRecord(date: DateTime(2026, 2, 25), score: 22, stressLevel: 'low'),
    AssessmentRecord(date: DateTime(2026, 2, 18), score: 35, stressLevel: 'high'),
    AssessmentRecord(date: DateTime(2026, 2, 11), score: 20, stressLevel: 'low'),
    AssessmentRecord(date: DateTime(2026, 2, 4), score: 30, stressLevel: 'moderate'),
    AssessmentRecord(date: DateTime(2026, 1, 28), score: 15, stressLevel: 'low'),
    AssessmentRecord(date: DateTime(2026, 1, 21), score: 26, stressLevel: 'moderate'),
  ];
}

// -- Incident Reports ---------------------------------------------------------

class IncidentReport {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final int stressLevel; // 1-5
  final String status; // 'pending', 'reviewed', 'resolved'
  final String? hrResponse;

  const IncidentReport({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.stressLevel,
    required this.status,
    this.hrResponse,
  });
}

class DummyIncidentReports {
  static final List<IncidentReport> reports = [
    IncidentReport(
      id: 'RPT001',
      date: DateTime(2026, 3, 25),
      category: 'Beban Kerja Berlebihan',
      description:
          'Selama 2 minggu terakhir, saya mendapatkan assignment tambahan dari 3 project berbeda secara bersamaan. Deadline yang diberikan sangat ketat dan tidak realistis. Saya sudah mencoba berbicara dengan lead saya tetapi belum ada perubahan signifikan. Hal ini membuat saya merasa kewalahan dan sulit fokus.',
      stressLevel: 4,
      status: 'reviewed',
      hrResponse:
          'Terima kasih atas laporan Anda. Kami sudah berdiskusi dengan manajer divisi untuk melakukan review beban kerja tim. Akan ada penyesuaian task distribution mulai minggu depan. Silakan hubungi kami jika kondisi tidak membaik.',
    ),
    IncidentReport(
      id: 'RPT002',
      date: DateTime(2026, 3, 18),
      category: 'Konflik dengan Rekan Kerja',
      description:
          'Terjadi miskomunikasi berulang dengan rekan satu tim terkait pembagian tugas. Beberapa kali hasil pekerjaan saya diubah tanpa diskusi terlebih dahulu, yang membuat saya merasa tidak dihargai.',
      stressLevel: 3,
      status: 'resolved',
      hrResponse:
          'Kami telah memfasilitasi mediasi antara kedua belah pihak pada tanggal 22 Maret. Kedua pihak sepakat untuk membuat workflow yang lebih jelas dan melakukan daily sync setiap pagi. Laporan ini ditutup karena situasi sudah membaik.',
    ),
    IncidentReport(
      id: 'RPT003',
      date: DateTime(2026, 3, 10),
      category: 'Work-Life Balance',
      description:
          'Akhir-akhir ini saya sering diminta lembur hingga malam tanpa kompensasi yang jelas. Waktu istirahat saya berkurang drastis dan mulai mempengaruhi kesehatan fisik saya.',
      stressLevel: 5,
      status: 'reviewed',
      hrResponse:
          'Kami memahami kekhawatiran Anda. Tim HR sedang melakukan audit terhadap kebijakan overtime di divisi Anda. Sementara itu, kami sarankan untuk berkomunikasi langsung dengan atasan mengenai batas waktu kerja Anda.',
    ),
    IncidentReport(
      id: 'RPT004',
      date: DateTime(2026, 2, 28),
      category: 'Masalah Manajemen',
      description:
          'Atasan saya jarang memberikan feedback yang konstruktif dan seringkali mengubah prioritas kerja secara mendadak. Hal ini membuat saya bingung dan tidak yakin dengan arah pekerjaan saya.',
      stressLevel: 3,
      status: 'pending',
    ),
    IncidentReport(
      id: 'RPT005',
      date: DateTime(2026, 2, 15),
      category: 'Lingkungan Kerja',
      description:
          'Ruangan kerja kami sangat bising karena renovasi gedung lantai atas. Sudah berlangsung selama 3 minggu dan sangat mengganggu konsentrasi tim kami.',
      stressLevel: 2,
      status: 'resolved',
      hrResponse:
          'Renovasi telah selesai per tanggal 5 Maret. Kami juga telah menyediakan noise-cancelling headphones untuk tim Anda sebagai solusi jangka pendek. Terima kasih atas kesabaran Anda.',
    ),
    IncidentReport(
      id: 'RPT006',
      date: DateTime(2026, 2, 5),
      category: 'Beban Kerja Berlebihan',
      description:
          'Saya ditugaskan menangani client baru yang sangat demanding sementara project lama belum selesai. Merasa tertekan karena harus multitasking terus-menerus.',
      stressLevel: 4,
      status: 'resolved',
      hrResponse:
          'Setelah evaluasi, kami telah menambahkan satu anggota tim baru untuk membantu project lama Anda. Semoga ini membantu meringankan beban kerja.',
    ),
    IncidentReport(
      id: 'RPT007',
      date: DateTime(2026, 1, 20),
      category: 'Lainnya',
      description:
          'Saya merasa kurang mendapat kesempatan untuk pengembangan karir. Tidak ada program training atau mentoring yang tersedia di divisi saya.',
      stressLevel: 2,
      status: 'pending',
    ),
  ];
}

// -- Mood & Weekly Stress (for Analytics) --------------------------------------

class MoodEntry {
  final String day; // e.g. 'Mon'
  final int moodScore; // 1=Kurang Baik, 2=Netral, 3=Baik, 4=Sangat Baik

  const MoodEntry(this.day, this.moodScore);
}

class DummyMoodHistory {
  static const List<MoodEntry> last7Days = [
    MoodEntry('Sen', 3),
    MoodEntry('Sel', 4),
    MoodEntry('Rab', 2),
    MoodEntry('Kam', 3),
    MoodEntry('Jum', 3),
    MoodEntry('Sab', 4),
    MoodEntry('Min', 3),
  ];

  static const moodLabels = {1: 'Kurang', 2: 'Netral', 3: 'Baik', 4: 'Sangat Baik'};
}

class WeeklyStressEntry {
  final String label; // e.g. 'Minggu 1'
  final double avgScore; // 0-100

  const WeeklyStressEntry(this.label, this.avgScore);
}

class DummyWeeklyStress {
  static const List<WeeklyStressEntry> last4Weeks = [
    WeeklyStressEntry('Mg 1', 62),
    WeeklyStressEntry('Mg 2', 48),
    WeeklyStressEntry('Mg 3', 55),
    WeeklyStressEntry('Mg 4', 40),
  ];
}
