import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

Future<String> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  Position position = await Geolocator.getCurrentPosition();

  var response = await http.post(
    Uri.parse('https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Token a29000408ff35f96119caf675e6714e746d6391d"
    },
    body: jsonEncode({
      'lat': '${position.latitude}',
      'lon': '${position.longitude}'
    }),
  );
  if (response.statusCode == 200) {
    var jsonResponse = await jsonDecode(response.body) as Map<String, dynamic>;
    return jsonResponse['suggestions'][0]['value'].toString();
  } else {
    throw ArgumentError('Message');
  }


}