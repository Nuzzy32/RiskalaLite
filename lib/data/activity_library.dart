import 'package:flutter/material.dart';

/// Curated catalog of wellness activities ("Your Plan").
///
/// Lives in Flutter (not the backend) because the content is static, curated,
/// and carries an [IconData] that doesn't serialize cleanly. The backend only
/// stores the stable [Activity.key] string in `user_activities` / `activity_logs`.

enum ActivityType {
  /// Runs a countdown via the timer sheet (e.g. breathing, meditation).
  timed,

  /// Marked done with a single tap (e.g. hydration, gratitude note).
  simple,
}

class Activity {
  /// Stable identifier persisted to the backend. Never rename in place.
  final String key;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final ActivityType type;

  /// Duration in seconds (only meaningful for [ActivityType.timed]).
  final int durationSeconds;

  const Activity({
    required this.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.type,
    this.durationSeconds = 0,
  });

  bool get isTimed => type == ActivityType.timed;

  String get durationLabel {
    if (!isTimed || durationSeconds == 0) return 'Cepat';
    final mins = durationSeconds ~/ 60;
    return mins > 0 ? '$mins min' : '$durationSeconds dtk';
  }
}

/// The master catalog, keyed for O(1) lookup by [Activity.key].
const Map<String, Activity> kActivityCatalog = {
  'breathing_478': Activity(
    key: 'breathing_478',
    title: 'Pernapasan 4-7-8',
    desc: 'Tarik 4 dtk, tahan 7, embuskan 8',
    icon: Icons.air_rounded,
    color: Color(0xFF61D1DB),
    bgColor: Color(0xFFE8FBFC),
    type: ActivityType.timed,
    durationSeconds: 120,
  ),
  'meditation': Activity(
    key: 'meditation',
    title: 'Meditasi Singkat',
    desc: 'Tenangkan pikiran dengan mindfulness',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFFA78BFA),
    bgColor: Color(0xFFF3EEFF),
    type: ActivityType.timed,
    durationSeconds: 300,
  ),
  'grounding_54321': Activity(
    key: 'grounding_54321',
    title: 'Grounding 5-4-3-2-1',
    desc: 'Sebutkan hal di sekitarmu untuk hadir',
    icon: Icons.touch_app_rounded,
    color: Color(0xFF4EC8A8),
    bgColor: Color(0xFFE6F8F1),
    type: ActivityType.timed,
    durationSeconds: 180,
  ),
  'micro_break': Activity(
    key: 'micro_break',
    title: 'Jeda Mikro',
    desc: 'Berdiri, regangkan tubuh, jauhi layar',
    icon: Icons.timer_outlined,
    color: Color(0xFFFB923C),
    bgColor: Color(0xFFFFF4E5),
    type: ActivityType.timed,
    durationSeconds: 300,
  ),
  'hydration': Activity(
    key: 'hydration',
    title: 'Minum Air',
    desc: 'Satu gelas air untuk menyegarkan',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF60A5FA),
    bgColor: Color(0xFFE3F2FD),
    type: ActivityType.simple,
  ),
  'journaling': Activity(
    key: 'journaling',
    title: 'Journaling',
    desc: 'Tuliskan apa yang kamu rasakan',
    icon: Icons.edit_note_rounded,
    color: Color(0xFFC084FC),
    bgColor: Color(0xFFF3E5F5),
    type: ActivityType.timed,
    durationSeconds: 600,
  ),
  'gratitude': Activity(
    key: 'gratitude',
    title: 'Catatan Syukur',
    desc: 'Sebutkan 3 hal yang kamu syukuri',
    icon: Icons.favorite_rounded,
    color: Color(0xFFF472B6),
    bgColor: Color(0xFFFCE7F3),
    type: ActivityType.simple,
  ),
  'light_walk': Activity(
    key: 'light_walk',
    title: 'Jalan Ringan',
    desc: 'Bergerak sebentar untuk melepas penat',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF34D399),
    bgColor: Color(0xFFE6F9F1),
    type: ActivityType.timed,
    durationSeconds: 600,
  ),
  'stretch': Activity(
    key: 'stretch',
    title: 'Peregangan',
    desc: 'Lemaskan otot leher dan bahu',
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFFFBBF24),
    bgColor: Color(0xFFFEF6E0),
    type: ActivityType.timed,
    durationSeconds: 180,
  ),
  'sleep_winddown': Activity(
    key: 'sleep_winddown',
    title: 'Persiapan Tidur',
    desc: 'Rutinitas tenang sebelum istirahat',
    icon: Icons.bedtime_rounded,
    color: Color(0xFF818CF8),
    bgColor: Color(0xFFEEF0FF),
    type: ActivityType.timed,
    durationSeconds: 300,
  ),
};

List<String> recommendedActivityKeys({int? stressCategory, int? moodLevel}) {
  int level;
  if (stressCategory != null) {
    level = stressCategory.clamp(1, 3);
    if (moodLevel != null && moodLevel <= 2 && level < 3) level += 1;
  } else if (moodLevel != null) {
    if (moodLevel <= 2) {
      level = 3;
    } else if (moodLevel == 3) {
      level = 2;
    } else {
      level = 1;
    }
  } else {
    level = 2;
  }

  switch (level) {
    case 3:
      return [
        'breathing_478',
        'grounding_54321',
        'micro_break',
        'sleep_winddown',
      ];
    case 1:
      return ['gratitude', 'journaling', 'light_walk', 'hydration'];
    case 2:
    default:
      return ['breathing_478', 'journaling', 'stretch', 'hydration'];
  }
}

/// Safe lookup — returns null for unknown keys (e.g. catalog drift).
Activity? activityByKey(String key) => kActivityCatalog[key];

/// All activities as an ordered list (for the library picker).
List<Activity> get allActivities => kActivityCatalog.values.toList();
