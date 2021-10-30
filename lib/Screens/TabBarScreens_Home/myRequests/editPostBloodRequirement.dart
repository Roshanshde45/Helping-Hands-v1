import 'package:android_intent/android_intent.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/HospitalLocationDetails.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Screens/FeedBackScreen.dart';
import 'package:bd_app/Screens/MapsScreen/SearchHospitalMapScreen.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class editPostBloodRequirement extends StatefulWidget {
  PatientDetails patientDetail;
  editPostBloodRequirement({this.patientDetail});
  @override
  _editPostBloodRequirementState createState() =>
      _editPostBloodRequirementState();
}

class _editPostBloodRequirementState extends State<editPostBloodRequirement> {
  PersistentBottomSheetController _controller;
  TextEditingController _requiredBloodGrpController =
      new TextEditingController();
  TextEditingController _bloodRequiredTimeController =
      new TextEditingController();
  TextEditingController _bloodRequiredDateController =
      new TextEditingController();
  TextEditingController _patientNameController = new TextEditingController();
  TextEditingController _patientAgeController = new TextEditingController();
  TextEditingController _requiredUnitsController = new TextEditingController();
  TextEditingController _purposeController = new TextEditingController();
  TextEditingController _hospitalNameController = new TextEditingController();
  TextEditingController _hospitalAreaNameController =
      new TextEditingController();
  TextEditingController _hospitalRoomNumberController =
      new TextEditingController();
  TextEditingController _patientContact1Controller =
      new TextEditingController();
  TextEditingController _patientContact2Controller =
      new TextEditingController();
  TextEditingController _otherDetailsController = new TextEditingController();
  TextEditingController _hospitalCityNameController =
      new TextEditingController();
  TextEditingController _patientContact3Controller =
      new TextEditingController();
  TextEditingController _hospitalLocationController =
      new TextEditingController();
  HospitalLocationDetails _hospitalLocationDetails = HospitalLocationDetails();
  // DateTime selectedDate = time.getCurrentTime();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  Time time;
  DateTime selectedDate;

  String uid,
      imageUrl,
      userName,
      _patientName,
      _purpose,
      _hospitalName,
      _hospitalCityName,
      _hospitalAreaName,
      _hospitalLocation,
      _otherDetails,
      _attenderContact1,
      _attenderContact2,
      _attenderContact3,
      bloodGrp;

  int _hospitalRoomNumber, _age, _bloodRequiredDate;

  bool firstTime = false;
  bool anyGrp = false;

  List<String> myRequest = [];
  bool permissionEnabled = true;

  List bloodGroups = [
    {"bloodGrp": "A-", "colorBool": false},
    {"bloodGrp": "B-", "colorBool": false},
    {"bloodGrp": "AB-", "colorBool": false},
    {"bloodGrp": "O-", "colorBool": false},
    {"bloodGrp": "A+", "colorBool": false},
    {"bloodGrp": "B+", "colorBool": false},
    {"bloodGrp": "AB+", "colorBool": false},
    {"bloodGrp": "O+", "colorBool": false},
  ];

