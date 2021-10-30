// import 'dart:io';
// import 'package:bd_app/provider/time.dart';
// import 'package:bd_app/services/CommonUtilFuctions.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_screenutil/size_extension.dart';
// import 'package:bd_app/Widgets/CustomMadeButton.dart';
// import 'package:bd_app/provider/server.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:simple_tooltip/simple_tooltip.dart';

// class BottomForm extends StatefulWidget {
//   DocumentSnapshot snapshot;
//   Map<String, dynamic> userData;
//   BottomForm(this.snapshot, this.userData);
//   @override
//   _BottomFormState createState() => _BottomFormState();
// }

// class _BottomFormState extends State<BottomForm> {
//   int radioValue;
//   int units;
//   bool showToolTip = false;
//   DateTime selectedDate;
//   TextEditingController _dobController = new TextEditingController();
//   Notify _notify;
//   File _image;
//   final picker = ImagePicker();
//   DateTime _firstDate = DateTime(2000);
//   CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
//   Time time;

//   Future getImageCamera() async {
//     final pickedFile =
//         await picker.getImage(source: ImageSource.camera, imageQuality: 25);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   void isEligible() async {
//     _firstDate = DateTime(2000);
//     List<Timestamp> lastDates = [];
//     if (widget.userData["lastDonated"] != null) {
//       lastDates.add(widget.userData["lastDonated"]);
//     } else {
//       lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
//           DateTime(2000).millisecondsSinceEpoch));
//     }

//     if (widget.userData["lastPlasmaDonated"] != null) {
//       lastDates.add(widget.userData["lastPlasmaDonated"]);
//     } else {
//       lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
//           DateTime(2000).millisecondsSinceEpoch));
//     }

//     if (widget.userData["lastPlateletsDonated"] != null) {
//       lastDates.add(widget.userData["lastPlateletsDonated"]);
//     } else {
//       lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
//           DateTime(2000).millisecondsSinceEpoch));
//     }

//     List<Timestamp> temp = List.from(lastDates);
//     print(lastDates);
//     temp.sort((a, b) => a.compareTo(b));
//     print(temp);
//     int index = lastDates.indexOf(temp[2]);

//     String lastDonated;

//     if (index == 0) {
//       lastDonated = "Blood";
//     } else if (index == 1) {
//       lastDonated = "Plasma";
//     } else if (index == 2) {
//       lastDonated = "Platelets";
//     }

//     print("lastDonated" + lastDonated);

//     if (radioValue == 1) {
//       _firstDate = lastDates[index]
//           .toDate()
//           .add(Duration(days: _notify.dynamicValue[lastDonated + "ToBlood"]));

//       print("index" + radioValue.toString());
//       // if (_notify.userData["lastDonated"] != null) {
//       //   DateTime _temp = DateTime.fromMillisecondsSinceEpoch(
//       //       _notify.userData["lastDonated"].millisecondsSinceEpoch);
//       //   _firstDate =
//       //       _temp.add(Duration(days: _notify.dynamicValue["BloodToBlood"]));
//       // }
//     }

//     if (radioValue == 2) {
//       _firstDate = lastDates[index]
//           .toDate()
//           .add(Duration(days: _notify.dynamicValue[lastDonated + "ToPlasma"]));

//       print("index" + radioValue.toString());
//     }

//     if (radioValue == 3) {
//       _firstDate = lastDates[index].toDate().add(
//           Duration(days: _notify.dynamicValue[lastDonated + "ToPlatelets"]));

