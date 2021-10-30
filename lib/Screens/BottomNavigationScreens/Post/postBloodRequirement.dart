import 'dart:math';

import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/HospitalLocationDetails.dart';
import 'package:bd_app/Screens/MapsScreen/GoogleMapScreen.dart';
import 'package:bd_app/Screens/MapsScreen/SearchHospitalMapScreen.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:geocoder/model.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'package:intl/intl.dart';
import 'package:time_picker_widget/time_picker_widget.dart';

class PostRequirement extends StatefulWidget {
  DocumentSnapshot data;
  bool expired;

  PostRequirement([this.data, this.expired = false]);

  @override
  _PostRequirementState createState() => _PostRequirementState();
}

class _PostRequirementState extends State<PostRequirement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _patientNameController = new TextEditingController();
  TextEditingController _patientAgeController = new TextEditingController();
  String defaultError = "Please select your gender";
  TextEditingController _requiredUnitsController = new TextEditingController();
  TextEditingController _plasmaRequiredController = new TextEditingController();
  TextEditingController _bloodPurposeController = new TextEditingController();
  DateTime plasmaRequiredDate, plasmaRequiredDateFirst;
  TextEditingController _requiredBloodGrpController =
      new TextEditingController();
  String bloodGrp, _myBloodGrp;
  bool anyGrp;

  // bool covid = false;
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  HospitalLocationDetails _hospitalLocationDetails = HospitalLocationDetails();
  TextEditingController _hospitalNameController = new TextEditingController();
  TextEditingController _hospitalLocationController =
      new TextEditingController();

  // TextEditingController _noOfDaysAfterCovidController =
  //     new TextEditingController();

  Position hospitalLocation;
  TextEditingController _hospitalCityController = new TextEditingController();
  TextEditingController _hospitalAreaNameController =
      new TextEditingController();
  TextEditingController _hospitalRoomNoController = new TextEditingController();
  TextEditingController _hospitalOtherDetailsController =
      new TextEditingController();

  List<TextEditingController> _patientAttenderNameController = [];
  List<TextEditingController> _patientAttenderContactController = [];
  bool expansionList1 = false;
  bool expansionList2 = false;
  String gender;
  String errorText, errorText1;

  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  bool active = true;

  int selectedIndex = 1;
  Time time;
  List bloodGroups = [
    {"bloodGrp": "A-", "colorBool": false},
    {"bloodGrp": "B-", "colorBool": false},
    {"bloodGrp": "AB-", "colorBool": false},
    {"bloodGrp": "O-", "colorBool": false},
    {"bloodGrp": "A+", "colorBool": false},
    {"bloodGrp": "B+", "colorBool": false},
    {"bloodGrp": "AB+", "colorBool": false},
    {"bloodGrp": "O+", "colorBool": false},
    {"bloodGrp": "Any", "colorBool": false},
  ];

  @override
  void initState() {
    for (int i = 0; i < 3; i++) {
      _patientAttenderNameController.add(new TextEditingController());
      _patientAttenderContactController.add(new TextEditingController());
    }

    if (widget.data != null) {
      active = widget.data.data()["active"] ?? false;
      if (widget.data.data()["requirementType"] == "plasma" ||
          widget.data.data()["requirementType"] == "plasmaForCovid") {
        // if (widget.data.data()["requirementType"] == "plasmaForCovid") {
        //   covid = true;
        //   _noOfDaysAfterCovidController.text =
        //       widget.data.data()["noOfDaysAfterCoivd"];
        // }
        selectedIndex = 1;
      }

      if (widget.data.data()["requirementType"] == "blood") {
        selectedIndex = 2;
      }

      if (widget.data.data()["requirementType"] == "platelets") {
        selectedIndex = 3;
      }
      _myBloodGrp = widget.data.data()["requiredBloodGrp"];
      bloodGroups.forEach((element) {
        if (element["bloodGrp"] == _myBloodGrp) {
          element["colorBool"] = true;
          _requiredBloodGrpController.text = _myBloodGrp;
        }
      });
      _requiredUnitsController.text = widget.data.data()["requiredUnits"];
      _patientNameController.text = widget.data.data()["patientName"];
      _patientAgeController.text = widget.data.data()["patientAge"];
      gender = widget.data.data()["gender"];
      for (int i = 0; i < 3; i++) {
        _patientAttenderNameController[i].text =
            widget.data.data()["patientAttenderName" + (i + 1).toString()];
        _patientAttenderContactController[i].text =
            widget.data.data()["patientAttenderContact" + (i + 1).toString()];
      }
      _hospitalAreaNameController.text = widget.data.data()["hospitalArea"];
      _hospitalCityController.text = widget.data.data()["hospitalCity"];
      _hospitalLocationController.text = widget.data.data()["hospitalAddr"];
      GeoPoint _geoPoint = widget.data.data()["hospitalLocation"]["geopoint"];
      hospitalLocation = Position(
          latitude: _geoPoint.latitude, longitude: _geoPoint.longitude);
      _hospitalNameController.text = widget.data.data()["hospitalName"];
      _hospitalRoomNoController.text = widget.data.data()["hospitalRoomNo"];
      _hospitalOtherDetailsController.text = widget.data.data()["otherDetails"];

      Timestamp plasmaRequiredDateStamp =
          widget.data.data()["bloodRequiredDateTime"];

      plasmaRequiredDate = DateTime.fromMillisecondsSinceEpoch(
          plasmaRequiredDateStamp.millisecondsSinceEpoch);

      _plasmaRequiredController.text =
          DateFormat('dd MMM yyyy, hh:mm a').format(plasmaRequiredDate);

      Timestamp plasmaRequiredDateFirstStamp =
          widget.data.data()["bloodRequiredDateTimeFirst"];

      plasmaRequiredDateFirst = DateTime.fromMillisecondsSinceEpoch(
          plasmaRequiredDateFirstStamp.millisecondsSinceEpoch);

      _bloodPurposeController.text = widget.data.data()["purpose"];
    }
    // TODO: implement initState
    super.initState();
  }

  Notify _notify;

  Future<bool> showCancelRequestDialog(BuildContext context) {
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
                "Cancel Request",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "Are you sure you want to cancel this request?",
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
                      "Cancel",
                      style:
                          TextStyle(color: CustomColor.grey, fontSize: 50.sp),
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
                      "YES",
                      style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      _firestore.collection("Post").doc(widget.data.id).update({
                        'expired': true,
                        'active': false,
                      });

                      _notify.notify();
                      Get.back();
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

  Future updateAnyForm(String type) async {
    Map<String, dynamic> data = {
      'active': active,
      'expired': false,
      // 'requirementType': !covid ? "plasma" : "plasmaForCovid",
      'requirementType': type,
      'requiredBloodGrp': _myBloodGrp,
      'requiredUnits': _requiredUnitsController.text,
      'bloodRequiredDateTime': Timestamp.fromDate(plasmaRequiredDate),
      'bloodRequiredDateTimeFirst': Timestamp.fromDate(plasmaRequiredDate),
      'purpose':
          _commonUtilFunctions.firstCaptial(_bloodPurposeController.text),
      // 'noOfDaysAfterCoivd': _noOfDaysAfterCovidController.text,
      'patientName':
          _commonUtilFunctions.firstCaptial(_patientNameController.text),
      'patientAge': _patientAgeController.text,
      'gender': _commonUtilFunctions.firstCaptial(gender),
      'patientAttenderName1': _commonUtilFunctions
          .firstCaptial(_patientAttenderNameController[0].text),
      'patientAttenderContact1': _patientAttenderContactController[0].text,
      'patientAttenderName2': _commonUtilFunctions
          .firstCaptial(_patientAttenderNameController[1].text),
      'patientAttenderContact2': _patientAttenderContactController[1].text,
      'patientAttenderName3': _commonUtilFunctions
          .firstCaptial(_patientAttenderNameController[2].text),
      'patientAttenderContact3': _patientAttenderContactController[2].text,
      'hospitalName':
          _commonUtilFunctions.firstCaptial(_hospitalNameController.text),
      'hospitalCity':
          _commonUtilFunctions.firstCaptial(_hospitalCityController.text),
      'hospitalArea':
          _commonUtilFunctions.firstCaptial(_hospitalAreaNameController.text),
      'hospitalAddr':
          _commonUtilFunctions.firstCaptial(_hospitalLocationController.text),
      'hospitalLocation': geo
          .point(
              latitude: hospitalLocation.latitude,
              longitude: hospitalLocation.longitude)
          .data,
      'hospitalRoomNo': _hospitalRoomNoController.text,
      'otherDetails': _commonUtilFunctions
          .firstCaptial(_hospitalOtherDetailsController.text),
      'createdTime': FieldValue.serverTimestamp(),
      'createdBy': FirebaseAuth.instance.currentUser.uid,
    };
    if (widget.data != null) {
      data.remove("bloodRequiredDateTimeFirst");
      _firestore.collection("Post").doc(widget.data.id).update(data);
    } else {
      _firestore.collection("Post").add(data);
    }
    _notify.notify();
    Get.back();
  }

  void decisionToSendNotif(String formType) async {
    int editedFields = 0;
    if (widget.data != null) {
      print("Widget data not null going to check");
      if (widget.data.data()["active"] != active) {
        ++editedFields;
      } else if (widget.data.data()["requirementType"] != formType) {
        print("requirementType");
        ++editedFields;
      } else if (widget.data.data()["requiredBloodGrp"] != _myBloodGrp) {
        ++editedFields;
      } else if (widget.data.data()["requiredUnits"] !=
          _requiredUnitsController.text) {
        ++editedFields;
      } else if (DateTime.fromMillisecondsSinceEpoch(widget.data
              .data()["bloodRequiredDateTime"]
              .millisecondsSinceEpoch) !=
          plasmaRequiredDate) {
        ++editedFields;
      } else if (DateTime.fromMillisecondsSinceEpoch(widget.data
              .data()["bloodRequiredDateTimeFirst"]
              .millisecondsSinceEpoch) !=
          plasmaRequiredDateFirst) {
        ++editedFields;
      } else if (widget.data.data()["purpose"] !=
          _bloodPurposeController.text) {
        ++editedFields;
      } else if (widget.data.data()["patientName"] !=
          _patientNameController.text) {
        ++editedFields;
      } else if (widget.data.data()["patientAge"] !=
          _patientAgeController.text) {
        ++editedFields;
      } else if (widget.data.data()["gender"] != gender) {
        ++editedFields;
      } else if (widget.data
              .data()["patientAttenderName" + (0 + 1).toString()] !=
          _patientAttenderNameController[0].text) {
        ++editedFields;
      } else if (widget.data
              .data()["patientAttenderName" + (1 + 1).toString()] !=
          _patientAttenderNameController[1].text) {
        ++editedFields;
      } else if (widget.data
              .data()["patientAttenderName" + (2 + 1).toString()] !=
          _patientAttenderNameController[2].text) {
        ++editedFields;
      } else if (widget.data.data()["hospitalName"] !=
          _hospitalNameController.text) {
        ++editedFields;
      } else if (widget.data.data()["otherDetails"] !=
          _hospitalOtherDetailsController.text) {
        ++editedFields;
      } else if (widget.data.data()["hospitalCity"] !=
          _hospitalCityController.text) {
        ++editedFields;
      } else if (widget.data.data()["hospitalArea"] !=
          _hospitalAreaNameController.text) {
        ++editedFields;
      } else if (widget.data.data()["hospitalAddr"] !=
          _hospitalLocationController.text) {
        ++editedFields;
      } else if (widget.data.data()["hospitalRoomNo"] !=
          _hospitalRoomNoController.text) {
        ++editedFields;
      } else {
        print("No Changes in the form");
      }
      print("EditedFields $editedFields");
    }
    if (editedFields > 0) {
      await setToNotification(
        postId: widget.data.id,
        patientName: _patientNameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    List<String> _bloodType = [
      "Require \nPlasma",
      "Require \nBlood",
      "Require \nPlatelets"
    ];
    _notify = Provider.of<Notify>(context);
    time = Provider.of<Time>(context);
    return TimeLoading(
        child: DefaultTabController(
      length: 3,
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: CustomColor.lightGrey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            actions: [
              widget.data != null
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showCancelRequestDialog(context);
                      })
                  : Container(),
              widget.data != null
                  ? IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () async {
                        if (selectedIndex == 1) {
                          if (_formKey.currentState.validate()) {
                            int count = 0;
                            setState(() {
                              if (gender == null) {
                                count++;
                                errorText = defaultError;
                              } else {
                                errorText = null;
                              }
                            });
                            if (count == 0) {
                              await updateAnyForm("plasma");
                              decisionToSendNotif("plasma");
                            }
                          }
                        } else if (selectedIndex == 2) {
                          if (_formKey1.currentState.validate()) {
                            int count = 0;
                            setState(() {
                              if (gender == null) {
                                count++;
                                errorText = defaultError;
                              } else {
                                errorText = null;
                              }
                            });
                            if (count == 0) {
                              await updateAnyForm("blood");
                              decisionToSendNotif("blood");
                            }
                          }
                        } else if (selectedIndex == 3) {
                          if (_formKey2.currentState.validate()) {
                            int count = 0;
                            setState(() {
                              if (gender == null) {
                                count++;
                                errorText = defaultError;
                              } else {
                                errorText = null;
                              }
                            });
                            if (count == 0) {
                              await updateAnyForm("platelets");
                              decisionToSendNotif("platelets");
                            }
                          }
                        }
                        // Get.back();
                      })
                  : Container()
            ],
            // elevation: 1,
            // title: Text(null),
            title: Text(
              "Post Requirement",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    // child: FlutterToggleTab(
                    //   unSelectedBackgroundColors: [CustomColor.veryLightGrey],
                    //   // width in percent, to set full width just set to 100
                    //   width: screenWidth * 0.22,
                    //   borderRadius: 25,
                    //   height: 120.h,
                    //   initialIndex: selectedIndex,

                    //   // selectedColors: [Colors.blue],
                    //   selectedTextStyle: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 35.sp,
                    //       fontWeight: FontWeight.w700),
                    //   unSelectedTextStyle: TextStyle(
                    //       color: Colors.black87,
                    //       fontSize: 35.sp,
                    //       fontWeight: FontWeight.w500),
                    //   labels: _bloodType,
                    //   selectedLabelIndex: (index) {
                    //     setState(() {
                    //       selectedIndex = index;
                    //     });
                    //   },
                    // ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                topLeft: Radius.circular(30),
                              )),
                              color: widget.expired
                                  ? (selectedIndex == 1
                                      ? CustomColor.darkGrey
                                      : CustomColor.grey)
                                  : (selectedIndex == 1
                                      ? Colors.red
                                      : CustomColor.grey),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: FittedBox(
                                  child: Text(
                                    "Require \nPlasma",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (!widget.expired)
                                  setState(() {
                                    selectedIndex = 1;
                                  });
                              },

                              // _formKey.currentState.reset();
                              // _requiredBloodGroup = null;
                              // _bloodRequiredDate = null;
                              // _bloodRequiredTime = null;
                              // _hospitalLocation = null;
                              // _hospitalAreaNameController.text = "";
                              // _hospitalLocationDetails.address = null;
                              // _requiredBloodGrpController.text = "";
                              // _bloodRequiredDateController.text = "";
                              // _bloodRequiredTimeController.text = "";
                              // _hospitalLocationController.text = "";
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              color: widget.expired
                                  ? (selectedIndex == 2
                                      ? CustomColor.darkGrey
                                      : CustomColor.grey)
                                  : (selectedIndex == 2
                                      ? Colors.red
                                      : CustomColor.grey),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: FittedBox(
                                  child: Text(
                                    "Require \nBlood",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (!widget.expired)
                                  setState(() {
                                    selectedIndex = 2;
                                  });
                              },
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                if (!widget.expired)
                                  setState(() {
                                    selectedIndex = 3;
                                  });
                              },
                              color: widget.expired
                                  ? (selectedIndex == 3
                                      ? CustomColor.darkGrey
                                      : CustomColor.grey)
                                  : (selectedIndex == 3
                                      ? Colors.red
                                      : CustomColor.grey),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(30),
                                topRight: Radius.circular(30),
                              )),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: FittedBox(
                                    child: Text(
                                  "Require \nPlatelets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                widget.data != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Active"),
                                Container(
                                  width: 70,
                                  child: Switch(
                                      value: active,
                                      onChanged: (value) {
                                        setState(() {
                                          active = !active;
                                        });
                                      }),
                                ),
                              ],
                            ),
                            Text("Enable to make post public"),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: widget.data != null ? 10 : 0,
                ),
                selectedIndex == 1 ? plasmaForm(context) : Container(),
                selectedIndex == 2 ? bloodForm(context) : Container(),
                selectedIndex == 3 ? plateletsForm(context) : Container(),
              ],
            ),
          )),
    ));
  }

  Widget plasmaForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildCatagory(
                "Requirement Details", buildPlasmaRequirementDetails(context)),
            SizedBox(
              height: 20,
            ),
            buildDefaultDetails(context),
            SizedBox(
              height: 20,
            ),
            savePlasmaForm(),
          ],
        ),
      ),
    );
  }

  Future setToNotification({String postId, String patientName}) async {
    var donorListToNotify = [];
    donorListToNotify = await listOfDonorsToNotify(postId);
    print("Final List of Donors to Notify :::::::::::::::");
    print(donorListToNotify);
    for (int i = 0; i < donorListToNotify.length; i++) {
      try {
        _firestore
            .collection("Profile")
            .doc(donorListToNotify[i])
            .collection("notifications")
            .add({
          "postId": postId,
          "tag": "Update",
          "timeStamp": FieldValue.serverTimestamp(),
          "patientName": patientName,
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future listOfDonorsToNotify(String postId) async {
    var donorsList = [];
    var notDonorList = [];
    DocumentSnapshot snapshot =
        await _firestore.collection("Post").doc(postId).get();
    donorsList = snapshot.data()["donors"];
    notDonorList = snapshot.data()["notDonors"];
    print(":::::::::::::::::::::::::PRINTING DONORS AND NO DONORS");
    print(donorsList);
    print(notDonorList);
    if (donorsList.isEmpty || donorsList == null) {
      return;
    } else if (donorsList.isNotEmpty &&
        (notDonorList == null || notDonorList.isEmpty)) {
      return donorsList;
    } else if (donorsList.isNotEmpty && notDonorList.isNotEmpty) {
      var set1 = Set.from(donorsList);
      var set2 = Set.from(notDonorList);
      return List.from(set1.difference(set2));
    } else {
      print("Something went wrong while fetching donors to notify");
    }
  }

  Widget savePlasmaForm() {
    print("Inside savePlasmaForm");
    print(widget.expired);
    return InkWell(
      onTap: widget.expired
          ? null
          : () async {
              print("widget.expired not null");
              if (_formKey.currentState.validate()) {
                print("Validated");
                int count = 0;
                setState(() {
                  if (gender == null) {
                    count++;
                    errorText = defaultError;
                  } else {
                    errorText = null;
                  }
                });
                if (count == 0) {
                  Map<String, dynamic> plasmaData = {
                    'active': active,
                    'expired': false,
                    // 'requirementType': !covid ? "plasma" : "plasmaForCovid",
                    'requirementType': "plasma",
                    'requiredBloodGrp': _myBloodGrp,
                    'requiredUnits': _requiredUnitsController.text,
                    'bloodRequiredDateTime':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'bloodRequiredDateTimeFirst':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'purpose': _commonUtilFunctions
                        .firstCaptial(_bloodPurposeController.text),
                    // 'noOfDaysAfterCoivd': _noOfDaysAfterCovidController.text,
                    'patientName': _commonUtilFunctions
                        .firstCaptial(_patientNameController.text),
                    'patientAge': _patientAgeController.text,
                    'gender': _commonUtilFunctions.firstCaptial(gender),
                    'patientAttenderName1': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[0].text),
                    'patientAttenderContact1':
                        _patientAttenderContactController[0].text,
                    'patientAttenderName2': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[1].text),
                    'patientAttenderContact2':
                        _patientAttenderContactController[1].text,
                    'patientAttenderName3': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[2].text),
                    'patientAttenderContact3':
                        _patientAttenderContactController[2].text,
                    'hospitalName': _commonUtilFunctions
                        .firstCaptial(_hospitalNameController.text),
                    'hospitalCity': _commonUtilFunctions
                        .firstCaptial(_hospitalCityController.text),
                    'hospitalArea': _commonUtilFunctions
                        .firstCaptial(_hospitalAreaNameController.text),
                    'hospitalAddr': _commonUtilFunctions
                        .firstCaptial(_hospitalLocationController.text),
                    'hospitalLocation': geo
                        .point(
                            latitude: hospitalLocation.latitude,
                            longitude: hospitalLocation.longitude)
                        .data,
                    'hospitalRoomNo': _hospitalRoomNoController.text,
                    'otherDetails': _commonUtilFunctions
                        .firstCaptial(_hospitalOtherDetailsController.text),
                    'createdTime': FieldValue.serverTimestamp(),
                    'createdBy': FirebaseAuth.instance.currentUser.uid,
                  };
                  if (widget.data != null) {
                    plasmaData.remove("bloodRequiredDateTimeFirst");
                    _firestore
                        .collection("Post")
                        .doc(widget.data.id)
                        .update(plasmaData);
                  } else {
                    _firestore.collection("Post").add(plasmaData);
                  }
                  _notify.notify();
                  Get.back();
                }
              }
            },
      child: widget.data == null
          ? Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 35.h),
              decoration: BoxDecoration(
                  color: widget.expired ? CustomColor.grey : CustomColor.red,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Center(
                child: Text(
                  widget.data != null ? "Update Post" : 'Post',
                  style: TextStyle(color: Colors.white, fontSize: 48.sp),
                ),
              ),
            )
          : Container(),
    );
  }

  Widget bloodForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            buildCatagory(
                "Requirement Details", buildBloodRequirementDetails(context)),
            SizedBox(
              height: 20,
            ),
            buildDefaultDetails(context),
            SizedBox(
              height: 20,
            ),
            saveBloodForm(),
          ],
        ),
      ),
    );
  }

  Widget saveBloodForm() {
    return InkWell(
      onTap: widget.expired
          ? null
          : () async {
              if (_formKey1.currentState.validate()) {
                int count = 0;
                setState(() {
                  if (gender == null) {
                    count++;
                    errorText = defaultError;
                  } else {
                    errorText = null;
                  }
                });
                if (count == 0) {
                  Map<String, dynamic> plasmaData = {
                    'active': active,
                    'expired': false,
                    'requirementType': "blood",
                    'requiredBloodGrp': _myBloodGrp,
                    'requiredUnits': _requiredUnitsController.text,
                    'bloodRequiredDateTime':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'bloodRequiredDateTimeFirst':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'purpose': _commonUtilFunctions
                        .firstCaptial(_bloodPurposeController.text),
                    'patientName': _commonUtilFunctions
                        .firstCaptial(_patientNameController.text),
                    'patientAge': _patientAgeController.text,
                    'gender': _commonUtilFunctions.firstCaptial(gender),
                    'patientAttenderName1': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[0].text),
                    'patientAttenderContact1':
                        _patientAttenderContactController[0].text,
                    'patientAttenderName2': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[1].text),
                    'patientAttenderContact2':
                        _patientAttenderContactController[1].text,
                    'patientAttenderName3': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[2].text),
                    'patientAttenderContact3':
                        _patientAttenderContactController[2].text,
                    'hospitalName': _commonUtilFunctions
                        .firstCaptial(_hospitalNameController.text),
                    'hospitalCity': _commonUtilFunctions
                        .firstCaptial(_hospitalCityController.text),
                    'hospitalArea': _commonUtilFunctions
                        .firstCaptial(_hospitalAreaNameController.text),
                    'hospitalAddr': _commonUtilFunctions
                        .firstCaptial(_hospitalLocationController.text),
                    'hospitalLocation': geo
                        .point(
                            latitude: hospitalLocation.latitude,
                            longitude: hospitalLocation.longitude)
                        .data,
                    'hospitalRoomNo': _hospitalRoomNoController.text,
                    'otherDetails': _commonUtilFunctions
                        .firstCaptial(_hospitalOtherDetailsController.text),
                    'createdTime': FieldValue.serverTimestamp(),
                    'createdBy': FirebaseAuth.instance.currentUser.uid,
                  };
                  if (widget.data != null) {
                    plasmaData.remove("bloodRequiredDateTimeFirst");
                    _firestore
                        .collection("Post")
                        .doc(widget.data.id)
                        .update(plasmaData);
                  } else {
                    _firestore.collection("Post").add(plasmaData);
                  }
                  _notify.notify();
                  Get.back();
                }
              }
            },
      child: Container(
        width: double.infinity,
        height: 50,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: widget.expired ? CustomColor.grey : CustomColor.red,
            borderRadius: BorderRadius.all(Radius.circular(100))),
        child: Center(
          child: Text(
            widget.data != null ? "Update Post" : 'Post',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget plateletsForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            buildCatagory(
                "Requirement Details", buildBloodRequirementDetails(context)),
            SizedBox(
              height: 20,
            ),
            buildDefaultDetails(context),
            SizedBox(
              height: 20,
            ),
            saveplateletsForm(),
          ],
        ),
      ),
    );
  }

  Widget saveplateletsForm() {
    return InkWell(
      onTap: widget.expired
          ? null
          : () async {
              if (_formKey2.currentState.validate()) {
                int count = 0;
                setState(() {
                  if (gender == null) {
                    count++;
                    errorText = defaultError;
                  } else {
                    errorText = null;
                  }
                });
                if (count == 0) {
                  Map<String, dynamic> plasmaData = {
                    'active': active,
                    'expired': false,
                    'requirementType': "platelets",
                    'requiredBloodGrp': _myBloodGrp,
                    'requiredUnits': _requiredUnitsController.text,
                    'bloodRequiredDateTime':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'bloodRequiredDateTimeFirst':
                        Timestamp.fromDate(plasmaRequiredDate),
                    'purpose': _commonUtilFunctions
                        .firstCaptial(_bloodPurposeController.text),
                    'patientName': _commonUtilFunctions
                        .firstCaptial(_patientNameController.text),
                    'patientAge': _patientAgeController.text,
                    'gender': _commonUtilFunctions.firstCaptial(gender),
                    'patientAttenderName1': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[0].text),
                    'patientAttenderContact1':
                        _patientAttenderContactController[0].text,
                    'patientAttenderName2': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[1].text),
                    'patientAttenderContact2':
                        _patientAttenderContactController[1].text,
                    'patientAttenderName3': _commonUtilFunctions
                        .firstCaptial(_patientAttenderNameController[2].text),
                    'patientAttenderContact3':
                        _patientAttenderContactController[2].text,
                    'hospitalName': _commonUtilFunctions
                        .firstCaptial(_hospitalNameController.text),
                    'hospitalCity': _commonUtilFunctions
                        .firstCaptial(_hospitalCityController.text),
                    'hospitalArea': _commonUtilFunctions
                        .firstCaptial(_hospitalAreaNameController.text),
                    'hospitalAddr': _commonUtilFunctions
                        .firstCaptial(_hospitalLocationController.text),
                    'hospitalLocation': geo
                        .point(
                            latitude: hospitalLocation.latitude,
                            longitude: hospitalLocation.longitude)
                        .data,
                    'hospitalRoomNo': _hospitalRoomNoController.text,
                    'otherDetails': _commonUtilFunctions
                        .firstCaptial(_hospitalOtherDetailsController.text),
                    'createdTime': FieldValue.serverTimestamp(),
                    'createdBy': FirebaseAuth.instance.currentUser.uid,
                  };
                  if (widget.data != null) {
                    plasmaData.remove("bloodRequiredDateTimeFirst");
                    _firestore
                        .collection("Post")
                        .doc(widget.data.id)
                        .update(plasmaData);
                  } else {
                    _firestore.collection("Post").add(plasmaData);
                  }
                  _notify.notify();
                  Get.back();
                }
              }
            },
      child: Container(
        width: double.infinity,
        height: 50,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: widget.expired ? CustomColor.grey : CustomColor.red,
            borderRadius: BorderRadius.all(Radius.circular(100))),
        child: Center(
          child: Text(
            widget.data != null ? "Update Post" : 'Post',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Column buildPlasmaRequirementDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBloodGrup(context),
        SizedBox(
          height: 15,
        ),
        buildRequiredUnits(),
        SizedBox(
          height: 15,
        ),
        buildDate(context),
        SizedBox(
          height: 15,
        ),
        buildBloodPurpose(),
      ],
    );
  }

  Column buildBloodRequirementDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBloodGrup(context),
        SizedBox(
          height: 15,
        ),
        buildRequiredUnits(),
        SizedBox(
          height: 15,
        ),
        buildDate(context),
        SizedBox(
          height: 15,
        ),
        buildBloodPurpose()
      ],
    );
  }

  TextFormField buildBloodPurpose() {
    return TextFormField(
      decoration: InputDecoration(
          counterText: "",
          labelText: "Purpose *",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLength: 25,
      keyboardType: TextInputType.text,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textCapitalization: TextCapitalization.words,
      controller: _bloodPurposeController,
      validator: (val) {
        if (val.isEmpty) {
          return "Please enter your purpose";
        }
      },
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  GestureDetector buildBloodGrup(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.expired)
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17))),
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context,
                    StateSetter setMode /*You can rename this!*/) {
                  return Container(
                    padding: EdgeInsets.all(50.w),
                    height: 625.h,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      children: [
                        Text(
                          "Selected your Blood Group",
                          style: TextStyle(
                              color: CustomColor.red, fontSize: 50.sp),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 50.w,
                            runSpacing: 30.h,
                            children: bloodGroups
                                .map((e) => GestureDetector(
                                      onTap: () {
                                        print(bloodGrp);
                                        for (var i = 0; i <= 8; i++) {
                                          setMode(() {
                                            bloodGroups[i]["colorBool"] = false;
                                          });
                                          print(bloodGroups[i]["colorBool"]);
                                        }
                                        print("Done Loop");
                                        setMode(() {
                                          bloodGroups[bloodGroups.indexOf(e)]
                                              ["colorBool"] = !bloodGroups[
                                                  bloodGroups.indexOf(e)]
                                              ["colorBool"];
                                        });
                                        setState(() {
                                          _myBloodGrp = bloodGroups[bloodGroups
                                              .indexOf(e)]["bloodGrp"];
                                          _requiredBloodGrpController.text =
                                              bloodGroups[bloodGroups
                                                  .indexOf(e)]["bloodGrp"];
                                        });
                                        print(
                                            "Required Blood Brp = $_myBloodGrp");
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 113.h,
                                        width:
                                            bloodGroups[bloodGroups.indexOf(e)]
                                                        ["bloodGrp"] ==
                                                    "Any"
                                                ? 200
                                                : 40,
                                        decoration: BoxDecoration(
                                            color: bloodGroups[bloodGroups
                                                    .indexOf(e)]["colorBool"]
                                                ? CustomColor.red
                                                : Colors.white,
                                            border: Border.all(
                                                color: CustomColor.red),
                                            borderRadius: BorderRadius.circular(
                                                bloodGroups[bloodGroups.indexOf(
                                                            e)]["bloodGrp"] ==
                                                        "Any"
                                                    ? 20
                                                    : 80)),
                                        child: Text(
                                          (bloodGroups[bloodGroups.indexOf(e)]
                                                  ["bloodGrp"] +
                                              (bloodGroups[bloodGroups.indexOf(
                                                          e)]["bloodGrp"] ==
                                                      "Any"
                                                  ? " Group"
                                                  : "")),
                                          style: TextStyle(
                                              fontSize: 43.sp,
                                              color: bloodGroups[bloodGroups
                                                      .indexOf(e)]["colorBool"]
                                                  ? Colors.white
                                                  : CustomColor.red,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
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
            labelText: "Required blood group *",
            labelStyle: TextStyle(fontSize: 41.sp),
            errorStyle: TextStyle(
              color: Theme.of(context).errorColor, // or any other color
            ),
            border: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffff4757))),
            enabledBorder: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffdfe6e9))),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h)),
        readOnly: true,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
            fontSize: 41.sp,
            color: widget.expired ? CustomColor.grey : Colors.black),
        validator: (val) {
          if (val.isEmpty) {
            return "Please select your Blood Group";
          }
        },
        onSaved: (val) {
          setState(() {});
        },
      ),
    );
  }

  Future<void> _selectPlasmaDate(BuildContext context) async {
    DateTime initialDate = plasmaRequiredDate;
    if (plasmaRequiredDate == null ||
        plasmaRequiredDate.isBefore(time.getCurrentTime())) {
      plasmaRequiredDate = time.getCurrentTime();
    }
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: plasmaRequiredDate ?? time.getCurrentTime(),
        firstDate: time.getCurrentTime(),
        lastDate: widget.data == null
            ? DateTime(2030)
            : plasmaRequiredDateFirst.add(Duration(days: 30)));
    if (picked != null && picked != plasmaRequiredDate) {
      // TimeOfDay _time = await showTimePicker(
      //     context: context,
      //     initialEntryMode: TimePickerEntryMode.input,
      //     initialTime: TimeOfDay.fromDateTime(plasmaRequiredDate ??
      //         DateTime(1970))
      // );

      TimeOfDay _time = await showCustomTimePicker(
          context: context,
          // It is a must if you provide selectableTimePredicate
          onFailValidation: (context) => print('Unavailable selection'),
          initialTime: TimeOfDay(
              hour: time.getCurrentTime().hour,
              minute: time.getCurrentTime().minute),
          // ignore: missing_return
          selectableTimePredicate: (time) {
            if (picked ==
                DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)) {
              print("Inside if");
              return time.hour > TimeOfDay.now().hour ||
                  (time.minute >= TimeOfDay.now().minute &&
                      time.hour == TimeOfDay.now().hour);
            } else {
              return true;
            }
          });
      // setState(() => _time = time?.format(context)))
      if (_time != null) {
        setState(() {
          picked = DateTime(
              picked.year, picked.month, picked.day, _time.hour, _time.minute);
          plasmaRequiredDate = picked;
          _plasmaRequiredController.text =
              DateFormat('dd MMM yyyy, hh:mm a').format(picked);
        });
      }
    }
  }

  GestureDetector buildDate(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.expired) _selectPlasmaDate(context);
      },
      child: TextFormField(
        enabled: false,
        controller: _plasmaRequiredController,
        decoration: InputDecoration(
          labelText: "Required Date & Time *",
          labelStyle: TextStyle(fontSize: 41.sp),
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor, // or any other color
          ),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
          // suffixIcon: SimpleTooltip(
          //   animationDuration: Duration(seconds: 1),
          //   hideOnTooltipTap: true,
          //   borderColor: Colors.white,
          //   show: showToolTip,
          //   tooltipDirection: TooltipDirection.horizontal,
          //   content: Text(
          //     "This information is used to determine the
          //     services available for your account",
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 10,
          //       decoration: TextDecoration.none,
          //     ),
          //   ),
          //   child: IconButton(
          //     icon: Icon(
          //       Icons.help_outlined,
          //       color: Colors.black,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         showToolTip = !showToolTip;
          //       });
          //     },
          //   ),
          // ),
        ),
        readOnly: false,
        textCapitalization: TextCapitalization.words,
        validator: (val) {
          if (val.isEmpty) {
            return "Select Required Date & Time";
          }
        },
        style: TextStyle(
            fontSize: 41.sp,
            color: widget.expired ? CustomColor.grey : Colors.black),
      ),
    );
  }

  TextFormField buildRequiredUnits() {
    return TextFormField(
      controller: _requiredUnitsController,
      decoration: InputDecoration(
          labelText: "Required Units *",
          counterText: "",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLength: 2,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.words,
      validator: (val) {
        if (val.isEmpty) {
          return "Please enter required units";
        } else if (val.length > 2) {
          return "Enter Valid Number";
        }
      },
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  // TextFormField buildNoOfDaysAfterCovid() {
  //   return TextFormField(
  //     controller: _noOfDaysAfterCovidController,
  //     decoration: InputDecoration(
  //         labelText: "No of days after covid recovery",
  //         labelStyle: TextStyle(fontSize: 41.sp),
  //         counterText: "",
  //         border: OutlineInputBorder(
  //             // borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide(color: Color(0xffff4757))),
  //         enabledBorder: OutlineInputBorder(
  //             // borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide(color: Color(0xffdfe6e9))),
  //         contentPadding:
  //             EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
  //     maxLines: 1,
  //     minLines: 1,
  //     maxLength: 10,
  //     keyboardType: TextInputType.number,
  //     textCapitalization: TextCapitalization.words,
  //     validator: (val) {
  //       if (val.isEmpty && covid) {
  //         return "madatory";
  //       } else if (val.length > 3 && covid) {
  //         return "Enter Valid Number";
  //       }
  //     },
  //     enabled: !widget.expired,
  //     style: TextStyle(
  //         fontSize: 41.sp, color: widget.expired ? CustomColor.grey : Colors.black),
  //   );
  // }

  Column buildDefaultDetails(BuildContext context) {
    return Column(
      children: [
        buildCatagory("Patient Details", buildPatient()),
        SizedBox(
          height: 20,
        ),
        buildCatagory(
            "Patient Attender Details", buildPatientAttenderDetails()),
        SizedBox(
          height: 20,
        ),
        buildCatagory("Location Details", buildLocationDetails(context))
      ],
    );
  }

  Container buildCatagory(String title, Widget _widget) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Opensans"),
            ),
          ),
          Divider(
            endIndent: 10,
            indent: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: _widget,
          ),
        ],
      ),
    );
  }

  Column buildPatient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPatientName(),
        SizedBox(
          height: 15,
        ),
        buildPatientAge(),
        SizedBox(
          height: 15,
        ),
        buildDropDown("Gender*", buildPatientGender()),
      ],
    );
  }

  Column buildPatientAttenderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPatientAttenderName(0),
        SizedBox(
          height: 15,
        ),
        buildPatientAttenderContact(0),
        SizedBox(
          height: 15,
        ),
        buildPatientAttenderName(1),
        SizedBox(
          height: 15,
        ),
        buildPatientAttenderContact(1),
        SizedBox(
          height: 15,
        ),
        buildPatientAttenderName(2),
        SizedBox(
          height: 15,
        ),
        buildPatientAttenderContact(2),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Column buildLocationDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHospitalLocation(context),
        SizedBox(
          height: 20,
        ),
        hospitalLocation != null ? buildHospitalName() : Container(),
        SizedBox(
          height: hospitalLocation != null ? 15 : 0,
        ),
        hospitalLocation != null ? buildHospitalCityName() : Container(),
        SizedBox(
          height: hospitalLocation != null ? 15 : 0,
        ),
        hospitalLocation != null ? buildHospitalAreaName() : Container(),
        SizedBox(
          height: hospitalLocation != null ? 15 : 0,
        ),
        buildHospitalRoomNo(),
        SizedBox(
          height: 20,
        ),
        buildHospitalOtherDeatils(),
      ],
    );
  }

  TextFormField buildHospitalName() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Hospital Name*",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLines: 1,
      minLines: 1,
      enabled: !widget.expired,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _hospitalNameController,
      validator: (val) {
        if (val.isEmpty) {
          return "Enter hospital name";
        }
      },
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  TextFormField buildHospitalCityName() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Hospital City Name*",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLines: 1,
      minLines: 1,
      enabled: !widget.expired,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _hospitalCityController,
      validator: (val) {
        if (val.isEmpty) {
          return "Enter your city name";
        }
      },
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  TextFormField buildHospitalAreaName() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Hospital Area Name*",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLines: 1,
      minLines: 1,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _hospitalAreaNameController,
      validator: (val) {
        if (val.isEmpty) {
          return "Enter hospital area name";
        }
      },
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  Widget buildHospitalLocation(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.expired) {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            _commonUtilFunctions.openLocationSetting();
          }
          if (serviceEnabled) {
            final res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GoogleMapScreen(hospitalLocation)));
            if (res != null) {
              Address addr = res[0];
              setState(() {
                hospitalLocation = Position(
                    latitude: addr.coordinates.latitude,
                    longitude: addr.coordinates.longitude);
                _hospitalCityController.text = addr.locality;
                _hospitalAreaNameController.text = addr.subLocality;
                _hospitalLocationController.text = addr.addressLine;
              });
            }
          }
        }
      },
      child: TextFormField(
        controller: _hospitalLocationController,
        decoration: InputDecoration(
          labelText: "Hospital Location *",
          labelStyle: TextStyle(fontSize: 41.sp),
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor, // or any other color
          ),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        ),
        maxLines: 3,
        minLines: 1,
        enabled: false,
        textCapitalization: TextCapitalization.words,
        validator: (val) {
          if (val.isEmpty) {
            return "Please select hospital location";
          }
        },
        style: TextStyle(
            fontSize: 41.sp,
            color: widget.expired ? CustomColor.grey : Colors.black),
      ),
    );
  }

  TextFormField buildHospitalRoomNo() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Hospital Room Number",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLines: 1,
      minLines: 1,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _hospitalRoomNoController,
      // validator: (val) {
      //   if (val.isEmpty) {
      //     return "Enter your full name";
      //   }
      // },
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  TextFormField buildHospitalOtherDeatils() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Other Details",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLength: 100,
      maxLines: null,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: _hospitalOtherDetailsController,

      // validator: (val) {
      //   if (val.isEmpty) {
      //     return "Enter your full name";
      //   }
      // },
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  TextFormField buildPatientAttenderName(int i) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: i == 0
              ? "Patient Attender Name " + (i + 1).toString() + "*"
              : "Patient Attender Name " + (i + 1).toString(),
          counterText: "",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      enabled: !widget.expired,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _patientAttenderNameController[i],
      validator: (val) {
        if (val.isEmpty && i == 0) {
          return "Please enter patient attender name";
        }
      },
      maxLength: 25,
      // maxLengthEnforcement: MaxLengthEnforcement.enforced,
      // maxLengthEnforced: true,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      // inputFormatters: [
      //   new LengthLimitingTextInputFormatter(25),
      // ],
      // maxLengthEnforcement: MaxLengthEnforcement.enforced,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  TextFormField buildPatientAttenderContact(int i) {
    return TextFormField(
      controller: _patientAttenderContactController[i],
      decoration: InputDecoration(
          counterText: "",
          labelText: i == 0
              ? "Patient Attender Contact Number " + (i + 1).toString() + "*"
              : "Patient Attender Contact Number " + (i + 1).toString(),
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLength: 10,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      enabled: !widget.expired,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.words,
      validator: (val) {
        if (val.isEmpty) {
          if (i == 0) return "Please enter patient attender contact";
          return null;
        } else if (val.length < 10) {
          return "Enter Valid Number";
        }
      },
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  Widget buildPatientGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            if (!widget.expired)
              setState(() {
                expansionList1 = !expansionList1;
              });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: gender != null
                      ? Text(
                          gender,
                          style: TextStyle(
                              color: widget.expired
                                  ? CustomColor.grey
                                  : Colors.black),
                        )
                      : Text(
                          "Gender*",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  gender != "Male"
                      ? ListTile(
                          title: Text("Male"),
                          onTap: () async {
                            expansionList1 = !expansionList1;
                            setState(() {
                              gender = "Male";
                            });
                          },
                        )
                      : Container(),
                  gender != "Female"
                      ? ListTile(
                          title: Text("Female"),
                          onTap: () {
                            expansionList1 = !expansionList1;
                            setState(() {
                              gender = "Female";
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                  gender != "Prefer Not To Say"
                      ? ListTile(
                          title: Text("Prefer Not To Say"),
                          onTap: () {
                            expansionList1 = !expansionList1;
                            setState(() {
                              gender = "Prefer Not To Say";
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                ],
              ),
              isExpanded: expansionList1,
            ),
          ],
        ),
        errorText != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  TextFormField buildPatientName() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Patient Name *",
          counterText: "",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      enabled: !widget.expired,
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      controller: _patientNameController,
      maxLength: 25,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      validator: (val) {
        if (val.isEmpty) {
          return "Please enter patient name";
        }
      },
    );
  }

  TextFormField buildPatientAge() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Patient Age *",
          counterText: "",
          labelStyle: TextStyle(fontSize: 41.sp),
          border: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffff4757))),
          enabledBorder: OutlineInputBorder(
              // borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffdfe6e9))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h)),
      maxLength: 3,
      enabled: !widget.expired,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.words,
      controller: _patientAgeController,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      validator: (val) {
        if (val.isEmpty) {
          return "Please enter patient age";
        }
      },
      style: TextStyle(
          fontSize: 41.sp,
          color: widget.expired ? CustomColor.grey : Colors.black),
    );
  }

  Container buildDropDown(String title, Widget _widget) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: CustomColor.lightGrey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(
            height: 10,
          ),
          _widget
        ],
      ),
    );
  }
}
