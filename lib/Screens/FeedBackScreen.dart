import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:bd_app/Screens/FeedBackForm.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedBackScreen extends StatefulWidget {
  final String postId;
  final String uid;
  FeedBackScreen({this.postId, this.uid});
  @override
  _FeedBackScreenState createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  bool noneBool = false;
  List donorList = [];
  int donorListIndex;
  bool loaded = false;
  String uid;
  Time time;
  Future<void> getDonorListFunc() async {
    var donorList = [];
    try {
      DataSnapshot snapshot = await databaseReference
          .child("Users")
          .child(widget.uid)
          .child("donorList")
          .child(widget.postId)
          .once();
      if (snapshot != null && snapshot.value != null) {
        for (var key in (snapshot.value as Map).keys) {
          donorList.add(snapshot.value[key]);
        }
        for (var j = 0; j < donorList.length; j++) {
          donorList[j]["donatedBool"] = false;
        }

        print("::::::::::::::::::::::::::");
        setState(() {
          this.donorList = donorList;
          this.loaded = true;
        });
      }
      setState(() {
        this.loaded = true;
      });
    } catch (e) {
      setState(() {
        this.loaded = true;
      });
      print(e);
    }
    print(donorList);
  }

  saveFeedBack() async {
    var donatedUsers = [];
    if (!noneBool) {
      for (var i = 0; i < donorList.length; i++) {
        if (donorList[i]["donatedBool"] == true) {
          donatedUsers.add(donorList[i]["donorUid"]);
        }
      }
      for (var j = 0; j < donatedUsers.length; j++) {
        await databaseReference
            .child("Users")
            .child(donatedUsers[j])
            .child("UserDonated")
            .update({
          time.getCurrentTime().millisecondsSinceEpoch.toString(): {
            "toUser": uid,
          }
        });
      }
      await databaseReference.child("Post").child(widget.postId).update({
        "status": false,
      });
    } else {
      await databaseReference.child("Post").child(widget.postId).update({
        "status": false,
      });
    }
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
    getDonorListFunc();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "",
            style: TextStyle(color: CustomColor.red),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: CustomColor.red),
          elevation: 0.0,
        ),
        body: TimeLoading(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(30.w, 10.w, 30.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Feedback",
                      style: TextStyle(
                          color: CustomColor.red,
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    Text(
                      "Who filled your requirement?",
                      style:
                          TextStyle(color: CustomColor.grey, fontSize: 50.sp),
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    Row(
                      children: [
                        CircularCheckBox(
                            value: noneBool,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onChanged: (bool x) {
                              setState(() {
                                noneBool = !noneBool;
                              });
                            }),
                        Text("None of the above")
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Expanded(
                      child: Container(
                          child: ListView.builder(
                              itemCount: donorList.length,
                              itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(bottom: 20.h),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                              padding: EdgeInsets.all(25.w),
                                              height: 330.h,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: CustomColor
                                                          .lightGrey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              80),
                                                                  child: donorList[index]
                                                                              [
                                                                              "profileImageUrl"] !=
                                                                          null
                                                                      ? FadeInImage
                                                                          .assetNetwork(
                                                                          placeholder:
                                                                              "images/person.png",
                                                                          height:
                                                                              130.h,
                                                                          width:
                                                                              130.h,
                                                                          image:
                                                                              donorList[index]["profileImageUrl"],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          "images/person.png",
                                                                          height:
                                                                              130.h,
                                                                        )),
                                                              SizedBox(
                                                                height: 15.h,
                                                              ),
                                                              Text(
                                                                donorList[index]
                                                                        [
                                                                        "bloodGrp"]
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        45.sp,
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ]),
                                                        SizedBox(
                                                          width: 25.w,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Donor Name",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      33.sp),
                                                            ),
                                                            Text(
                                                              "Came from",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      33.sp),
                                                            ),
                                                            Text(
                                                              "Donated Units",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      33.sp),
                                                            ),
                                                            Text(
                                                              "Last Donated",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      33.sp),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.w),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ":",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              Text(
                                                                ":",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              Text(
                                                                ":",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              Text(
                                                                ":",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 28.w),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                donorList[index]
                                                                    [
                                                                    "donorName"],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              Text(
                                                                "10Km away",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              Text(
                                                                "1",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        33.sp),
                                                              ),
                                                              donorList[index][
                                                                          "lastDonated"] !=
                                                                      null
                                                                  ? Text(
                                                                      _commonUtilFunctions.convertDateTimeDisplay(
                                                                          donorList[index]
                                                                              [
                                                                              "lastDonated"]),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              33.sp),
                                                                    )
                                                                  : Text(
                                                                      "Haven't donated yet",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              33.sp),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 20.w),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () async {
                                                              String uid1 = uid;
                                                              String uid2 =
                                                                  donorList[
                                                                          index]
                                                                      [
                                                                      "donorUid"];
                                                              String donorId;
                                                              var OneWayChatRoomId =
                                                                  _commonUtilFunctions
                                                                      .getChatRoomIdByUid(
                                                                          uid1,
                                                                          uid2);
                                                              var ReverseChatRoomId =
                                                                  _commonUtilFunctions
                                                                      .getChatRoomIdByUid(
                                                                          uid2,
                                                                          uid1);
                                                              var ChatRoomId;
                                                              print(
                                                                  "OneWayChatRoomId:  $OneWayChatRoomId");
                                                              print(
                                                                  "OneWayChatRoomId:  $ReverseChatRoomId");
                                                              Map<String,
                                                                      dynamic>
                                                                  chatRoomInfo =
                                                                  {
                                                                "users": [
                                                                  uid,
                                                                  donorList[
                                                                          index]
                                                                      [
                                                                      "donorUid"]
                                                                ],
                                                                "patientName":
                                                                    donorList[
                                                                            index]
                                                                        [
                                                                        "patientName"],
                                                                "postId": donorList[
                                                                        index]
                                                                    ["postId"],
                                                              };
                                                              final snapShot =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "ChatRooms")
                                                                      .doc(
                                                                          OneWayChatRoomId)
                                                                      .get();

                                                              final RevSnapShot =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "ChatRooms")
                                                                      .doc(
                                                                          ReverseChatRoomId)
                                                                      .get();

                                                              if (snapShot
                                                                  .exists) {
                                                                ChatRoomId =
                                                                    OneWayChatRoomId;
                                                                donorId = ChatRoomId
                                                                        .toString()
                                                                    .replaceAll(
                                                                        uid,
                                                                        "");
                                                                donorId = donorId
                                                                    .replaceAll(
                                                                        "_", "")
                                                                    .trim();
                                                                print(
                                                                    "Chat Already Exists");
                                                              } else if (RevSnapShot
                                                                  .exists) {
                                                                ChatRoomId =
                                                                    ReverseChatRoomId;
                                                                donorId = ChatRoomId
                                                                        .toString()
                                                                    .replaceAll(
                                                                        uid,
                                                                        "");
                                                                donorId = donorId
                                                                    .replaceAll(
                                                                        "_", "")
                                                                    .trim();
                                                              } else {
                                                                ChatRoomId =
                                                                    OneWayChatRoomId;
                                                                donorId = ChatRoomId
                                                                        .toString()
                                                                    .replaceAll(
                                                                        uid,
                                                                        "");
                                                                donorId = donorId
                                                                    .replaceAll(
                                                                        "_", "")
                                                                    .trim();
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "ChatRooms")
                                                                    .doc(
                                                                        ChatRoomId)
                                                                    .set(
                                                                        chatRoomInfo);
                                                              }
                                                              print(
                                                                  "ChatRoomId Passing: $ChatRoomId");
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ChatScreen(
                                                                            donorName:
                                                                                donorList[index]["userName"],
                                                                            donorProfilePic:
                                                                                donorList[index]["profileImageUrl"],
                                                                            donorUid:
                                                                                donorList[index]["donorUid"],
                                                                            chatRoomId:
                                                                                ChatRoomId,
                                                                          )));
                                                            },
                                                            child: Icon(
                                                              Icons.chat,
                                                              size: 20,
                                                              color: CustomColor
                                                                  .red,
                                                            )),
                                                        GestureDetector(
                                                            onTap: () {
                                                              _commonUtilFunctions
                                                                  .makePhoneCall(
                                                                      donorList[
                                                                              index]
                                                                          [
                                                                          "phone"],
                                                                      false);
                                                            },
                                                            child: Icon(
                                                              Icons.phone,
                                                              size: 20,
                                                              color: CustomColor
                                                                  .red,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 20.w),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Checkbox(
                                                          value: donorList[
                                                                  index]
                                                              ["donatedBool"],
                                                          onChanged: (val) {
                                                            setState(() {
                                                              donorList[index][
                                                                      "donatedBool"] =
                                                                  !donorList[
                                                                          index]
                                                                      [
                                                                      "donatedBool"];
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ))),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ignore: deprecated_member_use
                    Expanded(
                        child: FlatButton(
                      onPressed: () async {
                        await saveFeedBack();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedBackForm()));
                      },
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 50.h),
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          )),
                      color: CustomColor.red,
                    ))
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