  Future _gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        permissionEnabled = false;
      });
      _checkGps();
      return null;
    } else
      setState(() {
        permissionEnabled = true;
      });
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
                title: Text("Can't get current location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        _gpsService();
                      })
                ],
              );
            });
      }
    }
  }

  void selectedGrpFunc(int j) {
    for (var i = 0; i <= 7; i++) {
      _controller.setState(() {
        bloodGroups[i]["colorBool"] = false;
      });
      print(bloodGroups[i]["colorBool"]);
    }
    print("Done Loop");
    _controller.setState(() {
      bloodGroups[j]["colorBool"] = !bloodGroups[j]["colorBool"];
      bloodGrp = bloodGroups[j]["bloodGrp"];
    });
  }

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat serverFormatter = DateFormat('yMMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted;
  }

  Future<void> updatePost() async {
    try {
      try {
        await databaseReference
            .child("Post")
            .child(widget.patientDetail.postId)
            .update({
          "requiredBloodGrp": _requiredBloodGrpController.text,
          "requiredUnits": _requiredUnitsController.text,
          "bloodRequiredDate": _bloodRequiredDate,
          "bloodRequiredTime": _bloodRequiredTimeController.text,
          "hospitalName": _hospitalNameController.text,
          "hospitalCityName": _hospitalCityNameController.text,
          "hospitalAreaName": _hospitalAreaNameController.text,
          "hospitalAddress": _hospitalLocationController.text,
          "hospitalRoomNumber": _hospitalRoomNumberController.text,
          "patientAttender1": _patientContact1Controller.text,
          "patientAttender2": _patientContact2Controller.text,
          "patientAttender3": _patientContact3Controller.text,
          "otherDetails": _otherDetailsController.text,
        });
        print("Post Saved Successfully!!!");
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: time.getCurrentTime(),
        lastDate: time.getCurrentTime().add(Duration(days: 30)));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _bloodRequiredDate = Timestamp.fromDate(picked).millisecondsSinceEpoch;
        _bloodRequiredDateController.text = convertDateTimeDisplay(
            Timestamp.fromDate(picked).millisecondsSinceEpoch);
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final localizations = MaterialLocalizations.of(context);
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _bloodRequiredTimeController.text =
            localizations.formatTimeOfDay(picked);
      });
  }

  Future<Widget> myBottomSheet(BuildContext context, String postId) {
    int currentView = 0;
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              // ignore: missing_return
              builder: (BuildContext context, StateSetter setMode) {
            switch (currentView) {
              case 0:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 15.h),
                                  child: Text(
                                    "Do you want to cancel your request?",
                                    style: TextStyle(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => FeedBackScreen(
                                                postId: postId,
                                                uid: uid,
                                              ))).then((value) {
                                    // setMode(() {
                                    //   currentView = 6;
                                    // });
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "Yes, my requirement is fulfilled.",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  setMode(() {
                                    currentView = 2;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "No",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Image.asset(
                          "images/icons/visibility.png",
                          height: 90.h,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Text(
                          "Post Hidden",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "Ok we have removed your post from the feed.\nBut you can still see it in your \" My Request \" tab.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
              case 2:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 15.h),
                                  child: Text(
                                    "Why do you want to cancel your request ?",
                                    style: TextStyle(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  await databaseReference
                                      .child("Users")
                                      .child(uid)
                                      .child("HiddenPosts")
                                      .update({
                                    time
                                        .getCurrentTime()
                                        .millisecondsSinceEpoch
                                        .toString(): {
                                      "forPostId": postId,
                                      "reason": "No Requirement"
                                    }
                                  });
                                  print(":::::HiddenPost Saved::::::");
                                  databaseReference
                                      .child("Post")
                                      .child(postId)
                                      .update({
                                    "status": false,
                                  });
                                  print(":::::Status made false:::::");
                                  setMode(() {
                                    currentView = 1;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "No Requirement",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  await databaseReference
                                      .child("Users")
                                      .child(uid)
                                      .child("HiddenPosts")
                                      .update({
                                    time
                                        .getCurrentTime()
                                        .millisecondsSinceEpoch
                                        .toString(): {
                                      "forPostId": postId,
                                      "reason": "I just want to cancel"
                                    }
                                  });
                                  print(":::::HiddenPost Saved::::::");
                                  databaseReference
                                      .child("Post")
                                      .child(postId)
                                      .update({
                                    "status": false,
                                  });
                                  print(":::::Status made false:::::");
                                  setMode(() {
                                    currentView = 1;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "I just want to cancel",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              default:
                print("Something went wrong");
            }
          });
        });
  }

  @override
  void initState() {
    Time _time2;
    _time2 = Provider.of<Time>(context, listen: false);
    if (_time2.offset != null) {
      selectedDate = _time2.getCurrentTime();
    }

    uid = FirebaseAuth.instance.currentUser.uid;
    _patientNameController.text = widget.patientDetail.patientName;
    _hospitalLocationController.text = widget.patientDetail.hospitalAddress;
    _patientAgeController.text = widget.patientDetail.age.toString();
    _requiredBloodGrpController.text = widget.patientDetail.reqBloodGroup;
    _requiredUnitsController.text = widget.patientDetail.reqUnits.toString();
    _bloodRequiredDateController.text =
        convertDateTimeDisplay(widget.patientDetail.reqDate);
    _bloodRequiredTimeController.text = widget.patientDetail.reqTime;
    _purposeController.text = widget.patientDetail.purpose;
    _hospitalNameController.text = widget.patientDetail.hospitalName;
    _hospitalCityNameController.text = widget.patientDetail.cityName;
    _hospitalAreaNameController.text = widget.patientDetail.areaName;
    _hospitalRoomNumberController.text =
        widget.patientDetail.hospitalRoomNumber;
    _patientContact1Controller.text = widget.patientDetail.contact1;
    _patientContact2Controller.text = widget.patientDetail.contact2;
    _patientContact3Controller.text = widget.patientDetail.contact3;
    _otherDetailsController.text = widget.patientDetail.otherDetails;
    _hospitalLocation = widget.patientDetail.hospitalAddress;
    _bloodRequiredDate = widget.patientDetail.reqDate;
    _checkGps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 4)
      // ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      // ..loadingStyle = EasyLoadingStyle.dark
      // ..indicatorSize = 45.0
      // ..radius = 10.0
      // ..progressColor = Colors.yellow
      // ..backgroundColor = Colors.green
      // ..indicatorColor = Colors.yellow
      // ..textColor = Colors.yellow
      // ..maskColor = Colors.blue.withOpacity(0.5)
      // ..userInteractions = true
      ..dismissOnTap = false;

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: CustomColor.red,
          actions: [
            IconButton(
                icon: Image.asset(
                  "images/icons/on.png",
                  height: 70.h,
                  color: Colors.white,
                ),
                onPressed: () {
                  myBottomSheet(context, widget.patientDetail.postId);
                })
          ],
          // elevation: 1,
          title: Text(
            "Update Requirement",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: TimeLoading(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      top: 80.h, bottom: 170.h, left: 65.w, right: 65.w),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Patient Name",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Patient Name";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _patientName = val;
                                });
                              },
                              style: TextStyle(color: CustomColor.grey),
                              enabled: false,
                              controller: _patientNameController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Patient Age",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Your Age";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _age = int.parse(val);
                                });
                              },
                              style: TextStyle(color: CustomColor.grey),
                              keyboardType: TextInputType.number,
                              enabled: false,
                              controller: _patientAgeController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(17),
                                            topRight: Radius.circular(17))),
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder: (BuildContext
                                              context,
                                          StateSetter
                                              setMode /*You can rename this!*/) {
                                        return Container(
                                          padding: EdgeInsets.all(60.w),
                                          height: 620.h,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Selected required Blood Group",
                                                style: TextStyle(
                                                    color: CustomColor.red,
                                                    fontSize: 50.sp),
                                              ),
                                              SizedBox(
                                                height: 40.h,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                child: Wrap(
                                                  spacing: 50.w,
                                                  runSpacing: 30.h,
                                                  children: bloodGroups
                                                      .map(
                                                          (e) =>
                                                              GestureDetector(
                                                                onTap: () {
                                                                  print(
                                                                      bloodGrp);
                                                                  for (var i =
                                                                          0;
                                                                      i <= 7;
                                                                      i++) {
                                                                    setMode(() {
                                                                      bloodGroups[i]
                                                                              [
                                                                              "colorBool"] =
                                                                          false;
                                                                    });
                                                                    setMode(() {
                                                                      anyGrp =
                                                                          false;
                                                                    });
                                                                    print(bloodGroups[
                                                                            i][
                                                                        "colorBool"]);
                                                                  }
                                                                  print(
                                                                      "Done Loop");
                                                                  setMode(() {
                                                                    bloodGroups[
                                                                            bloodGroups.indexOf(e)]
                                                                        [
                                                                        "colorBool"] = !bloodGroups[
                                                                            bloodGroups.indexOf(e)]
                                                                        [
                                                                        "colorBool"];
                                                                    _requiredBloodGrpController
                                                                        .text = bloodGroups[
                                                                            bloodGroups.indexOf(e)]
                                                                        [
                                                                        "bloodGrp"];
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  height: 113.h,
                                                                  width: 113.h,
                                                                  decoration: BoxDecoration(
                                                                      color: bloodGroups[bloodGroups.indexOf(e)]
                                                                              [
                                                                              "colorBool"]
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .white,
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .red),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              80)),
                                                                  child: Text(
                                                                    bloodGroups[
                                                                            bloodGroups.indexOf(e)]
                                                                        [
                                                                        "bloodGrp"],
                                                                    style: TextStyle(
                                                                        fontSize: 43
                                                                            .sp,
                                                                        color: bloodGroups[bloodGroups.indexOf(e)]["colorBool"]
                                                                            ? Colors
                                                                                .white
                                                                            : Colors
                                                                                .red,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                ),
                                                              ))
                                                      .toList(),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 32.h,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  for (var i = 0; i <= 7; i++) {
                                                    setMode(() {
                                                      bloodGroups[i]
                                                          ["colorBool"] = false;
                                                    });
                                                    print(bloodGrp);
                                                  }
                                                  setMode(() {
                                                    _requiredBloodGrpController
                                                        .text = "Any";
                                                    anyGrp = !anyGrp;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 90.h,
                                                  width: 320.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: CustomColor.red),
                                                    color: anyGrp != false
                                                        ? CustomColor.red
                                                        : Colors.white,
                                                  ),
                                                  child: Text(
                                                    "Any Group",
                                                    style: TextStyle(
                                                        color: anyGrp == false
                                                            ? CustomColor.red
                                                            : Colors.white),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: _requiredBloodGrpController,
                                decoration: InputDecoration(
                                    labelText: "Required Blood Group",
                                    labelStyle: TextStyle(fontSize: 41.sp),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context)
                                          .errorColor, // or any other color
                                    ),
                                    border: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffff4757))),
                                    enabledBorder: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffdfe6e9))),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 28.w, vertical: 14.h)),
                                maxLines: 1,
                                minLines: 1,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Please select required Blood Group";
                                  }
                                },
                                onSaved: (val) {
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: "Required Units",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  counterText: "",
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLength: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Required Units";
                                }
                              },
                              controller: _requiredUnitsController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: TextFormField(
                                controller: _bloodRequiredDateController,
                                enabled: false,
                                decoration: InputDecoration(
                                    labelText: "Blood Required Date",
                                    labelStyle: TextStyle(fontSize: 41.sp),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context)
                                          .errorColor, // or any other color
                                    ),
                                    border: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffff4757))),
                                    enabledBorder: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffdfe6e9))),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 28.w, vertical: 14.h)),
                                maxLines: 1,
                                minLines: 1,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Blood Required Date";
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectTime(context);
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: _bloodRequiredTimeController,
                                decoration: InputDecoration(
                                    labelText: "Blood Required Time",
                                    labelStyle: TextStyle(fontSize: 41.sp),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context)
                                          .errorColor, // or any other color
                                    ),
                                    border: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffff4757))),
                                    enabledBorder: OutlineInputBorder(
                                        // borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Color(0xffdfe6e9))),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 28.w, vertical: 14.h)),
                                maxLines: 1,
                                minLines: 1,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Blood Required Time";
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Purpose",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Your purpose";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _purpose = val;
                                });
                              },
                              style: TextStyle(color: CustomColor.grey),
                              controller: _purposeController,
                              enabled: false,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Hospital Name",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Hospital Name";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _hospitalName = val;
                                });
                              },
                              controller: _hospitalNameController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Hospital City Name",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Hospital City Name";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _hospitalCityName = val;
                                });
                              },
                              controller: _hospitalCityNameController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Hospital Area Name",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Hospital Area Name";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _hospitalAreaName = val;
                                });
                              },
                              controller: _hospitalAreaNameController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (permissionEnabled) {
                                        final res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchHospitalMapScreen()));
                                        if (res != null) {
                                          print(res);
                                          setState(() {
                                            _hospitalLocationDetails = res;
                                            _hospitalLocationController.text =
                                                _hospitalLocationDetails
                                                    .address;
                                          });
                                        }
                                      } else {
                                        _checkGps();
                                      }
                                    },
                                    // child: Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white,
                                    //     borderRadius: BorderRadius.circular(6),
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //         color: CustomColor.grey.withOpacity(0.3),
                                    //         spreadRadius: 1,
                                    //         blurRadius: 1,
                                    //         offset: Offset(0, 2), // changes position of shadow
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   child: Padding(
                                    //       padding: EdgeInsets.symmetric(vertical: 38.h),
                                    //       child: Padding(
                                    //           padding: EdgeInsets.only(left: 20.w),
                                    //           child: _hospitalLocationDetails.address == null ?
                                    //           Text("Hospital Location",style: TextStyle(color: CustomColor.grey),)
                                    //               : Text(_hospitalLocationDetails.address,maxLines: 1,overflow: TextOverflow.ellipsis,))),
                                    // ),
                                    child: TextFormField(
                                      controller: _hospitalLocationController,
                                      decoration: InputDecoration(
                                          labelText: "Hospital Location",
                                          labelStyle:
                                              TextStyle(fontSize: 41.sp),
                                          enabled: false,
                                          errorStyle: TextStyle(
                                            color: Theme.of(context)
                                                .errorColor, // or any other color
                                          ),
                                          border: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Color(0xffff4757))),
                                          enabledBorder: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Color(0xffdfe6e9))),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 28.w,
                                              vertical: 20.h)),
                                      maxLines: 3,
                                      minLines: 1,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: (val) {
                                        if (val.isEmpty) {
                                          return "Please select hospital location";
                                        }
                                      },
                                      onSaved: (val) {
                                        setState(() {
                                          _hospitalLocation = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Hospital Room Number",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Hospital Room Number";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _hospitalRoomNumber = int.parse(val);
                                });
                              },
                              controller: _hospitalRoomNumberController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              maxLength: 10,
                              decoration: InputDecoration(
                                  labelText:
                                      "Patient Attender Contact Number 1",
                                  labelStyle: TextStyle(fontSize: 43.sp),
                                  counterText: "",
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Required";
                                } else if (val.length < 10) {
                                  return "Enter valid Phone Number";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _attenderContact1 = val;
                                });
                              },
                              keyboardType: TextInputType.phone,
                              controller: _patientContact1Controller,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              controller: _patientContact2Controller,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  labelText:
                                      "Patient Attender Contact Number 2",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  counterText: "",
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              onSaved: (val) {
                                setState(() {
                                  _attenderContact2 = val;
                                });
                              },
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              maxLength: 10,
                              decoration: InputDecoration(
                                  labelText:
                                      "Patient Attender Contact Number 3",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  counterText: "",
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h)),
                              readOnly: false,
                              maxLines: 1,
                              minLines: 1,
                              textCapitalization: TextCapitalization.words,
                              onSaved: (val) {
                                setState(() {
                                  _attenderContact3 = val;
                                });
                              },
                              keyboardType: TextInputType.phone,
                              controller: _patientContact3Controller,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Other Details (Optional)",
                                  labelStyle: TextStyle(fontSize: 41.sp),
                                  enabled: true,
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffff4757))),
                                  enabledBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xffdfe6e9))),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 20.h)),
                              readOnly: false,
                              maxLines: 5,
                              textCapitalization: TextCapitalization.words,
                              onSaved: (val) {
                                setState(() {
                                  _otherDetails = val;
                                });
                              },
                              keyboardType: TextInputType.phone,
                              controller: _otherDetailsController,
                            ),
                            SizedBox(
                              height: 33.h,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
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
                        EasyLoading.show(status: 'saving...');
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          await updatePost();
                          EasyLoading.addStatusCallback((status) {
                            print('EasyLoading Status $status');
                          });
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                          print(
                              "$_patientName\n$_age\n${_requiredBloodGrpController.text}\n$_purpose\n$_hospitalName\n$_hospitalCityName\n$_hospitalAreaName\n$_hospitalLocation\n$_hospitalRoomNumber\n$_attenderContact1\n$_attenderContact2\n$_attenderContact3\n$_otherDetails");
                        } else {
                          EasyLoading.dismiss();
                        }
                      },
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 17),
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 47.sp,
                                letterSpacing: 1),
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
