import 'package:flutter/material.dart';

class SelfHelpTip {
  final IconData icon;
  final String title;
  final String description;

  const SelfHelpTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class StressGuidance {
  final int category;
  final String label;
  final String headline;
  final String message;
  final Color color;
  final Color softColor;
  final List<SelfHelpTip> tips;

  const StressGuidance({
    required this.category,
    required this.label,
    required this.headline,
    required this.message,
    required this.color,
    required this.softColor,
    required this.tips,
  });
}

int stressCategoryFromScore(int score) {
  if (score <= 13) return 1;
  if (score <= 26) return 2;
  return 3;
}

const _low = StressGuidance(
  category: 1,
  label: 'Stres Ringan',
  headline: 'Kamu dalam kondisi baik 🌿',
  message:
      'Tingkat stresmu rendah. Pertahankan kebiasaan sehat ini agar tetap seimbang.',
  color: Color(0xFF22C55E),
  softColor: Color(0xFFE9F9EF),
  tips: [
    SelfHelpTip(
      icon: Icons.bedtime_outlined,
      title: 'Jaga Ritme Istirahat',
      description:
          'Tidur dan bangun di jam yang konsisten menjaga energimu sepanjang hari.',
    ),
    SelfHelpTip(
      icon: Icons.emoji_events_outlined,
      title: 'Apresiasi Pencapaian Kecil',
      description:
          'Luangkan waktu mengakui progres harianmu, sekecil apa pun itu.',
    ),
    SelfHelpTip(
      icon: Icons.groups_outlined,
      title: 'Tetap Terhubung',
      description:
          'Hubungan baik dengan rekan kerja adalah penyangga alami terhadap stres.',
    ),
  ],
);

const _moderate = StressGuidance(
  category: 2,
  label: 'Stres Sedang',
  headline: 'Saatnya beri ruang untuk diri 🌤️',
  message:
      'Stresmu mulai terasa. Coba langkah-langkah kecil berikut untuk meredakannya.',
  color: Color(0xFFE0982E),
  softColor: Color(0xFFFFF6E6),
  tips: [
    SelfHelpTip(
      icon: Icons.self_improvement_outlined,
      title: 'Pernapasan 4-7-8',
      description:
          'Tarik napas 4 detik, tahan 7 detik, embuskan 8 detik. Ulangi 4 kali saat tegang.',
    ),
    SelfHelpTip(
      icon: Icons.checklist_rtl_outlined,
      title: 'Pecah Tugas Besar',
      description:
          'Bagi pekerjaan menjadi langkah-langkah kecil agar tidak terasa kewalahan.',
    ),
    SelfHelpTip(
      icon: Icons.timer_outlined,
      title: 'Ambil Jeda Mikro',
      description:
          'Istirahat 5 menit tiap jam: berdiri, regangkan tubuh, dan jauhkan layar.',
    ),
    SelfHelpTip(
      icon: Icons.notifications_off_outlined,
      title: 'Kurangi Gangguan',
      description:
          'Matikan notifikasi non-esensial saat kamu butuh fokus penuh.',
    ),
  ],
);

const _high = StressGuidance(
  category: 3,
  label: 'Stres Tinggi',
  headline: 'Kamu tidak sendirian 💙',
  message:
      'Tingkat stresmu tinggi. Jangan memikulnya sendiri — langkah berikut bisa membantu.',
  color: Color(0xFFE5484D),
  softColor: Color(0xFFFFEDED),
  tips: [
    SelfHelpTip(
      icon: Icons.support_agent_outlined,
      title: 'Bicara dengan Seseorang',
      description:
          'Hubungi orang terpercaya atau psikolog. Berbagi beban itu meringankan.',
    ),
    SelfHelpTip(
      icon: Icons.psychology_outlined,
      title: 'Pertimbangkan Konsultasi',
      description:
          'Sesi dengan psikolog dapat sangat membantu dan bisa diajukan rahasia dari aplikasi.',
    ),
    SelfHelpTip(
      icon: Icons.spa_outlined,
      title: 'Prioritaskan Pemulihan',
      description:
          'Tidur cukup dan aktivitas fisik ringan membantu menurunkan ketegangan.',
    ),
    SelfHelpTip(
      icon: Icons.touch_app_outlined,
      title: 'Grounding 5-4-3-2-1',
      description:
          'Sebutkan 5 hal yang kamu lihat, 4 yang disentuh, 3 yang didengar, 2 dicium, 1 dirasakan.',
    ),
  ],
);

StressGuidance guidanceForCategory(int category) {
  switch (category) {
    case 1:
      return _low;
    case 3:
      return _high;
    case 2:
    default:
      return _moderate;
  }
}

StressGuidance guidanceForScore(int score) =>
    guidanceForCategory(stressCategoryFromScore(score));
