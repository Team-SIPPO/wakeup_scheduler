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
      print("recieved: " + event);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _wakeupSchedulerPlugin.getPlatformVersion() ?? 'Unknown platform version';
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
          child: ElevatedButton(
            child: Text('Running on: $_platformVersion\n'),
            onPressed: () async {
              await _wakeupSchedulerPlugin.setOneShotSchedule(const Duration(seconds: 5), 1);
            },
          ),
        ),
      ),
    );
  }
}
