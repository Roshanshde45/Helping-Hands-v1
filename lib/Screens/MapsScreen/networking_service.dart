import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

class NetworkService {
  final String baseURL =
      "https://maps.googleapis.com/maps/api/geocode/json?address=";
  final String keyString = ",+IN&key=AIzaSyDd0kfaaaa2a-W3IfTlXv2A68smycZqvjY";

  final String reverseBaseUrl =
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=";
  final String reverseKeyString =
      "&key=AIzaSyDd0kfaaaa2a-W3IfTlXv2A68smycZqvjY";

  Future<LatLng> getLatLong(String address) async {
    try {
      Response response = await http.get(baseURL + address + keyString);
      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        print(resData);
        return new LatLng(resData['results'][0]['geometry']['location']['lat'],
            resData['results'][0]['geometry']['location']['lng']);
      } else {
        print("Status code " + response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getCityName(double latitude, double longitude) async {
    print(latitude);
    print(longitude);
    try {
      Response response = await http.get(reverseBaseUrl +
          latitude.toString() +
          ',' +
          longitude.toString() +
          reverseKeyString);
      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        print(resData);
        return resData['results'][0]['address_components'][0]['long_name'] +
            ', ' +
            resData['results'][0]['address_components'][1]['long_name'];
      } else {
        print("Status code " + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print("[getCityName] = ${e.toString()}");
      return null;
    }
  }
}
