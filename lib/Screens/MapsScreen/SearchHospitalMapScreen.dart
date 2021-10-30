import 'dart:async';

import 'package:bd_app/Model/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:bd_app/services/assistantMethods.dart';
import 'package:bd_app/Model/HospitalLocationDetails.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart';

class SearchHospitalMapScreen extends StatefulWidget {
  @override
  _SearchHospitalMapScreenState createState() =>
      _SearchHospitalMapScreenState();
}

class _SearchHospitalMapScreenState extends State<SearchHospitalMapScreen> {
  List<LatLng> pLineCoordinates = [];
  final Set<Marker> _markers = {};
  int _markerIdCounter = 0;
  String updatingLocation;
  Set<Polyline> polylineSet = {};
  LatLng hospitalLocation;
  LatLng myCurrentLocation;
  String hospitalAddress;
  LatLngBounds _latLngBounds;
  Position _currentPosition;
  LatLng updatePosition;
  GoogleMapController mapController;
  // Set<Marker> _markers = {};
  LatLng newPosition;
  HospitalLocationDetails _hospitalLocationDetails = HospitalLocationDetails();
  GoogleMapController _mapController;

  Future<void> getPlaceDirection(
      LatLng initialLocation, LatLng finalLocation) async {
    print(initialLocation);
    print(finalLocation);
    // var initialPos;
    // var finalPos;

    // var pickUpLatLng = LatLng(my, initialPos.longitude);
    // var dropOffUpLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => ProgressDialog(message: "");
    //
    var details = await AssistantMethods.obtainDirectionsDetails(
        initialLocation, finalLocation);
    print(details.durationValue);
    print(details.distanceValue);

    Navigator.pop(context);
    print("This id Encoded Points:\n ${details.encodedPoints} ");

    // PolylinePoints polylinePoints = PolylinePoints();
    // List<PointLatLng> decodePolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);
    //
    // pLineCoordinates.clear();
    // if(decodePolyLinePointsResult.isNotEmpty){
    //   decodePolyLinePointsResult.forEach((pointLatLng) {
    //     pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    //   });
    // }
    // polylineSet.clear();
    // if(this.mounted){
    //   setState(() {
    //     Polyline polyline = Polyline(color: CustomColor.redAccent,
    //       polylineId: PolylineId("PolylineId"),
    //       jointType: JointType.round,
    //       points: pLineCoordinates,
    //       width: 5,
    //       startCap: Cap.roundCap,
    //       endCap: Cap.roundCap,
    //       geodesic: true,
    //     );
    //     polylineSet.add(polyline);
    //   });
    // }

    // LatLngBounds latLngBounds;
    // if(initialLocation.latitude > finalLocation.latitude && initialLocation.longitude > finalLocation.longitude){
    //   latLngBounds = LatLngBounds(southwest: finalLocation, northeast: initialLocation);
    // }
    // else if(initialLocation.longitude > finalLocation.longitude){
    //   latLngBounds = LatLngBounds(southwest: LatLng(initialLocation.latitude,finalLocation.longitude), northeast: LatLng(finalLocation.latitude,initialLocation.longitude));
    // }
    // else if(initialLocation.latitude > finalLocation.latitude){
    //   latLngBounds = LatLngBounds(southwest: LatLng(finalLocation.latitude,initialLocation.longitude), northeast: LatLng(initialLocation.latitude,finalLocation.longitude));
    // }
    // else{
    //   latLngBounds = LatLngBounds(southwest: initialLocation, northeast: finalLocation);
    // }
    // if(mounted){
    //   setState(() {
    //     _latLngBounds = latLngBounds;
    //   });
    // }
  }

  Future<void> _determinePosition() async {
    Position pos;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    pos =
        await Geolocator.getCurrentPosition(forceAndroidLocationManager: false);
    setState(() {
      _currentPosition = pos;
    });
    print("CURRENT LOCATION LATITUDE: ${_currentPosition.latitude}");
  }

