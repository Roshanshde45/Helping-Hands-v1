import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/fullPagePhoto.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class DonorListScreen extends StatefulWidget {
  // final List<dynamic> donorList;

  final String postId;

  // DonorListScreen(
  //     {this.postData,
  //     this.donorList,
  //     this.donorsRespones,
  //     this.requirement,
  //     this.notDonors});
  DonorListScreen({this.postId});

  @override
  _DonorListScreenState createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  Map<String, dynamic> constValuesFB;
  String uid;
  List<dynamic> donorList;
  int donorListIndex;
  bool loaded = false;
  Notify _notify;
  DocumentSnapshot postData;
  List<dynamic> donorsRespones;
  List<dynamic> notDonors;
  String requirement;
  Time time;
  int donationPoints;
  // Future<void> getDonorListFunc() async{
  //   var donorList = [];
  //   try{
  //     DataSnapshot snapshot = await databaseReference.child("Users").child(uid).child("donorList").child(widget.postID).once();
  //     if(snapshot != null && snapshot.value != null){
  //       for (var key in (snapshot.value as Map).keys) {
  //         donorList.add(snapshot.value[key]);
  //       }
  //       print("::::::::::::::::::::::::::");
  //       setState(() {
  //         this.donorList = donorList;
  //         this.loaded = true;
  //       });
  //     }setState(() {
  //       this.loaded = true;
  //     });
  //   }catch(e){
  //     setState(() {
  //       this.loaded = true;
  //     });
  //     print(e);
  //   }
  //   print(donorList);
  // }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    _notify = Provider.of<Notify>(context, listen: false);

    donationPoints = _notify.dynamicValue["donationPoints"];
    print(donationPoints);
    super.initState();
    // getDonorListFunc();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Donors List",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: TimeLoading(
          child: StreamBuilder<DocumentSnapshot>(
              stream: _notify.firestore
                  .collection("Post")
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                donorList = snapshot.data.data()["donors"] ?? [];
                postData = snapshot.data;
                donorsRespones = snapshot.data.data()["response time"];
                notDonors = snapshot.data.data()["notDonors"];
                requirement = snapshot.data.data()["requirementType"];

                if (notDonors != null)
                  donorList
                      .removeWhere((element) => notDonors.contains(element));
                if (donorList.isEmpty) {
                  return Center(
                    child: Text("No Donors"),
                  );
                }
                return ListView.builder(
                    // separatorBuilder: (context,i) => Divider(
                    //   indent: 10,
                    //   endIndent: 10,
                    // ),
                    padding: EdgeInsets.all(15.w),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: donorList.length,
                    itemBuilder: (context, index) {
                      return buildDonorCard(index);
                    });
              }),
        ));
  }

  FutureBuilder<DocumentSnapshot> buildDonorCard(int index) {
    return FutureBuilder<DocumentSnapshot>(
        future:
            _notify.firestore.collection("Profile").doc(donorList[index]).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading");
          }
          Timestamp dobTimeStamp = snapshot.data.data()["dob"];
          DateTime dob = DateTime.fromMillisecondsSinceEpoch(
              dobTimeStamp.millisecondsSinceEpoch);
          DateTime currentTime = time.getCurrentTime();
          int age;
          age = currentTime.year - dob.year;
          if (currentTime.month < dob.month) {
            age = age - 1;
          } else if (currentTime.month == dob.month) {
            if (currentTime.day < dob.day) {
              age = age - 1;
            }
          }

          List<dynamic> donationReq = postData.data()["donationRequest"];
          bool requested = false;
          String donorPic;
          bool donated = false;
          String donatedType;
          if (donationReq != null) {
            donationReq.forEach((element) {
              element.forEach((key, value) {
                if (key == donorList[index]) {
                  requested = true;
                  donorPic = value["imageUrl"];
                  donatedType = value["donated"];
                  donatedType = donatedType.toLowerCase();
                }
              });
            });
          }

          List<dynamic> finalDonors = postData.data()["finalDonors"];
          if (finalDonors != null) {
            finalDonors.forEach((element) {
              if (element == donorList[index]) {
                requested = false;
                donated = true;
              }
            });
          }

          Timestamp responseTime;

          print("donor response");
          print(donorsRespones);
          List<dynamic> donorsResponesList = donorsRespones;
          donorsResponesList.forEach((element) {
            element.forEach((key, value) {
              if (key == donorList[index]) {
                responseTime = value;
              }
            });
          });
          DateTime responseDateTime = DateTime.fromMillisecondsSinceEpoch(
              responseTime.millisecondsSinceEpoch);

          DateTime lastDonated;
          if (requirement == "blood") {
            Timestamp lastDaontedTimeStamp =
                snapshot.data.data()["lastDonated"];
            if (lastDaontedTimeStamp != null) {
              lastDonated = DateTime.fromMillisecondsSinceEpoch(
                  lastDaontedTimeStamp.millisecondsSinceEpoch);
            }
          } else if (requirement == "plasma") {
            Timestamp lastDaontedTimeStamp =
                snapshot.data.data()["lastPlasmaDonated"];
            if (lastDaontedTimeStamp != null) {
              lastDonated = DateTime.fromMillisecondsSinceEpoch(
                  lastDaontedTimeStamp.millisecondsSinceEpoch);
            }
          } else if (requirement == "platelets") {
            Timestamp lastDaontedTimeStamp =
                snapshot.data.data()["lastPlateletsDonated"];
            if (lastDaontedTimeStamp != null) {
              lastDonated = DateTime.fromMillisecondsSinceEpoch(
                  lastDaontedTimeStamp.millisecondsSinceEpoch);
            }
          }

          bool availble = true;
          if (notDonors != null)
            notDonors.forEach((element) {
              if (element == donorList[index]) {
                availble = false;
              }
            });

          return DonorListCard(
            requested: requested,
            postId: postData.id,
            donationPoints: donationPoints,
            // proofImg: postData.data()["donationRequest"][index]["UIR9R8bGnYeAgOrTJMxnSA8HYrR2"]["imageUrl"],
            donated: donated,
            donatedType: donatedType,
            context: context,
            donorName: snapshot.data.data()["name"],
            donorUid: snapshot.data.data()["uid"],
            bloodGrp: snapshot.data.data()["bloodGrp"],
            postStatus: availble,
            address: snapshot.data.data()["userAddress"],
            age: age.toString(),
            location: (Geolocator.distanceBetween(
                        snapshot.data.data()["latLng"]["geopoint"].latitude,
                        snapshot.data.data()["latLng"]["geopoint"].longitude,
                        _notify.currLoc.latitude,
                        _notify.currLoc.longitude) /
                    1000)
                .floor()
                .toString(),
            lastDonated: lastDonated == null
                ? "I have not Donated"
                : DateFormat('dd MMM yy').format(lastDonated),
            // location:  snapshot.data.data()["location"].toString(),
            // cityName: snapshot.data.data()["cityName"],
            // lastDonated: snapshot.data.data()["lastDonated"] != null
            //     ? _commonUtilFunctions.convertDateTimeDisplay(
            //         donorList[index]["lastDonated"])
            //     : null,
            donorPic: donorPic ?? snapshot.data.data()["profilePic"],
            responseDate:
                DateFormat('dd MMM yy hh:mm a').format(responseDateTime),
            // responseDate: _commonUtilFunctions.convertDateTimeDisplay(
            //     donorList[index]["responseDate"]),
            onPressed: () => _commonUtilFunctions.makePhoneCall(
                snapshot.data.data()["phone"].toString(), true),
            getToChatScreen: () async {
              String uid1 = uid;
              String uid2 = snapshot.data.data()["uid"];
              var OneWayChatRoomId =
                  _commonUtilFunctions.getChatRoomIdByUid(uid1, uid2);
              var ReverseChatRoomId =
                  _commonUtilFunctions.getChatRoomIdByUid(uid2, uid1);
              var ChatRoomId;
              Map<String, dynamic> chatRoomInfo = {
                "users": [uid1, uid2],
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
                print("Chat Already Exists");
              } else if (RevSnapShot.exists) {
                ChatRoomId = ReverseChatRoomId;
              } else {
                ChatRoomId = OneWayChatRoomId;
                FirebaseFirestore.instance
                    .collection("ChatRooms")
                    .doc(ChatRoomId)
                    .set(chatRoomInfo);
              }
              print("ChatRoomId Passing: $ChatRoomId");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            donorName: snapshot.data.data()["name"],
                            donorProfilePic: snapshot.data.data()["profilePic"],
                            donorUid: snapshot.data.data()["uid"],
                            chatRoomId: ChatRoomId,
                            phone: snapshot.data.data()["phone"],
                          )));
            },
          );
        });
  }
}

