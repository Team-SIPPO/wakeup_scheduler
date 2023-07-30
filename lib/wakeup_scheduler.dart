import 'package:flutter/services.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';


import 'wakeup_scheduler_platform_interface.dart';

class WakeupScheduler {
  static const EventChannel _eventChannel = EventChannel("wakeup_scheduler/schedule");
  static bool _isInitialized = false;
  Future<String?> getPlatformVersion() {
    return WakeupSchedulerPlatform.instance.getPlatformVersion();
  }
  Stream<dynamic> detectScheduleStream() {
    return _eventChannel.receiveBroadcastStream();
  }
  Future<void> setOneShotSchedule(Duration duration, alarmNumber) async {
    initialize();
    AndroidAlarmManager.oneShot(
      duration,
      // Ensure we have a unique alarm ID.
      alarmNumber,
      callback,
      allowWhileIdle: true,
      wakeup: true,
      exact: true,
    );
    return ;
  }
  Future<void> setPeriodicSchedule(Duration duration, alarmNumber) async {
    initialize();
    AndroidAlarmManager.periodic(
      duration,
      // Ensure we have a unique alarm ID.
      alarmNumber,
      callback,
      allowWhileIdle: true,
      wakeup: true,
      exact: true,
    );
    return ;
  }

  Future<void> cancelSchedule(alarmNumber) async {
    initialize();
    await AndroidAlarmManager.cancel(alarmNumber);
    return ;
  }

  void initialize() {
    if (!_isInitialized) {
      WidgetsFlutterBinding.ensureInitialized();
      AndroidAlarmManager.initialize();
      _isInitialized = true;
    }
  }
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    const intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      category: "android.intent.category.DEFAULT",
      package: "io.github.team_sippo.wakeup_scheduler_example",
      type: 'text/plain', // dataを書くと動かない
      arguments: {
        'extra1': 'value1',
      },
    );
    intent.launch();
  }

}