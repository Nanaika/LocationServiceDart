import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";

  @override
  void initState() {
    super.initState();
    final service = FlutterBackgroundService();
    service.invoke('getLocation');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(

                children: [
                  PositionWidget(),
                  DistanceTraveled(),
                ],
              ),
              ElevatedButton(
                child: const Text("Foreground Mode"),
                onPressed: () =>
                    FlutterBackgroundService().invoke("setAsForeground"),
              ),
              ElevatedButton(
                child: const Text("Background Mode"),
                onPressed: () =>
                    FlutterBackgroundService().invoke("setAsBackground"),
              ),
              ElevatedButton(
                child: Text(text),
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  var isRunning = await service.isRunning();
                  isRunning
                      ? service.invoke("stopService")
                      : service.startService();

                  setState(() {
                    text = isRunning ? 'Start Service' : 'Stop Service';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DistanceTraveled extends StatelessWidget {
  const DistanceTraveled({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FlutterBackgroundService().on('updateDistance'),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }
        return Text('Distance : ${snapshot.data['distance']}');
      },
    );
  }
}

class PositionWidget extends StatelessWidget {
  const PositionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FlutterBackgroundService().on('updatePos'),
      builder: (context, snapshot) {
        print('STREAMBUILDER POS--------------------');
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }
        final data = snapshot.data!;
        String? lat = data["lat"];
        String? long = data["long"];
        return Text('$lat / $long');
      },
    );
  }
}