import 'package:flutter/services.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';

import 'wakeup_scheduler_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AlarmInfo {
  final int alarmNumber;
  final String tag;
  AlarmInfo(this.alarmNumber, this.tag);
}

AlarmInfo parseAlarmInfo(dynamic event) {
    var message = event.toString();
    var stringNumber = message.split(":")[0];
    var alarmNumber = int.parse(stringNumber);
    var tag = message.replaceFirst("$stringNumber:", "");
    return AlarmInfo(alarmNumber, tag);
}

class WakeupScheduler {
  static const EventChannel _eventChannel = EventChannel("wakeup_scheduler/schedule");
  static bool _isInitialized = false;

  Future<String?> getPlatformVersion() {
    return WakeupSchedulerPlatform.instance.getPlatformVersion();
  }
  Stream<AlarmInfo> detectScheduleStream() {
    return _eventChannel.receiveBroadcastStream().map((event) => parseAlarmInfo(event));
  }
  Future<void> setOneShotSchedule(Duration duration, int alarmNumber, {String tag = ""}) async {
    initialize();
    Map<String, String> params = <String, String>{} ;
    params["wakeup_tag"] = "$alarmNumber:$tag";
    AndroidAlarmManager.oneShot(
      duration,
      // Ensure we have a unique alarm ID.
      alarmNumber,
      callback,
      allowWhileIdle: true,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
      params: params
    );
    return ;
  }
  Future<void> setPeriodicSchedule(Duration duration, int alarmNumber, {DateTime? startAt, String tag = ""}) async {
    initialize();
    Map<String, String> params = <String, String>{} ;
    params["wakeup_tag"] = "$alarmNumber:$tag";
    AndroidAlarmManager.periodic(
      duration,
      // Ensure we have a unique alarm ID.
      alarmNumber,
      callback,
      startAt: startAt,
      allowWhileIdle: true,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
      params: params
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
  static Future<void> callback(int alarmNum, Map<String, dynamic> params) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      category: "android.intent.category.DEFAULT",
      package: packageName,
      type: 'text/plain', // dataを書くと動かない
      arguments: params,
    );
    intent.launch();
  }

}