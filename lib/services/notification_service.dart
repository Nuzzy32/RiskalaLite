import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Smart daily mood-reminder scheduler.
///
/// Rather than one repeating notification that fires every morning regardless,
/// we keep a rolling [_windowDays]-day window of one-shot reminders. Each app
/// launch (and every mood check-in) calls [sync], which rebuilds the window and
/// **skips today when the user has already checked in** — so the nudge only
/// appears on days they haven't. Inexact scheduling is used on purpose: a
/// wellness nudge doesn't need second-precision and it avoids the restricted
/// exact-alarm permission.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _kEnabledKey = 'mood_reminder_enabled';
  static const _kHourKey = 'mood_reminder_hour';
  static const _kMinuteKey = 'mood_reminder_minute';

  /// Base id for the rolling window; day offset N uses [_baseId] + N.
  static const int _baseId = 100;
  static const int _windowDays = 7;

  static const TimeOfDay defaultTime = TimeOfDay(hour: 9, minute: 0);

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // One-time cleanup: the previous version used a single repeating
    // notification (id 1). Cancel any orphan so it doesn't fire forever.
    await _plugin.cancel(1);

    // Runtime permission — Android 13+ requires POST_NOTIFICATIONS, iOS prompts.
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Preferences ───────────────────────────────────────────────────────────

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  static Future<TimeOfDay> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getInt(_kHourKey);
    final m = prefs.getInt(_kMinuteKey);
    if (h == null || m == null) return defaultTime;
    return TimeOfDay(hour: h, minute: m);
  }

  /// Turn the reminder on/off. When enabling we don't yet know today's check-in
  /// state, so today is included; the next [sync] (on launch / check-in) prunes it.
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
    if (value) {
      await sync(checkedInToday: false);
    } else {
      await _cancelWindow();
    }
  }

  static Future<void> setTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHourKey, time.hour);
    await prefs.setInt(_kMinuteKey, time.minute);
    if (await isEnabled()) await sync(checkedInToday: false);
  }

  // ── Scheduling ──────────────────────────────────────────────────────────

  /// Rebuild the reminder window. Call on app launch and after every mood
  /// check-in. [checkedInToday] true → today's reminder is dropped.
  static Future<void> sync({required bool checkedInToday}) async {
    await _cancelWindow();
    if (!await isEnabled()) return;

    final time = await getTime();
    final now = tz.TZDateTime.now(tz.local);

    for (var offset = 0; offset < _windowDays; offset++) {
      // Skip today if already checked in.
      if (offset == 0 && checkedInToday) continue;

      final when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute,
      ).add(Duration(days: offset));

      // Today's slot already passed → nothing to fire today.
      if (when.isBefore(now)) continue;

      await _plugin.zonedSchedule(
        _baseId + offset,
        _titleFor(time.hour),
        'Sudah catat mood hari ini? Luangkan sebentar untuk dirimu. 💙',
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> _cancelWindow() async {
    for (var offset = 0; offset < _windowDays; offset++) {
      await _plugin.cancel(_baseId + offset);
    }
  }

  static String _titleFor(int hour) {
    if (hour < 11) return 'Selamat Pagi 🌅';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌤️';
    return 'Selamat Malam 🌙';
  }

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'mood_reminder_channel',
      'Pengingat Mood Harian',
      channelDescription: 'Pengingat lembut untuk check-in mood',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    ),
  );
}
