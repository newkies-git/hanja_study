import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 일일 학습 리마인더를 관리하는 로컬 알림 서비스.
///
/// 사용 방법:
///   1. `main()` 에서 `await NotificationService.initialize()` 호출.
///   2. 알림 권한이 필요할 때 `await NotificationService.requestPermissions()`.
///   3. 요일·시간 설정 후 `await NotificationService.scheduleWeeklyReminders(...)`.
///   4. 알림 끄기: `await NotificationService.cancelDailyReminders()`.
abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // 알림 ID: 요일별 0~6
  static const int _baseId = 100;

  // ── 초기화 ─────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // 타임존 조회 실패 시 UTC로 동작
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _initialized = true;
  }

  // ── 권한 요청 ──────────────────────────────────────────────────────────

  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  // ── 스케줄링 ───────────────────────────────────────────────────────────

  /// [selectedDays]: 월(0)~일(6) 순서의 7개 bool 리스트.
  /// [hour], [minute]: 24시간 기준 알림 시각.
  static Future<void> scheduleWeeklyReminders({
    required List<bool> selectedDays,
    required int hour,
    required int minute,
  }) async {
    assert(selectedDays.length == 7, 'selectedDays must have 7 elements');
    await cancelDailyReminders();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      '일일 학습 알림',
      channelDescription: '매일 설정한 시간에 한자 학습을 리마인드합니다.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // 월요일 = 1 (DateTime.weekday), 일요일 = 7
    // selectedDays[0]=월, ..., selectedDays[6]=일
    for (int i = 0; i < 7; i++) {
      if (!selectedDays[i]) continue;

      final weekday = i + 1; // 1=월 ~ 7=일 (DateTime 기준)
      await _plugin.zonedSchedule(
        _baseId + i,
        '오늘의 한자 학습 시간이에요 📖',
        '추사 1817을 열어 오늘의 한자를 학습하세요.',
        _nextWeekday(weekday, hour, minute),
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelDailyReminders() async {
    for (int i = 0; i < 7; i++) {
      await _plugin.cancel(_baseId + i);
    }
  }

  // ── 내부 헬퍼 ─────────────────────────────────────────────────────────

  static tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 현재 요일에서 목표 요일까지 며칠 앞으로 가야 하는지 계산
    int daysAhead = (weekday - now.weekday) % 7;
    if (daysAhead == 0 && scheduled.isBefore(now)) {
      daysAhead = 7; // 오늘이지만 이미 지난 시각이면 다음 주로
    }
    return scheduled.add(Duration(days: daysAhead));
  }
}
