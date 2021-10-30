import 'package:age/age.dart';
import 'package:android_intent/android_intent.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/provider/time.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/size_extension.dart';

class CommonUtilFunctions {
  String convertDateTimeDisplay(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    final DateFormat serverFormatter = DateFormat('yMMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted;
  }

  String firstCaptial(String temp) {
    if (temp != null && temp.length != 0)
      return "${temp[0].toUpperCase()}" + temp.substring(1);
    return null;
  }

  String timeStampToDate(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    final DateFormat serverFormatter = DateFormat('yMMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted.toString();
  }

  DateTime timestampToDate(Timestamp timestamp) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    return date;
  }

  String calculateAge(Timestamp timestamp, Time time) {
    AgeDuration age;
    DateTime dob =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime today = time.getCurrentTime();
    age =
        Age.dateDifference(fromDate: dob, toDate: today, includeToDate: false);
    return age.years.toString();
  }

  String extractTimeFromTimeStamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat("hh:mm").format(date).toString();
  }

  Future<void> makePhoneCall(String contact, bool direct) async {
    if (direct == true) {
      bool res = await FlutterPhoneDirectCaller.callNumber(contact);
    } else {
      String telScheme = 'tel:$contact';

      if (await canLaunch(telScheme)) {
        await launch(telScheme);
      } else {
        throw 'Could not launch $telScheme';
      }
    }
  }

  String getChatRoomIdByUid(String MyUid, String donorUid) {
    print("getChatRoomIdByUid");
    print("MyUid: $MyUid \n DonorUid: $donorUid");
    return "$MyUid\_$donorUid";
  }

  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  void loadingCircle(String text) {
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
                Text(text)
              ],
            ),
          ),
        ),
        barrierDismissible: false);
  }

  Future<bool> showError(BuildContext context) {
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
                "Error",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "There is some error!",
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
                      "Ok",
                      style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
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

  int calculateDifferenceMonth(int timestamp, Time time) {
    AgeDuration age;
    DateTime dob = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime today = time.getCurrentTime();
    age =
        Age.dateDifference(fromDate: dob, toDate: today, includeToDate: false);
    return age.months;
  }

  double distanceBetweenCoordinates(
      LatLng firstLocation, LatLng secondLocation) {
    return Geolocator.distanceBetween(
            firstLocation.latitude,
            firstLocation.longitude,
            secondLocation.latitude,
            secondLocation.longitude) /
        1000.floor();
  }

  Widget flushbarNotify(String title, String subTitle) {
    return Flushbar(
      title: title.toString(),
      // titleColor: Colors.white,
      message: subTitle.toString(),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: CustomColor.red,
      boxShadows: [
        BoxShadow(
            color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      backgroundGradient:
          LinearGradient(colors: [Colors.blueGrey, Colors.black]),
      isDismissible: false,
      duration: Duration(seconds: 4),
      icon: Icon(
        Icons.check,
        color: Colors.greenAccent,
      ),
      // mainButton: FlatButton(
      //   onPressed: () {},
      //   child: Text(
      //     "CLAP",
      //     style: TextStyle(color: Colors.amber),
      //   ),
      // ),
      // showProgressIndicator: true,
      // progressIndicatorBackgroundColor: Colors.blueGrey,
      // titleText: Text(
      //   "Hello Hero",
      //   style: TextStyle(
      //       fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.yellow[600], fontFamily: "ShadowsIntoLightTwo"),
      // ),
      // messageText: Text(
      //   "You killed that giant monster in the city. Congratulations!",
      //   style: TextStyle(fontSize: 18.0, color: Colors.green, fontFamily: "ShadowsIntoLightTwo"),
      // ),
    );
  }

  Widget bottomSheetPill() {
    return Container(
      height: 17.h,
      width: 180.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CustomColor.lightGrey),
    );
  }
}
