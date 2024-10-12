import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker/ui.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  bool isAccelerating = false;
  Position? prevPosition;
  double distance = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('getLocation').listen((event) async {
    Position position = await Geolocator.getCurrentPosition();
    service.invoke(
      'updatePos',
      {
        "lat": position.latitude.toString(),
        "long": position.longitude.toString(),
      },
    );
    service.invoke(
      'updateDistance',
      {
        "distance": distance,
      },
    );
  });

  int estSeconds = 0;

  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      estSeconds++;
      int hours = estSeconds ~/ 3600;
      int minutes = (estSeconds % 3600) ~/ 60;
      int seconds = estSeconds % 60;
      service.invoke('updateTime',
          {'hours': hours, 'minutes': minutes, 'seconds': seconds});
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  service.on('startTimer').listen((event) {
    if (timer != null) {
      if (timer!.isActive) {
        stopTimer();
      } else {
        startTimer();
      }
    } else {
      startTimer();
    }
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      flutterLocalNotificationsPlugin.show(
        888,
        'Location Service',
        'Updated at ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      // service.setForegroundNotificationInfo(
      //   title: "My App Service",
      //   content: "Updated at ${DateTime.now()}",
      // );
    }
  }
  userAccelerometerEventStream().listen((sensors) {
    if (sensors.z > 0.2 || sensors.z < -0.2) {
      isAccelerating = true;
      stopTimer();
    } else {
      isAccelerating = false;
    }
  });

  Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  )).listen((position) {
    if (!isAccelerating) {
      return;
    }

    if (position.speed < 0.01) {
      return;
    }

    if (prevPosition != null) {
      final dist = Geolocator.distanceBetween(prevPosition!.latitude,
          prevPosition!.longitude, position.latitude, position.longitude);
      if (dist > 5) {
        return;
      }
      distance += Geolocator.distanceBetween(prevPosition!.latitude,
          prevPosition!.longitude, position.latitude, position.longitude);
      prevPosition = position;
      service.invoke('updateDistance', {'distance': distance});
    } else {
      prevPosition = position;
      service.invoke('updateDistance', {'distance': distance});
    }

    service.invoke(
      'updatePos',
      {
        "lat": position.latitude.toString(),
        "long": position.longitude.toString(),
      },
    );
    service.invoke(
      'updateSpeed',
      {
        "speed": position.speed.toString(),
      },
    );
  });
}
