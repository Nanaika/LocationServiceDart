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
          title: const Text('Location Service'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  const DistanceTraveled(),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const WaitingTime(),
                    ElevatedButton(
                      onPressed: () {
                        FlutterBackgroundService().invoke("startTimer");
                      },
                      child: const Text('WAIT'),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DISTANCE : ',
              style: TextStyle(color: Colors.grey),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${(snapshot.data['distance'] / 1000).toStringAsFixed(3)}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Text(
                  ' km',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        );
        // return Text('Distance : ${snapshot.data['distance'] / 1000}');
      },
    );
  }
}

class WaitingTime extends StatelessWidget {
  const WaitingTime({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FlutterBackgroundService().on('updateTime'),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WAITING TIME : ',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '00 : 00 : 00',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ],
          );;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WAITING TIME : ',
              style: TextStyle(color: Colors.grey),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${(snapshot.data['hours']?? 0).toString().padLeft(2, '0')} : ${(snapshot.data['minutes']?? 0).toString().padLeft(2, '0')} : ${(snapshot.data['seconds']?? 0).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ],
        );
        // return Text('Distance : ${snapshot.data['distance'] / 1000}');
      },
    );
  }
}