//       print("index" + radioValue.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _notify = Provider.of<Notify>(context, listen: false);
//     time = Provider.of<Time>(context);
//     return time.offset == null
//         ? Container(
//             child: CircularProgressIndicator(),
//           )
//         : Container(
//             height: 250,
//             color: Colors.white,
//             padding: EdgeInsets.all(8),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Radio(
//                           value: 1,
//                           groupValue: radioValue,
//                           onChanged: (value) async {
//                             selectedDate = null;
//                             _dobController.clear();
//                             radioValue = 1;
//                             isEligible();
//                             if (_firstDate.millisecondsSinceEpoch >=
//                                 time.getCurrentTime().millisecondsSinceEpoch) {
//                               await Fluttertoast.showToast(
//                                   msg: "You can only donate blood after" +
//                                       DateFormat('dd MMM yyyy')
//                                           .format(_firstDate),
//                                   toastLength: Toast.LENGTH_LONG,
//                                   gravity: ToastGravity.BOTTOM,
//                                   // timeInSecForIosWeb: 1,
//                                   backgroundColor: Colors.red,
//                                   textColor: Colors.yellow,
//                                   fontSize: 16.0);
//                               setState(() {
//                                 radioValue = null;
//                               });
//                             } else {
//                               setState(() {
//                                 radioValue = value;
//                               });
//                             }
//                           }),
//                       Text("Blood"),
//                       Radio(
//                           value: 2,
//                           groupValue: radioValue,
//                           onChanged: (value) async {
//                             selectedDate = null;
//                             _dobController.clear();
//                             radioValue = 2;
//                             isEligible();
//                             if (_firstDate.millisecondsSinceEpoch >
//                                 time.getCurrentTime().millisecondsSinceEpoch) {
//                               await Fluttertoast.showToast(
//                                   msg: "You can only donate plasma after " +
//                                       DateFormat('dd MMM yyyy')
//                                           .format(_firstDate),
//                                   toastLength: Toast.LENGTH_LONG,
//                                   gravity: ToastGravity.CENTER,
//                                   // timeInSecForIosWeb: 1,
//                                   backgroundColor: Colors.grey,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                               setState(() {
//                                 radioValue = null;
//                               });
//                             } else {
//                               setState(() {
//                                 radioValue = value;
//                               });
//                             }
//                           }),
//                       Text("Plasma"),
//                       Radio(
//                           value: 3,
//                           groupValue: radioValue,
//                           onChanged: (value) async {
//                             selectedDate = null;
//                             _dobController.clear();
//                             radioValue = 3;
//                             isEligible();
//                             if (_firstDate.millisecondsSinceEpoch >
//                                 time.getCurrentTime().millisecondsSinceEpoch) {
//                               await Fluttertoast.showToast(
//                                   msg: "You can only donate platelets after " +
//                                       DateFormat('dd MMM yyyy')
//                                           .format(_firstDate),
//                                   toastLength: Toast.LENGTH_LONG,
//                                   gravity: ToastGravity.CENTER,
//                                   // timeInSecForIosWeb: 1,
//                                   backgroundColor: Colors.grey,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                               setState(() {
//                                 radioValue = null;
//                               });
//                             } else {
//                               setState(() {
//                                 radioValue = value;
//                               });
//                             }
//                           }),
//                       Text("Platelets"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Radio(
//                           value: 1,
//                           groupValue: units,
//                           onChanged: (value) {
//                             setState(() {
//                               units = value;
//                             });
//                           }),
//                       Text("1"),
//                       Radio(
//                           value: 2,
//                           groupValue: units,
//                           onChanged: (value) {
//                             setState(() {
//                               units = value;
//                             });
//                           }),
//                       Text("2"),
//                       Radio(
//                           value: 3,
//                           groupValue: units,
//                           onChanged: (value) {
//                             setState(() {
//                               units = value;
//                             });
//                           }),
//                       Text("3"),
//                     ],
//                   ),
//                   RaisedButton(
//                     onPressed: () {
//                       getImageCamera();
//                     },
//                     child: Text(
//                       _image == null ? "click photo" : _image.path,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   // radioValue != null
//                   //     ? Row(
//                   //         children: [
//                   //           Expanded(
//                   //             child: GestureDetector(
//                   //               onTap: () {
//                   //                 _selectDate(context);
//                   //               },
//                   //               child: TextFormField(
//                   //                 enabled: false,
//                   //                 controller: _dobController,
//                   //                 decoration: InputDecoration(
//                   //                   labelText: "Date of Birth",
//                   //                   labelStyle: TextStyle(fontSize: 41.sp),
//                   //                   errorStyle: TextStyle(
//                   //                     color: Theme.of(context)
//                   //                         .errorColor, // or any other color
//                   //                   ),
//                   //                   border: OutlineInputBorder(
//                   //                       // borderRadius: BorderRadius.circular(8),
//                   //                       borderSide:
//                   //                           BorderSide(color: Color(0xffff4757))),
//                   //                   enabledBorder: OutlineInputBorder(
//                   //                       // borderRadius: BorderRadius.circular(8),
//                   //                       borderSide:
//                   //                           BorderSide(color: Color(0xffdfe6e9))),
//                   //                   contentPadding: EdgeInsets.symmetric(
//                   //                       horizontal: 28.w, vertical: 14.h),
//                   //                 ),
//                   //                 readOnly: false,
//                   //                 maxLines: 1,
//                   //                 minLines: 1,
//                   //                 textCapitalization: TextCapitalization.words,
//                   //                 validator: (val) {
//                   //                   if (val.isEmpty) {
//                   //                     return "Select your date of birth";
//                   //                   }
//                   //                 },
//                   //               ),
//                   //             ),
//                   //           ),
//                   //           SimpleTooltip(
//                   //             animationDuration: Duration(seconds: 1),
//                   //             hideOnTooltipTap: true,
//                   //             borderColor: Colors.white,
//                   //             show: showToolTip,
//                   //             tooltipDirection: TooltipDirection.horizontal,
//                   //             content: Text(
//                   //               "This information is used to determine the services available for your account",
//                   //               style: TextStyle(
//                   //                 color: Colors.black,
//                   //                 fontSize: 10,
//                   //                 decoration: TextDecoration.none,
//                   //               ),
//                   //             ),
//                   //             child: IconButton(
//                   //               icon: Icon(
//                   //                 Icons.help_outlined,
//                   //                 color: Colors.black,
//                   //               ),
//                   //               onPressed: () {
//                   //                 setState(() {
//                   //                   showToolTip = !showToolTip;
//                   //                 });
//                   //               },
//                   //             ),
//                   //           )
//                   //         ],
//                   //       )
//                   //     : Container(),
//                   CustomMadeButton(
//                     onPress: () async {
//                       if (radioValue != null &&
//                           units != null &&
//                           _image != null) {
//                         String _url;
//                         _commonUtilFunctions.loadingCircle("Please wait...");
//                         FirebaseStorage storage = FirebaseStorage.instance;
//                         Reference ref = storage.ref().child("Donation").child(
//                             widget.snapshot.id +
//                                 FirebaseAuth.instance.currentUser.uid +
//                                 DateFormat("yyyy mmm dd")
//                                     .format(time.getCurrentTime()));
//                         UploadTask uploadTask = ref.putFile(_image);
//                         await uploadTask.then((res) async {
//                           _url = await res.ref.getDownloadURL();
//                         });
//                         List<String> donatedType = [
//                           "Blood",
//                           "Plasma",
//                           "Platelets"
//                         ];
//                         if (_url != null) {
//                           FirebaseFirestore.instance
//                               .collection("Post")
//                               .doc(widget.snapshot.id)
//                               .update({
//                             "donationRequest": FieldValue.arrayUnion([
//                               {
//                                 FirebaseAuth.instance.currentUser.uid: {
//                                   "time": time.getCurrentTimeStamp(),
//                                   "imageUrl": _url,
//                                   "donatedUnits": units,
//                                   "donated": donatedType[radioValue - 1],
//                                   "location": GeoPoint(_notify.currLoc.latitude,
//                                       _notify.currLoc.longitude)
//                                 },
//                               }
//                             ])
//                           });
//                           _notify.notify();
//                           Get.back();
//                           Get.back();
//                         } else {
//                           Get.back();
//                           Get.back();
//                           showError(context);
//                         }
//                       }
//                     },
//                     buttonText: "Donated",
//                     color:
//                         (radioValue != null && units != null && _image != null)
//                             ? Colors.red
//                             : Colors.grey,
//                   )
//                 ],
//               ),
//             ),
//           );
//   }

