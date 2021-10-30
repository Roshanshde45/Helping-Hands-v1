// import 'dart:math';

// import 'package:android_intent/android_intent.dart';
// import 'package:another_flushbar/flushbar.dart';
// import 'package:bd_app/Model/HospitalLocationDetails.dart';
// import 'package:bd_app/Screens/DashboardScreen.dart';
// import 'package:bd_app/Screens/MapsScreen/SearchHospitalMapScreen.dart';
// import 'package:bd_app/Widgets/CommonUtilFuctions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';

// class PostBloodRequirementScreen extends StatefulWidget {
//   @override
//   _PostBloodRequirementScreenState createState() =>
//       _PostBloodRequirementScreenState();
// }

// class _PostBloodRequirementScreenState
//     extends State<PostBloodRequirementScreen> {
//   PersistentBottomSheetController _controller;

//   TextEditingController _requiredBloodGrpController =
//       new TextEditingController();
//   TextEditingController _bloodRequiredTimeController =
//       new TextEditingController();
//   TextEditingController _bloodRequiredDateController =
//       new TextEditingController();
//   TextEditingController _hospitalAreaNameController =
//       new TextEditingController();
//   TextEditingController _hospitalLocationController =
//       new TextEditingController();
//   HospitalLocationDetails _hospitalLocationDetails = HospitalLocationDetails();
//   String uid,
//       imageUrl,
//       userName,
//       phone,
//       _bloodRequiredTime,
//       _requiredBloodGroup;
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final databaseReference = FirebaseDatabase.instance.reference();
//   final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   DateTime selectedDate = time.getCurrentTime()();
//   TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

//   String _patientName,
//       _purpose,
//       _hospitalName,
//       _hospitalCityName,
//       _hospitalAreaName,
//       _hospitalLocation,
//       _otherDetails,
//       _attenderContact1,
//       _attenderContact2,
//       _attenderContact3,
//       bloodGrp;
//   int _requiredUnits, _hospitalRoomNumber, _age, _bloodRequiredDate;

//   bool firstTime = false;
//   bool anyGrp = false;

//   List myRequest = [];
//   List bloodGroups = [
//     {"bloodGrp": "A-", "colorBool": false},
//     {"bloodGrp": "B-", "colorBool": false},
//     {"bloodGrp": "AB-", "colorBool": false},
//     {"bloodGrp": "O-", "colorBool": false},
//     {"bloodGrp": "A+", "colorBool": false},
//     {"bloodGrp": "B+", "colorBool": false},
//     {"bloodGrp": "AB+", "colorBool": false},
//     {"bloodGrp": "O+", "colorBool": false},
//   ];

//   void selectedGrpFunc(int j) {
//     for (var i = 0; i <= 7; i++) {
//       _controller.setState(() {
//         bloodGroups[i]["colorBool"] = false;
//       });
//       print(bloodGroups[i]["colorBool"]);
//     }
//     print("Done Loop");
//     _controller.setState(() {
//       bloodGroups[j]["colorBool"] = !bloodGroups[j]["colorBool"];
//       bloodGrp = bloodGroups[j]["bloodGrp"];
//     });
//   }

