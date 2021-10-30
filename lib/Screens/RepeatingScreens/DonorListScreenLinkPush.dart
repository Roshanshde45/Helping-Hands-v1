// import 'package:bd_app/Screens/ChatScreen.dart';
// import 'package:bd_app/provider/server.dart';
// import 'package:bd_app/services/CommonUtilFuctions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class DonorListScreenLinkPush extends StatefulWidget {
//   final String postId;
//   DonorListScreenLinkPush({this.postId});
//   @override
//   _DonorListScreenLinkPushState createState() =>
//       _DonorListScreenLinkPushState();
// }

// class _DonorListScreenLinkPushState extends State<DonorListScreenLinkPush> {
//   final databaseReference = FirebaseDatabase.instance.reference();
//   final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
//   String uid;
//   List<dynamic> donorList;
//   List<dynamic> notDonors;
//   List<dynamic> donorsRespones;
//   String requirement;
//   int donorListIndex;
//   bool loaded = false;
//   Notify _notify;

//   getDonorList() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection("Post")
//           .doc(widget.postId)
//           .get();
//       setState(() {
//         donorList = snapshot.data()["donors"];
//         notDonors = snapshot.data()["notDonors"];
//         donorsRespones = snapshot.data()["response time"];
//         requirement = snapshot.data()["requirementType"];
//         loaded = true;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   void initState() {
//     uid = FirebaseAuth.instance.currentUser.uid;
//     loaded = false;
//     if (widget.postId != null) {
//       getDonorList();
//     } else {
//       print("PostId Called On Null");
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _notify = Provider.of<Notify>(context);
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Donors List"),
//         ),
//         body: !loaded
//             ? Container(
//                 child: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               )
//             : ListView.builder(
//                 padding: EdgeInsets.all(15.w),
//                 scrollDirection: Axis.vertical,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: donorList.length,
//                 itemBuilder: (context, index) {
//                   return FutureBuilder<DocumentSnapshot>(
//                       future: FirebaseFirestore.instance
//                           .collection("Profile")
//                           .doc(donorList[index])
//                           .get(),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData && loaded) {
//                           return Text("Loading");
//                         }
//                         DateTime dob;
//                         var temp = snapshot.data.data()["dob"];
//                         if (temp.runtimeType == int) {
//                           dob = DateTime.fromMillisecondsSinceEpoch(temp);
//                         } else {
//                           Timestamp t = temp;
//                           dob = t.toDate();
//                         }

//                         DateTime currentTime = time.getCurrentTime()();
//                         int age;
//                         age = currentTime.year - dob.year;
//                         if (currentTime.month < dob.month) {
//                           age = age - 1;
//                         } else if (currentTime.month == dob.month) {
//                           if (currentTime.day < dob.day) {
//                             age = age - 1;
//                           }
//                         }

//                         Timestamp responseTime;
//                         print("donor response");
//                         print(donorsRespones);
//                         List<dynamic> donorsResponesList = donorsRespones;
//                         donorsResponesList.forEach((element) {
//                           element.forEach((key, value) {
//                             if (key == donorList[index]) {
//                               responseTime = value;
//                             }
//                           });
//                         });
//                         DateTime responseDateTime =
//                             DateTime.fromMillisecondsSinceEpoch(
//                                 responseTime.millisecondsSinceEpoch);

//                         DateTime lastDonated;
//                         if (requirement == "blood") {
//                           int lastDaontedTimeStamp =
//                               snapshot.data.data()["lastDonated"];
//                           if (lastDaontedTimeStamp != null) {
//                             lastDonated = DateTime.fromMillisecondsSinceEpoch(
//                                 lastDaontedTimeStamp);
//                           }
//                         } else if (requirement == "plasma") {
//                           int lastDaontedTimeStamp =
//                               snapshot.data.data()["lastPlasmaDonated"];
//                           if (lastDaontedTimeStamp != null) {
//                             lastDonated = DateTime.fromMillisecondsSinceEpoch(
//                                 lastDaontedTimeStamp);
//                           }
//                         }

