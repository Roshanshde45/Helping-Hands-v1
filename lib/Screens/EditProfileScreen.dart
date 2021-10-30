import 'dart:io';

import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PostBloodRequirement.dart';
import 'package:bd_app/provider/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  DateTime selectedDate;
  final picker = ImagePicker();

  File _image;
  bool FirstTimeUser = false;
  String _lastDonated, _phone;
  String uid;
  bool loaded = false;
  String imageUrl;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _bloodGrpController = new TextEditingController();
  TextEditingController _lastDonatedController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _emergency1Controller = new TextEditingController();
  TextEditingController _emergency2Controller = new TextEditingController();
  TextEditingController _otherDetailsController = new TextEditingController();
  String _name, _emergency1, _emergency2, _otherDetails;
  Timestamp _dobTs;

  void getData() async {
    await databaseReference.child("Users").once().then((DataSnapshot snapshot) {
      _nameController.text = snapshot.value[uid]["name"];
      _bloodGrpController.text = snapshot.value[uid]["bloodGrp"];
      if (snapshot.value[uid]["lastDonated"] == null) {
        _lastDonatedController.text = "Didn't donate in last 3 months";
      } else {
        _lastDonatedController.text =
            convertDateTimeDisplay(snapshot.value[uid]["lastDonated"]);
      }
      print(snapshot.value[uid]["dob"]);
      if (snapshot.value[uid]["dob"] != null) {
        _dobController.text =
            convertDateTimeDisplay(snapshot.value[uid]["dob"]);
      }
      print(snapshot.value[uid]["emergency1"]);
      if (snapshot.value[uid]["emergency1"] != null) {
        _emergency1Controller.text = snapshot.value[uid]["emergency1"];
      }
      print(snapshot.value[uid]["emergency2"]);
      if (snapshot.value[uid]["emergency2"] != null) {
        _emergency2Controller.text = snapshot.value[uid]["emergency2"];
      }
      print(snapshot.value[uid]["otherDetails"]);
      if (snapshot.value[uid]["otherDetails"] != null) {
        _otherDetailsController.text = snapshot.value[uid]["otherDetails"];
      }

      print(snapshot.value[uid]["name"]);
      print(snapshot.value[uid]["bloodGrp"]);
      print(snapshot.value[uid]["lastDonated"]);
      print(snapshot.value[uid]["dob"]);
      print(snapshot.value[uid]["emergency1"]);
      print(snapshot.value[uid]["emergency2"]);
      print(snapshot.value[uid]["otherDetails"]);
      setState(() {
        imageUrl = snapshot.value[uid]["profilePic"];
        loaded = true;
      });
    });
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

  Future<void> saveData() async {
    try {
      if (_image != null) {
      } else {
        await databaseReference.child("Users").child(uid).update({
          "name": _name,
          "dob": _dobTs.seconds.toString(),
          "emergency1": _emergency1,
          "emergency2": _emergency2,
          "otherDetails": _otherDetails,
        });
      }
      Navigator.pop(context, "Done");
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
    // print("$_name\n$_dob\n$_emergency1\n$_emergency2\n$_otherDetails");
  }

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat serverFormatter = DateFormat('yMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

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
                "Post Requirement?",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "For posting requirements firstly you have to fill your details in Your Profile.",
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
                      Navigator.pop(context);
                      // Navigator.pop(context);
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

  @override
  void initState() {
    Time _time2;
    _time2 = Provider.of<Time>(context, listen: false);
    if (_time2.offset != null) {
      selectedDate = _time2.getCurrentTime();
    }
    uid = FirebaseAuth.instance.currentUser.uid;
    print(uid);
    _phoneController.text = FirebaseAuth.instance.currentUser.phoneNumber;
    super.initState();
    getData();
    print("Image URL: $imageUrl");
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: CustomColor.red,
          actions: [
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: _signOut),
          ],
          // elevation: 1,
          title: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            loaded
                ? SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(60.w),
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            height: 330.h,
                            width: 330.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(300),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomColor.grey,
                                    blurRadius: 5.0,
                                  ),
                                ]),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    chooseSourceImage(context);
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: imageUrl != null
                                          ? FadeInImage.assetNetwork(
                                              placeholder: "images/person.png",
                                              image: imageUrl,
                                              height: 345.h,
                                              width: 325.h,
                                              fit: BoxFit.cover,
                                            )
                                          : _image != null
                                              ? Image.file(
                                                  _image,
                                                  fit: BoxFit.cover,
                                                  height: 325.h,
                                                  width: 325.w,
                                                )
                                              : Image.asset(
                                                  "images/person.png",
                                                  height: 300.h,
                                                ),
                                    ),
                                  ),
                                ),
                                imageUrl == null
                                    ? Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.w),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: CustomColor.red,
                                            )))
                                    : Container()
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Your Name",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      enabled: false,
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
                                  readOnly: false,
                                  controller: _nameController,
                                  maxLines: 1,
                                  minLines: 1,
                                  textCapitalization: TextCapitalization.words,
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
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      labelText: "Your Date of Birth",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      suffixIcon: Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _dobController,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return "Provide your date of birth";
                                    }
                                  },
                                  style: TextStyle(fontSize: 41.sp),
                                  readOnly: true,
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Blood Group",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      enabled: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _bloodGrpController,
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Last Donated",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      enabled: false,
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _lastDonatedController,
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  controller: _emergency1Controller,
                                  decoration: InputDecoration(
                                      labelText: "Emergency 1",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      counterText: "",
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  maxLength: 10,
                                  keyboardType: TextInputType.phone,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return "One Emergency Number is madatory";
                                    } else if (val.length < 10) {
                                      return "Enter Valid Number";
                                    }
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _emergency1 = val;
                                    });
                                  },
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  controller: _emergency2Controller,
                                  decoration: InputDecoration(
                                      labelText: "Emergency 2",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      counterText: "",
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  maxLength: 10,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    if (val.length < 10) {
                                      return "Enter Valid Number";
                                    }
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _emergency2 = val;
                                    });
                                  },
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 36.h,
                                ),
                                TextFormField(
                                  controller: _otherDetailsController,
                                  decoration: InputDecoration(
                                      labelText: "Other Details",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 20.h)),
                                  textCapitalization: TextCapitalization.words,
                                  maxLines: 4,
                                  onSaved: (val) {
                                    setState(() {
                                      _otherDetails = val;
                                    });
                                  },
                                  style: TextStyle(fontSize: 41.sp),
                                ),
                                SizedBox(
                                  height: 33.h,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Contact Number",
                                      labelStyle: TextStyle(fontSize: 41.sp),
                                      border: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffff4757))),
                                      enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xffdfe6e9))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 28.w, vertical: 16.h)),
                                  maxLines: 1,
                                  minLines: 1,
                                  enabled: false,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _phoneController,
                                  style: TextStyle(fontSize: 41.sp),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200.h,
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: SpinKitThreeBounce(
                      size: 23,
                      color: CustomColor.red,
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                      child: FlatButton(
                    color: CustomColor.red,
                    shape: RoundedRectangleBorder(),
                    onPressed: () async {
                      await pr.show();
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        saveData();
                        await pr.hide();
                      } else {
                        pr.hide();
                      }
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 17),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 47.sp,
                          ),
                        )),
                  ))
                ],
              ),
            ),
          ],
        ));
  }
}