//   Future<bool> showError(BuildContext context) {
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
//                 "Error",
//                 textAlign: TextAlign.start,
//               ),
//             ),
//             content: Padding(
//               padding: EdgeInsets.only(left: 12),
//               child: Text(
//                 "There is some error!",
//                 style: TextStyle(fontSize: 42.sp, color: Colors.grey),
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
//                       "Ok",
//                       style: TextStyle(color: Colors.red, fontSize: 50.sp),
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

//   // Future<void> _selectDate(BuildContext context) async {
//   //   // if (radioValue == 1) {
//   //   //   if (_notify.userData["lastDonated"] != null) {
//   //   //     DateTime _temp = DateTime.fromMillisecondsSinceEpoch(
//   //   //         _notify.userData["lastDonated"].millisecondsSinceEpoch);
//   //   //     _firstDate =
//   //   //         _temp.add(Duration(days: _notify.dynamicValue["BloodToBlood"]));
//   //   //   }
//   //   // }

//   //   // if (radioValue == 2) {
//   //   //   if (_notify.userData["lastPlasmaDonated"] != null) {
//   //   //     DateTime _temp = DateTime.fromMillisecondsSinceEpoch(
//   //   //         _notify.userData["lastPlasmaDonated"].millisecondsSinceEpoch);
//   //   //     _firstDate =
//   //   //         _temp.add(Duration(days: _notify.dynamicValue["BloodToBlood"]));
//   //   //   }
//   //   // }

//   //   // if (radioValue == 3) {
//   //   //   if (_notify.userData["lastPlateletsDonated"] != null) {
//   //   //     DateTime _temp = DateTime.fromMillisecondsSinceEpoch(
//   //   //         _notify.userData["lastPlateletsDonated"].millisecondsSinceEpoch);
//   //   //     _firstDate =
//   //   //         _temp.add(Duration(days: _notify.dynamicValue["BloodToBlood"]));
//   //   //   }
//   //   // }

//   //   final DateTime picked = await showDatePicker(
//   //       errorInvalidText: "Minimum age should be 18 years.",
//   //       context: context,
//   //       initialDate: selectedDate ?? time.getCurrentTime()(),
//   //       firstDate: _firstDate,
//   //       lastDate: time.getCurrentTime()());
//   //   if (picked != null && picked != selectedDate)
//   //     setState(() {
//   //       selectedDate = picked;
//   //       // selectedDateOfBirth = picked;
//   //       // dobTimestamp = Timestamp.fromDate(picked);
//   //       _dobController.text = DateFormat('yMMMd').format(picked);
//   //     });
//   // }
// }
