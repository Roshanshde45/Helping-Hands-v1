import 'dart:io';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:bd_app/Widgets/CustomMadeButton.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DonationSubmissionScreen extends StatefulWidget {
  File image;
  DocumentSnapshot snapshot;
  DocumentSnapshot userData;
  DonationSubmissionScreen(this.image, this.userData, this.snapshot);
  @override
  _DonationSubmissionScreenState createState() =>
      _DonationSubmissionScreenState();
}

class _DonationSubmissionScreenState extends State<DonationSubmissionScreen> {
  File _image;
  final picker = ImagePicker();
  int radioValue;
  int units;
  bool showToolTip = false;
  DateTime selectedDate;
  DateTime _firstDate = DateTime(2000);
  TextEditingController _dobController = new TextEditingController();
  CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  Notify _notify;
  Time time;
  String myName;

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
  }

  void isEligible() async {
    _firstDate = DateTime(2000);
    List<Timestamp> lastDates = [];
    if (widget.userData.data()["lastDonated"] != null) {
      lastDates.add(widget.userData.data()["lastDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    if (widget.userData.data()["lastPlasmaDonated"] != null) {
      lastDates.add(widget.userData.data()["lastPlasmaDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    if (widget.userData.data()["lastPlateletsDonated"] != null) {
      lastDates.add(widget.userData.data()["lastPlateletsDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    List<Timestamp> temp = List.from(lastDates);
    print(lastDates);
    temp.sort((a, b) => a.compareTo(b));
    print(temp);
    int index = lastDates.indexOf(temp[2]);

    String lastDonated;

    if (index == 0) {
      lastDonated = "Blood";
    } else if (index == 1) {
      lastDonated = "Plasma";
    } else if (index == 2) {
      lastDonated = "Platelets";
    }

    print("lastDonated" + lastDonated);

    if (radioValue == 1) {
      if (lastDonated == "Blood") {
        _firstDate = lastDates[index].toDate().add(Duration(
            days: _notify.dynamicValue[lastDonated +
                "ToBlood" +
                (widget.userData.data()["gender"] == "Male" ? "M" : "F")]));
      } else {
        _firstDate = lastDates[index]
            .toDate()
            .add(Duration(days: _notify.dynamicValue[lastDonated + "ToBlood"]));
      }

      print("index " + radioValue.toString() + " " + lastDonated + "ToBlood");
      // if (_notify.userData["lastDonated"] != null) {
      //   DateTime _temp = DateTime.fromMillisecondsSinceEpoch(
      //       _notify.userData["lastDonated"].millisecondsSinceEpoch);
      //   _firstDate =
      //       _temp.add(Duration(days: _notify.dynamicValue["BloodToBlood"]));
      // }
    }

    if (radioValue == 2) {
      _firstDate = lastDates[index]
          .toDate()
          .add(Duration(days: _notify.dynamicValue[lastDonated + "ToPlasma"]));

      print("index" + radioValue.toString());
    }

    if (radioValue == 3) {
      _firstDate = lastDates[index].toDate().add(
          Duration(days: _notify.dynamicValue[lastDonated + "ToPlatelets"]));

      print("index" + radioValue.toString());
    }
  }

  Future setToNotification({String uid, String postId}) async {
    await FirebaseFirestore.instance
        .collection("Profile")
        .doc(uid)
        .collection("notifications")
        .add({
      "timeStamp": FieldValue.serverTimestamp(),
      "personRequesting": myName,
      "tag": "Request",
      "requestForPostId": postId,
    });
  }

  getMyName() {
    FirebaseFirestore.instance
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                myName = value.data()["name"];
              })
            });
  }

  @override
  void initState() {
    getMyName();
    super.initState();
    _image = widget.image;
    print("::::::::::::::::::::::");
    print(widget.userData);
    print(myName);
  }

  @override
  Widget build(BuildContext context) {
    _notify = Provider.of<Notify>(context, listen: false);
    time = Provider.of<Time>(context);
    return TimeLoading(
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   title: Text(
        //     "Donation Submission",
        //     style: TextStyle(color: Colors.black),
        //   ),
        //   leading: IconButton(
        //     icon: Icon(Icons.clear),
        //     onPressed: () {
        //       Get.back();
        //     },
        //   ),
        //   iconTheme: IconThemeData(color: Colors.black),
        // ),
        body: SafeArea(
            child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.52,
                            width: double.infinity,
                            child: Image.file(
                              _image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: EdgeInsets.all(28.w),
                                child: GestureDetector(
                                  onTap: getImageCamera,
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: CustomColor.red),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () => Get.back()),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40.h,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 45.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Donating",
                              style: TextStyle(
                                  fontSize: 46.sp, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "Select what you are donating",
                              style: TextStyle(
                                  fontSize: 33.sp,
                                  color: CustomColor.darkGrey,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic),
                            ),
                            Row(
                              children: [
                                Radio(
                                    value: 1,
                                    groupValue: radioValue,
                                    onChanged: (value) async {
                                      selectedDate = null;
                                      _dobController.clear();
                                      radioValue = 1;
                                      isEligible();
                                      if (_firstDate.millisecondsSinceEpoch >=
                                          time
                                              .getCurrentTime()
                                              .millisecondsSinceEpoch) {
                                        await Fluttertoast.showToast(
                                            msg:
                                                "You can only donate blood after " +
                                                    DateFormat('dd MMM yyyy')
                                                        .format(_firstDate),
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: CustomColor.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        // _commonUtilFunctions.flushbarNotify(
                                        //     "Sorry",
                                        //     "You can only donate blood after " +
                                        //         DateFormat('dd MMM yyyy')
                                        //             .format(_firstDate));
                                        setState(() {
                                          radioValue = null;
                                        });
                                      } else {
                                        setState(() {
                                          radioValue = value;
                                        });
                                      }
                                    }),
                                Text("Blood"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Radio(
                                    value: 2,
                                    groupValue: radioValue,
                                    onChanged: (value) async {
                                      selectedDate = null;
                                      _dobController.clear();
                                      radioValue = 2;
                                      isEligible();
                                      if (_firstDate.millisecondsSinceEpoch >
                                          time
                                              .getCurrentTime()
                                              .millisecondsSinceEpoch) {
                                        await Fluttertoast.showToast(
                                            msg:
                                                "You can only donate plasma after " +
                                                    DateFormat('dd MMM yyyy')
                                                        .format(_firstDate),
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: CustomColor.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        // _commonUtilFunctions.flushbarNotify(
                                        //     "Sorry",
                                        //     "You can only donate plasma after " +
                                        //         DateFormat('dd MMM yyyy')
                                        //             .format(_firstDate));
                                        setState(() {
                                          radioValue = null;
                                        });
                                      } else {
                                        setState(() {
                                          radioValue = value;
                                        });
                                      }
                                    }),
                                Text("Plasma"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Radio(
                                    value: 3,
                                    groupValue: radioValue,
                                    onChanged: (value) async {
                                      selectedDate = null;
                                      _dobController.clear();
                                      radioValue = 3;
                                      isEligible();
                                      if (_firstDate.millisecondsSinceEpoch >
                                          time
                                              .getCurrentTime()
                                              .millisecondsSinceEpoch) {
                                        // _commonUtilFunctions.flushbarNotify(
                                        //     "Sorry",
                                        //     "You can only donate platelets after " +
                                        //         DateFormat('dd MMM yyyy')
                                        //             .format(_firstDate));
                                        await Fluttertoast.showToast(
                                            msg:
                                                "You can only donate platelets after " +
                                                    DateFormat('dd MMM yyyy')
                                                        .format(_firstDate),
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: CustomColor.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        setState(() {
                                          radioValue = null;
                                        });
                                      } else {
                                        setState(() {
                                          radioValue = value;
                                        });
                                      }
                                    }),
                                Text("Platelets"),
                              ],
                            ),
                            Divider(),
                            Text(
                              "Select number of units",
                              style: TextStyle(
                                  fontSize: 46.sp, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "Select units you are donating",
                              style: TextStyle(
                                  fontSize: 33.sp,
                                  color: CustomColor.darkGrey,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic),
                            ),
                            Row(
                              children: [
                                Radio(
                                    value: 1,
                                    groupValue: units,
                                    onChanged: (value) {
                                      setState(() {
                                        units = value;
                                      });
                                    }),
                                Text("1"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Radio(
                                    value: 2,
                                    groupValue: units,
                                    onChanged: (value) {
                                      setState(() {
                                        units = value;
                                      });
                                    }),
                                Text("2"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Radio(
                                    value: 3,
                                    groupValue: units,
                                    onChanged: (value) {
                                      setState(() {
                                        units = value;
                                      });
                                    }),
                                Text("3"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Radio(
                                    value: 4,
                                    groupValue: units,
                                    onChanged: (value) {
                                      setState(() {
                                        units = value;
                                      });
                                    }),
                                Text("4"),
                              ],
                            ),
                            // Slider(value: units.toDouble(),
                            //     onChanged: (value){
                            //       setState(() {
                            //         units = value.floor();
                            //       });
                            // },
                            //   divisions: 3,
                            //   max: 4,
                            //   min: 1,
                            //   label: "$units Unit",
                            // ),
                            SizedBox(
                              height: 40.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 70.h,
                      ),
                    ],
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
                child: CustomMadeButton(
                  onPress: () async {
                    if (radioValue != null && units != null && _image != null) {
                      String _url;
                      _commonUtilFunctions.loadingCircle("Please wait..");
                      FirebaseStorage storage = FirebaseStorage.instance;
                      Reference ref = storage.ref().child("Donation").child(
                          widget.snapshot.id +
                              FirebaseAuth.instance.currentUser.uid);
                      UploadTask uploadTask = ref.putFile(_image);
                      await uploadTask.then((res) async {
                        _url = await res.ref.getDownloadURL();
                      });
                      List<String> donatedType = [
                        "Blood",
                        "Plasma",
                        "Platelets"
                      ];
                      if (_url != null) {
                        FirebaseFirestore.instance
                            .collection("Post")
                            .doc(widget.snapshot.id)
                            .update({
                          "donationRequest": FieldValue.arrayUnion([
                            {
                              FirebaseAuth.instance.currentUser.uid: {
                                "time": time.getCurrentTimeStamp(),
                                "imageUrl": _url,
                                "donatedUnits": units,
                                "donated": donatedType[radioValue - 1],
                                "location": GeoPoint(_notify.currLoc.latitude,
                                    _notify.currLoc.longitude)
                              },
                            }
                          ])
                        });

                        // await setToNotification(
                        //   uid: widget.snapshot["createdBy"],
                        //   postId: widget.snapshot.id,
                        // );

                        Map<String, dynamic> updatedDate = {};
                        if (radioValue == 1) {
                          updatedDate["lastDonated"] =
                              time.getCurrentTimeStamp();
                        } else if (radioValue == 2) {
                          updatedDate["lastPlasmaDonated"] =
                              time.getCurrentTimeStamp();
                        } else if (radioValue == 3) {
                          updatedDate["lastPlateletsDonated"] =
                              time.getCurrentTimeStamp();
                        }

                        FirebaseFirestore.instance
                            .collection("Profile")
                            .doc(widget.userData.id)
                            .update(updatedDate);
                        _notify.notify();
                        Get.back();
                        Get.back();
                      } else {
                        Get.back();
                        Get.back();
                        showError(context);
                      }
                    }
                  },
                  buttonText: "Donated",
                  color: (radioValue != null && units != null && _image != null)
                      ? CustomColor.red
                      : CustomColor.grey,
                ),
              ),
            )
          ],
        )),
      ),
    );
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
}
