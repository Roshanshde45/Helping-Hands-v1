import 'dart:async';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:bd_app/Screens/OnBoardUser/GettingStartedScreen.dart';
import 'package:bd_app/appUpdate.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geocoder/geocoder.dart' as geocoderClass;
import 'package:shimmer/shimmer.dart';
import 'package:trust_location/trust_location.dart';
import 'package:bd_app/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String uid;
  bool _visible = false;
  String referalCode;
  final databaseReference = FirebaseFirestore.instance;
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Notify _notfiy;
  final geo = Geoflutterfire();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Time time;
  Image logo;
  Notify _notify;
  Future<Timer> loadData() async {
    setState(() {
      _visible = !_visible;
    });
    return Timer(
        Duration(
          seconds: 3,
        ), () {
      checkUserLog();
    });
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  update() async {
    if (_notfiy.currLoc == null) {
      await _notfiy.gpsService();
    }
    final coordinates = geocoderClass.Coordinates(
        _notfiy.currLoc.latitude, _notfiy.currLoc.longitude);
    var addresses = await geocoderClass.Geocoder.local
        .findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    var deviceToken = await getToken();

    String _userAddress = first.addressLine;
    _notfiy.firestore
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      "latLng": geo
          .point(
              latitude: _notfiy.currLoc.latitude,
              longitude: _notfiy.currLoc.longitude)
          .data,
      "userAddress": _userAddress,
      "lastOpened": FieldValue.serverTimestamp(),
      "deviceToken": deviceToken
    });
  }

  Future<void> checkUserLog() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        print("1");
        DocumentSnapshot snapshot = await databaseReference
            .collection("Profile")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get();
        print("2");
        if (snapshot.exists) {
          // "lastOpened": time.getCurrentTime()().millisecondsSinceEpoch,

          // if(Geolocator.distanceBetween(_notfiy.currLoc.latitude, _notfiy.currLoc.longitude, snapshot.data()["latLng"]["geopoint"].latitude, snapshot.data()["latLng"]["geopoint"].longitude))
          update();
          print("3");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AppUpdate(child: DashboardScreen())),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AppUpdate(child: GettingStartedScreen())),
              (route) => false);
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => AppUpdate(child: GettingStartedScreen())),
            (route) => false);
      }
    } catch (e) {
      print(e);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   precacheImage(logo.image, context);
  // }

  @override
  void initState() {
    _notfiy = Provider.of<Notify>(context, listen: false);

    // requestLocationPermission();
    // logo = Image.asset('images/helpingHandsLogo.png',height: 120,);

    Firebase.initializeApp().whenComplete(() {
      print("completed");
      if (FirebaseAuth.instance.currentUser != null) {
        setState(() {
          uid = FirebaseAuth.instance.currentUser.uid;
          print(uid);
        });
      }
    });
    // try{
    //   print("Trying");
    //   print(_notify.textint);
    //   _notify.initDynamicLinks();
    // }catch(e){
    //   print(e);
    // }
    TrustLocation.start(5);
    getLocation();

    // FirebaseCrashlytics.instance.crash();
    // timeStamp = time.getCurrentTime().millisecondsSinceEpoch;
    loadData();
    super.initState();
  }

  void getLocation() {
    try {
      TrustLocation.onChange.listen((values) {
        _notfiy.changeValues(
            values.latitude, values.longitude, values.isMockLocation);
      });
    } on PlatformException catch (e) {
      print('PlatformException $e');
    }
  }

  //  void requestLocationPermission() async {
  //   PermissionStatus permission =
  //       await LocationPermissions().requestPermissions();
  //   print('permissions: $permission');
  // }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: loader()),
    );
  }

  Widget loader() {
    return Container(
      padding: EdgeInsets.all(40.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "\"Helping Hands are better than praying lips\"",
            style: TextStyle(
                color: CustomColor.darkGrey,
                fontStyle: FontStyle.italic,
                fontSize: 40.sp),
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "- Mother Teresa",
                style: TextStyle(
                  color: CustomColor.darkGrey,
                  fontSize: 45.sp,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          SpinKitWave(
            color: CustomColor.red,
            size: 20,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Please wait...",
            style: TextStyle(
              color: CustomColor.lightGrey,
              fontSize: 35.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget shimmer() {
    double height = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: ListView.builder(
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48.0,
                height: 48.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: 40.0,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        itemCount: (height ~/ 48),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "images/HelpingHands_Red.svg",
          height: 85,
          width: 70,
        ),
        SizedBox(
          height: 10.h,
        ),
        Text(
          "Helping Hands",
          style: TextStyle(
            color: CustomColor.red,
            fontSize: 95.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "OpenSans",
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Text(
          "DONATE AND SAVE LIFE",
          style: TextStyle(
            color: CustomColor.lightGrey,
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
