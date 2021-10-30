import 'package:android_intent/android_intent.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/ActionButtonScreens/ChatLobbyScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PostBloodRequirement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../TabBarScreens_Home/accepted/acceptedScreen.dart';
import '../TabBarScreens_Home/allRequest/AllRequestScreen.dart';
import '../TabBarScreens_Home/myRequests/myRequestScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';

import 'Post/postBloodRequirement.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  List<Widget> _tabContainer = [
    AllRequestScreen(),
    myRequestScreen(),
    acceptedScreen(),
  ];
  bool permissionGiven = false;

  Future _checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text("Can't get current location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text(
                        'Ok',
                        style: TextStyle(color: CustomColor.red),
                      ),
                      onPressed: () async {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        await _gpsService();
                      })
                ],
              );
            });
      }
    } else {
      _determinePosition();
    }
  }

  Future _gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
      setState(() {
        permissionGiven = false;
      });
      return null;
    } else
      setState(() {
        permissionGiven = true;
      });
    return true;
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
      // return Future.error(
      print(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    if (permission != LocationPermission.deniedForever) {
      pos = await Geolocator.getCurrentPosition();
    }
    try {
      if (pos.latitude != null && pos.longitude != null) {
        setState(() {
          permissionGiven = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabContainer.length,
      child: Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
          // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.orange),
          backgroundColor: Colors.white,
          title: Text(
            "Helping Hands",
            style: TextStyle(color: CustomColor.red, fontSize: 63.sp),
          ),
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.question_answer_outlined,
                  color: CustomColor.red,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatLobbyScreen()));
                }),
            // IconButton(
            //     icon: Icon(
            //       Icons.post_add_sharp,
            //       color: CustomColor.red,
            //       size: 30,
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => NewPatientDetail()));
            //     }),
          ],
          bottom: TabBar(
            // labelPadding: EdgeInsets.only(top: 100.h),
            labelColor: CustomColor.red,
            isScrollable: false,
            unselectedLabelColor: CustomColor.grey,
            indicatorColor: CustomColor.red,
            tabs: [
              Tab(
                child: Text(
                  "Blood Requests",
                  style: TextStyle(fontSize: 36.sp),
                ),
              ),
              Tab(
                child: Text(
                  "My Requests",
                  style: TextStyle(fontSize: 36.sp),
                ),
              ),
              Tab(
                child: Text(
                  "Accepted",
                  style: TextStyle(fontSize: 36.sp),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: _tabContainer,
        ),
      ),
    );
  }

  Future<bool> showDonateDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Location Permission",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "For posting requirements you have to give location permission.",
                style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
                textAlign: TextAlign.justify,
              ),
            ),
            contentPadding: EdgeInsets.all(28.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "Retry",
                      style:
                          TextStyle(color: CustomColor.grey, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      await _gpsService();
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  FlatButton(
                    child: Text(
                      "Give Permission",
                      style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      final AndroidIntent intent = AndroidIntent(
                          action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                      intent.launch();
                      Navigator.of(context, rootNavigator: true).pop();
                      _gpsService();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )
                ],
              )
            ],
          );
        });
  }
}
