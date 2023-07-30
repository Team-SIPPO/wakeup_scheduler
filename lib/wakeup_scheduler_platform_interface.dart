import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wakeup_scheduler_method_channel.dart';

abstract class WakeupSchedulerPlatform extends PlatformInterface {
  /// Constructs a WakeupSchedulerPlatform.
  WakeupSchedulerPlatform() : super(token: _token);

  static final Object _token = Object();

  static WakeupSchedulerPlatform _instance = MethodChannelWakeupScheduler();

  /// The default instance of [WakeupSchedulerPlatform] to use.
  ///
  /// Defaults to [MethodChannelWakeupScheduler].
  static WakeupSchedulerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WakeupSchedulerPlatform] when
  /// they register themselves.
  static set instance(WakeupSchedulerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
