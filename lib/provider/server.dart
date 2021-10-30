import 'package:android_intent/android_intent.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:bd_app/Screens/OnBoardUser/SplashScreen.dart';
import 'package:bd_app/mockLocation.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Notify extends ChangeNotifier {
  int textint = 10;
  LatLng currLoc;
  Map<String, dynamic> dynamicValue = {};
  bool isMock = false;
  final firestore = FirebaseFirestore.instance;
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  String verificationCode;
  String referralCode;
  var phone;
  int _forceResendingToken;
  ProgressDialog pr;
  BuildContext context;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Map<String, dynamic> userData;
  bool checkTime = true;
  bool critical_update = false;
  bool normal_update = false;
  String mess;
  Notify() {
    getValues();
    gpsService();
  }

  void setUpadte(bool critc, bool normal, String messa) {
    mess = messa;
    critical_update = critc;
    normal_update = normal;
  }

  extractRefferalCodeFromLink(String gotReferalCode) async {
    print(":::::::::extractRefferalCodeFromLink:::::::::::");
    print(gotReferalCode);
    referralCode = gotReferalCode;
  }

// _notify.firestore
  bool versionCompare(String v1, String v2) {
    List v1List = [], v2List = [];
    v1List = v1.split(".");
    v2List = v2.split(".");
    int a, b;
    for (int i = 0; i < 3; i++) {
      a = int.parse(v1List[i]);
      b = int.parse(v2List[i]);

      print(i.toString() + " " + a.toString() + " " + b.toString());

      if (a < b) {
        return true;
      } else if (a > b) {
        return false;
      }
    }

    return false;
  }

  void initDynamicLinks() async {
    print("Calling initDynamicLinks::::");
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    // print(deepLink);
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');
      var isPost = deepLink.pathSegments.contains("post");
      var isReferal = deepLink.pathSegments.contains("refer");

      if (isPost) {
        print(
            "postId found in deepLink: ${deepLink.queryParameters['postId']}");
        //Handling in DashboardScreen
      } else if (isReferal) {
        print(
            "Referal Code found in deepLink: ${deepLink.queryParameters['referalCode']}");
        referralCode = deepLink.queryParameters['referalCode'];
      } else {
        print("::::Failed Extraction:::::::");
      }
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        // Navigator.pushNamed(context, deepLink.path);
        var isPost = deepLink.pathSegments.contains("post");
        var isReferal = deepLink.pathSegments.contains("refer");

        if (isPost) {
          print(
              "postId found in deepLink: ${deepLink.queryParameters['postId']}");
          //Handling in DashboardScreen

        } else if (isReferal) {
          print(
              "Referal Code found in deepLink: ${deepLink.queryParameters['referalCode']}");
          referralCode = deepLink.queryParameters['referalCode'];
        } else {
          print("::::Failed Extraction:::::::");
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  void setUser(DocumentSnapshot snapshot) {
    userData = snapshot.data();
  }

  void changeValues(String lat, String lon, bool _isMock) {
    if (lat != null && lon != null) {
      currLoc = LatLng(double.parse(lat), double.parse(lon));
      // print("Tag " + DateFormat("mm : ss").format(DateTime.now()));
      print("Tag" + _isMock.toString());
      if (isMock != _isMock) {
        print("changing");
        isMock = _isMock;
        if (isMock) {
          checkTime = false;
          Get.to(() => MockLocation());
        } else {
          checkTime = true;
          Get.back();
        }
      }
    }
  }

  // Future _checkGps() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     if (Theme.of(context).platform == TargetPlatform.android) {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text("Can't get current location"),
  //               content:
  //                   const Text('Please make sure you enable GPS and try again'),
  //               actions: <Widget>[
  //                 FlatButton(
  //                     child: Text('Ok'),
  //                     onPressed: () {
  //                       final AndroidIntent intent = AndroidIntent(
  //                           action:
  //                               'android.settings.LOCATION_SOURCE_SETTINGS');
  //                       intent.launch();
  //                       Navigator.of(context, rootNavigator: true).pop();
  //                     })
  //               ],
  //             );
  //           });
  //     }
  //   }
  // }

  void getValues() async {
    final data =
        await firestore.collection("values").doc("referralLifePoints").get();
    dynamicValue = data.data();
    print("fetched dynamic values");
    print(dynamicValue);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  setPhone(String _phone) {
    phone = _phone;
  }

  setBuildContext(BuildContext _context) {
    context = _context;
  }

  setScaffoldKey(key) {
    _scaffoldKey = key;
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
    if (serviceEnabled &&
        permission != LocationPermission.deniedForever &&
        permission != LocationPermission.denied) {
      pos = await Geolocator.getCurrentPosition(
          forceAndroidLocationManager: false);

      currLoc = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
    }
    print(currLoc);
  }

  // Future _checkGps() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     if (Theme.of(context).platform == TargetPlatform.android) {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(15)),
  //               title: Text("Can't get current location"),
  //               content:
  //                   const Text('Please make sure you enable GPS and try again'),
  //               actions: <Widget>[
  //                 FlatButton(
  //                     child: Text(
  //                       'Ok',
  //                       style: TextStyle(color: CustomColor.red),
  //                     ),
  //                     onPressed: () async {
  //                       final AndroidIntent intent = AndroidIntent(
  //                           action:
  //                               'android.settings.LOCATION_SOURCE_SETTINGS');
  //                       intent.launch();
  //                       Navigator.of(context, rootNavigator: true).pop();
  //                       await _gpsService();
  //                     })
  //               ],
  //             );
  //           });
  //     }
  //   } else {
  //     _determinePosition();
  //   }
  // }
  Future gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
      return null;
    } else
      await _determinePosition();
    return true;
  }
}