//                         bool availble = true;
//                         if (notDonors != null)
//                           notDonors.forEach((element) {
//                             if (element == donorList[index]) {
//                               availble = false;
//                             }
//                           });

//                         return DonorListCard(
//                           context: context,
//                           donorName: snapshot.data.data()["name"],
//                           bloodGrp: snapshot.data.data()["bloodGrp"],
//                           postStatus: availble,
//                           address: snapshot.data.data()["userAddress"],
//                           age: age.toString(),
//                           location: (Geolocator.distanceBetween(
//                                       snapshot.data
//                                           .data()["latLng"]["geopoint"]
//                                           .latitude,
//                                       snapshot.data
//                                           .data()["latLng"]["geopoint"]
//                                           .longitude,
//                                       _notify.currLoc.latitude,
//                                       _notify.currLoc.longitude) /
//                                   1000)
//                               .floor()
//                               .toString(),
//                           lastDonated: lastDonated == null
//                               ? "I have not Donated"
//                               : DateFormat('dd MMM yy').format(lastDonated),
//                           // location:  snapshot.data.data()["location"].toString(),
//                           // cityName: snapshot.data.data()["cityName"],
//                           // lastDonated: snapshot.data.data()["lastDonated"] != null
//                           //     ? _commonUtilFunctions.convertDateTimeDisplay(
//                           //         donorList[index]["lastDonated"])
//                           //     : null,
//                           donorUid: snapshot.data.data()["uid"],
//                           donorProfilePic:
//                               snapshot.data.data()["profileImageUrl"],
//                           responseDate: DateFormat('dd MMM yy, hh:mm a')
//                               .format(responseDateTime),
//                           // responseDate: _commonUtilFunctions.convertDateTimeDisplay(
//                           //     donorList[index]["responseDate"]),
//                           onPressed: () => _commonUtilFunctions.makePhoneCall(
//                               snapshot.data.data()["phone"].toString(), true),
//                           getToChatScreen: () async {
//                             String uid1 = uid;
//                             String uid2 = snapshot.data.data()["uid"];
//                             var OneWayChatRoomId = _commonUtilFunctions
//                                 .getChatRoomIdByUid(uid1, uid2);
//                             var ReverseChatRoomId = _commonUtilFunctions
//                                 .getChatRoomIdByUid(uid2, uid1);
//                             var ChatRoomId;
//                             Map<String, dynamic> chatRoomInfo = {
//                               "users": [uid1, uid2],
//                             };
//                             final snapShot = await FirebaseFirestore.instance
//                                 .collection("ChatRooms")
//                                 .doc(OneWayChatRoomId)
//                                 .get();

//                             final RevSnapShot = await FirebaseFirestore.instance
//                                 .collection("ChatRooms")
//                                 .doc(ReverseChatRoomId)
//                                 .get();

