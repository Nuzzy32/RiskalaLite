import 'package:flutter/material.dart';

/// Daily rotating micro-content for the home surface.
///
/// Lives in Flutter (not the backend) because it is static, curated, and
/// carries an [IconData]. Selection is deterministic per calendar day via
/// [dailyItemFor] so the card is stable across rebuilds within a day and
/// quietly rotates each morning — giving a reason to open the app even on
/// days when nothing else changed.

enum DailyKind {
  /// Practical, actionable advice.
  tip,

  /// A short reflective quote.
  quote,

  /// A tiny practice the user can act on now (may link to an [Activity]).
  practice,
}

class DailyItem {
  final DailyKind kind;
  final String title;
  final String body;

  /// Attribution, only meaningful for [DailyKind.quote].
  final String? author;

  /// If set, the card shows a CTA that opens the matching [Activity] from
  /// `kActivityCatalog`. Must be a valid catalog key.
  final String? activityKey;

  const DailyItem({
    required this.kind,
    required this.title,
    required this.body,
    this.author,
    this.activityKey,
  });
}

/// Curated pool — kept above ~21 so content does not repeat within three weeks.
const List<DailyItem> kDailyPool = [
  // ── Tips ──────────────────────────────────────────────────────────────────
  DailyItem(
    kind: DailyKind.tip,
    title: 'Aturan dua menit',
    body:
        'Kalau ada tugas yang bisa diselesaikan di bawah dua menit, kerjakan sekarang. Menunda hal kecil diam-diam menumpuk jadi beban mental.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Jeda tanpa layar',
    body:
        'Setiap satu jam kerja, alihkan pandangan dari layar selama 20 detik ke objek jauh. Mata lelah sering disalahartikan otak sebagai stres.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Satu hal pada satu waktu',
    body:
        'Multitasking terasa produktif tapi menguras fokus. Pilih satu tugas, selesaikan, baru pindah. Pikiranmu akan terasa lebih tenang.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Tidur lebih penting dari lembur',
    body:
        'Satu jam tidur yang cukup mengembalikan fokus lebih banyak daripada satu jam lembur dalam keadaan lelah. Jaga jam tidurmu.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Batas yang sehat',
    body:
        'Mengatakan "tidak" pada hal yang melebihi kapasitasmu bukan egois — itu menjaga agar "ya"-mu tetap berkualitas.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Pisahkan kerja dan rumah',
    body:
        'Buat ritual penutup hari kerja: tutup laptop, rapikan meja, tarik napas. Sinyal kecil ini membantu otak berpindah mode.',
  ),
  DailyItem(
    kind: DailyKind.tip,
    title: 'Gerak sebentar',
    body:
        'Duduk terlalu lama menumpuk ketegangan. Berdiri, regangkan bahu, jalan ke dapur. Tubuh yang bergerak menenangkan pikiran.',
  ),

  // ── Quotes ──────────────────────────────────────────────────────────────
  DailyItem(
    kind: DailyKind.quote,
    title: 'Kamu tidak harus selalu kuat',
    body:
        'Merawat diri bukan tanda lemah, melainkan cara bertahan untuk jangka panjang.',
    author: 'RISKALA',
  ),
  DailyItem(
    kind: DailyKind.quote,
    title: 'Istirahat itu produktif',
    body: 'Hampir semua hal akan bekerja lagi kalau kamu mencabutnya sebentar, termasuk dirimu.',
    author: 'Anne Lamott',
  ),
  DailyItem(
    kind: DailyKind.quote,
    title: 'Cukup untuk hari ini',
    body: 'Kamu tidak perlu menyelesaikan segalanya hari ini. Lakukan yang bisa, lalu beri dirimu istirahat.',
    author: 'RISKALA',
  ),
  DailyItem(
    kind: DailyKind.quote,
    title: 'Perasaan datang dan pergi',
    body:
        'Tidak ada perasaan yang permanen. Hari yang berat tidak menentukan keseluruhan dirimu.',
    author: 'RISKALA',
  ),
  DailyItem(
    kind: DailyKind.quote,
    title: 'Kemajuan kecil tetap kemajuan',
    body: 'Tidak harus melompat jauh. Selangkah kecil hari ini sudah cukup berarti.',
    author: 'RISKALA',
  ),
  DailyItem(
    kind: DailyKind.quote,
    title: 'Minta tolong itu wajar',
    body:
        'Meminta bantuan bukan beban bagi orang lain — sering kali itu justru cara terbaik untuk tetap terhubung.',
    author: 'RISKALA',
  ),

  // ── Practices (some link to activities) ──────────────────────────────────
  DailyItem(
    kind: DailyKind.practice,
    title: 'Tarik napas dalam',
    body:
        'Luangkan dua menit untuk pernapasan 4-7-8. Cara cepat menurunkan ketegangan saat pikiran terasa penuh.',
    activityKey: 'breathing_478',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Kembali ke saat ini',
    body:
        'Coba teknik grounding 5-4-3-2-1 untuk menarik perhatianmu kembali ke momen sekarang.',
    activityKey: 'grounding_54321',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Tiga hal hari ini',
    body:
        'Tuliskan tiga hal kecil yang kamu syukuri hari ini. Otak yang melatih syukur lebih tahan terhadap stres.',
    activityKey: 'gratitude',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Minum air dulu',
    body:
        'Sering kali lelah dan sulit fokus sebenarnya tanda dehidrasi ringan. Ambil segelas air sekarang.',
    activityKey: 'hydration',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Jeda mikro',
    body:
        'Berhenti satu menit. Tutup mata, lemaskan bahu, dan biarkan napasmu melambat. Tidak perlu alasan.',
    activityKey: 'micro_break',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Regangkan tubuh',
    body:
        'Bangun dan regangkan leher serta punggung selama satu menit. Ketegangan fisik dan mental saling terhubung.',
    activityKey: 'stretch',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Tulis yang mengganjal',
    body:
        'Pikiran yang berputar terasa lebih ringan saat dituangkan. Coba journaling singkat beberapa baris.',
    activityKey: 'journaling',
  ),
  DailyItem(
    kind: DailyKind.practice,
    title: 'Jalan ringan',
    body:
        'Jalan kaki sebentar, walau hanya mengelilingi ruangan, membantu menjernihkan kepala.',
    activityKey: 'light_walk',
  ),
];

/// Deterministic pick for a given calendar [date]. Same day → same item.
DailyItem dailyItemFor(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  return kDailyPool[dayOfYear % kDailyPool.length];
}
