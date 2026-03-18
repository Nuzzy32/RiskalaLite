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
