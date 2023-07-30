
import 'wakeup_scheduler_platform_interface.dart';

class WakeupScheduler {
  Future<String?> getPlatformVersion() {
    return WakeupSchedulerPlatform.instance.getPlatformVersion();
  }
}