//   Future<void> savePost() async {
//     int timeStamp = time.getCurrentTime()().millisecondsSinceEpoch;
//     DataSnapshot snap;
//     var reqList = new List();
//     try {
//       try {
//         await databaseReference
//             .child("Post")
//             .child(timeStamp.toString() + uid)
//             .set({
//           "uid": uid,
//           "patientName": _patientName,
//           "postedUserPhone": phone,
//           "patientAge": _age,
//           "requiredBloodGrp": _requiredBloodGroup,
//           "requiredUnits": _requiredUnits,
//           "bloodRequiredDate": _bloodRequiredDate,
//           "bloodRequiredTime": _bloodRequiredTime,
//           "purpose": _purpose,
//           "hospitalName": _hospitalName,
//           "hospitalCityName": _hospitalCityName,
//           "hospitalAreaName": _hospitalAreaName,
//           "hospitalLatLng": [
//             _hospitalLocationDetails.coordinates.latitude,
//             _hospitalLocationDetails.coordinates.longitude
//           ],
//           "hospitalAddress": _hospitalLocationDetails.address,
//           "hospitalRoomNumber": _hospitalRoomNumber,
//           "patientAttender1": _attenderContact1,
//           "patientAttender2": _attenderContact2,
//           "patientAttender3": _attenderContact3,
//           "otherDetails": _otherDetails,
//           "imageUrl": imageUrl,
//           "userName": userName,
//           "userPhone": phone,
//           "status": true,
//           "postId": timeStamp.toString() + uid
//         });
//         print("Post Saved Successfully!!!");
//       } catch (e) {
//         print(e);
//       }
//       snap = await databaseReference.child("Users").child(uid).once();
//       if (snap.value["myRequest"] != null) {
//         print(snap.value["myRequest"]);
//         for (var req in snap.value["myRequest"]) reqList.add(req);
//         print("ReqList: $reqList");
//         reqList.add(timeStamp.toString() + uid);
//         print("ReqList Updated: $reqList");

//         databaseReference
//             .child("Users")
//             .child(uid)
//             .update({"myRequest": reqList}).then(
//                 (value) => print(":::::::Request Saved::::::"));
//       } else {
//         print("myRequest is NULL");
//         reqList.add(timeStamp.toString() + uid);
//         print("ReqList Updated: $reqList");

//         databaseReference
//             .child("Users")
//             .child(uid)
//             .update({"myRequest": reqList}).then(
//                 (value) => print(":::::::Request Saved::::::"));
//       }
//       _formKey.currentState.reset();
//       setState(() {
//         _requiredBloodGroup = null;
//         _bloodRequiredDate = null;
//         _bloodRequiredTime = null;
//         _hospitalLocation = null;
//         _hospitalAreaNameController.text = "";
//         _hospitalLocationDetails.address = null;
//         _requiredBloodGrpController.text = "";
//         _bloodRequiredDateController.text = "";
//         _bloodRequiredTimeController.text = "";
//         _hospitalLocationController.text = "";
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDate,
//         firstDate: time.getCurrentTime()(),
//         lastDate: time.getCurrentTime()().add(Duration(days: 30)));
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         _bloodRequiredDateController.text = DateFormat('yMMMd').format(picked);
//         _bloodRequiredDate = Timestamp.fromDate(picked).millisecondsSinceEpoch;
//         print(_bloodRequiredDateController.text);
//       });
//     }
//   }

//   Future<Null> _selectTime(BuildContext context) async {
//     final localizations = MaterialLocalizations.of(context);
//     final TimeOfDay picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//     );
//     if (picked != null)
//       setState(() {
//         selectedTime = picked;
//         _bloodRequiredTime = localizations.formatTimeOfDay(picked);
//         _bloodRequiredTimeController.text =
//             localizations.formatTimeOfDay(picked);
//       });
//   }

