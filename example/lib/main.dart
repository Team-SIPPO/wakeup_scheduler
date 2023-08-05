import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakeup_scheduler/wakeup_scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _wakeupSchedulerPlugin = WakeupScheduler();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    initPlatformState();
    _wakeupSchedulerPlugin.detectScheduleStream().listen((event) {
      var now = DateTime.now();
      print("recieved->alarmNum ${event.alarmNumber}, tag ${event.tag} ${now.toString()}");
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _wakeupSchedulerPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.scheduleExactAlarm.request().isDenied) {
      print("scheduleExactAlarm is Denied");
    }
    if (await Permission.systemAlertWindow.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("SYSTEM_ALERT_WINDOW is Granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                child: Text('oneShot 5sec: $_platformVersion\n'),
                onPressed: () async {
                  await _wakeupSchedulerPlugin.setOneShotSchedule(
                      const Duration(seconds: 5), 1,
                      tag: "test");
                },
              ),
              ElevatedButton(
                child: const Text('cancel button'),
                onPressed: () async {
                  final now = DateTime.now();
                  print("cancel button $now");
                  await _wakeupSchedulerPlugin.cancelSchedule(1);
                },
              ),
              ElevatedButton(
                child: const Text('Periodic button'),
                onPressed: () async {
                  final now = DateTime.now();
                  final startAt = DateTime(now.year, now.month, now.day + 1, 8);
                  print("Periodic button $now startAt: $startAt");
                  await _wakeupSchedulerPlugin.setPeriodicSchedule(
                      const Duration(minutes: 60), 1,
                      startAt: startAt);
                },
              ),
            ]),
          )),
    );
  }
}
