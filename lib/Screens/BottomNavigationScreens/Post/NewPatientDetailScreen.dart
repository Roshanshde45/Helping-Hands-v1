import 'dart:io';
import 'dart:math';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/MapUtils.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/postBloodRequirement.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bd_app/Widgets/CustomMadeButton.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_app/Model/PostCardDetails.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import '../../ChatScreen.dart';
import 'package:get/get.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/DonationSubmissionScreen.dart';

import 'donationRequest.dart';

class NewPatientDetail extends StatefulWidget {
  // PostCardDetails postCardDetails;
  String postId;
  List bloodGroups;

  // DocumentSnapshot documentSnapshot;
  NewPatientDetail({this.postId, this.bloodGroups});

  @override
  _NewPatientDetailState createState() => _NewPatientDetailState();
}

class _NewPatientDetailState extends State<NewPatientDetail> {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final _firestore = FirebaseFirestore.instance;
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  Color subTextColor = Color(0xff1e272e);
  String sharePostLink, uid;
  String userProfileImg, name, phone;
  bool loaded = false, expired = false;
  File _image;
  final picker = ImagePicker();
  final firestoe = FirebaseFirestore.instance;
  String requiredBloodGrp,
      requirement,
      patientName,
      purpose,
      patientAttenderName1,
      patientAttenderName2,
      patientAttenderName3,
      patientAttender1,
      patientAttender2,
      patientAttender3,
      hospitalName,
      hospitalCityName,
      hospitalAreaName,
      roomNumber,
      userCreatedUid,
      postId;
  String requirementDate, requiredUnits, patientAge, otherDetails;
  LatLng hospitalLatLng;
  Notify _notify;

  DocumentSnapshot documentSnapshot;

