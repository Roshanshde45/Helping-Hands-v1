import 'dart:convert';

import 'package:android_intent/android_intent.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/ActionButtonScreens/ChatLobbyScreen.dart';
import 'package:bd_app/Screens/ActionButtonScreens/SearchScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/AmbulanceScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/HomeScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/HospitalScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PostBloodRequirement.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/postBloodRequirement.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/LifePoints.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/UserScreen.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/myRequests/DonorListScreen.dart';
import 'package:bd_app/appUpdate.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'ActionButtonScreens/NotificationScreen.dart';
import 'package:geolocator/geolocator.dart';
import '../provider/time.dart' as Time1;
import 'RepeatingScreens/DonorListScreenLinkPush.dart';
import 'package:bd_app/Screens/RepeatingScreens/DonorListScreenLinkPush.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PostBloodRequirement.dart'
    as PostRequirement;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot snapshot;
  bool permissionGiven = false;
  String uid;
  int _currentIndex = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  FlutterLocalNotificationsPlugin fltrNotification;
  Time1.Time time;
  List<Widget> _bottomNavigationScreens = [
    HomeScreen(),
    SearchScreen(),
    PostRequirement.PostRequirement(),
    NotificationScreen(),
    UserScreen()
  ];

  Future _gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
      // setState(() {
      //   permissionGiven = false;
      // });
      return null;
    } else
      // setState(() {
      //   permissionGiven = true;
      // });
      return true;
  }

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

  Future<bool> showDonateDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
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
        print("PERMISSION : $permissionGiven");
        await databaseReference.child("Users").child(uid).update({
          "latLng": [pos.latitude, pos.longitude],
          "lastOpened": time.getCurrentTime().millisecondsSinceEpoch
        });
      } else {
        await databaseReference.child("Users").child(uid).update(
            {"lastOpened": time.getCurrentTime().millisecondsSinceEpoch});
      }
    } catch (e) {
      print(e);
    }
  }

  getToken() {
    _firebaseMessaging.getToken().then((deviceToken) => print(deviceToken));
  }

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");

      if (message["data"]["tag"] == "lp") {
        _showRewardNotification(message["notification"]["title"],
            message["notification"]["body"], "lp");
      } else if (message["data"]["tag"] == "da") {
        _showLinkPushNotification(
            message["notification"]["title"],
            message["notification"]["body"],
            message["data"]["tag"],
            message["data"]["postId"]);
      } else if (message["data"]["tag"] == "chat") {
        _showMsgNotification(
          title: message["notification"]["title"],
          body: message["notification"]["body"],
          tag: "chat",
          chatRoomId: message["data"]["chatRoomId"],
          donorName: message["data"]["name"],
          donorProfilePic: message["data"]["profilePic"],
          donorUid: message["data"]["uid"],
          phone: message["data"]["phone"],
        );
      } else if (message["data"]["tag"] == "Update") {
        _showUpdationNotification(
            title: message["notification"]["title"],
            body: message["notification"]["body"],
            tag: message["data"]["tag"],
            postId: message["data"]["postId"]);
      } else if (message["data"]["tag"] == "Request") {
        _showRequestNotification(
            title: message["notification"]["title"],
            body: message["notification"]["body"],
            tag: message["data"]["tag"],
            postId: message["data"]["postId"]);
      } else if (message["data"]["tag"] == "Accepted") {
        _showAcceptanceNotification(
          title: message["notification"]["title"],
          body: message["notification"]["body"],
          tag: message["data"]["tag"],
        );
      }
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
      if (message["data"]["tag"] == "lp") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LifePointsScreen()));
      } else if (message["data"]["tag"] == "da") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DonorListScreen(
                      postId: message["data"]["postId"],
                    )));
      } else if (message["data"]["tag"] == "chat") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      donorName: message["data"]["name"],
                      donorProfilePic: message["data"]["profilePic"],
                      chatRoomId: message["data"]["chatRoomId"],
                      donorUid: message["data"]["uid"],
                      phone: message["data"]["phone"],
                    )));
      } else if (message["data"]["tag"] == "Update") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPatientDetail(
                      postId: message["data"]["postId"],
                    )));
      } else if (message["data"]["tag"] == "Request") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DonorListScreen(
                      postId: message["data"]["postId"],
                    )));
      } else if (message["data"]["tag"] == "Accepted") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LifePointsScreen()));
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      if (message["data"]["tag"] == "lp") {
        if (message["notification"]["title"] != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LifePointsScreen()));
        }
      } else if (message["data"]["tag"] == "da") {
        if (message["notification"]["title"] != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DonorListScreen(
                        postId: message["data"]["postId"],
                      )));
        }
      } else if (message["data"]["tag"] == "Update") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPatientDetail(
                      postId: message["data"]["postId"],
                    )));
      } else if (message["data"]["tag"] == "Request") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DonorListScreen(
                      postId: message["data"]["postId"],
                    )));
      } else if (message["data"]["tag"] == "Accepted") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LifePointsScreen()));
      }
    });
  }

  Future notificationSelected(String data) async {
    print("##########################################");
    print("POST ID: ${data.toString()}");
    if (data.isNotEmpty) {
      var jsonData = json.decode(data);
      if (jsonData["tag"] == "lp") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LifePointsScreen()));
      } else if (jsonData["tag"] == "chat") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      donorName: jsonData["donorName"],
                      donorUid: jsonData["donorUid"],
                      donorProfilePic: jsonData["donorProfilePic"],
                      chatRoomId: jsonData["chatRoomId"],
                      phone: jsonData["phone"],
                    )));
      } else if (jsonData["tag"] == "da") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DonorListScreen(
                      postId: jsonData["postId"],
                    )));
      } else if (jsonData["tag"] == "Update") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NewPatientDetail(
                      postId: jsonData["postId"],
                    )));
      } else if (jsonData["tag"] == "Accepted") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LifePointsScreen()));
      } else if (jsonData["tag"] == "Request") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DonorListScreen(
                      postId: jsonData["postId"],
                    )));
      }
    }
  }

  Future _showRewardNotification(String title, String body, String tag) async {
    var androidDetails =
        new AndroidNotificationDetails("11521", "Helping Hands", "None",
            playSound: true,
            timeoutAfter: 5000,
            fullScreenIntent: true,
            // sound: RawResourceAndroidNotificationSound('notification'),
            color: Colors.red,
            icon: "give",
            importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    await fltrNotification.show(11521, title, body, generalNotificationDetails,
        payload: tag);
  }

  Future _showMsgNotification({
    String title,
    String body,
    String tag,
    String donorName,
    String donorProfilePic,
    String chatRoomId,
    String donorUid,
    String phone,
  }) async {
    var androidDetails = new AndroidNotificationDetails(
        "11511", "Helping Hands", "None",
        timeoutAfter: 5000, fullScreenIntent: true, importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);
    var data = {
      "tag": tag,
      "donorName": donorName,
      "donorProfilePic": donorProfilePic,
      "chatRoomId": chatRoomId,
      "donorUid": donorUid,
      "phone": phone
    };

    await fltrNotification.show(11511, title, body, generalNotificationDetails,
        payload: json.encode(data));
  }

  Future _showUpdationNotification(
      {String title, String body, String tag, String postId}) async {
    var androidDetails = new AndroidNotificationDetails(
        "11511", "Helping Hands", "None",
        timeoutAfter: 5000, fullScreenIntent: true, importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    var data = {"tag": tag, "postId": postId};
    await fltrNotification.show(11511, title, body, generalNotificationDetails,
        payload: json.encode(data));
  }

  Future _showLinkPushNotification(
      String title, String body, String tag, String postId) async {
    var androidDetails = new AndroidNotificationDetails(
        "11551", "Helping Hands", "None",
        timeoutAfter: 5000, fullScreenIntent: true, importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    var data = {
      "tag": tag,
      "postId": postId,
    };

    await fltrNotification.show(11551, title, body, generalNotificationDetails,
        payload: json.encode(data));
  }

  Future _showRequestNotification(
      {String title, String body, String tag, String postId}) async {
    var androidDetails = new AndroidNotificationDetails(
        "11551", "Helping Hands", "None",
        timeoutAfter: 5000, fullScreenIntent: true, importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    var data = {
      "tag": tag,
      "postId": postId,
    };

    await fltrNotification.show(11551, title, body, generalNotificationDetails,
        payload: json.encode(data));
  }

  Future _showAcceptanceNotification(
      {String title, String body, String tag}) async {
    var androidDetails = new AndroidNotificationDetails(
        "11551", "Helping Hands", "None",
        timeoutAfter: 5000, fullScreenIntent: true, importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    var data = {
      "tag": tag,
    };

    await fltrNotification.show(11551, title, body, generalNotificationDetails,
        payload: json.encode(data));
  }

  @override
  void initState() {
    var androidInitilize = new AndroidInitializationSettings('ic_notification');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    _configureFirebaseListeners();
    _determinePosition();
    _dynamicLinkService.handleDynamicLinks(context);

    // _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time1.Time>(context);
    return TimeLoading(
      child: DefaultTabController(
        length: _bottomNavigationScreens.length,
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 20,
            // fixedColor: CustomColor.red,
            backgroundColor: Colors.white,
            // unselectedItemColor: CustomColor.grey,
            // selectedItemColor: CustomColor.red,
            items: [
              BottomNavigationBarItem(
                // backgroundColor: CustomColor.red,
                icon: Image.asset(
                  "images/icons/drop_outline.png",
                  height: 65.h,
                  color: CustomColor.grey,
                  alignment: Alignment.center,
                ),
                title: Text(""),
                activeIcon: Image.asset(
                  "images/drop.png",
                  height: 65.h,
                  color: CustomColor.red,
                  alignment: Alignment.center,
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "images/icons/filledsearch.png",
                  height: 65.h,
                  color: CustomColor.grey,
                ),
                title: Text(""),
                activeIcon: Image.asset(
                  "images/icons/filledsearch.png",
                  height: 65.h,
                  color: CustomColor.red,
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "images/icons/add.png",
                  height: 65.h,
                  color: CustomColor.grey,
                ),
                title: Text(""),
                activeIcon: Image.asset(
                  "images/icons/add_filled.png",
                  height: 65.h,
                  color: CustomColor.red,
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "images/icons/outlinebell.png",
                  color: CustomColor.grey,
                  height: 65.h,
                ),
                title: Text(""),
                activeIcon: Image.asset(
                  "images/icons/bell.png",
                  height: 65.h,
                  color: CustomColor.red,
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "images/icons/user_outline.png",
                  height: 65.h,
                  color: CustomColor.grey,
                ),
                title: Text(""),
                activeIcon: Image.asset(
                  "images/icons/user_filled.png",
                  height: 65.h,
                  color: CustomColor.red,
                ),
              ),
            ],
            onTap: (index) async {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body: IndexedStack(
              index: _currentIndex, children: _bottomNavigationScreens),
        ),
      ),
    );
  }
}
