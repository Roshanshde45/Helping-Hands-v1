import 'dart:io';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/HomeScreen.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:bd_app/provider/time.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class UserBloodDetailScreen extends StatefulWidget {
  @override
  _UserBloodDetailScreenState createState() => _UserBloodDetailScreenState();
}

class _UserBloodDetailScreenState extends State<UserBloodDetailScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TextEditingController donatePurposeController = new TextEditingController();
  DateTime selectedDate;
  String uid;
  String dateDonated;
  String _name;
  Position _currentPosition;
  String _currentAddress;
  bool _notDonated = false;
  bool _agreedTerms = false;
  String bloodGrp;
  File _image;
  final picker = ImagePicker();
  int selected;
  String profileUrl;
  Time time;

  List<bool> arrayGrp = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

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

  List<String> listtype = ["Roshan", "Singh"];

  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final String formatted = serverFormater.format(date);
    return formatted;
  }

  Future<bool> chooseSourceImage(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Take Picture",
                  textAlign: TextAlign.start,
                ),
              ),
              content: Container(
                height: 420.h,
                padding:
                    EdgeInsets.only(left: 40.w, right: 40.w, bottom: 100.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImageCamera();
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 80,
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            Text("Camera"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        getImageFromGallery();
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_size_select_actual,
                              size: 80,
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            Text("Gallery"),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  Future<bool> deleteDialog(BuildContext context) {
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
                "Not agreed to T&C",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "You haven't agreed to our Terms & Condition without which we cannot let you proceed.",
                style: TextStyle(fontSize: 42.sp),
              ),
            ),
            contentPadding: EdgeInsets.all(28.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    color: CustomColor.red,
                    onPressed: () {
                      print("OK");
                      Navigator.of(context).pop();
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

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
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
    print(_currentPosition.latitude);
  }

  Future<void> saveData() async {
    String uid;
    String deviceToken;
    String phone;
    String url;
    uid = FirebaseAuth.instance.currentUser.uid;
    phone = FirebaseAuth.instance.currentUser.phoneNumber;
    try {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        deviceToken = await getToken();
        if (_image != null) {
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = storage
              .ref()
              .child("profileImg" + time.getCurrentTime().toString());
          UploadTask uploadTask = ref.putFile(_image);
          uploadTask.then((res) {
            res.ref.getDownloadURL().then((value) {
              databaseReference.child("Users").child(uid).set({
                "name": _name,
                "profilePic": value,
                "bloodGrp": bloodGrp,
                "lastDonated": dateDonated,
                "notDonated": _notDonated,
                "deviceToken": deviceToken,
                // "latLng": [_currentPosition.latitude,_currentPosition.longitude],
                "uid": uid,
                "phone": phone,
              }).then((value) => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                  (route) => false));
              print(
                  "$_name\n$url\n$bloodGrp\n$dateDonated\n$_notDonated\n${_currentPosition.latitude}\n${_currentPosition.longitude}");
            });
          });
        } else {
          //Saving data
          databaseReference.child("Users").child(uid).set({
            "name": _name,
            "profilePic": url,
            "bloodGrp": bloodGrp,
            "lastDonated": dateDonated,
            "notDonated": _notDonated,
            "deviceToken": deviceToken,
            // "latLng": [_currentPosition.latitude,_currentPosition.longitude],
            "uid": uid,
            "phone": phone,
          }).then((value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //
  // Future<Widget> myBottomSheet(BuildContext context) {
  //   return showModalBottomSheet(
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(topLeft: Radius.circular(17),topRight: Radius.circular(17))
  //       ),
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) {
  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setMode /*You can rename this!*/) {
  //               return Padding(
  //                   padding: MediaQuery.of(context).viewInsets,
  //                 child: Container(
  //                   padding: EdgeInsets.all(66.w),
  //                   height: 800.h,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       SizedBox(height: 20.h,),
  //                         Text("Last Donated",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 60.sp),),
  //                         SizedBox(height: 10.h,),
  //                         // Text(DateFormat.yMMMMEEEEd().format(time.getCurrentTime()()),style: TextStyle(color: CustomColor.grey),),
  //                       SizedBox(height: 20.h,),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           RaisedButton(onPressed: _notDonated != true ? () async{
  //                             String lastDoTimeStamp;
  //                             final DateTime picked = await showDatePicker(
  //                                 context: context,
  //                                 initialDate: selectedDate,
  //                                 firstDate: DateTime(1950, 1),
  //                                 lastDate: time.getCurrentTime()());
  //                             if (picked != null && picked != selectedDate){
  //                               lastDoTimeStamp = Timestamp.fromDate(picked).seconds.toString();
  //                               setMode(() {
  //                                 selectedDate = picked;
  //                                 dateDonated = lastDoTimeStamp;
  //                               });
  //                             }
  //                           }:(){},
  //                             child: Row(
  //                               children: [
  //                                 Icon(Icons.calendar_today_outlined,size:15,color: Colors.white,),
  //                                 SizedBox(width: 16.w,),
  //                                 dateDonated != null ? Text(convertDateTimeDisplay(int.parse(dateDonated)).toString(),style: TextStyle(color: Colors.white,fontSize: 38.sp,fontWeight: FontWeight.bold),):
  //                                 _notDonated != true ? Text("Select Date",style: TextStyle(color: Colors.white,fontSize: 38.sp,fontWeight: FontWeight.bold)):
  //                                 Text("Not Donated",style: TextStyle(color: Colors.white,fontSize: 38.sp,fontWeight: FontWeight.bold))
  //                               ],
  //                             ),
  //                             color: _notDonated != false ? CustomColor.grey:CustomColor.red,
  //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //                           ),
  //
  //                           // dateDonated == "None" ? Container():Text(dateDonated.toString(),style: TextStyle(fontSize: 42.sp,color: Colors.green,fontWeight: FontWeight.w600),)
  //                         ],
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           Checkbox(value: _notDonated, onChanged: (val) {
  //                             setMode(() {
  //                               _notDonated = val;
  //                               dateDonated = null;
  //                             });
  //                           }),
  //                           Text("I have not donated in the last 3 months")
  //                         ],
  //                       ),
  //                       SizedBox(height: 50.h,),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: FlatButton(
  //                               color: CustomColor.red,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(10)
  //                                 ),
  //                                 onPressed: (){
  //                                 Navigator.pop(context);
  //                                 },
  //                                 child: Text("Confirm",style: TextStyle(color: Colors.white),)
  //                             ),
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             });
  //       });
  // }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
  }

  void selectedGrpFunc(int j) {
    for (var i = 0; i <= 7; i++) {
      setState(() {
        bloodGroups[i]["colorBool"] = false;
      });
      print(bloodGroups[i]["colorBool"]);
    }
    print("Done Loop");
    setState(() {
      bloodGroups[j]["colorBool"] = !bloodGroups[j]["colorBool"];
      bloodGrp = bloodGroups[j]["bloodGrp"];
    });
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(
        message: 'Please wait ...',
        borderRadius: 6.0,
        backgroundColor: Colors.white,
        progressWidget: Container(
          child: SpinKitRing(
            size: 45,
            color: CustomColor.red,
            lineWidth: 2.3,
          ),
          height: 20,
          width: 20,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Scaffold(
        key: scaffoldKey,
        body: time.offset == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.all(60.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              chooseSourceImage(context);
                            },
                            child: Container(
                              height: 330.h,
                              width: 330.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: CustomColor.grey,
                                      blurRadius: 5.0,
                                    ),
                                  ]),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: _image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(80),
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                              height: 325.h,
                                              width: 325.w,
                                            ))
                                        : Image.asset(
                                            "images/person.png",
                                            color: CustomColor.red,
                                          ),
                                  ),
                                  _image == null
                                      ? Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10.w),
                                              child: Icon(
                                                Icons.camera_alt_rounded,
                                                color: CustomColor.red,
                                              )))
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70.h,
                          ),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter Your Name";
                                }
                              },
                              onSaved: (val) {
                                setState(() {
                                  _name = val;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: "Your Name",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 14.h),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7))),
                            ),
                          ),
                          SizedBox(
                            height: 90.h,
                          ),
                          Text(
                            "Select your blood group",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ),
                          Text(
                            "You can't change your blood group later",
                            style: TextStyle(
                                fontSize: 13, color: CustomColor.grey),
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            width: 700.w,
                            child: Wrap(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: bloodGroups
                                    .map((e) => GestureDetector(
                                          onTap: () {
                                            selectedGrpFunc(
                                                bloodGroups.indexOf(e));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 30.w, top: 30.h),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 130.h,
                                              width: 130.w,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: CustomColor.red),
                                                  color: bloodGroups[bloodGroups
                                                              .indexOf(e)]
                                                          ["colorBool"]
                                                      ? CustomColor.red
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Text(
                                                bloodGroups[bloodGroups
                                                    .indexOf(e)]["bloodGrp"],
                                                style: TextStyle(
                                                    color: bloodGroups[
                                                            bloodGroups.indexOf(
                                                                e)]["colorBool"]
                                                        ? Colors.white
                                                        : CustomColor.red,
                                                    fontSize: 53.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList()),
                          ),
                          SizedBox(
                            height: 85.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              // myBottomSheet(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Last Donated",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Icon(Icons.calendar_today, size: 17)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "You cannot change your last donated date later",
                            style: TextStyle(
                                color: CustomColor.grey, fontSize: 32.sp),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                onPressed: _notDonated != true
                                    ? () async {
                                        String lastDonatedTimeStamp;
                                        final DateFormat formatter =
                                            DateFormat('yyyy-MM-dd');

                                        final DateTime picked =
                                            await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    time.getCurrentTime(),
                                                firstDate: DateTime(1950, 1),
                                                lastDate:
                                                    time.getCurrentTime());
                                        if (picked != null &&
                                            picked != selectedDate)
                                          lastDonatedTimeStamp =
                                              Timestamp.fromDate(picked)
                                                  .seconds
                                                  .toString();
                                        // final String formatted = formatter.format(now);
                                        setState(() {
                                          selectedDate = picked;
                                          // _lastDonatedController.text = DateFormat('dd-MM-yyyy').format(picked);
                                          dateDonated = lastDonatedTimeStamp;
                                        });
                                      }
                                    : () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22.w,
                                    ),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 16.w,
                                    ),
                                    selectedDate != null
                                        ? Text(
                                            DateFormat('dd-MM-yyyy')
                                                .format(selectedDate),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 38.sp,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : _notDonated != true
                                            ? Text("Select Date",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 38.sp,
                                                    fontWeight:
                                                        FontWeight.bold))
                                            : Text("Not Donated",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 38.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                    SizedBox(
                                      width: 22.w,
                                    ),
                                  ],
                                ),
                                color: _notDonated != false
                                    ? CustomColor.grey
                                    : CustomColor.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              !_notDonated
                                  ? IconButton(
                                      icon: Icon(Icons.delete_outline_rounded),
                                      onPressed: () {
                                        setState(() {
                                          selectedDate = null;
                                          _notDonated = false;
                                        });
                                      })
                                  : Container()
                              // dateDonated == "None" ? Container():Text(dateDonated.toString(),style: TextStyle(fontSize: 42.sp,color: Colors.green,fontWeight: FontWeight.w600),)
                            ],
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          selectedDate == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: _notDonated,
                                        onChanged: (val) {
                                          setState(() {
                                            _notDonated = val;
                                            dateDonated = null;
                                          });
                                        }),
                                    Text(
                                      "I have not donated in the last 3 months",
                                      style: TextStyle(fontSize: 35.sp),
                                    )
                                  ],
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                  value: _agreedTerms,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreedTerms = val;
                                    });
                                  }),
                              RichText(
                                  text: TextSpan(
                                      text: "I agree ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 35.sp),
                                      children: [
                                    TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(
                                            color: Colors.deepPurpleAccent,
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 35.sp))
                                  ]))
                            ],
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
                            print(_agreedTerms);
                            await pr.show();
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              if (_agreedTerms == true) {
                                saveData();
                              } else {
                                pr.hide();
                                deleteDialog(context);
                              }
                            } else {
                              pr.hide();
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 17),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 47.sp),
                              )),
                        ))
                      ],
                    ),
                  )
                ],
              ));
  }
}