  Widget lableContainer(String lable, String fillText) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40.h,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              lable,
              style: TextStyle(
                color: subTextColor,
                fontSize: 38.sp,
              ),
            ),
          ),
          Text(
            ":",
            style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
                fontWeight: FontWeight.bold),
          ),
          Container(
            height: 80.h,
            width: MediaQuery.of(context).size.width * 0.4,
            alignment: Alignment.centerLeft,
            child: Text(
              fillText,
              style: TextStyle(
                color: subTextColor,
                fontSize: 38.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequiredDetails() {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Requirement Details",
            style: TextStyle(
                color: CustomColor.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 25.h,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lableContainer(
                  "Requirement", commonUtilFunctions.firstCaptial(requirement)),
              lableContainer("Requirement Date & Time", requirementDate),
              lableContainer("Required Blood Group", requiredBloodGrp),
              lableContainer("Required Units", requiredUnits),
            ],
          ),
        ],
      ),
    );
  }

  // Widget buildStatusInfo() {
  //   return Container(
  //     alignment: Alignment.topLeft,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           height: 20.h,
  //         ),
  //         Text(
  //           "Requi",
  //           style: TextStyle(
  //               color: CustomColor.red,
  //               fontSize: 50.sp,
  //               fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(
  //           height: 25.h,
  //         ),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             lableContainer("Requirement", requirement),
  //             lableContainer("Requirement Date & Time", requirementDate),
  //             lableContainer("Required Blood Group", requiredBloodGrp),
  //             lableContainer("Required Units", requiredUnits),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildPatientDetails() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Patient Details",
            style: TextStyle(
                color: CustomColor.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 25.h,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lableContainer("Patient Name", patientName),
              lableContainer("Age", patientAge),
              lableContainer("Purpose", purpose),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPatientAttenders() {
    return Container(
      alignment: Alignment.centerLeft,
      // width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Patient Attenders",
            style: TextStyle(
                color: CustomColor.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 25.h,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patientAttenderName1,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 38.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        commonUtilFunctions.makePhoneCall(
                            patientAttender1, false);
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColor.grey,
                                blurRadius: 5.0,
                              ),
                            ]),
                        child: Icon(
                          Icons.call,
                          color: CustomColor.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: (patientAttenderName2 != null &&
                              patientAttenderName2 != "" &&
                              patientAttender2 != null &&
                              patientAttender2 != "") !=
                          null
                      ? 20.h
                      : 0,
                ),
                (patientAttenderName2 != null &&
                        patientAttenderName2 != "" &&
                        patientAttender2 != null &&
                        patientAttender2 != "")
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patientAttenderName2,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 38.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              commonUtilFunctions.makePhoneCall(
                                  patientAttender2, false);
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CustomColor.grey,
                                      blurRadius: 5.0,
                                    ),
                                  ]),
                              child: Icon(
                                Icons.call,
                                color: CustomColor.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: (patientAttenderName3 != null &&
                          patientAttenderName3 != "" &&
                          patientAttender3 != null &&
                          patientAttender3 != "")
                      ? 20.h
                      : 0,
                ),
                (patientAttenderName3 != null &&
                        patientAttenderName3 != "" &&
                        patientAttender3 != null &&
                        patientAttender3 != "")
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patientAttenderName3,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 38.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              commonUtilFunctions.makePhoneCall(
                                  patientAttender3, false);
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CustomColor.grey,
                                      blurRadius: 5.0,
                                    ),
                                  ]),
                              child: Icon(
                                Icons.call,
                                color: CustomColor.red,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildLocationDetails() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Location Details",
            style: TextStyle(
                color: CustomColor.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 25.h,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lableContainer("Hospital Name", hospitalName),
              lableContainer("Hospital City Name", hospitalCityName),
              lableContainer("Hospital Area Name", hospitalAreaName),
              roomNumber != null && roomNumber != ""
                  ? lableContainer("Hospital Room No.", roomNumber.toString())
                  : Container(),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        "Hospital Address",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 38.sp,
                        ),
                      ),
                    ),
                    Text(
                      ":",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 130.h),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 80.h,
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: () {
                            MapUtils.openMap(
                              hospitalLatLng.latitude,
                              hospitalLatLng.longitude,
                            );
                          },
                          child: Icon(
                            Icons.directions,
                            color: CustomColor.red,
                            size: 23,
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 17.h,
              ),
              otherDetails != null && otherDetails != ""
                  ? Padding(
                      padding: EdgeInsets.only(top: 0.h),
                      child: Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                "Other Details",
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 38.sp,
                                ),
                              ),
                            ),
                            Text(
                              ":",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            FittedBox(
                              fit: BoxFit.fill,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  otherDetails.toString(),
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 38.sp,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  Widget cancelDonationText() {
    Map<String, dynamic> data = documentSnapshot.data();
    List<dynamic> donors = data["donors"] ?? [];
    if (donors.contains(FirebaseAuth.instance.currentUser.uid)) {
      List<dynamic> notDonors = data["notDonors"];
      if (notDonors != null &&
          notDonors.contains(FirebaseAuth.instance.currentUser.uid)) {
        return Container();
      } else {
        List<dynamic> donationReq = data["donationRequest"];
        bool requested = false;
        bool donated = false;
        if (donationReq != null) {
          donationReq.forEach((element) {
            element.forEach((key, value) {
              if (key == FirebaseAuth.instance.currentUser.uid) {
                requested = true;
              }
            });
          });
        }
        List<dynamic> finalDonors = data["finalDonors"];
        if (finalDonors != null) {
          finalDonors.forEach((element) {
            if (element == FirebaseAuth.instance.currentUser.uid) {
              requested = false;
              donated = true;
            }
          });
        }
        if (requested) {
          return Container();
        } else if (donated) {
          return Container();
        } else {
          return GestureDetector(
            onTap: () {
              showCancelDialog(context);
            },
            child: Text(
              "Cancel Donation",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: CustomColor.red,
                  fontSize: 40.sp),
            ),
          );
        }
      }
    } else {
      return Container();
    }
  }

  Widget buildUserPostedMeta() {
    return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection("Profile").doc(userCreatedUid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          _notify.setUser(snapshot.data);
          userProfileImg = _notify.userData["profilePic"];
          name = _notify.userData["name"];
          phone = _notify.userData["phone"];
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: CustomColor.red,
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: userProfileImg != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: "images/person.png",
                                  image: userProfileImg,
                                  height: 325.h,
                                  width: 325.w,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "images/person.png",
                                  height: 130.h,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Posted By",
                      style:
                          TextStyle(color: CustomColor.grey, fontSize: 30.sp),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          color: CustomColor.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 40.sp),
                    )
                  ],
                ),
                SizedBox(
                  width: 80.w,
                ),
                GestureDetector(
                  onTap: () async {
                    print("::::::::::::::::::::::::::::::::::::::");
                    String uid1 = uid;
                    String uid2 = userCreatedUid;
                    String donorId;
                    commonUtilFunctions.loadingCircle("Loading...");
                    var OneWayChatRoomId =
                        commonUtilFunctions.getChatRoomIdByUid(uid1, uid2);
                    var ReverseChatRoomId =
                        commonUtilFunctions.getChatRoomIdByUid(uid2, uid1);
                    var ChatRoomId;
                    print("OneWayChatRoomId:  $OneWayChatRoomId");
                    print("OneWayChatRoomId:  $ReverseChatRoomId");
                    Map<String, dynamic> chatRoomInfo = {
                      "users": [uid, userCreatedUid],
                      // "bloodGrp": selectedBloodRequired,
                    };
                    final snapShot = await FirebaseFirestore.instance
                        .collection("ChatRooms")
                        .doc(OneWayChatRoomId)
                        .get();

                    final RevSnapShot = await FirebaseFirestore.instance
                        .collection("ChatRooms")
                        .doc(ReverseChatRoomId)
                        .get();

                    if (snapShot.exists) {
                      ChatRoomId = OneWayChatRoomId;
                      donorId = ChatRoomId.toString().replaceAll(uid, "");
                      donorId = donorId.replaceAll("_", "").trim();
                      print("Chat Already Exists");
                    } else if (RevSnapShot.exists) {
                      ChatRoomId = ReverseChatRoomId;
                      donorId = ChatRoomId.toString().replaceAll(uid, "");
                      donorId = donorId.replaceAll("_", "").trim();
                    } else {
                      ChatRoomId = OneWayChatRoomId;
                      donorId = ChatRoomId.toString().replaceAll(uid, "");
                      donorId = donorId.replaceAll("_", "").trim();
                      FirebaseFirestore.instance
                          .collection("ChatRooms")
                          .doc(ChatRoomId)
                          .set(chatRoomInfo);
                    }
                    Get.back();
                    print("ChatRoomId Passing: $ChatRoomId");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  donorName: name,
                                  donorProfilePic: userProfileImg,
                                  donorUid: userCreatedUid,
                                  chatRoomId: ChatRoomId,
                                  phone: phone,
                                )));
                    print(":::::::::::::::::::::::::::::::::::::::::::");
                    print(chatRoomInfo);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColor.grey,
                            blurRadius: 5.0,
                          ),
                        ]),
                    child: Icon(
                      Icons.question_answer_outlined,
                      color: CustomColor.red,
                    ),
                  ),
                ),
                SizedBox(
                  width: 30.w,
                ),
                GestureDetector(
                  onTap: () {
                    commonUtilFunctions.makePhoneCall(phone, false);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColor.grey,
                            blurRadius: 5.0,
                          ),
                        ]),
                    child: Icon(
                      Icons.call,
                      color: CustomColor.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  getPostDetailsLinkPush(snapshot) async {
    print("Getting Post Details from db }");
    if (snapshot != null && snapshot.data() != null) {
      print(snapshot.data());
      postId = snapshot.id;
      roomNumber = snapshot.data()["hospitalRoomNo"];
      requiredBloodGrp = snapshot.data()["requiredBloodGrp"];
      userCreatedUid = snapshot.data()["createdBy"];
      requirementDate = DateFormat('dd MMM yy, hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              snapshot.data()["bloodRequiredDateTime"].millisecondsSinceEpoch));
      requirement = snapshot.data()["requirementType"];
      requiredUnits = snapshot.data()["requiredUnits"];
      patientName = snapshot.data()["patientName"];
      patientAge = snapshot.data()["patientAge"];
      purpose = snapshot.data()["purpose"];
      patientAttenderName1 = snapshot.data()["patientAttenderName1"];
      patientAttenderName2 = snapshot.data()["patientAttenderName2"];
      patientAttenderName3 = snapshot.data()["patientAttenderName3"];
      patientAttender1 = snapshot.data()["patientAttenderContact1"];
      patientAttender2 = snapshot.data()["patientAttenderContact2"];
      patientAttender3 = snapshot.data()["patientAttenderContact3"];
      hospitalName = snapshot.data()["hospitalName"];
      hospitalCityName = snapshot.data()["hospitalCity"];
      hospitalAreaName = snapshot.data()["hospitalArea"];
      hospitalLatLng = LatLng(
          snapshot.data()["hospitalLocation"]["geopoint"].latitude,
          snapshot.data()["hospitalLocation"]["geopoint"].longitude);
      otherDetails = snapshot.data()["otherDetails"];
    }
  }

  Stream _stream;
  Time time;

  @override
  void initState() {
    print("postid" + widget.postId);
    _stream = _firestore.collection("Post").doc(widget.postId).snapshots();
    uid = FirebaseAuth.instance.currentUser.uid;
    if (widget.postId != null) {
      print("WE have postId: ${widget.postId}");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    print("building");
    _notify = Provider.of<Notify>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(
                    "Patient Details",
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                body: Center(
                  child: CircularProgressIndicator(),
                ));
          }
          documentSnapshot = snapshot.data;
          getPostDetailsLinkPush(snapshot.data);
          print(documentSnapshot.data());
          return TimeLoading(
              child: Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Patient Details",
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.black),
                    actions: [
                      // IconButton(icon: Icon(Icons.info_outline_rounded,color: CustomColor.red,), onPressed: () {}),
                      (documentSnapshot.data()["active"] != null &&
                              documentSnapshot.data()["active"] != false &&
                              documentSnapshot.data()["expired"] != true)
                          ? IconButton(
                              icon: Icon(Icons.share_rounded),
                              onPressed: () async {
                                String requiredDate;
                                requiredDate = DateFormat('dd MMM yy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        documentSnapshot
                                            .data()["bloodRequiredDateTime"]
                                            .millisecondsSinceEpoch));
                                String quote =
                                    "\n\n\"Donation Is A Small Act Of Kindness That Does Great And Big Wonders\"\n\n-Team Helping Hands";
                                String msg =
                                    "${documentSnapshot.data()["patientName"]} requires ${documentSnapshot.data()["requiredBloodGrp"]} $requirement on $requiredDate\.\n\nClick the link below to see details.\n\n";
                                print("Creating link with :${postId}");
                                commonUtilFunctions.loadingCircle("Loading...");
                                String link = await _dynamicLinkService
                                    .createFirstPostLink(
                                        requirementType: requirement,
                                        postId: postId,
                                        bloodGrp: requiredBloodGrp);
                                Clipboard.setData(
                                    ClipboardData(text: msg + link + quote));
                                Get.back();
                                Fluttertoast.showToast(
                                  msg: "Link Copied",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: CustomColor.grey,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                                Share.share(msg + link + quote);
                              })
                          : Container(),
                      (!documentSnapshot.data()["expired"] &&
                              (uid == documentSnapshot.data()["createdBy"]))
                          ? IconButton(
                              icon: Icon(Icons.edit_outlined),
                              onPressed: () {
                                Get.to(
                                  () => PostRequirement(
                                      documentSnapshot, expired),
                                );
                              })
                          : Container()
                      // IconButton(
                      //     icon: Icon(Icons.copy),
                      //     onPressed: () async {
                      //       String link =
                      //           await _dynamicLinkService.createFirstPostLink(
                      //               postId: postId, bloodGrp: requiredBloodGrp);
                      //       Share.share(link, subject: 'Donation Request');
                      //       Clipboard.setData(ClipboardData(text: link));
                      //       Fluttertoast.showToast(
                      //         msg: "Copied",
                      //         toastLength: Toast.LENGTH_SHORT,
                      //         gravity: ToastGravity.BOTTOM,
                      //         timeInSecForIosWeb: 1,
                      //         backgroundColor: CustomColor.grey,
                      //         textColor: Colors.white,
                      //         fontSize: 16.0,
                      //       );
                      //     })
                    ],
                  ),
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(45.w, 20.h, 45.w, 0),
                          child: Column(
                            children: [
                              // lableContainer(
                              //     "Status",
                              //     documentSnapshot.data()["active"] == true
                              //         ? "Active"
                              //         : "Not Active"),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Text(
                                        "Status",
                                        style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 45.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      ":",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 40.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 8.5,
                                          width: 8.5,
                                          decoration: documentSnapshot
                                                      .data()["expired"] ==
                                                  false
                                              ? BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  color:
                                                      documentSnapshot.data()[
                                                                  "active"] ==
                                                              true
                                                          ? Colors.greenAccent
                                                          : CustomColor.red,
                                                  borderRadius:
                                                      BorderRadius.circular(50))
                                              : BoxDecoration(
                                                  color: Colors.yellow,
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Container(
                                          height: 80.h,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          alignment: Alignment.centerLeft,
                                          child: documentSnapshot
                                                      .data()["expired"] ==
                                                  false
                                              ? Text(
                                                  documentSnapshot.data()[
                                                              "active"] ==
                                                          true
                                                      ? "Active"
                                                      : "Not active",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 38.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                )
                                              : Text(
                                                  "Expired",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 38.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              buildRequiredDetails(),
                              SizedBox(
                                height: 30.h,
                              ),
                              buildPatientDetails(),
                              SizedBox(
                                height: 30.h,
                              ),
                              documentSnapshot.data()["createdBy"] == uid ||
                                      (documentSnapshot.data()["donors"] !=
                                              null &&
                                          documentSnapshot
                                              .data()["donors"]
                                              .contains(uid))
                                  ? buildPatientAttenders()
                                  : Container(),
                              SizedBox(
                                height: 30.h,
                              ),
                              buildLocationDetails(),
                              SizedBox(
                                height: 60.h,
                              ),
                              documentSnapshot.data()["createdBy"] != uid
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        documentSnapshot.data()["createdBy"] !=
                                                uid
                                            ? buildUserPostedMeta()
                                            : Container(),
                                        SizedBox(
                                          height: documentSnapshot
                                                      .data()["createdBy"] !=
                                                  uid
                                              ? 50.h
                                              : 0,
                                        ),
                                        cancelDonationText(),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: 230.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      documentSnapshot.data()["createdBy"] != uid
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 20.h),
                                child: Container(
                                    child: widget.bloodGroups.contains(
                                            snapshot.data["requiredBloodGrp"])
                                        ? buildCustomMadeButton()
                                        : Container()),
                              ))
                          : Container(),
                    ],
                  )));
        });
  }

  Future<void> setToNotifications({
    String notifyUserUid,
    String patientName,
    String postId,
  }) async {
    print("Nofity UID: $notifyUserUid");
    print("PatientName: $patientName");
    print("postId: $postId");
    // print("donorName: $donorName");
    String donorName;
    try {
      await firestoe
          .collection("Profile")
          .doc(uid)
          .get(GetOptions(source: Source.cache))
          .then((snapshot) {
        name = snapshot.data()["name"];
        donorName = name;
      });
      firestoe.collection("Post").doc(postId).update({
        'donors':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser.uid]),
        'response time': FieldValue.arrayUnion([
          {FirebaseAuth.instance.currentUser.uid: time.getCurrentTimeStamp()}
        ]),
      });
      firestoe
          .collection("Profile")
          .doc(notifyUserUid)
          .collection("notifications")
          .add({
        "tag": "da", // Donors Appeared
        "donorName": donorName,
        "postId": postId,
        "patientName": patientName,
        "timeStamp": FieldValue.serverTimestamp()
      });
    } catch (e) {
      print(e);
    }
  }

  Future getImageCamera() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 23);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<bool> showDonateDialog(
      BuildContext context,
      String postId,
      // String userAcceptingName,
      String patientName,
      String posterUid,
      String bloodGrp) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(
              "Donate Blood",
            ),
            titlePadding: EdgeInsets.only(top: 45.h, left: 35.w),
            content: Text(
              "Thank you for being a donor. We will send your information "
              "to the requested person. By clicking confirm you agree that you "
              "will respond to phone calls an in app messages.",
              style: TextStyle(fontSize: 42.sp, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
            contentPadding: EdgeInsets.all(35.w),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style:
                      TextStyle(color: CustomColor.lightGrey, fontSize: 50.sp),
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
                  "Confirm",
                  style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                ),
                color: Colors.white,
                onPressed: () {
                  setToNotifications(
                    notifyUserUid: posterUid,
                    patientName: patientName,
                    postId: postId,
                  );
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          );
        });
  }

  Widget buildCustomMadeButton() {
    Map<String, dynamic> data = documentSnapshot.data();
    List<dynamic> donors = data["donors"] ?? [];
    if (donors.contains(FirebaseAuth.instance.currentUser.uid)) {
      List<dynamic> notDonors = data["notDonors"];
      if (notDonors != null &&
          notDonors.contains(FirebaseAuth.instance.currentUser.uid)) {
        return Container();
      } else {
        List<dynamic> donationReq = data["donationRequest"];
        bool requested = false;
        bool donated = false;
        if (donationReq != null) {
          donationReq.forEach((element) {
            element.forEach((key, value) {
              if (key == FirebaseAuth.instance.currentUser.uid) {
                requested = true;
              }
            });
          });
        }
        List<dynamic> finalDonors = data["finalDonors"];
        if (finalDonors != null) {
          finalDonors.forEach((element) {
            if (element == FirebaseAuth.instance.currentUser.uid) {
              requested = false;
              donated = true;
            }
          });
        }

        if (requested) {
          return CustomMadeButton(
            onPress: () {
              showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      title: Text("Life Points"),
                      content:
                          Text("Your Life Points will be credited soon... "),
                    );
                  },
                  barrierDismissible: true);
              // firestoe
              //     .collection("Post")
              //     .doc(widget.documentSnapshot.id)
              //     .update({
              //   "donationRequest": FieldValue.arrayUnion([
              //     {FirebaseAuth.instance.currentUser.uid: Timestamp.now()}
              //   ])
              // });
            },
            buttonText: "Life Points",
          );
        } else if (donated) {
          return Container(
              padding: EdgeInsets.all(25.h),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/icons/checked.png",
                    height: 25,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Text(
                    "You have already donated",
                    style: TextStyle(fontFamily: "opensans"),
                  ),
                ],
              ));
        } else {
          print("cancel dontation");
          return Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomMadeButton(
                  onPress: () async {
                    loadingCircle();
                    await _notify.gpsService();
                    bool inRadius = checkRadius();
                    if (inRadius) {
                      final _userData = await FirebaseFirestore.instance
                          .collection("Profile")
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .get();
                      Get.back();
                      if (_userData != null) {
                        // Get.bottomSheet(
                        //   BottomForm(documentSnapshot, _userData.data()),
                        // );
                        createDonationRequest(_userData, documentSnapshot);
                      }
                    } else {
                      Get.back();
                      showNotInRaduisDialog(context);
                    }

                    // firestoe
                    //     .collection("Post")
                    //     .doc(widget.documentSnapshot.id)
                    //     .update({
                    //   "donationRequest": FieldValue.arrayUnion([
                    //     {FirebaseAuth.instance.currentUser.uid: time.getCurrentTimeStamp()}
                    //   ])
                    // });
                  },
                  buttonText: "Donate",
                ),
                SizedBox(
                  height: 20.h,
                ),
                // GestureDetector(
                //     onTap: () {
                //       showCancelDialog(context);
                //     },
                //     child: Column(
                //       children: [
                //         Text(
                //           "Cancel My Donation",
                //           style: TextStyle(
                //             decoration: TextDecoration.underline,
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.h,
                //         )
                //       ],
                //     )),
              ],
            ),
          );
        }
      }
    } else if (documentSnapshot.data()["active"]) {
      return CustomMadeButton(
        onPress: () {
          isEligible(documentSnapshot);
        },
        buttonText: "I'll Donate",
      );
    } else {
      return Container();
    }
  }

  void isEligible(DocumentSnapshot snapshot) async {
    commonUtilFunctions.loadingCircle("Loading...");
    final _userData = await FirebaseFirestore.instance
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    Get.back();
    if (_userData == null) {
      commonUtilFunctions.showError(context);
    } else {
      DateTime _firstDate = DateTime(2000);
      List<Timestamp> lastDates = [];
      if (_userData["lastDonated"] != null) {
        lastDates.add(_userData["lastDonated"]);
      } else {
        lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
            DateTime(2000).millisecondsSinceEpoch));
      }

      if (_userData["lastPlasmaDonated"] != null) {
        lastDates.add(_userData["lastPlasmaDonated"]);
      } else {
        lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
            DateTime(2000).millisecondsSinceEpoch));
      }

      if (_userData["lastPlateletsDonated"] != null) {
        lastDates.add(_userData["lastPlateletsDonated"]);
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

      if (snapshot.data()["requirementType"] == 'blood') {
        if (lastDonated == "Blood") {
          _firstDate = lastDates[index].toDate().add(Duration(
              days: _notify.dynamicValue[lastDonated +
                  "ToBlood" +
                  (_userData.data()["gender"] == "Male" ? "M" : "F")]));
        } else {
          _firstDate = lastDates[index].toDate().add(
              Duration(days: _notify.dynamicValue[lastDonated + "ToBlood"]));
        }
      }

      if (snapshot.data()["requirementType"] == 'plasma') {
        _firstDate = lastDates[index].toDate().add(
            Duration(days: _notify.dynamicValue[lastDonated + "ToPlasma"]));
      }

      if (snapshot.data()["requirementType"] == 'platelets') {
        _firstDate = lastDates[index].toDate().add(
            Duration(days: _notify.dynamicValue[lastDonated + "ToPlatelets"]));
      }

      Timestamp _temp = snapshot.data()["bloodRequiredDateTime"];
      if (_temp.millisecondsSinceEpoch > _firstDate.millisecondsSinceEpoch) {
        showDonateDialog(context, snapshot.id, snapshot.data()["patientName"],
            snapshot.data()["createdBy"], snapshot.data()["requiredBloodGrp"]);
      } else {
        await Fluttertoast.showToast(
            msg: "You can only donate blood after " +
                DateFormat('dd MMM yyyy').format(_firstDate),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: CustomColor.grey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  bool checkRadius() {
    int distance = (Geolocator.distanceBetween(
            documentSnapshot.data()["hospitalLocation"]["geopoint"].latitude,
            documentSnapshot.data()["hospitalLocation"]["geopoint"].longitude,
            _notify.currLoc.latitude,
            _notify.currLoc.longitude))
        .floor();
    if (distance > _notify.dynamicValue["checkRadius"]) {
      return false;
    } else {
      return true;
    }
  }

  Future<Widget> createDonationRequest(
      DocumentSnapshot userData, DocumentSnapshot snapshot) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18))),
        builder: (context) {
          return Container(
            padding: EdgeInsets.fromLTRB(40.w, 50.h, 40.w, 0),
            height: 580.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                commonUtilFunctions.bottomSheetPill(),
                SizedBox(
                  height: 40.h,
                ),
                Text(
                  "Add a Picture",
                  style: TextStyle(fontSize: 58.sp),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Text(
                  "Please take your picture while donating and make sure that your picture is visible fully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CustomColor.grey, fontSize: 40.sp),
                ),
                SizedBox(
                  height: 40.h,
                ),
                GestureDetector(
                  onTap: () async {
                    await getImageCamera();
                    if (_image != null) {
                      Get.back();
                      Get.to(
                          DonationSubmissionScreen(_image, userData, snapshot));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 120.h,
                    width: 380.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: CustomColor.grey,
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Text(
                      "Add Picture",
                      style: TextStyle(color: CustomColor.grey),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<bool> showNotInRaduisDialog(BuildContext context) {
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
                "Not In Radius",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "You are not in radius",
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

  loadingCircle() {
    Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 20,
              ),
              Text("Please Wait")
            ],
          ),
        ),
        barrierDismissible: false);
  }

  Future<bool> showCancelDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(
              "Cancel donation",
              textAlign: TextAlign.start,
            ),
            titlePadding: EdgeInsets.only(top: 45.h, left: 35.w),
            content: Text(
              "Are you sure you are not available for donation?",
              style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
              textAlign: TextAlign.justify,
            ),
            contentPadding: EdgeInsets.all(35.w),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style:
                      TextStyle(color: CustomColor.lightGrey, fontSize: 50.sp),
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
                  "Yes",
                  style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                ),
                color: Colors.white,
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("Post")
                      .doc(postId)
                      .update({
                    "notDonors": FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser.uid])
                  });
                  _notify.notify();
                  // saveAcceptedPost(
                  //     postId, posterUid, posterPhone, bloodGrp);
                  // setToNotifications(
                  //     postsList[index]["uid"],
                  //     postsList[index]["patientName"],
                  //     postsList[index]["postId"]);
                  // setToDonorList(
                  //     index, postsList[index]["uid"], postId, patientName);
                  // refreshList();
                  // setState(() {});
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          );
        });
  }
}
