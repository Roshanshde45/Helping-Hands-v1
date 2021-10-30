import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'constant.dart';
import 'networking_service.dart';

// API KEY = AIzaSyABOaKzPhGpPx89VcTk8bKoo8jh6gQcxxk

class MapScreen extends StatefulWidget {
  static String route = '/mapScreen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  String searchText = "";
  bool isLoading = false;
  bool isLocationLoading = false;

  LatLng selectedLoc = new LatLng(37.324585265376584, -121.99152465909721);

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.32373608841897, -121.99228405952452),
    zoom: 16.4746,
  );

  Future<void> _goToPos(lat, long) async {
    CameraPosition _kLake =
        CameraPosition(target: LatLng(lat, long), zoom: 16.451926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void _onTap(BuildContext context) async {
    setState(() {
      isLocationLoading = true;
    });
    NetworkService networkService = new NetworkService();
    var locationName = await networkService.getCityName(
        selectedLoc.latitude, selectedLoc.longitude);
    print(locationName);
    Navigator.pop(context, [selectedLoc, locationName]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select location"),
      ),
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              buildingsEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) async {
                Position p = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);
                _controller.complete(controller);
                _goToPos(p.latitude, p.longitude);
              },
              zoomControlsEnabled: false,
              onCameraMove: (CameraPosition cameraPosition) {
                selectedLoc = cameraPosition.target;
              },
            ),
            Center(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
            Positioned(
              top: 8.0,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                height: 50.0,
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: TextField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                        onChanged: (val) {
                          searchText = val;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_city),
                          hintText: 'Search location',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6.0,
                    ),
                    Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: isLoading
                            ? CupertinoActivityIndicator()
                            : IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  NetworkService netSer = new NetworkService();
                                  var data =
                                      await netSer.getLatLong(searchText);
                                  if (data != null) {
                                    _goToPos(data.latitude, data.longitude);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              )),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50.0,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  elevation: 10.0,
                  child: isLocationLoading
                      ? CupertinoActivityIndicator()
                      : Text(
                          'Select',
                          style: TextStyle(color: Colors.white),
                        ),
                  color: kThemeBlueColor,
                  onPressed: () {
                    _onTap(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
