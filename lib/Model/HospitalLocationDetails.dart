import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalLocationDetails{
  String address;
  LatLng coordinates;
  String locationType;

  HospitalLocationDetails({this.address, this.coordinates, this.locationType});
}