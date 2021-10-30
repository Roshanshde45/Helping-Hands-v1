import 'dart:io';
import 'dart:ui';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/OnBoardUser/referral.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:bd_app/Widgets/CustomMadeButton.dart';

class EditUserDetails extends StatefulWidget {
  String name, email;
  File file;
  Map<String, dynamic> data;

  EditUserDetails(this.data, [this.name, this.email, this.file]);

  @override
  _EditUserDetailsState createState() => _EditUserDetailsState();
}

class _EditUserDetailsState extends State<EditUserDetails> {
  TextEditingController _recoveredDateForCovid = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emergency1Controller = new TextEditingController();
  TextEditingController _emergency2Controller = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _requiredBloodGrpController =
      new TextEditingController();
  Timestamp dobTimestamp, lastDonatedTimestamp;
  DateTime selectedDate,
      selectedLastDonatedDate,
      selectedLastPlasmaDonatedDate,
      selectedLastPlateletsDate;
  File _image;
  Notify _notify;
  final picker = ImagePicker();
  bool expansionList1 = false;
  bool expansionList2 = false;
  bool expansionList3 = false;
  bool expansionList4 = false;
  bool expansionList5 = false;
  bool expansionList6 = false;
  bool expansionList7 = false;
  bool expansionList8 = false;
  bool donateBlood;
  bool donatePlasma;
  bool donatePlatlets;
  bool plasmaForCovid;
  bool gotCovid;
  bool showToolTip = false;
  bool anyGrp = false;
  String _name,
      _myBloodGrp,
      lastDonated,
      lastPlasmaDonated,
      lastPlateletsDonated,
      uid,
      phone;
  String gender;
  String bloodGrp;
  DateTime selectedCovidRecoveryDate;
  String name, phoneNumber, emergency1, emergency2;
  String errorText1,
      errorText2,
      errorText3,
      errorText4,
      errorText5,
      errorText6,
      errorText7,
      errorText8,
      errorText9;

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
  ];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();

  Future<void> saveData() async {
    String url;
    String defaultErrorText = "Mandatory Field*";
    // try {

    if (_formKey.currentState.validate()) {
      int count = 0;
      setState(() {
        if (lastDonated == null) {
          count++;
          errorText1 = defaultErrorText;
        } else {
          errorText1 = null;
        }

        if (donateBlood == null) {
          errorText2 = defaultErrorText;
          count++;
        } else {
          errorText2 = null;
        }

        if (lastPlasmaDonated == null) {
          count++;
          errorText3 = defaultErrorText;
        } else {
          errorText3 = null;
        }

        // if (gotCovid == null) {
        //   errorText4 = defaultErrorText + "4";
        //   count++;
        // } else {
        //   errorText4 = null;
        // }

        if (donatePlasma == null) {
          errorText5 = defaultErrorText;
          count++;
        } else {
          errorText5 = null;
        }
        if (donatePlatlets == null) {
          errorText6 = defaultErrorText;
          count++;
        } else {
          errorText6 = null;
        }
        if (lastPlateletsDonated == null) {
          errorText7 = defaultErrorText;
          count++;
        } else {
          errorText7 = null;
        }
        if (gender == null) {
          errorText9 = defaultErrorText;
          count++;
        } else {
          errorText9 = null;
        }
        // if (gotCovid) {
        //   if (plasmaForCovid == null) {
        //     errorText8 = defaultErrorText + "8";
        //     count++;
        //   } else {
        //     errorText8 = null;
        //   }
        // }
      });

      if (count == 0) {
        if (widget.data == null) {
          print("go");
          Get.back();
          Get.to(() => ReffaralPage(
                {
                  "name":
                      _commonUtilFunctions.firstCaptial(_nameController.text),
                  "email": widget.email,
                  "gender": _commonUtilFunctions.firstCaptial(gender),
                  // "userAddress": _userAddress,
                  "dob": dobTimestamp,
                  "bloodGrp": _myBloodGrp,
                  "emergency1": _emergency1Controller.text,
                  "emergency2": _emergency2Controller.text,
                  "lastDonated": selectedLastDonatedDate == null
                      ? null
                      : Timestamp.fromDate(selectedLastDonatedDate),
                  'donateBlood': donateBlood,
                  "lastPlasmaDonated": selectedLastPlasmaDonatedDate == null
                      ? null
                      : Timestamp.fromDate(selectedLastPlasmaDonatedDate),
                  "lastPlateletsDonated": selectedLastPlateletsDate == null
                      ? null
                      : Timestamp.fromDate(selectedLastPlateletsDate),
                  'gotCovid': gotCovid,
                  "covidRecoverDate": selectedCovidRecoveryDate == null
                      ? null
                      : Timestamp.fromDate(selectedCovidRecoveryDate),
                  'donatePlasma': donatePlasma,
                  'donatePlatlets': donatePlatlets,
                  'donatePlasmaForCovid': plasmaForCovid,
                  "lastOpened": FieldValue.serverTimestamp(),
                  "uid": uid,
                  "phone": phone,
                },
                _image,
              ));
        } else {
          String _url;
          if (_image != null) {
            String phone = FirebaseAuth.instance.currentUser.phoneNumber;
            _commonUtilFunctions.loadingCircle("Setting things up...");
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference ref = storage
                .ref()
                .child("Profile")
                .child(FirebaseAuth.instance.currentUser.uid);
            UploadTask uploadTask = ref.putFile(_image);
            await uploadTask.then((res) async {
              _url = await res.ref.getDownloadURL();
            });
            FirebaseFirestore.instance
                .collection("Profile")
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              "name": _commonUtilFunctions.firstCaptial(_nameController.text),
              "gender": gender,
              "profilePic": _url,
              "dob": dobTimestamp,
              "bloodGrp": _myBloodGrp,
              "emergency1": _emergency1Controller.text,
              "emergency2": _emergency2Controller.text,
              "lastDonated": selectedLastDonatedDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastDonatedDate),
              'donatePlatlets': donatePlatlets,
              'donatePlasmaForCovid': plasmaForCovid,
              'donateBlood': donateBlood,
              "lastPlasmaDonated": selectedLastPlasmaDonatedDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastPlasmaDonatedDate),
              "lastPlateletsDonated": selectedLastPlateletsDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastPlateletsDate),
              'gotCovid': gotCovid,
              "covidRecoverDate": selectedCovidRecoveryDate == null
                  ? null
                  : selectedCovidRecoveryDate.millisecondsSinceEpoch,
              'donatePlasma': donatePlasma,
              "lastOpened": FieldValue.serverTimestamp(),
              "uid": uid,
            });
            Get.back();
            Get.back();
            Get.back();
            _notify.notify();
          } else {
            FirebaseFirestore.instance
                .collection("Profile")
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              "name": _commonUtilFunctions.firstCaptial(_nameController.text),
              "gender": gender,
              // "userAddress": _userAddress,
              "dob": dobTimestamp,
              "bloodGrp": _myBloodGrp,
              "emergency1": _emergency1Controller.text,
              "emergency2": _emergency2Controller.text,
              "lastDonated": selectedLastDonatedDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastDonatedDate),
              'donatePlatlets': donatePlatlets,
              'donatePlasmaForCovid': plasmaForCovid,
              'donateBlood': donateBlood,
              "lastPlasmaDonated": selectedLastPlasmaDonatedDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastPlasmaDonatedDate),
              "lastPlateletsDonated": selectedLastPlateletsDate == null
                  ? null
                  : Timestamp.fromDate(selectedLastPlateletsDate),
              'gotCovid': gotCovid,
              "covidRecoverDate": selectedCovidRecoveryDate == null
                  ? null
                  : selectedCovidRecoveryDate.millisecondsSinceEpoch,
              'donatePlasma': donatePlasma,
              "lastOpened": FieldValue.serverTimestamp(),
              "uid": uid,
            });
            _notify.notify();
            Get.back();
            Get.back();
          }
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        errorInvalidText: "Minimum age should be 18 years.",
        context: context,
        initialDate: selectedDate ??
            DateTime(time.getCurrentTime().year - 18,
                time.getCurrentTime().month, time.getCurrentTime().day),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(time.getCurrentTime().year - 18,
            time.getCurrentTime().month, time.getCurrentTime().day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

        dobTimestamp = Timestamp.fromDate(picked);
        _dobController.text = DateFormat('yMMMd').format(picked);
      });
  }

  Future<DateTime> _selectLastDonatedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: time.getCurrentTime(),
        firstDate: DateTime(1950, 1),
        lastDate: time.getCurrentTime());
    if (picked != null) {
      // selectedLastDonatedDate = picked;
      // lastDonatedTimestamp = Timestamp.fromDate(picked).millisecondsSinceEpoch;
      // lastDonated = DateFormat('yMMMd').format(picked);
      // showError = false;
      return picked;
    }
    return null;
  }

  Future getImageCamera() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 25);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    Navigator.pop(context);
  }

  Future getImageFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 25);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    Navigator.pop(context);
  }

  Future<Widget> bottomSheetForImagePick() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18))),
        builder: (context) {
          return Container(
            padding: EdgeInsets.fromLTRB(80.w, 50.h, 30.w, 0),
            height: 580.h,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: 15.h,
                  width: 170.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: CustomColor.lightGrey,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        "Add Image",
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontWeight: FontWeight.bold,
                          // fontFamily: "OpenSans"
                        ),
                      ),
                      SizedBox(
                        height: 27.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0.w),
                        child: Container(
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: getImageCamera,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.h),
                                  child: Container(
                                      child: Row(
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 30,
                                        color: Color(0xff596275),
                                      ),
                                      SizedBox(
                                        width: 20.h,
                                      ),
                                      Text(
                                        "Camera",
                                        style: TextStyle(
                                          fontSize: 48.sp,
                                        ),
                                      )
                                    ],
                                  )),
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: getImageFromGallery,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.h),
                                  child: Container(
                                      child: Row(
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 30,
                                        color: Color(0xff596275),
                                      ),
                                      SizedBox(
                                        width: 20.h,
                                      ),
                                      Text(
                                        "Gallery",
                                        style: TextStyle(
                                          fontSize: 48.sp,
                                        ),
                                      )
                                    ],
                                  )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
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
                  "Upload Picture",
                  textAlign: TextAlign.start,
                ),
              ),
              content: Container(
                  height: 210,
                  padding:
                      EdgeInsets.only(left: 40.w, right: 40.w, bottom: 100.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              getImageCamera();
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "images/icons/camera.png",
                                    height: 70,
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                  Text("Camera"),
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                          GestureDetector(
                            onTap: () {
                              getImageFromGallery();
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "images/gallery.png",
                                    height: 70,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: CustomColor.lightGrey,
                                primary: Colors.black,
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )));
        });
  }

  Widget buildPhoto(BuildContext context) {
    // return GestureDetector(
    //   child: Container(
    //     height: 110,
    //     width: 110,
    //     decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(100),
    //         color: Colors.black,
    //         // shape: BoxShape.circle,
    //         boxShadow: [
    //           BoxShadow(
    //             color: CustomColor.grey,
    //             blurRadius: 5.0,
    //           ),
    //         ]),
    //     child: Stack(
    //       children: [
    //         Align(
    //           alignment: Alignment.center,
    //           child: (_image != null || widget.data != null)
    //               ? ClipRRect(
    //                   borderRadius: BorderRadius.circular(100),
    //                   child: (_image != null
    //                       ? Image.file(
    //                           _image,
    //                           fit: BoxFit.cover,
    //                           height: 110,
    //                         )
    //                       : CachedNetworkImage(
    //                           fit: BoxFit.cover,
    //                           height: 110,
    //                           imageUrl: widget.data["profilePic"],
    //                           placeholder: (context, url) {
    //                             return Image.asset(
    //                               "images/userbig.png",
    //                               color: CustomColor.grey[350],
    //                               height: 110,
    //                             );
    //                           },
    //                           errorWidget: (context, url, error) {
    //                             return Image.asset(
    //                               "images/userbig.png",
    //                               color: CustomColor.grey[350],
    //                               height: 110,
    //                             );
    //                           },
    //                         )),
    //                 )
    //               : Image.asset(
    //                   "images/userbig.png",
    //                   color: CustomColor.grey[350],
    //                   height: 110,
    //                 ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CustomColor.grey,
              blurRadius: 10.0,
              offset: Offset(0, 0),
            )
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        child: _image == null
            ? CachedNetworkImage(
                fit: BoxFit.fill,
                useOldImageOnUrlChange: true,
                imageUrl: widget.data["profilePic"],
                progressIndicatorBuilder: (context, url, _) {
                  return CircularProfileAvatar(
                    widget.data["profilePic"],
                    backgroundColor: Colors.white,
                    child: Shimmer.fromColors(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(42),
                              color: Colors.white),
                        ),
                        baseColor: CustomColor.grey,
                        highlightColor: CustomColor.lightGrey),
                  );
                },
              )
            : Image.file(
                _image,
                fit: BoxFit.cover,
                height: 110,
              ),
      ),
    );
  }

  Widget personalFormDetails() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 27.h,
            ),
            Text(
              "Personal Details",
              style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSans"),
            ),
            Divider(),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: _nameController,
              maxLength: 25,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomColor.lightGrey)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
                  labelText: "Full Name*",
                  labelStyle: TextStyle(fontSize: 38.sp)),
              validator: (val) {
                if (val.isEmpty) {
                  return "Please enter your full name";
                }
              },
            ),
            SizedBox(
              height: widget.data != null ? 0 : 30.h,
            ),
            widget.data == null
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: TextFormField(
                            enabled: false,
                            controller: _dobController,
                            decoration: InputDecoration(
                              labelText: "Date of Birth*",
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(fontSize: 41.sp),
                              errorStyle: TextStyle(
                                color: Theme.of(context)
                                    .errorColor, // or any other color
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColor.lightGrey)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 28.w, vertical: 14.h),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (val) {
                              if (val.isEmpty) {
                                return "please select your date of birth";
                              }
                            },
                          ),
                        ),
                      ),
                      // SimpleTooltip(
                      //   animationDuration: Duration(seconds: 1),
                      //   hideOnTooltipTap: true,
                      //   borderColor: Colors.white,
                      //   show: showToolTip,
                      //   tooltipDirection: TooltipDirection.horizontal,
                      //   content: Text(
                      //     "This information is used to determine the services available for your account",
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
                      // )
                    ],
                  )
                : Container(),
            SizedBox(
              height: widget.data != null ? 0 : 30.h,
            ),
            widget.data == null ? buildBloodGrup(context) : Container(),
            SizedBox(
              height: 27.h,
            ),
            TextFormField(
              controller: _emergency1Controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
                labelText: "Emergency Contact 1*",
                labelStyle: TextStyle(fontSize: 38.sp),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColor.lightGrey)),
                counterText: "",
              ),
              validator: (val) {
                if (val.isEmpty) {
                  return "One emergency contact is mandatory";
                } else if (val.length < 10) {
                  return "Invalid phone number";
                }
              },
              keyboardType: TextInputType.phone,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: 10,
            ),
            SizedBox(
              height: 30.h,
            ),
            TextFormField(
              controller: _emergency2Controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColor.lightGrey)),
                contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
                labelText: "Emergency Contact 2",
                labelStyle: TextStyle(fontSize: 38.sp),
                counterText: "",
              ),
              maxLength: 10,
              validator: (val) {
                if (val.isNotEmpty) {
                  if (val.length < 10) {
                    return "Enter valid number";
                  }
                }
              },
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(
              height: 30.h,
            ),
            widget.data == null
                ? buildDropDown("Gender*", buildPatientGender())
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildPatientGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList8 = !expansionList8;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: gender != null
                      ? Text(
                          gender,
                          style: TextStyle(color: Colors.black),
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
                            expansionList8 = !expansionList8;
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
                            expansionList8 = !expansionList8;
                            setState(() {
                              gender = "Female";
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                  // gender != "Prefer Not To Say"
                  //     ? ListTile(
                  //   title: Text("Prefer Not To Say"),
                  //   onTap: () {
                  //     expansionList8 = !expansionList8;
                  //     setState(() {
                  //       gender = "Prefer Not To Say";
                  //       // gotCovid = null;
                  //       // donatePlasma = null;
                  //     });
                  //   },
                  // )
                  // : Container(),
                ],
              ),
              isExpanded: expansionList8,
            ),
          ],
        ),
        errorText9 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText9,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildSlideMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (widget.data == null) expansionList1 = !expansionList1;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  // dense: true,
                  title: lastDonated != null
                      ? Text(lastDonated)
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  ListTile(
                    title: Text('Pick a date'),
                    subtitle: Text('Date in which you have last donated'),
                    onTap: () async {
                      selectedLastDonatedDate =
                          await _selectLastDonatedDate(context);
                      expansionList1 = !expansionList1;
                      if (selectedLastDonatedDate != null) {
                        setState(() {
                          lastDonated = DateFormat('dd MMM yyyy')
                              .format(selectedLastDonatedDate);
                        });
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    title: Text('I have not Donated'),
                    subtitle: Text("If you haven't donated in last 3 Months"),
                    onTap: () {
                      setState(() {
                        expansionList1 = !expansionList1;
                        lastDonated = "I have not Donated";
                        selectedLastDonatedDate = null;
                      });
                    },
                  ),
                ],
              ),
              isExpanded: expansionList1,
            ),
          ],
        ),
        errorText1 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText1,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildplasmadate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (widget.data == null) expansionList5 = !expansionList5;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: lastPlasmaDonated != null
                      ? Text(lastPlasmaDonated)
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  ListTile(
                    title: Text('Pick a date'),
                    subtitle:
                        Text('Pick a date in which you have last donated'),
                    onTap: () async {
                      selectedLastPlasmaDonatedDate =
                          await _selectLastDonatedDate(context);
                      expansionList5 = !expansionList5;
                      if (selectedLastPlasmaDonatedDate != null) {
                        setState(() {
                          lastPlasmaDonated = DateFormat('dd MMM yyyy')
                              .format(selectedLastPlasmaDonatedDate);
                        });
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    title: Text('I have not Donated'),
                    subtitle: Text(
                        "If you haven't donated to anyone in last 1 Months"),
                    onTap: () {
                      setState(() {
                        expansionList5 = !expansionList5;
                        lastPlasmaDonated = "I have not Donated";
                        selectedLastPlasmaDonatedDate = null;
                      });
                    },
                  ),
                ],
              ),
              isExpanded: expansionList5,
            ),
          ],
        ),
        errorText3 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText3,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildPlateletsDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (widget.data == null) expansionList7 = !expansionList7;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: lastPlateletsDonated != null
                      ? Text(lastPlateletsDonated)
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  ListTile(
                    title: Text('Pick a date'),
                    subtitle:
                        Text('Pick a date in which you have last donated'),
                    onTap: () async {
                      selectedLastPlateletsDate =
                          await _selectLastDonatedDate(context);
                      expansionList7 = !expansionList7;
                      if (selectedLastPlateletsDate != null) {
                        setState(() {
                          lastPlateletsDonated = DateFormat('dd MMM yyyy')
                              .format(selectedLastPlateletsDate);
                        });
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    title: Text('I have not Donated'),
                    subtitle: Text(
                        "If you haven't donated to anyone in last 1 Months"),
                    onTap: () {
                      setState(() {
                        expansionList7 = !expansionList7;
                        lastPlateletsDonated = "I have not Donated";
                        selectedLastPlateletsDate = null;
                      });
                    },
                  ),
                ],
              ),
              isExpanded: expansionList7,
            ),
          ],
        ),
        errorText7 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText7,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget lastDonatedDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 27.h,
            ),
            Text(
              "Last Donated Details",
              style: TextStyle(fontSize: 48.sp),
            ),
            Divider(),
            Text(
              "*You will not be able to change last donated details later.",
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.red[300],
                // fontStyle: FontStyle.italic
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildDropDown("Select Last blood Donated*", buildSlideMenu()),
            SizedBox(
              height: 20,
            ),
            buildDropDown("Select Last plasma Donated*", buildplasmadate()),
            SizedBox(
              height: 20,
            ),
            buildDropDown(
                "Select Last platelets Donated*", buildPlateletsDate()),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildBloodGrup(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.data == null)
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17))),
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context,
                    StateSetter setMode /*You can rename this!*/) {
                  List<Widget> _widgets = bloodGroups
                      .map((e) => GestureDetector(
                            onTap: () {
                              print(bloodGrp);
                              for (var i = 0; i <= 7; i++) {
                                setMode(() {
                                  bloodGroups[i]["colorBool"] = false;
                                });
                                setMode(() {
                                  anyGrp = false;
                                });
                                print(bloodGroups[i]["colorBool"]);
                              }
                              print("Done Loop");
                              setMode(() {
                                bloodGroups[bloodGroups.indexOf(e)]
                                        ["colorBool"] =
                                    !bloodGroups[bloodGroups.indexOf(e)]
                                        ["colorBool"];
                              });
                              setState(() {
                                _myBloodGrp =
                                    bloodGroups[bloodGroups.indexOf(e)]
                                        ["bloodGrp"];
                                _requiredBloodGrpController.text =
                                    bloodGroups[bloodGroups.indexOf(e)]
                                        ["bloodGrp"];
                              });
                              print("Required Blood Brp = $_myBloodGrp");
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 113.h,
                              width: 113.h,
                              decoration: BoxDecoration(
                                  color: bloodGroups[bloodGroups.indexOf(e)]
                                          ["colorBool"]
                                      ? CustomColor.red
                                      : Colors.white,
                                  border: Border.all(color: CustomColor.red),
                                  borderRadius: BorderRadius.circular(80)),
                              child: Text(
                                bloodGroups[bloodGroups.indexOf(e)]["bloodGrp"],
                                style: TextStyle(
                                    fontSize: 43.sp,
                                    color: bloodGroups[bloodGroups.indexOf(e)]
                                            ["colorBool"]
                                        ? Colors.white
                                        : CustomColor.red,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ))
                      .toList();
                  return Container(
                    padding: EdgeInsets.all(60.w),
                    height: 600.h,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Center(
                              child: Text(
                                "Selected your Blood Group",
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: CustomColor.red, fontSize: 50.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              // color: Colors.green,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _widgets[0],
                                      _widgets[1],
                                      _widgets[2],
                                      _widgets[3],
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _widgets[4],
                                      _widgets[5],
                                      _widgets[6],
                                      _widgets[7],
                                    ],
                                  ),
                                ],
                              )),
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
            labelText: "Your blood group*",
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

  Widget donationAvailibilityForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 27.h,
            ),
            Text(
              "Donation Availibility Details",
              style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSans"),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            buildDropDown(
                "Would you like to donate blood? *", buildDonateBlood()),
            SizedBox(
              height: 20,
            ),
            buildDropDown("Would you like donate plasma? *", buildPlasma()),
            SizedBox(
              height: 20,
            ),
            buildDropDown(
                "Would you like to donate Platelets? *", buildPlatlets()),
          ],
        ),
      ),
    );
  }

  Widget covid19DetailsForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 27.h,
            ),
            Text(
              "COVID-19 Details",
              style: TextStyle(fontSize: 48.sp),
            ),
            Divider(),
            buildDropDown(
                "Did you recover from Covid-19?*", buildRecoverCovid()),
            SizedBox(
              height: 20,
            ),
            gotCovid == null
                ? Container()
                : gotCovid
                    ? buildCovidRecoveryDate(context)
                    : Container(),
            SizedBox(
              height: gotCovid == null
                  ? 0
                  : gotCovid
                      ? 20
                      : 0,
            ),
            // gotCovid ? buildCovidRecoveryDate(context):Container(),
            // SizedBox(height: gotCovid ? 50.h : 0.h,),
            gotCovid == null
                ? Container()
                : gotCovid
                    ? buildDropDown(
                        "Would you like to donate plasma for COVID-19 patients? *",
                        buildPlasmaCovid())
                    : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildPlasmaCovid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList5 = !expansionList5;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: plasmaForCovid != null
                      ? Text(plasmaForCovid ? "Yes" : "No")
                      : Text(
                          "Can you donate plasma for Covid patients? *",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  ListTile(
                    title: Text("Yes"),
                    onTap: () async {
                      expansionList5 = !expansionList5;
                      setState(() {
                        plasmaForCovid = true;
                      });
                    },
                  ),
                  ListTile(
                    title: Text("No"),
                    onTap: () {
                      expansionList5 = !expansionList5;
                      setState(() {
                        plasmaForCovid = false;
                        // gotCovid = null;
                        // donatePlasma = null;
                      });
                    },
                  ),
                ],
              ),
              isExpanded: expansionList5,
            ),
          ],
        ),
        errorText8 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText8,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildPlatlets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList6 = !expansionList6;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: donatePlatlets != null
                      ? Text(donatePlatlets ? "Yes" : "No")
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  donatePlatlets == null || !donatePlatlets
                      ? ListTile(
                          title: Text("Yes"),
                          onTap: () async {
                            expansionList6 = !expansionList6;
                            setState(() {
                              donatePlatlets = true;
                            });
                          },
                        )
                      : Container(),
                  donatePlatlets == null || donatePlatlets
                      ? ListTile(
                          title: Text("No"),
                          onTap: () {
                            expansionList6 = !expansionList6;
                            setState(() {
                              donatePlatlets = false;
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                ],
              ),
              isExpanded: expansionList6,
            ),
          ],
        ),
        errorText6 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText6,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  GestureDetector buildCovidRecoveryDate(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        selectedCovidRecoveryDate = await _selectLastDonatedDate(context);
        if (selectedCovidRecoveryDate != null)
          _recoveredDateForCovid.text =
              DateFormat('dd MMM yyyy').format(selectedCovidRecoveryDate);
      },
      child: TextFormField(
        enabled: false,
        controller: _recoveredDateForCovid,
        decoration: InputDecoration(
            labelText: "When did you recover from covid-19?",
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
            suffixIcon: SimpleTooltip(
              animationDuration: Duration(seconds: 1),
              hideOnTooltipTap: true,
              borderColor: Colors.white,
              show: showToolTip,
              tooltipDirection: TooltipDirection.horizontal,
              content: Text(
                "This information is used to determine the services available for your account",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  decoration: TextDecoration.none,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.help_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    showToolTip = !showToolTip;
                  });
                },
              ),
            )),
        readOnly: false,
        textCapitalization: TextCapitalization.words,
        validator: (val) {
          if (val.isEmpty && gotCovid != null) {
            if (gotCovid) return "Select your recovery date";
          }
        },
      ),
    );
  }

  Widget buildRecoverCovid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList3 = !expansionList3;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: gotCovid != null
                      ? Text(gotCovid ? "Yes" : "No")
                      : Text(
                          "Did you recover from Covid-19?*",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  ListTile(
                    title: Text("Yes"),
                    onTap: () async {
                      expansionList3 = !expansionList3;
                      setState(() {
                        gotCovid = true;
                      });
                    },
                  ),
                  ListTile(
                    title: Text("No"),
                    onTap: () {
                      expansionList3 = !expansionList3;
                      setState(() {
                        gotCovid = false;
                        // gotCovid = null;
                        // donatePlasma = null;
                      });
                    },
                  ),
                ],
              ),
              isExpanded: expansionList3,
            ),
          ],
        ),
        errorText4 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText4,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildDonateBlood() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList2 = !expansionList2;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: donateBlood != null
                      ? Text(donateBlood ? "Yes" : "No")
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  donateBlood == null || !donateBlood
                      ? ListTile(
                          title: Text("Yes"),
                          onTap: () async {
                            expansionList2 = !expansionList2;
                            setState(() {
                              donateBlood = true;
                            });
                          },
                        )
                      : Container(),
                  donateBlood == null || donateBlood
                      ? ListTile(
                          title: Text("No"),
                          onTap: () {
                            expansionList2 = !expansionList2;
                            setState(() {
                              donateBlood = false;
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                ],
              ),
              isExpanded: expansionList2,
            ),
          ],
        ),
        errorText2 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText2,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  Widget buildPlasma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expansionList4 = !expansionList4;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: donatePlasma != null
                      ? Text(donatePlasma ? "Yes" : "No")
                      : Text(
                          "Select",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                );
              },
              body: Column(
                children: [
                  donatePlasma == null || !donatePlasma
                      ? ListTile(
                          title: Text("Yes"),
                          onTap: () async {
                            expansionList4 = !expansionList4;
                            setState(() {
                              donatePlasma = true;
                            });
                          },
                        )
                      : Container(),
                  donatePlasma == null || donatePlasma
                      ? ListTile(
                          title: Text("No"),
                          onTap: () {
                            expansionList4 = !expansionList4;
                            setState(() {
                              donatePlasma = false;
                              // gotCovid = null;
                              // donatePlasma = null;
                            });
                          },
                        )
                      : Container(),
                ],
              ),
              isExpanded: expansionList4,
            ),
          ],
        ),
        errorText5 != null
            ? Padding(
                padding: EdgeInsets.only(left: 15.h, top: 10.h),
                child: Text(
                  errorText5,
                  style: TextStyle(color: CustomColor.red, fontSize: 35.sp),
                  textAlign: TextAlign.start,
                ))
            : Container(),
      ],
    );
  }

  @override
  void initState() {
    // if(widget.data != null){
    //     _dobController.text = widget.data["dob"].toString();
    //     _nameController.text = widget.data["name"];
    //     _emergency1Controller.text = widget.data["emergency1"];
    //     _emergency2Controller.text = widget.data["emergency2"];
    //     donateBlood = widget.data["donateBlood"];
    //     donatePlasma =  widget.data["donatePlasma"];
    //     gotCovid =  widget.data["gotCovid"];
    //     plasmaForCovid = widget.data["donatePlasmaCovid"];
    //     _recoveredDateForCovid.text = widget.data["covidRecoverDate"];
    // }
    // super.initState();
    if (widget.name != null) if (widget.name.length > 25) {
      widget.name = widget.name.substring(0, 25);
    }
    if (widget.data == null) {
      _image = widget.file;
      _nameController.text = widget.name;
    } else {
      _nameController.text = widget.data["name"];
      dobTimestamp = widget.data["dob"];
      gender = widget.data["gender"];
      _dobController.text = _commonUtilFunctions.timeStampToDate(dobTimestamp);
      _myBloodGrp = widget.data["bloodGrp"];
      _requiredBloodGrpController.text = widget.data["bloodGrp"];
      donatePlatlets = widget.data["donatePlatlets"];
      plasmaForCovid = widget.data["donatePlasmaForCovid"];

      // bloodGroups[bloodGroups.indexOf(_myBloodGrp)]["colorBool"] =
      //     !bloodGroups[bloodGroups.indexOf(_myBloodGrp)]["colorBool"];
      _emergency1Controller.text = widget.data["emergency1"];
      _emergency2Controller.text = widget.data["emergency2"];
      Timestamp lastDonatedTimeStamp = widget.data["lastDonated"];
      if (lastDonatedTimestamp != null) {
        selectedLastDonatedDate =
            _commonUtilFunctions.timestampToDate(lastDonatedTimeStamp);
        // DateTime.fromMillisecondsSinceEpoch(lastDonatedTimeStamp);
        lastDonated = DateFormat('dd MMM yyyy').format(selectedLastDonatedDate);
      } else {
        selectedLastDonatedDate = null;
        lastDonated = "I have not Donated";
      }
      donateBlood = widget.data["donateBlood"];
      Timestamp lastPlasmaDonatedTimeStamp = widget.data["lastPlasmaDonated"];
      if (lastPlasmaDonatedTimeStamp != null) {
        selectedLastPlasmaDonatedDate =
            _commonUtilFunctions.timestampToDate(lastPlasmaDonatedTimeStamp);
        // DateTime.fromMillisecondsSinceEpoch(lastPlasmaDonatedTimeStamp);
        lastPlasmaDonated =
            DateFormat('dd MMM yyyy').format(selectedLastPlasmaDonatedDate);
      } else {
        selectedLastPlasmaDonatedDate = null;
        lastPlasmaDonated = "I have not Donated";
      }
      Timestamp lastPlateletsDonatedTimeStamp =
          widget.data["lastPlateletsDonated"];
      if (lastPlateletsDonatedTimeStamp != null) {
        selectedLastPlateletsDate =
            _commonUtilFunctions.timestampToDate(lastPlateletsDonatedTimeStamp);
        // DateTime.fromMillisecondsSinceEpoch(lastPlasmaDonatedTimeStamp);
        lastPlateletsDonated =
            DateFormat('dd MMM yyyy').format(selectedLastPlateletsDate);
      } else {
        selectedLastPlateletsDate = null;
        lastPlateletsDonated = "I have not Donated";
      }

      gotCovid = widget.data["gotCovid"];
      Timestamp covidTimeStamp = widget.data["covidRecoverDate"];
      if (covidTimeStamp != null) {
        selectedCovidRecoveryDate =
            _commonUtilFunctions.timestampToDate(covidTimeStamp);
        // DateTime.fromMillisecondsSinceEpoch(covidTimeStamp);
        _recoveredDateForCovid.text =
            DateFormat('dd MMM yyyy').format(selectedCovidRecoveryDate);
      } else {
        selectedCovidRecoveryDate = null;
      }
      donatePlasma = widget.data["donatePlasma"];
    }
    super.initState();

    uid = FirebaseAuth.instance.currentUser.uid;
    phone = FirebaseAuth.instance.currentUser.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    _notify = Provider.of<Notify>(context);
    time = Provider.of<Time>(context);
    return Scaffold(
      appBar: widget.data != null
          ? AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
            )
          : null,
      body: time.offset == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Card(
                        elevation: 0,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsets.zero,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(),
                          child: Padding(
                              padding: EdgeInsets.all(15.w),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(colors: [
                                          Color(0xffC9D6FF),
                                          Color(0xffE2E2E2),
                                        ])),
                                    // color: Colors.blue.shade200,
                                    // padding: EdgeInsets.only(bottom: 30.h),
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.21,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 50.h,
                                        ),
                                        buildPhoto(context),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 24.h,
                                    right: 24.w,
                                    child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          // chooseSourceImage(context);
                                          bottomSheetForImagePick();
                                        },
                                        child: Icon(Icons.camera_alt_outlined)),
                                  )
                                ],
                              )),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 15.h,
                              ),
                              personalFormDetails(),
                              SizedBox(
                                height: 15.h,
                              ),
                              widget.data == null
                                  ? lastDonatedDetails()
                                  : Container(),
                              SizedBox(
                                height: 15.h,
                              ),
                              donationAvailibilityForm(),
                              SizedBox(
                                height: 15.h,
                              ),
                              // covid19DetailsForm(),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 60.h,
                      // ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.all(30.w),
                            child: CustomMadeButton(
                              onPress: saveData,
                              buttonText:
                                  widget.data == null ? 'Continue' : "Update",
                            )),
                      ),
                      SizedBox(
                        height: 60.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
