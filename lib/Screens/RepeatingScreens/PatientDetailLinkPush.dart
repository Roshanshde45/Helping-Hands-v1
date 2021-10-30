import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientDetailLinkPush extends StatefulWidget {
  final String postId;
  PatientDetailLinkPush({this.postId});
  // PatientDetails patientDetail;
  // final int index;
  // PatientDetailLinkPush({this.patientDetail,this.index});
  @override
  _PatientDetailLinkPushState createState() => _PatientDetailLinkPushState();
}

class _PatientDetailLinkPushState extends State<PatientDetailLinkPush> {
  final databaseReference = FirebaseDatabase.instance.reference();
  bool loaded = false;
  String uid, phone;
  Position _currentPosition;
  int dateTimestamp;
  String cityName;
  DataSnapshot postSnap;
  Time time;
  Future<void> setToDonorList(
      int index, String postedUserUid, String postId) async {
    print(":::::Inside Donor::::::");
    print("Post ID: $postId");
    DataSnapshot snap;
    DataSnapshot mySnap;
    int count = 0;
    int keyMatchedCount = 0;
    var donorList = [];
    List tempDonorList = [];
    List temp = [];
    List donorTemp = [];
    mySnap = await databaseReference.child("Users").child(uid).once();
    snap = await databaseReference.child("Users").child(postedUserUid).once();
    if (snap != null && snap.value != null) {
      if (snap.value["donorList"] != null) {
        temp = snap.value["donorList"];
        print("temp Length : ${temp.length}");
        for (var i = 0; i < temp.length; i++) {
          donorList.add(snap.value["donorList"][i]);
          for (var key in (snap.value["donorList"][i] as Map).keys) {
            count = count + 1;
            print("Key: $key");
            if (key == postId) {
              index = count;
              keyMatchedCount = keyMatchedCount + 1;
            }
          }
        }
        print("donorList::::::  $donorList");

        print("keyMAtched: $keyMatchedCount");
        if (keyMatchedCount >= 1) {
          donorList.removeAt(index - 1);
          donorList.add({
            postId: [
              {
                "donorName": mySnap.value["name"],
                // "age": calculateAge(
                //     convertTimeStampDisplay(mySnap.value["dob"]))
                //     .toString(),
                "location": Geolocator.distanceBetween(
                    _currentPosition.latitude,
                    _currentPosition.longitude,
                    snap.value["latLng"][0],
                    snap.value["latLng"][1]),
                "cityName": cityName,
                "responseDate": dateTimestamp,
                "bloodGrp": mySnap.value["bloodGrp"],
                "lastDonated": mySnap.value["lastDonated"],
                "phone": phone,
                "donorUid": uid,
                "profileImageUrl": mySnap.value["profilePic"],
              }
            ]
          });
          databaseReference.child("Users").child(postedUserUid).update({
            "donorList": {
              postId: tempDonorList,
            },
          });
        } else {
          donorList.add({
            postId: [
              {
                "donorName": mySnap.value["name"],
                // "age": calculateAge(
                //     convertTimeStampDisplay(mySnap.value["dob"]))
                //     .toString(),
                "location": Geolocator.distanceBetween(
                    _currentPosition.latitude,
                    _currentPosition.longitude,
                    snap.value["latLng"][0],
                    snap.value["latLng"][1]),
                "cityName": cityName,
                "responseDate": dateTimestamp,
                "bloodGrp": mySnap.value["bloodGrp"],
                "lastDonated": mySnap.value["lastDonated"],
                "phone": phone,
                "donorUid": uid,
                "profileImageUrl": mySnap.value["profilePic"],
              }
            ]
          });
          print("After adding donorList: $donorList");
          databaseReference
              .child("Users")
              .child(postedUserUid)
              .update({"donorList": donorList});
        }
      } else {
        print("Inside ELSEEEE");
        await databaseReference.child("Users").child(postedUserUid).update({
          "donorList": [
            {
              postId: [
                {
                  "donorName": mySnap.value["name"],
                  "age": calculateAge(
                      convertTimeStampDisplay(int.parse(snap.value["dob"]))),
                  "location": Geolocator.distanceBetween(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                      snap.value["latLng"][0],
                      snap.value["latLng"][1]),
                  "cityName": cityName,
                  "responseDate": dateTimestamp,
                  "bloodGrp": mySnap.value["bloodGrp"],
                  "lastDonated": mySnap.value["lastDonated"],
                  "phone": phone,
                  "donorUid": uid,
                  "profileImageUrl": mySnap.value["profilePic"],
                }
              ]
            }
          ]
        });
        print(":::Donor Data Saved:::");
      }
    } else {
      print("Data Not Received");
    }
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
    pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = pos;
    });
    cityNameExtracter(_currentPosition.latitude, _currentPosition.longitude);
  }

  Future<void> cityNameExtracter(double lat, double lng) async {
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.adminArea} : ${first.addressLine}");
    setState(() {
      cityName = first.adminArea;
      // print("CITYNAME: $cityName");
    });
  }

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final String formatted = serverFormater.format(date);
    return formatted;
  }

  DateTime convertTimeStampDisplay(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return date;
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = time.getCurrentTime();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  Future<bool> showDonateDialog(BuildContext context, String postId) {
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
                "Donate Blood",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "Thank you for being a donor.We will send your information to the requested person.By clicking OK you agree that you will respond to phone calls an in app messages.",
                style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
              ),
            ),
            contentPadding: EdgeInsets.all(28.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: CustomColor.grey, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      print("OK");
                      saveAcceptedPost(postId);
                      setToDonorList(1, "", postId);
                      Navigator.of(context).pop();
                      Flushbar(
                        title: "Accepted Request!!",
                        message:
                            "Thank you for being a donor.\nYou can check status of accepted request in Accepted Tab",
                        duration: Duration(seconds: 3),
                        flushbarStyle: FlushbarStyle.FLOATING,
                        flushbarPosition: FlushbarPosition.TOP,
                        isDismissible: false,
                      )..show(context);
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

  saveAcceptedPost(String postId) async {
    DataSnapshot snap;
    List reqList = [];
    List tempList = [];
    snap = await databaseReference.child("Users").child(uid).once();
    if (snap.value["accepted"] != null) {
      print(snap.value["accepted"]);
      tempList = snap.value["accepted"];
      print("tempList Length: ${tempList.length}");
      for (var i = 0; i < tempList.length; i++) {
        reqList.add(snap.value["accepted"][i]);
        print(reqList);
      }
      reqList.add({
        "postId": postId,
        "timeStamp": time.getCurrentTime().millisecondsSinceEpoch
      });
      print("ReqList Updated: $reqList");
      databaseReference
          .child("Users")
          .child(uid)
          .update({"accepted": reqList}).then(
              (value) => print(":::::::Request Saved::::::"));
      Navigator.pop(context);
    } else {
      reqList.add({
        "postId": postId,
        "timeStamp": time.getCurrentTime().millisecondsSinceEpoch
      });
      databaseReference
          .child("Users")
          .child(uid)
          .update({"accepted": reqList}).then(
              (value) => print(":::::::Request Saved::::::"));
    }
  }

  Future<void> getPostDetail() async {
    DataSnapshot snapshot =
        await databaseReference.child("Post").child(widget.postId).once();
    if (snapshot != null && snapshot.value != null) {
      setState(() {
        postSnap = snapshot;
        loaded = true;
      });
      print(snapshot.value);
    } else {
      setState(() {
        loaded = true;
        print("No data getPostDetail()");
      });
    }
  }

  @override
  void initState() {
    Time _time2;
    _time2 = Provider.of<Time>(context, listen: false);
    uid = FirebaseAuth.instance.currentUser.uid;
    phone = FirebaseAuth.instance.currentUser.phoneNumber;
    super.initState();
    if (_time2.offset != null)
      dateTimestamp = _time2.getCurrentTime().millisecondsSinceEpoch;
    _determinePosition();
    getPostDetail();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Patient details"),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 30.w),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 90.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Share",
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        body: TimeLoading(
          child: Stack(
            children: [
              loaded
                  ? Container(
                      padding: EdgeInsets.all(30.w),
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50.h,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(15.w),
                            height: 188.h,
                            width: 188.h,
                            decoration: BoxDecoration(
                                color: CustomColor.red,
                                border: Border.all(color: CustomColor.red),
                                borderRadius: BorderRadius.circular(80)),
                            child: Text(
                              postSnap.value["requiredBloodGrp"].toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 62.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Required Date & Time",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Patient Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Required Blood Group",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Required Units",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Hospital Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Hospital City Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Area Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Purpose",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Contact Number 1",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Contact Number 2",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Other Details",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30.w,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(":"),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${convertDateTimeDisplay(postSnap.value["bloodRequiredDate"])} ${postSnap.value["bloodRequiredTime"].toString()}",
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["patientName"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["requiredBloodGrp"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["requiredUnits"]
                                            .toString(),
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["hospitalName"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["hospitalCityName"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["hospitalAreaName"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["purpose"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["patientAttender1"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["patientAttender2"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        postSnap.value["otherDetails"],
                                        style: TextStyle(fontSize: 38.sp),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 120.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120.h,
                                  width: 120.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    color: CustomColor.red,
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          child:
                                              postSnap.value["imageUrl"] != null
                                                  ? FadeInImage.assetNetwork(
                                                      placeholder:
                                                          "images/person.png",
                                                      image: postSnap
                                                          .value["imageUrl"],
                                                      height: 325.h,
                                                      width: 325.w,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      "images/person.png",
                                                      height: 130.h,
                                                    ),
                                        ),
                                      ),
                                      widget.postId == null
                                          ? Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10.w),
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color:
                                                        CustomColor.red,
                                                  )))
                                          : Container()
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Posted By",
                                      style: TextStyle(
                                          color: CustomColor.grey,
                                          fontSize: 30.sp),
                                    ),
                                    Text(
                                      postSnap.value["userName"],
                                      style: TextStyle(
                                          color: CustomColor.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 33.sp),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                        child: FlatButton(
                      color: CustomColor.red,
                      onPressed: () {
                        showDonateDialog(context, "");
                      },
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 17),
                          child: Text(
                            "I'll Donate",
                            style:
                                TextStyle(color: Colors.white, fontSize: 47.sp),
                          )),
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
