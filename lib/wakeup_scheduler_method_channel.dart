import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wakeup_scheduler_platform_interface.dart';

/// An implementation of [WakeupSchedulerPlatform] that uses method channels.
class MethodChannelWakeupScheduler extends WakeupSchedulerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wakeup_scheduler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
