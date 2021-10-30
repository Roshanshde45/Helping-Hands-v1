import 'package:android_intent/android_intent.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/HospitalLocationDetails.dart';
import 'package:bd_app/Model/PatientDetails.dart';
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

class EditPostDetailsBottomPush extends StatefulWidget {
  final String postId;
  EditPostDetailsBottomPush({this.postId});
  @override
  _EditPostDetailsBottomPushState createState() =>
      _EditPostDetailsBottomPushState();
}

class _EditPostDetailsBottomPushState extends State<EditPostDetailsBottomPush> {
  String uid;
  int _bloodRequiredDate;
  String imageUrl;
  String userName;
  bool firstTime = false;
  bool loaded = false;
  List myRequestPostList;
  Time time;
  DateTime selectedDate;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final databaseReference = FirebaseDatabase.instance.reference();
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
  String _patientName,
      _purpose,
      _hospitalName,
      _hospitalCityName,
      _hospitalAreaName,
      _hospitalLocation,
      _otherDetails;
  int _requiredUnits;
  String _attenderContact1, _attenderContact2, _attenderContact3;
  int _hospitalRoomNumber, _age;
  String bloodGrp;
  bool anyGrp = false;
  List<String> myRequest = [];

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

  Future<void> updatePost() async {
    try {
      await databaseReference.child("Post").child(widget.postId).update({
        "requiredBloodGrp": _requiredBloodGrpController.text,
        "requiredUnits": _requiredUnitsController.text,
        "bloodRequiredDate": _bloodRequiredDate,
        "bloodRequiredTime": _bloodRequiredTimeController.text,
        "purpose": _purposeController.text,
        "hospitalName": _hospitalNameController.text,
        "hospitalCityName": _hospitalCityNameController.text,
        "hospitalAreaName": _hospitalAreaName,
        "hospitalRoomNumber": _hospitalRoomNumberController.text,
        "patientAttender1": _patientContact1Controller.text,
        "patientAttender2": _patientContact2Controller.text,
        "patientAttender3": _patientContact3Controller.text,
        "otherDetails": _otherDetailsController.text,
        "hospitalAddress": _hospitalLocationController.text
      });
      print("Post Saved Successfully!!!");
    } catch (e) {
      print(e);
    }
  }

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat serverFormatter = DateFormat('yMMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted;
  }

  Future<void> getRequestDetails() async {
    print("Entered getMy Request");
    DataSnapshot snap;
    List myReqPostList = [];
    snap = await databaseReference.child("Post").child(widget.postId).once();
    setState(() {
      _requiredBloodGrpController.text = snap.value["requiredBloodGrp"];
      _requiredUnitsController.text = snap.value["requiredUnits"].toString();
      _bloodRequiredDateController.text =
          convertDateTimeDisplay(snap.value["bloodRequiredDate"]);
      _bloodRequiredTimeController.text = snap.value["bloodRequiredTime"];
      _purposeController.text = snap.value["purpose"];
      _hospitalNameController.text = snap.value["hospitalName"];
      _hospitalCityNameController.text = snap.value["hospitalCityName"];
      _hospitalLocationController.text = snap.value["hospitalAddress"];
      _hospitalRoomNumberController.text =
          snap.value["hospitalRoomNumber"].toString();
      _patientContact1Controller.text = snap.value["patientAttender1"];
      _patientContact2Controller.text = snap.value["patientAttender2"];
      _patientContact3Controller.text = snap.value["patientAttender3"];
      _otherDetailsController.text = snap.value["otherDetails"];
      _patientNameController.text = snap.value["patientName"];
      _patientAgeController.text = snap.value["patientAge"].toString();
      _hospitalAreaNameController.text = snap.value["hospitalAreaName"];
      _bloodRequiredDate = snap.value["bloodRequiredDate"];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950, 1),
        lastDate: time.getCurrentTime().add(Duration(days: 30)));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _bloodRequiredDate = Timestamp.fromDate(picked).millisecondsSinceEpoch;
        _bloodRequiredDateController.text = DateFormat('yMMMd').format(picked);
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

  Future<bool> showDonateDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Post updated successfully!!!",
                textAlign: TextAlign.center,
              ),
            ),
            content: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Image.asset(
                  "images/done.png",
                  height: 240.h,
                )),
            contentPadding: EdgeInsets.all(28.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      print("OK");
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

  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = time.getCurrentTime();
    uid = FirebaseAuth.instance.currentUser.uid;
    getRequestDetails();
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
                                                                          ? CustomColor
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
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: GestureDetector(
                            //         onTap: () async{
                            //           bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                            //           if (!serviceEnabled) {
                            //             openLocationSetting();
                            //           }
                            //           if(serviceEnabled){
                            //             final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchHospitalMapScreen()));
                            //             if(res != null){
                            //               print(res);
                            //               setState(() {
                            //                 _hospitalLocation = res;
                            //               });
                            //             }
                            //           }
                            //         },
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(6),
                            //             boxShadow: [
                            //               BoxShadow(
                            //                 color: CustomColor.grey.withOpacity(0.3),
                            //                 spreadRadius: 1,
                            //                 blurRadius: 1,
                            //                 offset: Offset(0, 2), // changes position of shadow
                            //               ),
                            //             ],
                            //           ),
                            //           child: Padding(
                            //               padding: EdgeInsets.symmetric(vertical: 38.h),
                            //               child: Padding(
                            //                   padding: EdgeInsets.only(left: 20.w),
                            //                   child: _hospitalLocation == null ?
                            //                   Text("Hospital Location",style: TextStyle(color: CustomColor.grey),)
                            //                       : Text(_hospitalLocation,maxLines: 1,overflow: TextOverflow.ellipsis,))),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      bool serviceEnabled = await Geolocator
                                          .isLocationServiceEnabled();
                                      if (!serviceEnabled) {
                                        openLocationSetting();
                                      }
                                      if (serviceEnabled) {
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
                                              vertical: 14.h)),
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
                              maxLines: 1,
                              minLines: 1,
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
