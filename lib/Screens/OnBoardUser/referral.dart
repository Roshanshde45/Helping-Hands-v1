import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart' as geocoderClass;
import 'package:geoflutterfire/geoflutterfire.dart';

// import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../DashboardScreen.dart';

class ReffaralPage extends StatefulWidget {
  Map<String, dynamic> data;
  File image;

  ReffaralPage(
    this.data,
    this.image,
  );

  @override
  _ReffaralPageState createState() => _ReffaralPageState();
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random.secure();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class _ReffaralPageState extends State<ReffaralPage> {
  final _server = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TextEditingController _referralcode = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  final geo = Geoflutterfire();
  String errorText = "";
  String _userAddress;
  Position _currentPosition;
  int referalLifePoints;
  Notify _notify;
  Time time;

  getUserLocation() async {
    String error;
    try {} on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("fetch error 4");
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        print("fetch error 5");
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
    }
    final coordinates = geocoderClass.Coordinates(
        _currentPosition.latitude, _currentPosition.longitude);
    var addresses = await geocoderClass.Geocoder.local
        .findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _userAddress = first.addressLine;
    print("userAdd" + _userAddress);
  }

  Future<void> _determinePosition() async {
    Position pos;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("fetch error 1");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print("fetch error 2");
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("fetch error 3");
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    if (serviceEnabled &&
        permission != LocationPermission.deniedForever &&
        permission != LocationPermission.denied) {
      pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
      });
      await getUserLocation();
    }
    print(_currentPosition.latitude);
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

  Future permanentPermissionDenied() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text("Location Permission"),
            content: const Text(
                'Without location permission you cannot continue.Please grant permission to continue.'),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(color: CustomColor.red),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  Future _gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
      return null;
    } else
      _determinePosition();
    return true;
  }

  getConstValuesFromFB() async {
    _server
        .collection("values")
        .doc("referralLifePoints")
        .get()
        .then((snapshot) => {
              setState(() {
                referalLifePoints = snapshot.data()["referralPoints"];
                print("Considering referral Points: $referalLifePoints");
              })
            });
  }

  @override
  void initState() {
    _notify = Provider.of<Notify>(context, listen: false);
    _checkGps();
    getConstValuesFromFB();
    print(_notify.referralCode);
    _referralcode.text = _notify.referralCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Invited by a friend?",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // GestureDetector(
          //   onTap: () async {
          //     loadingCircle();
          //     try {
          //       await _determinePosition();
          //       await save();
          //     } catch (e) {
          //       print("location error 2");
          //       print(e.toString());
          //       permanentPermissionDenied();
          //     }
          //   },
          //   child: Text(
          //     "Skip",
          //     style: TextStyle(color: Colors.red),
          //   ),
          // )
          FlatButton(
            onPressed: () async {
              loadingCircle();
              try {
                await _determinePosition();
                await save();
              } catch (e) {
                print("location error 2");
                print(e.toString());
                permanentPermissionDenied();
              }
            },
            child: Text(
              "SKIP",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          )
        ],
      ),
      body: time.offset == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      maxLength: 6,
                      controller: _referralcode,
                      // onChanged: (text) async {
                      //   if (text.length == 6) {
                      //     loadingCircle();
                      //     try {
                      //       await _determinePosition();
                      //       QuerySnapshot _query = await _server
                      //           .collection("Profile")
                      //           .where("referralCode", isEqualTo: text)
                      //           .get();
                      //       if (_query.docs.length == 0) {
                      //         setState(() {
                      //           errorText = "invalid code";
                      //         });
                      //         Get.back();
                      //       } else {
                      //         await save(_query.docs.first.id);
                      //       }
                      //     } catch (e) {
                      //       print("location error 1");
                      //       Get.back();
                      //       permanentPermissionDenied();
                      //     }
                      //   }
                      // },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          errorText: errorText,
                          border: OutlineInputBorder(),
                          labelText: "Enter Invite Code"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FittedBox(
                      child: Text(
                        "Entering your friend's invite code rewards you and your friend!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        color: CustomColor.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Continue",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () async {
                          if (_referralcode.text.length == 6) {
                            loadingCircle();
                            try {
                              await _determinePosition();
                              QuerySnapshot _query = await _server
                                  .collection("Profile")
                                  .where("referralCode",
                                      isEqualTo: _referralcode.text)
                                  .get();
                              if (_query.docs.length == 0) {
                                setState(() {
                                  errorText = "invalid code";
                                });
                                Get.back();
                              } else {
                                await save(_query.docs.first.id);
                              }
                            } catch (e) {
                              print("location error 1");
                              Get.back();
                              permanentPermissionDenied();
                            }
                          } else {
                            setState(() {
                              errorText = "invalid code";
                            });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  void setToNotification(String sendToUid) {
    try {
      _server
          .collection("Profile")
          .doc(sendToUid)
          .collection("notifications")
          .add({
        "points": referalLifePoints,
        "tag": "lp",
        "badge": "lifePoints",
        "timeStamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> save([String friendId = ""]) async {
    String deviceToken;
    if (_currentPosition == null) {
      await _determinePosition();
    }
    if (_currentPosition.latitude != null &&
        _currentPosition.longitude != null) {
      print("asdf");
      String referralCode;
      deviceToken = await getToken();
      widget.data["deviceToken"] = deviceToken;
      widget.data["userAddress"] = _userAddress;
      widget.data["latLng"] = geo
          .point(
              latitude: _currentPosition.latitude,
              longitude: _currentPosition.longitude)
          .data;
      widget.data["profilePic"] = null;
      for (;;) {
        referralCode = getRandomString(6);
        QuerySnapshot _query = await _server
            .collection("Profile")
            .where("referralCode", isEqualTo: referralCode)
            .get();
        if (_query.docs.length == 0) {
          break;
        }
      }
      widget.data["referralCode"] = referralCode;
      widget.data["friend"] = friendId;
      widget.data["lifePoints"] = 0;

      String _url;
      if (widget.image != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage
            .ref()
            .child("Profile")
            .child(FirebaseAuth.instance.currentUser.uid);
        UploadTask uploadTask = ref.putFile(widget.image);
        await uploadTask.then((res) async {
          _url = await res.ref.getDownloadURL();
        });
        widget.data["profilePic"] = _url;

        await _server
            .collection("Profile")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set(widget.data);

        print("::::::::::::::::IN IF PIC Yes");
        print("Ids $friendId ${FirebaseAuth.instance.currentUser.uid}");

        if (friendId != "" && referalLifePoints != 0) {
          await _server.collection("Profile").doc(friendId).update({
            "lifePoints": FieldValue.increment(referalLifePoints)
          }).then((value) {
            _server
                .collection("Profile")
                .doc(friendId)
                .collection("notifications")
                .add({
              "timeStamp": FieldValue.serverTimestamp(),
              "points": referalLifePoints,
              "badge": "lifePoints",
              "tag": "lp",
              "receivedFrom": widget.data["name"]
            });
          }); //Incrementing friend's life Points

          _server
              .collection("Profile")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({"lifePoints": referalLifePoints}).then((value) {
            _server
                .collection("Profile")
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection("notifications")
                .add({
              "timeStamp": FieldValue.serverTimestamp(),
              "points": referalLifePoints,
              "badge": "lifePoints",
              "tag": "lp",
              "receivedFrom": "Referral Code"
            });
          }); //Incrementing user signedIn's  life Points//Incrementing friend's life Points
        }
      } else {
        print("::::::::::::::::IN Else No PIC");
        print("Ids $friendId ${FirebaseAuth.instance.currentUser.uid}");
        await _server
            .collection("Profile")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set(widget.data);

        if (friendId != "" && referalLifePoints != 0) {
          await _server.collection("Profile").doc(friendId).update({
            "lifePoints": FieldValue.increment(referalLifePoints)
          }).then((value) {
            _server
                .collection("Profile")
                .doc(friendId)
                .collection("notifications")
                .add({
              "timeStamp": FieldValue.serverTimestamp(),
              "points": referalLifePoints,
              "badge": "lifePoints",
              "tag": "lp",
              "receivedFrom": widget.data["name"]
            });
          }); //Incrementing friend's life Points
          _server
              .collection("Profile")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({"lifePoints": referalLifePoints}).then((value) {
            _server
                .collection("Profile")
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection("notifications")
                .add({
              "timeStamp": FieldValue.serverTimestamp(),
              "points": referalLifePoints,
              "badge": "lifePoints",
              "tag": "lp",
              "receivedFrom": "Referral Code"
            });
          }); //Incrementing user signedIn's  life Points
        }
      }

      Get.back();
      Get.offAll(DashboardScreen());
    } else {
      Get.back();
    }
  }

  loadingCircle() {
    Get.dialog(
        WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 20,
                ),
                Text("Please Wait")
              ],
            ),
          ),
        ),
        barrierDismissible: false);
  }
}