class DonorListCard extends StatelessWidget {
  final BuildContext context;
  final bool requested;
  final String donorName;
  final String bloodGrp;
  final String age;
  final bool donated;
  final String donatedType;
  final String location;
  final String cityName;
  final String responseDate;
  final String lastDonated;
  final String donorPic;
  final String address;
  final String donorUid;
  final bool postStatus;
  final int donationPoints;
  final VoidCallback onPressed;
  final VoidCallback getToChatScreen;
  final String postId;

  // final bool status = false;

  const DonorListCard({
    this.postId,
    this.donated,
    this.requested,
    this.donationPoints,
    this.context,
    this.donatedType,
    this.donorName,
    this.donorUid,
    this.donorPic,
    this.age,
    this.bloodGrp,
    this.onPressed,
    this.address,
    this.location,
    this.cityName,
    this.getToChatScreen,
    this.responseDate,
    this.lastDonated,
    this.postStatus,
    Key key,
  }) : super(key: key);

  updateLifePoints(String uid) async {
    await FirebaseFirestore.instance
        .collection("Profile")
        .doc(uid)
        .update({"lifePoints": FieldValue.increment(donationPoints)});
  }

  setToNotification({String uid, String myName, String postId}) async {
    await updateLifePoints(uid);
    if (donationPoints != 0) {
      FirebaseFirestore.instance
          .collection("Profile")
          .doc(uid)
          .collection("notifications")
          .add({
        "timeStamp": FieldValue.serverTimestamp(),
        "tag": "Accepted",
        "points": donationPoints,
        "badge": "lifePoints",
        "receivedFrom": myName,
        "postId": postId,
      }).then((value) => print("Notification Sent for Acceptance"));
    }
  }

