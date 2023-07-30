import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_scheduler/wakeup_scheduler_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWakeupScheduler platform = MethodChannelWakeupScheduler();
  const MethodChannel channel = MethodChannel('wakeup_scheduler');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
