import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lab1/geolocation.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraState {
  static bool camera = true;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  String? currentPosition;
  Stream<GyroscopeEvent>? _gyroscopeStream;
  GyroscopeEvent? _gyroscopeEvent;
  late CameraController _controller;
  late AccelerometerEvent accelerometerEvent = AccelerometerEvent(0, 0, 0);


  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _controller.initialize();
  }


  bool checkDeviceOrientation(AccelerometerEvent event) {
    if (
      -2 <= event.x.round() &&
          event.x.round() <= 2 &&
          event.y.round() <= 11 &&
          9 <= event.y.round() &&
          event.z.round() <= 5 &&
          -5 <= event.z.round()
    ) { //
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _gyroscopeStream = gyroscopeEvents;
    accelerometerEvents.listen((AccelerometerEvent event) {
        if (CameraState.camera && !checkDeviceOrientation(event)) {
          CameraState.camera = false;
        } else if (!CameraState.camera && checkDeviceOrientation(event)) {
          CameraState.camera = true;
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          title: Text(
              widget.title
          ),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.location_on),
              label: 'Геолокация',
            ),
            NavigationDestination(
              icon: ImageIcon(
                AssetImage("assets/images/gyroscope.png")
              ),
              label: 'Гироскоп',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time),
              label: 'Камера',
            ),
          ],
        ),
        body: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder(
                  future: determinePosition(),
                  builder: (context, snapshot) {
                    if (currentPosition != null) {
                      return Text(
                        currentPosition!,
                        textAlign: TextAlign.center,
                      );
                    }
                    if (snapshot.hasData){
                      currentPosition = snapshot.data.toString();
                      return Text(
                        snapshot.data.toString(),
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          Center(
            child: StreamBuilder<GyroscopeEvent>(
              stream: _gyroscopeStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _gyroscopeEvent = snapshot.data;
                }
                return Center(
                  child: Text(
                    "X: ${_gyroscopeEvent?.x.toStringAsFixed(2)}\n"
                        "Y: ${_gyroscopeEvent?.y.toStringAsFixed(2)}\n"
                        "Z: ${_gyroscopeEvent?.z.toStringAsFixed(2)}\n"
                    ),
                );
              },
            ),

          ),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 4/3,
                child: FutureBuilder<void>(
                    future: _initializeCamera(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
              MaterialButton(
                height: MediaQuery.of(context).size.width * 0.28,
                minWidth: MediaQuery.of(context).size.width * 0.25,
                shape: CircleBorder(
                  side: BorderSide(
                    width: MediaQuery.of(context).size.width * 0.43 / 50,
                    color: Colors.red,
                    style: BorderStyle.solid,
                  ),
                ),
                color: Colors.white,
                highlightElevation: 0,
                splashColor: Colors.red,
                highlightColor: Colors.red,
                elevation: 0,
                onPressed: ()  async {
                  if (CameraState.camera) {
                    XFile image = await _controller.takePicture();
                    Directory? directory = await getExternalStorageDirectory();
                    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                    image.saveTo("${directory?.path}/$currentTime.png");
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("У вас неправильная ориентация"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ок")
                              )
                            ],
                          );
                        }
                    );
                  }
                }
              )
            ],
          )
        ][currentPageIndex]
    );
  }
}