//                             if (snapShot.exists) {
//                               ChatRoomId = OneWayChatRoomId;
//                               print("Chat Already Exists");
//                             } else if (RevSnapShot.exists) {
//                               ChatRoomId = ReverseChatRoomId;
//                             } else {
//                               ChatRoomId = OneWayChatRoomId;
//                               FirebaseFirestore.instance
//                                   .collection("ChatRooms")
//                                   .doc(ChatRoomId)
//                                   .set(chatRoomInfo);
//                             }
//                             print("ChatRoomId Passing: $ChatRoomId");
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ChatScreen(
//                                           donorName:
//                                               snapshot.data.data()["name"],
//                                           donorProfilePic: snapshot.data
//                                               .data()["profilePic"],
//                                           donorUid: snapshot.data.data()["uid"],
//                                           chatRoomId: ChatRoomId,
//                                         )));
//                           },
//                         );
//                       });
//                 }));
//   }
// }

// class DonorListCard extends StatelessWidget {
//   final BuildContext context;
//   final String donorName;
//   final String bloodGrp;
//   final String age;
//   final String location;
//   final String cityName;
//   final String responseDate;
//   final String lastDonated;
//   final String donorProfilePic;
//   final String address;
//   final String donorUid;
//   final bool postStatus;
//   final VoidCallback onPressed;
//   final VoidCallback getToChatScreen;
//   // final bool status = false;

//   const DonorListCard({
//     this.context,
//     this.donorName,
//     this.donorUid,
//     this.donorProfilePic,
//     this.age,
//     this.bloodGrp,
//     this.onPressed,
//     this.address,
//     this.location,
//     this.cityName,
//     this.getToChatScreen,
//     this.responseDate,
//     this.lastDonated,
//     this.postStatus,
//     Key key,
//   }) : super(key: key);

//   Widget lableContainer(String lable, String fillText) {
//     return Container(
//       alignment: Alignment.center,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width * 0.3,
//             height: 40.h,
//             child: Text(
//               lable,
//               style: TextStyle(
//                 fontSize: 34.sp,
//               ),
//               maxLines: null,
//             ),
//           ),
//           Text(
//             ":",
//             style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 40.sp,
//                 fontWeight: FontWeight.bold),
//           ),
//           FittedBox(
//             fit: BoxFit.fill,
//             child: Container(
//               alignment: Alignment.topLeft,
//               width: MediaQuery.of(context).size.width * 0.5,
//               height: 60.h,
//               child: Text(
//                 fillText,
//                 style: TextStyle(
//                     fontSize: 34.sp,
//                     color: lable == "Blood Group" ? CustomColor.redr.red : Colors.black,
//                     fontWeight: lable == "Blood Group"
//                         ? FontWeight.bold
//                         : FontWeight.w400),
//                 maxLines: null,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Container(
//         padding: EdgeInsets.all(20.w),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Container(
//                 //   alignment: Alignment.center,
//                 //   height: 40,
//                 //   width: 40,
//                 //   decoration: BoxDecoration(
//                 //     color: CustomColor.redr.red,
//                 //     borderRadius: BorderRadius.circular(100),
//                 //   ),
//                 //   child: Text(bloodGrp,style: TextStyle(
//                 //       color: Colors.white,
//                 //       fontWeight: FontWeight.bold
//                 //   ),),
//                 // ),
//                 Container(
//                   alignment: Alignment.center,
//                   width: MediaQuery.of(context).size.width * 0.9,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       lableContainer("Blood Group", bloodGrp),
//                       lableContainer("Donor Name", donorName),
//                       lableContainer("Age", age),
//                       lableContainer("Response Time", responseDate),
//                       lableContainer("Last Donated", lastDonated),
//                       SizedBox(
//                         height: 10.h,
//                       ),
//                       Container(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               alignment: Alignment.topLeft,
//                               width: MediaQuery.of(context).size.width * 0.3,
//                               height: 35.h,
//                               child: Text(
//                                 "Location",
//                                 style: TextStyle(
//                                   fontSize: 34.sp,
//                                 ),
//                                 maxLines: null,
//                               ),
//                             ),
//                             Text(
//                               ":",
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 40.sp,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             FittedBox(
//                               fit: BoxFit.fill,
//                               child: Container(
//                                 alignment: Alignment.topLeft,
//                                 width: MediaQuery.of(context).size.width * 0.5,
//                                 // height: 80.h,
//                                 // height: 80.h,
//                                 child: Text(location + "Km away",
//                                     style: TextStyle(
//                                       fontSize: 34.sp,
//                                     )),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: postStatus ? 0 : 15.h,
//                       ),
//                       postStatus
//                           ? Container()
//                           : Text(
//                               "Not Available",
//                               style: TextStyle(
//                                   fontSize: 38.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: CustomColor.redr.red),
//                             ),
//                       Divider(),
//                       Row(
//                         children: [
//                           IconButton(
//                               icon: Icon(Icons.question_answer_outlined),
//                               onPressed: postStatus ? getToChatScreen : null),
//                           IconButton(
//                               icon: Icon(Icons.call),
//                               onPressed: postStatus ? onPressed : null)
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
