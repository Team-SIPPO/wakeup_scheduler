import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_scheduler/wakeup_scheduler.dart';
import 'package:wakeup_scheduler/wakeup_scheduler_platform_interface.dart';
import 'package:wakeup_scheduler/wakeup_scheduler_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWakeupSchedulerPlatform
    with MockPlatformInterfaceMixin
    implements WakeupSchedulerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WakeupSchedulerPlatform initialPlatform = WakeupSchedulerPlatform.instance;

  test('$MethodChannelWakeupScheduler is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWakeupScheduler>());
  });

  test('getPlatformVersion', () async {
    WakeupScheduler wakeupSchedulerPlugin = WakeupScheduler();
    MockWakeupSchedulerPlatform fakePlatform = MockWakeupSchedulerPlatform();
    WakeupSchedulerPlatform.instance = fakePlatform;

    expect(await wakeupSchedulerPlugin.getPlatformVersion(), '42');
  });
}