//   Future<void> getName() {
//     print("Inside getName()");
//     try {
//       databaseReference.child("Users").child(uid).once().then((snap) {
//         print(snap.value["name"]);
//         setState(() {
//           userName = snap.value["name"];
//           imageUrl = snap.value["profilePic"];
//         });
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<bool> showDonateDialog(
//       BuildContext context,
//       String postId,
//       int index,
//       String patientName,
//       String posterUid,
//       String posterPhone,
//       String bloodGrp) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return new AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.0)),
//             title: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 "Donate Blood",
//                 textAlign: TextAlign.start,
//               ),
//             ),
//             content: Padding(
//               padding: EdgeInsets.only(left: 12),
//               child: Text(
//                 "Thank you for being a donor.We will send your information to the requested person.By clicking OK you agree that you will respond to phone calls an in app messages.",
//                 style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
//                 textAlign: TextAlign.justify,
//               ),
//             ),
//             contentPadding: EdgeInsets.all(28.w),
//             actions: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   FlatButton(
//                     child: Text(
//                       "Cancel",
//                       style:
//                           TextStyle(color: CustomColor.grey[500], fontSize: 50.sp),
//                     ),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   FlatButton(
//                     child: Text(
//                       "OK",
//                       style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
//                     ),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   )
//                 ],
//               )
//             ],
//           );
//         });
//   }

//   @override
//   void initState() {
//     uid = FirebaseAuth.instance.currentUser.uid;
//     phone = FirebaseAuth.instance.currentUser.phoneNumber;
//     super.initState();
//     getName();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final InputDecoration stylebox = InputDecoration(
//         labelText: "Patient Name",
//         labelStyle: TextStyle(fontSize: 41.sp),
//         enabled: true,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h));

//     return Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: CustomColor.red,
//           actions: [
//             FlatButton(
//               onPressed: () {
//                 _formKey.currentState.reset();
//                 _requiredBloodGroup = null;
//                 _bloodRequiredDate = null;
//                 _bloodRequiredTime = null;
//                 _hospitalLocation = null;
//                 _hospitalAreaNameController.text = "";
//                 _hospitalLocationDetails.address = null;
//                 _requiredBloodGrpController.text = "";
//                 _bloodRequiredDateController.text = "";
//                 _bloodRequiredTimeController.text = "";
//                 _hospitalLocationController.text = "";
//               },
//               child: Text(
//                 "Clear",
//                 style: TextStyle(color: Colors.white, fontSize: 50.sp),
//               ),
//             )
//           ],
//           // elevation: 1,
//           // title: Text(null),
//           title: Text("Post Requirement",style: TextStyle(color: Colors.white),),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Container(
//                 padding: EdgeInsets.only(
//                     top: 80.h, bottom: 170.h, left: 65.w, right: 65.w),
//                 child: Column(
//                   children: [
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             decoration: InputDecoration(
//                               labelText: "Patient Name *",
//                               labelStyle: TextStyle(fontSize: 41.sp),
//                               border: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffff4757))),
//                               enabledBorder: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffdfe6e9))),
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 28.w, vertical: 14.h),
//                             ),
//                             maxLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Patient Name";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _patientName = val;
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                               labelText: "Patient Age *",
//                               labelStyle: TextStyle(fontSize: 41.sp),
//                               border: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffff4757))),
//                               enabledBorder: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffdfe6e9))),
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 28.w, vertical: 14.h),
//                               counterText: "",
//                             ),
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Your Age";
//                               }
//                             },
//                             maxLength: 2,
//                             onSaved: (val) {
//                               setState(() {
//                                 _age = int.parse(val);
//                               });
//                             },
//                             keyboardType: TextInputType.number,
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               showModalBottomSheet(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(17),
//                                           topRight: Radius.circular(17))),
//                                   context: context,
//                                   builder: (context) {
//                                     return StatefulBuilder(builder: (BuildContext
//                                             context,
//                                         StateSetter
//                                             setMode /*You can rename this!*/) {
//                                       return Container(
//                                         padding: EdgeInsets.all(60.w),
//                                         height: 620.h,
//                                         width:
//                                             MediaQuery.of(context).size.width,
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.only(
//                                                 topLeft: Radius.circular(20),
//                                                 topRight: Radius.circular(20))),
//                                         child: Column(
//                                           children: [
//                                             Text(
//                                               "Selected required Blood Group",
//                                               style: TextStyle(
//                                                   color: CustomColor.red,
//                                                   fontSize: 50.sp),
//                                             ),
//                                             SizedBox(
//                                               height: 40.h,
//                                             ),
//                                             Container(
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   0.6,
//                                               child: Wrap(
//                                                 spacing: 50.w,
//                                                 runSpacing: 30.h,
//                                                 children: bloodGroups
//                                                     .map((e) => GestureDetector(
//                                                           onTap: () {
//                                                             print(bloodGrp);
//                                                             for (var i = 0;
//                                                                 i <= 7;
//                                                                 i++) {
//                                                               setMode(() {
//                                                                 bloodGroups[i][
//                                                                         "colorBool"] =
//                                                                     false;
//                                                               });
//                                                               setMode(() {
//                                                                 anyGrp = false;
//                                                               });
//                                                               print(bloodGroups[
//                                                                       i][
//                                                                   "colorBool"]);
//                                                             }
//                                                             print("Done Loop");
//                                                             setMode(() {
//                                                               bloodGroups[bloodGroups
//                                                                       .indexOf(
//                                                                           e)][
//                                                                   "colorBool"] = !bloodGroups[
//                                                                       bloodGroups
//                                                                           .indexOf(
//                                                                               e)]
//                                                                   ["colorBool"];
//                                                               _requiredBloodGrpController
//                                                                   .text = bloodGroups[
//                                                                       bloodGroups
//                                                                           .indexOf(
//                                                                               e)]
//                                                                   ["bloodGrp"];
//                                                             });
//                                                             Navigator.pop(
//                                                                 context);
//                                                           },
//                                                           child: Container(
//                                                             alignment: Alignment
//                                                                 .center,
//                                                             height: 113.h,
//                                                             width: 113.h,
//                                                             decoration: BoxDecoration(
//                                                                 color: bloodGroups[
//                                                                             bloodGroups.indexOf(e)]
//                                                                         [
//                                                                         "colorBool"]
//                                                                     ? CustomColor.red
//                                                                     : Colors
//                                                                         .white,
//                                                                 border: Border.all(
//                                                                     color: Colors
//                                                                         .red),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             80)),
//                                                             child: Text(
//                                                               bloodGroups[bloodGroups
//                                                                       .indexOf(
//                                                                           e)]
//                                                                   ["bloodGrp"],
//                                                               style: TextStyle(
//                                                                   fontSize:
//                                                                       43.sp,
//                                                                   color: bloodGroups[
//                                                                               bloodGroups.indexOf(e)]
//                                                                           [
//                                                                           "colorBool"]
//                                                                       ? Colors
//                                                                           .white
//                                                                       : Colors
//                                                                           .red,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w700),
//                                                             ),
//                                                           ),
//                                                         ))
//                                                     .toList(),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height: 32.h,
//                                             ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 for (var i = 0; i <= 7; i++) {
//                                                   setMode(() {
//                                                     bloodGroups[i]
//                                                         ["colorBool"] = false;
//                                                   });
//                                                   print(bloodGrp);
//                                                 }
//                                                 setMode(() {
//                                                   _requiredBloodGrpController
//                                                       .text = "Any";
//                                                   anyGrp = !anyGrp;
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                               child: Container(
//                                                 alignment: Alignment.center,
//                                                 height: 90.h,
//                                                 width: 320.w,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(20),
//                                                   border: Border.all(
//                                                       color: CustomColor.red),
//                                                   color: anyGrp != false
//                                                       ? CustomColor.red
//                                                       : Colors.white,
//                                                 ),
//                                                 child: Text(
//                                                   "Any Group",
//                                                   style: TextStyle(
//                                                       color: anyGrp == false
//                                                           ? CustomColor.red
//                                                           : Colors.white),
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       );
//                                     });
//                                   });
//                             },
//                             child: TextFormField(
//                               enabled: false,
//                               controller: _requiredBloodGrpController,
//                               decoration: InputDecoration(
//                                   labelText: "Required Blood Group *",
//                                   labelStyle: TextStyle(fontSize: 41.sp),
//                                   enabled: false,
//                                   errorStyle: TextStyle(
//                                     color: Theme.of(context)
//                                         .errorColor, // or any other color
//                                   ),
//                                   border: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffff4757))),
//                                   enabledBorder: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffdfe6e9))),
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 28.w, vertical: 14.h)),
//                               maxLines: 1,
//                               minLines: 1,
//                               textCapitalization: TextCapitalization.words,
//                               validator: (val) {
//                                 if (val.isEmpty) {
//                                   return "Please select required Blood Group";
//                                 }
//                               },
//                               onSaved: (val) {
//                                 setState(() {
//                                   _requiredBloodGroup = val;
//                                 });
//                               },
//                             ),
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: "Required Units ",
//                               labelStyle: TextStyle(fontSize: 41.sp),
//                               border: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffff4757))),
//                               enabledBorder: OutlineInputBorder(
//                                   // borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Color(0xffdfe6e9))),
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 28.w, vertical: 14.h),
//                               counterText: "",
//                             ),
//                             maxLength: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Required Units";
//                               }
//                             },
//                             onSaved: (val) {
//                               _requiredUnits = int.parse(val);
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               _selectDate(context);
//                             },
//                             child: TextFormField(
//                               controller: _bloodRequiredDateController,
//                               enabled: false,
//                               decoration: InputDecoration(
//                                   labelText: "Blood Required Date *",
//                                   labelStyle: TextStyle(fontSize: 41.sp),
//                                   enabled: true,
//                                   counterText: "",
//                                   errorStyle: TextStyle(
//                                     color: Theme.of(context)
//                                         .errorColor, // or any other color
//                                   ),
//                                   border: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffff4757))),
//                                   enabledBorder: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffdfe6e9))),
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 28.w, vertical: 14.h)),
//                               maxLength: 1,
//                               textCapitalization: TextCapitalization.words,
//                               validator: (val) {
//                                 if (val.isEmpty) {
//                                   return "Blood Required Date*";
//                                 }
//                               },
//                             ),
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               _selectTime(context);
//                             },
//                             child: TextFormField(
//                               enabled: false,
//                               controller: _bloodRequiredTimeController,
//                               decoration: InputDecoration(
//                                   labelText: "Blood Required Time *",
//                                   labelStyle: TextStyle(fontSize: 41.sp),
//                                   enabled: true,
//                                   errorStyle: TextStyle(
//                                     color: Theme.of(context)
//                                         .errorColor, // or any other color
//                                   ),
//                                   border: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffff4757))),
//                                   enabledBorder: OutlineInputBorder(
//                                       // borderRadius: BorderRadius.circular(8),
//                                       borderSide:
//                                           BorderSide(color: Color(0xffdfe6e9))),
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 28.w, vertical: 14.h)),
//                               maxLines: 1,
//                               minLines: 1,
//                               textCapitalization: TextCapitalization.words,
//                               validator: (val) {
//                                 if (val.isEmpty) {
//                                   return "Blood Required Time*";
//                                 }
//                               },
//                             ),
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Purpose *",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Your purpose";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _purpose = val;
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Hospital Name *",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Hospital Name*";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _hospitalName = val;
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Hospital City Name *",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Hospital City Name";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _hospitalCityName = val;
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Hospital Area Name *",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Hospital Area Name";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _hospitalAreaName = val;
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     bool serviceEnabled = await Geolocator
//                                         .isLocationServiceEnabled();
//                                     if (!serviceEnabled) {
//                                       _commonUtilFunctions
//                                           .openLocationSetting();
//                                     }
//                                     if (serviceEnabled) {
//                                       final res = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   SearchHospitalMapScreen()));
//                                       if (res != null) {
//                                         print(res);
//                                         setState(() {
//                                           _hospitalLocationDetails = res;
//                                           _hospitalLocationController.text =
//                                               _hospitalLocationDetails.address;
//                                         });
//                                       }
//                                     }
//                                   },
//                                   child: TextFormField(
//                                     controller: _hospitalLocationController,
//                                     decoration: InputDecoration(
//                                         labelText: "Hospital Location *",
//                                         labelStyle: TextStyle(fontSize: 41.sp),
//                                         enabled: false,
//                                         errorStyle: TextStyle(
//                                           color: Theme.of(context)
//                                               .errorColor, // or any other color
//                                         ),
//                                         border: OutlineInputBorder(
//                                             // borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide(
//                                                 color: Color(0xffff4757))),
//                                         enabledBorder: OutlineInputBorder(
//                                             // borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide(
//                                                 color: Color(0xffdfe6e9))),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 28.w, vertical: 14.h)),
//                                     maxLines: 3,
//                                     minLines: 1,
//                                     textCapitalization:
//                                         TextCapitalization.words,
//                                     validator: (val) {
//                                       if (val.isEmpty) {
//                                         return "Please select hospital location";
//                                       }
//                                     },
//                                     onSaved: (val) {
//                                       setState(() {
//                                         _hospitalLocation = val;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Hospital Room Number",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Enter Hospital Room Number";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _hospitalRoomNumber = int.parse(val);
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             maxLength: 10,
//                             decoration: InputDecoration(
//                                 labelText:
//                                     "Patient Attender Contact Number 1 *",
//                                 labelStyle: TextStyle(fontSize: 43.sp),
//                                 counterText: "",
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             validator: (val) {
//                               if (val.isEmpty) {
//                                 return "Required";
//                               }
//                             },
//                             onSaved: (val) {
//                               setState(() {
//                                 _attenderContact1 = val;
//                               });
//                             },
//                             keyboardType: TextInputType.phone,
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             maxLength: 10,
//                             decoration: InputDecoration(
//                                 labelText: "Patient Attender Contact Number 2",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 counterText: "",
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             onSaved: (val) {
//                               setState(() {
//                                 _attenderContact2 = val;
//                               });
//                             },
//                             keyboardType: TextInputType.phone,
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             maxLength: 10,
//                             decoration: InputDecoration(
//                                 labelText: "Patient Attender Contact Number 3",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 counterText: "",
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 14.h)),
//                             readOnly: false,
//                             maxLines: 1,
//                             minLines: 1,
//                             textCapitalization: TextCapitalization.words,
//                             onSaved: (val) {
//                               setState(() {
//                                 _attenderContact3 = val;
//                               });
//                             },
//                             keyboardType: TextInputType.phone,
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(
//                                 labelText: "Other Details (Optional)",
//                                 labelStyle: TextStyle(fontSize: 41.sp),
//                                 enabled: true,
//                                 border: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffff4757))),
//                                 enabledBorder: OutlineInputBorder(
//                                     // borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Color(0xffdfe6e9))),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 28.w, vertical: 20.h)),
//                             maxLines: 5,
//                             textCapitalization: TextCapitalization.words,
//                             onSaved: (val) {
//                               setState(() {
//                                 _otherDetails = val;
//                               });
//                             },
//                             keyboardType: TextInputType.text,
//                           ),
//                           SizedBox(
//                             height: 33.h,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: FlatButton(
//                     color: CustomColor.red,
//                     onPressed: () async {
//                       if (_formKey.currentState.validate()) {
//                         _formKey.currentState.save();
//                         savePost();
//                         Flushbar(
//                           backgroundColor: Colors.black,
//                           icon: Icon(
//                             Icons.check,
//                             color: Colors.greenAccent,
//                           ),
//                           flushbarPosition: FlushbarPosition.TOP,
//                           flushbarStyle: FlushbarStyle.GROUNDED,
//                           title: "Your request has been posted successfully",
//                           duration: Duration(seconds: 3),
//                         )..show(context);
//                         print(
//                             "$_patientName\n$_age\n${_requiredBloodGrpController.text}\n$_purpose\n$_hospitalName\n$_hospitalCityName\n$_hospitalAreaName\n$_hospitalLocation\n$_hospitalRoomNumber\n$_attenderContact1\n$_attenderContact2\n$_attenderContact3\n$_otherDetails");
//                       }
//                     },
//                     child: Padding(
//                         padding: EdgeInsets.symmetric(vertical: 15),
//                         child: Text(
//                           "Post",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 47.sp,
//                               letterSpacing: 1),
//                         )),
//                   ))
//                 ],
//               ),
//             )
//           ],
//         ));
//   }
// }