  void _onMapCreated(GoogleMapController controller) async {
    LatLng INITIAL_LOCATION =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);
    _mapController = controller;
    if ([INITIAL_LOCATION] != null) {
      MarkerId markerId = MarkerId(_markerIdVal());
      LatLng position = INITIAL_LOCATION;
      Marker marker = Marker(
        markerId: markerId,
        position: position,
        draggable: false,
      );
      print(":::::::::::::::::::::::::::::::::::::::::::::::::");
      print(position);
      if (_markers.length >= 1) {
        _markers.clear();
      }
      setState(() {
        _markers.add(marker);
        updatePosition = position;
      });

      // Future.delayed(Duration(seconds: 2), () async {
      //   GoogleMapController controller = await _mapController.future;
      //   controller.animateCamera(
      //     CameraUpdate.newCameraPosition(
      //       CameraPosition(
      //         target: position,
      //         zoom: 17.0,
      //       ),
      //     ),
      //   );
      //   setState(() {
      //     updatePosition = position;
      //   });
      // });
    }
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  getUserLocation() async {
    //call this async method from whereever you need
    String error;
    try {} on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
    }
    final coordinates =
        new Coordinates(updatePosition.latitude, updatePosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    _hospitalLocationDetails.address = first.addressLine;
    _hospitalLocationDetails.coordinates =
        LatLng(first.coordinates.latitude, first.coordinates.longitude);

    // print(' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    Navigator.pop(context, _hospitalLocationDetails);
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(200.h),
            child: AppBar(
              // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: CustomColor.red),
              centerTitle: true,
              backgroundColor: CustomColor.red,
              title: Text(
                "Move the map to the Hospital\nlocation or search hospital",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: GestureDetector(
              onTap: () async {
                await _determinePosition();
                _mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition.latitude,
                          _currentPosition.longitude),
                      zoom: 17.0,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 25,
                child: Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                backgroundColor: CustomColor.red,
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: (_currentPosition != null)
              ? Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 160.h,
                      child: GoogleMap(
                        markers: _markers,
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,

                        // if(_markers.length > 0) {
                        //   MarkerId markerId = MarkerId(_markerIdVal());
                        //   Marker marker = _markers[markerId];
                        //   Marker updatedMarker = marker.copyWith(
                        //     positionParam: position.target,
                        //   );
                        //   print(polylineSet);
                        //   print(position);
                        //   setState(() {
                        //     _markers[markerId] = updatedMarker;
                        //     updatePosition = position.target;
                        //   });
                        // }
                        // },
                        // (GoogleMapController googleMapController) {
                        // setState(() {
                        //   mapController = googleMapController;
                        //   double a = double.parse((hospitalLocation.latitude).toStringAsFixed(7));
                        //   double b = double.parse((hospitalLocation.longitude).toStringAsFixed(7));
                        //
                        // });
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: LatLng(_currentPosition.latitude,
                              _currentPosition.longitude),
                        ),
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        // myLocationEnabled: true,
                        // polylines: polylineSet,
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(25.w, 35.h, 25.w, 0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       // IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
                          //       //   Navigator.pop(context,_hospitalLocationDetails.address);
                          //       // },color: CustomColor.red,),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 36.w, vertical: 36.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SearchMapPlaceWidget(
                                    hasClearButton: true,
                                    // location: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                                    // radius: 30000,
                                    iconColor: CustomColor.red,
                                    placeType: PlaceType.address,
                                    darkMode: false,
                                    placeholder: "Enter Hospital Location",
                                    apiKey:
                                        "AIzaSyB6otpUQEuN_O-itOO-7VYH-e0kYL5vXPA",
                                    onSelected: (Place place) async {
                                      Geolocation geolocation =
                                          await place.geolocation;
                                      print(
                                          "Hospital Location: $hospitalLocation");
                                      print("*******************");
                                      print(_markers);
                                      print(place.types);
                                      print(place.description);

                                      _mapController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: geolocation.coordinates,
                                            zoom: 17.0,
                                          ),
                                        ),
                                      );
                                      LatLng position = geolocation.coordinates;
                                      setState(() {
                                        Marker(
                                            markerId: MarkerId("marker_id_0"),
                                            position: position,
                                            draggable: false,
                                            infoWindow: InfoWindow(
                                                title: place.types[0],
                                                snippet: place.description));
                                      });
                                      // var type = place.types.indexOf("hospital");
                                      // if (type == -1) {
                                      //   print("Not a hospital");
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (context) => AlertDialog(
                                      //         title: Text(
                                      //             "Error"
                                      //         ),
                                      //         content: Text(
                                      //             "Please select a hospital."
                                      //         ),
                                      //         actions: [
                                      //           FlatButton(
                                      //               onPressed: () {
                                      //                 Navigator.pop(context);
                                      //               },
                                      //               child: Text(
                                      //                   "Ok"
                                      //               )
                                      //           )
                                      //         ],
                                      //       )
                                      //   );
                                      //   return;
                                      // }
                                      setState(() {
                                        // _markers.add(
                                        //     Marker(
                                        //       markerId: MarkerId("id-1"),
                                        //       position: geolocation.coordinates,
                                        //       infoWindow: InfoWindow(
                                        //         title: place.types[0],
                                        //         snippet:  place.description
                                        //       )
                                        //     )
                                        // );
                                        // _hospitalLocationDetails.address = place.description;
                                        // _hospitalLocationDetails.coordinates = geolocation.coordinates;
                                        // _hospitalLocationDetails.locationType = place.types[0];
                                      });
                                      print(geolocation.fullJSON);
                                      print(
                                          "________________________________________");
                                      print(geolocation.coordinates);
                                      // getPlaceDirection(LatLng(_currentPosition.latitude, _currentPosition.longitude),geolocation.coordinates);
                                      // getPlaceDirection(LatLng(_currentPosition.latitude, _currentPosition.longitude),LatLng(28.5659000, 77.2111000));
                                      // mapController.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
                                      // mapController.animateCamera(CameraUpdate.newLatLngBounds(_latLngBounds, 70));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: [
                          Expanded(
                              child: FlatButton(
                                  color: CustomColor.red,
                                  onPressed: () async {
                                    await getUserLocation();
                                  },
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 50.h),
                                      child: Text(
                                        "Continue",
                                        style: TextStyle(color: Colors.white),
                                      ))))
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
