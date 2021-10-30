import 'package:bd_app/Model/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class GoogleMapScreen extends StatefulWidget {
  Position position;
  bool first;
  GoogleMapScreen([this.position, this.first]);
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  // ignore: unused_field
  bool showToolTip = true;
  LatLng coord;
  final places =
      new GoogleMapsPlaces(apiKey: "AIzaSyB6otpUQEuN_O-itOO-7VYH-e0kYL5vXPA");
  final coordinate = new GoogleMapsGeocoding(
      apiKey: "AIzaSyB6otpUQEuN_O-itOO-7VYH-e0kYL5vXPA");
  final Set<Marker> _markers = {};
  GoogleMapController _controller;
  // String _mapStyle;
  List<Prediction> _prediction = List<Prediction>();
  String returnLocation = "Your Location";
  @override
  void initState() {
    super.initState();
    // rootBundle
    //     .loadString('asset/json_assets/map_style_sliver.txt')
    //     .then((string) {
    //   _mapStyle = string;
    // });
  }

  _onMapCreated(controller) async {
    _controller = controller;
    //  _controller.setMapStyle(_mapStyle);
    if (widget.position != null)
      addMarker(widget.position.latitude, widget.position.longitude);
    else {
      var position = await Geolocator.getCurrentPosition();
      _controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    }
  }

  addMarker(double latitude, double longitude) async {
    if (_markers.length >= 1) {
      _markers.clear();
    }
    _markers.add(Marker(
      markerId: MarkerId('SomeId'),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: CustomColor.red),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Add Location",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Unable to locate Hospital"),
                        content: Text(
                          "Move the map marker to the location or search location",
                        ),
                      );
                    },
                    barrierDismissible: true);
              })
        ],
      ),
      // resizeToAvoidBottomPadding: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: RaisedButton(
        color: CustomColor.red,
        disabledColor: CustomColor.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: Container(
          width: MediaQuery.of(context).size.width - 70,
          height: 40,
          child: Center(
              child: Text(
                  widget.first == null
                      ? "Add Location"
                      : "Select Start Location",
                  style: TextStyle(
                      color: widget.first != null ? Colors.white : Colors.white,
                      fontSize: 16.5))),
        ),
        onPressed: _markers.length == 0
            ? null
            : () async {
                showLoaderDialog(context);
                Coordinates latLng = Coordinates(
                    _markers.first.position.latitude,
                    _markers.first.position.longitude);
                List<Address> address = await Geocoder.google(
                        "AIzaSyB6otpUQEuN_O-itOO-7VYH-e0kYL5vXPA")
                    .findAddressesFromCoordinates(latLng);
                setState(() {
                  // returnLocation = address.first.subLocality +
                  //     " " +
                  //     address.first.subAdminArea +
                  //     " " +
                  //     address.first.adminArea;
                  coord = LatLng(_markers.first.position.latitude,
                      _markers.first.position.longitude);
                });
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.pop(context, [address.first, coord]);
              },
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            markers: _markers,
            onCameraMove: (CameraPosition position) {
              addMarker(position.target.latitude, position.target.longitude);
            },
            onTap: (LatLng position) {
              addMarker(position.latitude, position.longitude);
            },
            initialCameraPosition: CameraPosition(
              zoom: 16,
              target: widget.position == null
                  ? LatLng(12, 13)
                  : LatLng(widget.position.latitude, widget.position.longitude),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                var position = await Geolocator.getCurrentPosition();
                _controller.animateCamera(CameraUpdate.newLatLng(
                  LatLng(position.latitude, position.longitude),
                ));
                // if (_markers.length >= 1) {
                //   _markers.clear();
                // }
                // setState(() {
                //   _markers.add(Marker(
                //       markerId: MarkerId(position.latitude.toString()),
                //       position: LatLng(position.latitude, position.longitude),
                //       icon: BitmapDescriptor.defaultMarker));
                // });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 20),
                child: CircleAvatar(
                  maxRadius: 25,
                  backgroundColor: CustomColor.red,
                  child: Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 35),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: _prediction.length == 0
                              ? BorderRadius.circular(7)
                              : BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  topLeft: Radius.circular(7),
                                )),
                      child: Row(
                        children: <Widget>[
                          // IconButton(
                          //   splashColor: CustomColor.grey,
                          //   icon: Icon(Icons.arrow_back),
                          //   onPressed: () {
                          //     Navigator.pop(context, null);
                          //   },
                          // ),
                          Expanded(
                            child: TextField(
                              onChanged: (val) async {
                                if (val != null) {
                                  PlacesAutocompleteResponse response =
                                      await places.autocomplete(val,
                                          components: [
                                            Component("country", "IN")
                                          ],
                                          language: "en",
                                          radius: 5000);
                                  setState(() {
                                    _prediction = response.predictions;
                                  });
                                }
                              },
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.go,
                              style: TextStyle(fontSize: 16.5),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 15),
                                  hintText: "Search..."),
                            ),
                          ),
                          IconButton(
                            splashColor: CustomColor.grey,
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: _prediction.length != 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          )),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _prediction.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () async {
                              PlacesDetailsResponse response =
                                  await places.getDetailsByPlaceId(
                                      _prediction[index].placeId);
                              var coordinate =
                                  response.result.geometry.location;
                              addMarker(response.result.geometry.location.lat,
                                  response.result.geometry.location.lng);
                              setState(() {
                                _prediction.clear();
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                              _controller.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(coordinate.lat, coordinate.lng),
                                ),
                              );
                            },
                            title: Text(_prediction[index].description),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: new Row(
        children: [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700)),
          Container(
              margin: EdgeInsets.only(left: 20), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: alert);
      },
    );
  }
}
