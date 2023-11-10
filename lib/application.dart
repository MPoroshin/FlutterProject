import 'package:flutter/material.dart';
import 'package:lab1/geolocation.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              label: 'Что-то еще',
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
                    if(snapshot.hasData){
                      return Text(
                        snapshot.data.toString(),
                        textAlign: TextAlign.center,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),

              ],
            ),
          ),
          const Center(
            child: Text('Гироскоп'),
          ),
          const Center(
            child: Text('Что-то еще'),
          )
        ][currentPageIndex]
    );
  }
}
