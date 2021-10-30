import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/MapUtils.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetailScreenPush extends StatefulWidget {
  PatientDetails patientDetail;
  final int index;
  PatientDetailScreenPush({this.patientDetail, this.index});
  @override
  _PatientDetailScreenPushState createState() =>
      _PatientDetailScreenPushState();
}

class _PatientDetailScreenPushState extends State<PatientDetailScreenPush> {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final databaseReference = FirebaseDatabase.instance.reference();
  String uid, _name;
  Time time;

  String convertDateTimeDisplay(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat serverFormatter = DateFormat('yMMMMd');
    final String formatted = serverFormatter.format(date);
    return formatted;
  }

  Future<void> getName() async {
    databaseReference.child("Users").child(uid).once().then((snapshot) {
      setState(() {
        _name = snapshot.value["name"];
      });
    });
  }

  Future<void> _makePhoneCall(String contact, bool direct) async {
    if (direct == true) {
      bool res = await FlutterPhoneDirectCaller.callNumber(contact);
    } else {
      String telScheme = 'tel:$contact';

      if (await canLaunch(telScheme)) {
        await launch(telScheme);
      } else {
        throw 'Could not launch $telScheme';
      }
    }
  }

  Future<void> setToNotifications(String notifyUserUid) async {
    print("Inside setToNotifications");
    List notifList = [];
    List temp = [];
    DataSnapshot snap =
        await databaseReference.child("Users").child(notifyUserUid).once();
    try {
      if (snap != null && snap.value != null) {
        if (snap.value["notifications"] != null) {
          temp = snap.value["notifications"];
          print("Temp List length: ${temp.length}");
          for (var i = 0; i < temp.length; i++) {
            notifList.add(snap.value["notifications"][i]);
          }
          notifList.add({
            "name": _name,
            "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
            "tag": "NewMessage",
          });
          databaseReference
              .child("Users")
              .child(notifyUserUid)
              .update({"notifications": notifList});
        } else {
          notifList.add({
            "name": _name,
            "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
            "tag": "NewMessage",
          });
          databaseReference
              .child("Users")
              .child(notifyUserUid)
              .update({"notifications": notifList});
        }
      } else {
        print("Snap value NULL");
      }
    } catch (e) {}
  }