  Widget lableContainer(String lable, String fillText) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.7,
      // alignment: Alignment.centerLeft,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image.network(proofImg,height: 100.h,),
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            // height: 40.h,
            child: Text(
              lable,
              style: TextStyle(
                fontSize: 37.sp,
              ),
              maxLines: null,
            ),
          ),
          Text(
            ":",
            style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 10,
          ),
          // Spacer(),
          Container(
            // alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.34,
            // height: 60.h,
            child: Text(
              fillText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 37.sp,
                  color:
                      lable == "Blood Group" ? CustomColor.red : Colors.black,
                  fontWeight: lable == "Blood Group"
                      ? FontWeight.bold
                      : FontWeight.w400),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget donorData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lableContainer("Blood Group", bloodGrp),
        lableContainer("Donor Name", donorName),
        lableContainer("Age", age),
        lableContainer("Response Time", responseDate),
        lableContainer("Last Donated", lastDonated),
        lableContainer("Location", location + "Km away"),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          height: postStatus ? 0 : 60.h,
        ),
        postStatus
            ? (donated
                ? Row(
                    children: [
                      Image.asset(
                        "images/icons/checked.png",
                        height: 50.h,
                        color: CustomColor.red,
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Text(
                        "Donated",
                        style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.red),
                      )
                    ],
                  )
                : Container())
            : Text(
                "Not Available",
                style: TextStyle(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.red),
              ),
        SizedBox(
          height: 15.h,
        ),
      ],
    );
  }

  Widget contactDonor() {
    return Container(
      height: 200.h,
      width: 60.h,
      // width: double.minPositive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
              child: FittedBox(
                child: Icon(
                  Icons.question_answer_outlined,
                  // size: 24,
                ),
              ),
              onTap: postStatus ? getToChatScreen : null),
          InkWell(
              child: FittedBox(
                child: Icon(
                  Icons.call,
                  // size: 24,
                ),
              ),
              onTap: postStatus ? onPressed : null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Container(
        padding: EdgeInsets.fromLTRB(15.h, 20.h, 15.h, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 150.h,
                  width: 150.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: CustomColor.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: donorPic != null
                      ? Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => FullScreenPhoto(donorPic));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: donorPic,
                                progressIndicatorBuilder: (_, __, ___) {
                                  return Image.asset("images/person.png");
                                },
                                height: 150.h,
                                width: 150.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        )
                      : Image.asset("images/person.png"),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(child: donorData()),
                contactDonor(),
              ],
            ),
            // donorRequest(context)
          ],
        ),
      ),
    );
  }

  Container donorRequest(BuildContext context) {
    return Container(
      // alignment: Alignment.center,
      // width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("Donor Status"),

          // Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (requested && postStatus)
                  ? Text("Donated $donatedType for your request?")
                  : Container(),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      (requested && postStatus)
                          ? Flexible(
                              flex: 1,
                              child: FlatButton(
                                  onPressed: () {
                                    // FirebaseFirestore.instance
                                    //     .collection("Post")
                                    //     .doc(postId)
                                    //     .update({
                                    //   'finalDonors':
                                    //   FieldValue.arrayUnion([donorUid])
                                    // });
                                    showCancelRequestDialog(
                                        context, donorName, "Yes");
                                  },
                                  child: Text("Yes")),
                            )
                          : Container(),
                      (requested && postStatus)
                          ? Flexible(
                              flex: 1,
                              child: FlatButton(
                                  onPressed: () {
                                    // FirebaseFirestore.instance
                                    //     .collection("Post")
                                    //     .doc(postId)
                                    //     .update({
                                    //   "notDonors":
                                    //   FieldValue.arrayUnion([donorUid])
                                    // });
                                    showCancelRequestDialog(
                                        context, donorName, "No");
                                  },
                                  child: Text("No")),
                            )
                          : Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> showCancelRequestDialog(
      BuildContext context, String name, String yesOrNo) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(
              yesOrNo == "Yes" ? "Accept approval" : "Reject approval",
            ),
            titlePadding: EdgeInsets.only(top: 45.h, left: 35.w),
            content: Text(
              yesOrNo != "Yes"
                  ? "Are you sure $name hasn't donated to your request?"
                  : "Are you sure $name has donated for your request?",
              style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
              textAlign: TextAlign.justify,
            ),
            contentPadding: EdgeInsets.all(35.w),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: CustomColor.grey, fontSize: 50.sp),
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
                  yesOrNo == "Yes" ? "YES" : "No",
                  style: TextStyle(color: CustomColor.red, fontSize: 50.sp),
                ),
                color: Colors.white,
                onPressed: yesOrNo == "Yes"
                    ? () {
                        FirebaseFirestore.instance
                            .collection("Post")
                            .doc(postId)
                            .update({
                          'finalDonors': FieldValue.arrayUnion([donorUid])
                        });
                        setToNotification(
                          uid: donorUid,
                          myName: donorName,
                          postId: postId,
                        );
                        Get.back();
                      }
                    : () {
                        FirebaseFirestore.instance
                            .collection("Post")
                            .doc(postId)
                            .update({
                          "notDonors": FieldValue.arrayUnion([donorUid])
                        });
                        Get.back();
                      },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          );
        });
  }
}