  String getChatRoomIdByUid(String MyUid, String donorUid) {
    print("getChatRoomIdByUid");
    print("MyUid: $MyUid \n DonorUid: $donorUid");
    return "$MyUid\_$donorUid";
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Patient details"),
        ),
        body: TimeLoading(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(30.w),
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50.h,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 188.h,
                            width: 188.h,
                            decoration: BoxDecoration(
                                color: CustomColor.red,
                                border: Border.all(color: CustomColor.red),
                                borderRadius: BorderRadius.circular(80)),
                            child: Text(
                              widget.patientDetail.reqBloodGroup,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 62.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          Container(
                            alignment: Alignment.center,
                            // color: Colors.blue,
                            // padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Required Date",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Required Time",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Patient Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Required Blood Group",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Required Units",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Hospital Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Hospital City Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Area Name",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Purpose",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact1 != null
                                        ? Text(
                                            "Contact Number 1",
                                            style: TextStyle(fontSize: 38.sp),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact2 != null
                                        ? Text(
                                            "Contact Number 2",
                                            style: TextStyle(fontSize: 38.sp),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "Other Details",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact2 != null
                                        ? Text(":")
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact2 != null
                                        ? Text(":")
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(":"),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${convertDateTimeDisplay(widget.patientDetail.reqDate)}",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      "${widget.patientDetail.reqTime}",
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.patientName,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.reqBloodGroup,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.reqUnits.toString(),
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.hospitalName,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.hospitalCityName,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.areaName,
                                      style: TextStyle(fontSize: 38.sp),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.purpose,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact1 != null
                                        ? Row(
                                            children: [
                                              Text(
                                                widget.patientDetail.contact1,
                                                style:
                                                    TextStyle(fontSize: 38.sp),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    _makePhoneCall(
                                                        widget.patientDetail
                                                            .contact1,
                                                        true);
                                                  },
                                                  child: Icon(
                                                    Icons.call,
                                                    color: CustomColor.red,
                                                  ))
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    widget.patientDetail.contact2 != null
                                        ? Row(
                                            children: [
                                              Text(
                                                widget.patientDetail.contact2,
                                                style:
                                                    TextStyle(fontSize: 38.sp),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    _makePhoneCall(
                                                        widget.patientDetail
                                                            .contact2,
                                                        true);
                                                  },
                                                  child: Icon(
                                                    Icons.call,
                                                    color: CustomColor.red,
                                                  ))
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      widget.patientDetail.otherDetails,
                                      style: TextStyle(fontSize: 38.sp),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 120.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120.h,
                                  width: 120.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    color: CustomColor.red,
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          child: widget.patientDetail.imgUrl !=
                                                  null
                                              ? FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "images/person.png",
                                                  image: widget
                                                      .patientDetail.imgUrl,
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
                                  width: 10.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Posted By",
                                      style: TextStyle(
                                          color: CustomColor.grey,
                                          fontSize: 30.sp),
                                    ),
                                    Text(
                                      widget.patientDetail.postedUserName,
                                      style: TextStyle(
                                          color: CustomColor.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 33.sp),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.46,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        {
                                          print(
                                              "::::::::::::::::::::::::::::::::::::::");
                                          String uid1 = uid;
                                          String uid2 = widget
                                              .patientDetail.userPostedUid;
                                          String donorId;
                                          var OneWayChatRoomId =
                                              getChatRoomIdByUid(uid1, uid2);
                                          var ReverseChatRoomId =
                                              getChatRoomIdByUid(uid2, uid1);
                                          var ChatRoomId;
                                          print(
                                              "OneWayChatRoomId:  $OneWayChatRoomId");
                                          print(
                                              "OneWayChatRoomId:  $ReverseChatRoomId");
                                          Map<String, dynamic> chatRoomInfo = {
                                            "users": [
                                              uid,
                                              widget.patientDetail.userPostedUid
                                            ],
                                            "patientName": widget
                                                .patientDetail.patientName,
                                            "postId":
                                                widget.patientDetail.postId,
                                            "bloodGrp": widget
                                                .patientDetail.reqBloodGroup,
                                          };
                                          final snapShot =
                                              await FirebaseFirestore.instance
                                                  .collection("ChatRooms")
                                                  .doc(OneWayChatRoomId)
                                                  .get();

                                          final RevSnapShot =
                                              await FirebaseFirestore.instance
                                                  .collection("ChatRooms")
                                                  .doc(ReverseChatRoomId)
                                                  .get();

                                          if (snapShot.exists) {
                                            ChatRoomId = OneWayChatRoomId;
                                            donorId = ChatRoomId.toString()
                                                .replaceAll(uid, "");
                                            donorId = donorId
                                                .replaceAll("_", "")
                                                .trim();
                                            print("Chat Already Exists");
                                          } else if (RevSnapShot.exists) {
                                            ChatRoomId = ReverseChatRoomId;
                                            donorId = ChatRoomId.toString()
                                                .replaceAll(uid, "");
                                            donorId = donorId
                                                .replaceAll("_", "")
                                                .trim();
                                          } else {
                                            ChatRoomId = OneWayChatRoomId;
                                            donorId = ChatRoomId.toString()
                                                .replaceAll(uid, "");
                                            donorId = donorId
                                                .replaceAll("_", "")
                                                .trim();
                                            FirebaseFirestore.instance
                                                .collection("ChatRooms")
                                                .doc(ChatRoomId)
                                                .set(chatRoomInfo);
                                          }
                                          setToNotifications(donorId);
                                          print(
                                              "ChatRoomId Passing: $ChatRoomId");
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                        donorName: widget
                                                            .patientDetail
                                                            .postedUserName,
                                                        donorProfilePic: widget
                                                            .patientDetail
                                                            .imgUrl,
                                                        donorUid: widget
                                                            .patientDetail
                                                            .userPostedUid,
                                                        chatRoomId: ChatRoomId,
                                                      )));
                                          print(
                                              ":::::::::::::::::::::::::::::::::::::::::::");
                                          print(chatRoomInfo);
                                        }
                                      },
                                      child: Container(
                                        height: 127.h,
                                        width: 127.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            boxShadow: [
                                              BoxShadow(
                                                color: CustomColor.grey,
                                                blurRadius: 5.0,
                                              ),
                                            ]),
                                        child: Icon(
                                          Icons.chat,
                                          color: CustomColor.red,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 127.h,
                                      width: 127.w,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: CustomColor.grey,
                                              blurRadius: 5.0,
                                            ),
                                          ]),
                                      child: GestureDetector(
                                          onTap: () {
                                            MapUtils.openMap(
                                                widget
                                                    .patientDetail
                                                    .hospitalCoordinates
                                                    .latitude,
                                                widget
                                                    .patientDetail
                                                    .hospitalCoordinates
                                                    .longitude);
                                          },
                                          child: Icon(
                                            Icons.directions,
                                            color: CustomColor.red,
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 70.h,
                          ),
                          RaisedButton(
                            onPressed: () async {
                              String link =
                                  await _dynamicLinkService.createFirstPostLink(
                                requirementType: "Blood",
                                postId: widget.patientDetail.postId,
                                bloodGrp: widget.patientDetail.reqBloodGroup,
                              );
                              print(link);
                              Share.share(link, subject: 'Request');
                            },
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 80.w),
                                child: Text(
                                  "Share",
                                  style: TextStyle(color: Colors.white),
                                )),
                            color: CustomColor.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
