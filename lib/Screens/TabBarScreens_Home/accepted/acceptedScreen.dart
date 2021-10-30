import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/MapUtils.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Model/PostCardDetails.dart';
import 'package:bd_app/Model/RequestAcceptedDetails.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/Widgets/loadingPost.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:bd_app/Screens/RepeatingScreens/PatientDetailScreenPush.dart';
import '../../ChatScreen.dart';

class acceptedScreen extends StatefulWidget {
  @override
  _acceptedScreenState createState() => _acceptedScreenState();
}

class _acceptedScreenState extends State<acceptedScreen> {
  // @override
  // bool get wantKeepAlive => true;

  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  final databaseReference = FirebaseDatabase.instance.reference();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  String uid;
  String _name;
  List acceptedPostList = [];
  List acceptedPostIdDetails = [];
  List<RequestedAcceptedDetails> acceptedDataList = [];
  String radioItem = '';
  bool loaded = false;
  List postIds = [];

  // Future<void> acceptedPosts() async {
  //   var acceptedRequestList = [];
  //   var acceptedPostIds = [];
  //   var acceptedPostIdDetails = [];
  //   try {
  //     DataSnapshot snapshot = await databaseReference
  //         .child("Users")
  //         .child(uid)
  //         .child("accepted")
  //         .once();
  //     if (snapshot != null && snapshot.value != null) {
  //       for (var key in (snapshot.value as Map).keys) {
  //         acceptedPostIds.add(key);
  //         acceptedRequestList.add(snapshot.value);
  //       }
  //       for (var i = 0; i < acceptedPostIds.length; i++) {
  //         DataSnapshot snapshotPostId = await databaseReference
  //             .child("Post")
  //             .child(acceptedPostIds[i])
  //             .once();
  //         acceptedPostIdDetails.add(snapshotPostId.value);
  //       }
  //       setState(() {
  //         this.acceptedPostList = acceptedRequestList;
  //         this.acceptedPostIdDetails = acceptedPostIdDetails;
  //         this.postIds = acceptedPostIds;
  //       });
  //     }
  //     print(acceptedPostIdDetails);
  //     setState(() {
  //       loaded = true;
  //     });
  //   } catch (e) {
  //     print(e);
  //     setState(() {
  //       loaded = true;
  //     });
  //   }
  // }

  // Future<void> setToNotifications(String notifyUserUid) async {
  //   print("Inside setToNotifications");
  //   List notifList = [];
  //   List temp = [];
  //   DataSnapshot snap =
  //       await databaseReference.child("Users").child(notifyUserUid).once();
  //   try {
  //     if (snap != null && snap.value != null) {
  //       if (snap.value["notifications"] != null) {
  //         temp = snap.value["notifications"];
  //         print("Temp List length: ${temp.length}");
  //         for (var i = 0; i < temp.length; i++) {
  //           notifList.add(snap.value["notifications"][i]);
  //         }
  //         notifList.add({
  //           "name": _name,
  //           "timeStamp": time.getCurrentTime()().millisecondsSinceEpoch,
  //           "tag": "NewMessage",
  //         });
  //         databaseReference
  //             .child("Users")
  //             .child(notifyUserUid)
  //             .update({"notifications": notifList});
  //       } else {
  //         notifList.add({
  //           "name": _name,
  //           "timeStamp": time.getCurrentTime()().millisecondsSinceEpoch,
  //           "tag": "NewMessage",
  //         });
  //         databaseReference
  //             .child("Users")
  //             .child(notifyUserUid)
  //             .update({"notifications": notifList});
  //       }
  //     } else {
  //       print("Snap value NULL");
  //     }
  //   } catch (e) {}
  // }

  // Future<void> getName() async {
  //   databaseReference.child("Users").child(uid).once().then((snapshot) {
  //     setState(() {
  //       _name = snapshot.value["name"];
  //     });
  //   });
  // }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    // await acceptedPosts();
    setState(() {});
    return null;
  }

  // Future<Widget> myBottomSheet(
  //     BuildContext context,
  //     int i,
  //     String postId,
  //     String posterUid,
  //     LatLng hospitalLocation,
  //     String patientName,
  //     String bloodGrp) {
  //   TextEditingController _responseController = TextEditingController();
  //   int currentView = 0;
  //   String selectedReason = "";
  //   return showModalBottomSheet(
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(25), topRight: Radius.circular(25))),
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) {
  //         return StatefulBuilder(
  //             // ignore: missing_return
  //             builder: (BuildContext context,
  //                 StateSetter setMode /*You can rename this!*/) {
  //           switch (currentView) {
  //             case 0:
  //               return Padding(
  //                 padding: MediaQuery.of(context).viewInsets,
  //                 child: Container(
  //                   padding: EdgeInsets.all(66.w),
  //                   height: 885.h,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             height: 20.h,
  //                             width: 170.w,
  //                             decoration: BoxDecoration(
  //                                 color: CustomColor.grey,
  //                                 borderRadius: BorderRadius.circular(20)),
  //                           )
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 70.h,
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(6),
  //                               onTap: () {
  //                                 setMode(() {
  //                                   currentView = 1;
  //                                 });
  //                               },
  //                               child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 15.h),
  //                                   child: Text(
  //                                     "Cancel Donation",
  //                                     style: TextStyle(fontSize: 45.sp),
  //                                   )),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 20.h,
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(6),
  //                               onTap: () async {
  //                                 String link = await _dynamicLinkService
  //                                     .createFirstPostLink(
  //                                         postId: postId,
  //                                         patientName: patientName,
  //                                         bloodGrp: bloodGrp);
  //                                 print(link);
  //                                 Clipboard.setData(
  //                                     new ClipboardData(text: link));
  //                               },
  //                               child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 15.h),
  //                                   child: Text(
  //                                     "Copy Link",
  //                                     style: TextStyle(fontSize: 45.sp),
  //                                   )),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 20.h,
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(6),
  //                               onTap: () {
  //                                 MapUtils.openMap(hospitalLocation.latitude,
  //                                     hospitalLocation.longitude);
  //                               },
  //                               child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 15.h),
  //                                   child: Text(
  //                                     "Direction to hospital",
  //                                     style: TextStyle(fontSize: 45.sp),
  //                                   )),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 20.h,
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           Expanded(
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(6),
  //                               onTap: () async {
  //                                 String link = await _dynamicLinkService
  //                                     .createFirstPostLink(
  //                                         postId: postId,
  //                                         patientName: patientName,
  //                                         bloodGrp: bloodGrp);
  //                                 print(link);
  //                                 Share.share(link, subject: 'Request');
  //                               },
  //                               child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 15.h),
  //                                   child: Text(
  //                                     "Share to...",
  //                                     style: TextStyle(fontSize: 45.sp),
  //                                   )),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 20.h,
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           Expanded(
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(6),
  //                               onTap: () async {
  //                                 {
  //                                   print(
  //                                       "::::::::::::::::::::::::::::::::::::::");
  //                                   String uid1 = uid;
  //                                   String uid2 = acceptedPostList[i]
  //                                       [postIds[i]]["userPostedUid"];
  //                                   String donorId;
  //                                   var OneWayChatRoomId = _commonUtilFunctions
  //                                       .getChatRoomIdByUid(uid1, uid2);
  //                                   var ReverseChatRoomId = _commonUtilFunctions
  //                                       .getChatRoomIdByUid(uid2, uid1);
  //                                   var ChatRoomId;
  //                                   print(
  //                                       "OneWayChatRoomId:  $OneWayChatRoomId");
  //                                   print(
  //                                       "OneWayChatRoomId:  $ReverseChatRoomId");
  //                                   Map<String, dynamic> chatRoomInfo = {
  //                                     "users": [
  //                                       uid,
  //                                       acceptedPostList[i][postIds[i]]
  //                                           ["userPostedUid"]
  //                                     ],
  //                                     "patientName": acceptedPostIdDetails[i]
  //                                         ["patientName"],
  //                                     "postId": acceptedPostList[i][postIds[i]]
  //                                         ["postId"],
  //                                     "bloodGrp": acceptedPostList[i]
  //                                         [postIds[i]]["bloodGrp"],
  //                                   };
  //                                   final snapShot = await FirebaseFirestore
  //                                       .instance
  //                                       .collection("ChatRooms")
  //                                       .doc(OneWayChatRoomId)
  //                                       .get();

  //                                   final RevSnapShot = await FirebaseFirestore
  //                                       .instance
  //                                       .collection("ChatRooms")
  //                                       .doc(ReverseChatRoomId)
  //                                       .get();

  //                                   if (snapShot.exists) {
  //                                     ChatRoomId = OneWayChatRoomId;
  //                                     donorId = ChatRoomId.toString()
  //                                         .replaceAll(uid, "");
  //                                     donorId =
  //                                         donorId.replaceAll("_", "").trim();
  //                                     print("Chat Already Exists");
  //                                   } else if (RevSnapShot.exists) {
  //                                     ChatRoomId = ReverseChatRoomId;
  //                                     donorId = ChatRoomId.toString()
  //                                         .replaceAll(uid, "");
  //                                     donorId =
  //                                         donorId.replaceAll("_", "").trim();
  //                                   } else {
  //                                     ChatRoomId = OneWayChatRoomId;
  //                                     donorId = ChatRoomId.toString()
  //                                         .replaceAll(uid, "");
  //                                     donorId =
  //                                         donorId.replaceAll("_", "").trim();
  //                                     FirebaseFirestore.instance
  //                                         .collection("ChatRooms")
  //                                         .doc(ChatRoomId)
  //                                         .set(chatRoomInfo);
  //                                   }
  //                                   setToNotifications(donorId);
  //                                   print("ChatRoomId Passing: $ChatRoomId");
  //                                   Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => ChatScreen(
  //                                                 donorName:
  //                                                     acceptedPostIdDetails[i]
  //                                                         ["userName"],
  //                                                 donorProfilePic:
  //                                                     acceptedPostIdDetails[i]
  //                                                         ["imageUrl"],
  //                                                 donorUid: acceptedPostList[i]
  //                                                         [postIds[i]]
  //                                                     ["userPostedUid"],
  //                                                 chatRoomId: ChatRoomId,
  //                                               )));
  //                                   print(
  //                                       ":::::::::::::::::::::::::::::::::::::::::::");
  //                                   print(chatRoomInfo);
  //                                 }
  //                               },
  //                               child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 15.h),
  //                                   child: Text(
  //                                     "Chat",
  //                                     style: TextStyle(fontSize: 45.sp),
  //                                   )),
  //                             ),
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             case 1:
  //               return Padding(
  //                 padding: MediaQuery.of(context).viewInsets,
  //                 child: Container(
  //                   height: 1150.h,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       SizedBox(
  //                         height: 70.h,
  //                       ),
  //                       Container(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Padding(
  //                                 padding: EdgeInsets.only(left: 70.w),
  //                                 child: Text(
  //                                   "Why are you not donating?",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 56.sp),
  //                                 )),
  //                             SizedBox(
  //                               height: 25.h,
  //                             ),
  //                             RadioListTile(
  //                               groupValue: selectedReason,
  //                               title: Text('Requirement already fulfilled'),
  //                               value: 'Requirement already fulfilled',
  //                               onChanged: (val) {
  //                                 setMode(() {
  //                                   selectedReason = val;
  //                                 });
  //                                 print(selectedReason);
  //                               },
  //                             ),
  //                             RadioListTile(
  //                               groupValue: selectedReason,
  //                               title: Text('Wrong location'),
  //                               value: 'Wrong location',
  //                               onChanged: (val) {
  //                                 setMode(() {
  //                                   selectedReason = val;
  //                                 });
  //                                 print(selectedReason);
  //                               },
  //                             ),
  //                             RadioListTile(
  //                               groupValue: selectedReason,
  //                               title: Text('Need a different blood group'),
  //                               value: 'Need a different blood group',
  //                               onChanged: (val) {
  //                                 setMode(() {
  //                                   selectedReason = val;
  //                                 });
  //                                 print(selectedReason);
  //                               },
  //                             ),
  //                             RadioListTile(
  //                               groupValue: selectedReason,
  //                               title: Text("Can't contact the person"),
  //                               value: "Can't contact the person",
  //                               onChanged: (val) {
  //                                 setMode(() {
  //                                   selectedReason = val;
  //                                 });
  //                                 print(selectedReason);
  //                               },
  //                             ),
  //                             Padding(
  //                               padding: EdgeInsets.only(left: 30.w),
  //                               child: ListTile(
  //                                 title: Text("Other"),
  //                                 onTap: () {
  //                                   setMode(() {
  //                                     currentView = 2;
  //                                   });
  //                                 },
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                       Align(
  //                         alignment: Alignment.bottomCenter,
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [
  //                             Expanded(
  //                                 child: FlatButton(
  //                                     onPressed: () async {
  //                                       print("Final: $selectedReason");
  //                                       try {
  //                                         DataSnapshot snapshot =
  //                                             await databaseReference
  //                                                 .child("Users")
  //                                                 .child(uid)
  //                                                 .child("CancelDonations")
  //                                                 .once();
  //                                         if (snapshot != null &&
  //                                             snapshot.value != null) {
  //                                           databaseReference
  //                                               .child("Users")
  //                                               .child(uid)
  //                                               .child("CancelDonations")
  //                                               .update({
  //                                             postId: {
  //                                               "postId": postId,
  //                                               "reason": selectedReason,
  //                                               "timeStamp": time.getCurrentTime()()
  //                                                   .millisecondsSinceEpoch
  //                                             }
  //                                           });
  //                                         } else {
  //                                           databaseReference
  //                                               .child("Users")
  //                                               .child(uid)
  //                                               .child("CancelDonations")
  //                                               .update({
  //                                             postId: {
  //                                               "postId": postId,
  //                                               "reason": selectedReason,
  //                                               "timeStamp": time.getCurrentTime()()
  //                                                   .millisecondsSinceEpoch
  //                                             }
  //                                           });
  //                                         }
  //                                         databaseReference
  //                                             .child("Users")
  //                                             .child(uid)
  //                                             .child("accepted")
  //                                             .child(postId)
  //                                             .remove();

  //                                         databaseReference
  //                                             .child("Users")
  //                                             .child(posterUid)
  //                                             .child("donorList")
  //                                             .child(postId)
  //                                             .child(uid)
  //                                             .update({
  //                                           "status": false,
  //                                         });

  //                                         setMode(() {
  //                                           currentView = 3;
  //                                         });

  //                                         setState(() {
  //                                           print("Remove From Main List");
  //                                           acceptedPostList.removeAt(i);
  //                                         });
  //                                       } catch (e) {
  //                                         print(e);
  //                                       }
  //                                     },
  //                                     color: CustomColor.red,
  //                                     child: Padding(
  //                                         padding: EdgeInsets.symmetric(
  //                                             vertical: 50.h),
  //                                         child: Text(
  //                                           "Submit",
  //                                           style: TextStyle(
  //                                               color: Colors.white,
  //                                               letterSpacing: 0.5),
  //                                         ))))
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             case 2:
  //               return Padding(
  //                 padding: MediaQuery.of(context).viewInsets,
  //                 child: Container(
  //                   height: 800.h,
  //                   padding: EdgeInsets.all(66.w),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Container(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             SizedBox(
  //                               height: 110.h,
  //                             ),
  //                             Text(
  //                               "Why are you not donating?",
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 56.sp),
  //                               textAlign: TextAlign.start,
  //                             ),
  //                             SizedBox(
  //                               height: 40.h,
  //                             ),
  //                             Form(
  //                               child: TextFormField(
  //                                 controller: _responseController,
  //                                 autofocus: true,
  //                                 // ignore: missing_return
  //                                 decoration: InputDecoration(
  //                                     hintText: "write your reason here..."),
  //                                 validator: (val) {
  //                                   if (val.isEmpty) {
  //                                     return "Please write your reason";
  //                                   }
  //                                 },
  //                                 onSaved: (val) {
  //                                   setMode(() {
  //                                     selectedReason = val;
  //                                   });
  //                                 },
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       Align(
  //                         alignment: Alignment.bottomCenter,
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [
  //                             Expanded(
  //                                 child: FlatButton(
  //                                     onPressed: () async {
  //                                       print("Final: $selectedReason");

  //                                       if (_responseController.text != null) {
  //                                         try {
  //                                           DataSnapshot snapshot =
  //                                               await databaseReference
  //                                                   .child("Users")
  //                                                   .child(uid)
  //                                                   .child("CancelDonations")
  //                                                   .once();
  //                                           if (snapshot != null &&
  //                                               snapshot.value != null) {
  //                                             databaseReference
  //                                                 .child("Users")
  //                                                 .child(uid)
  //                                                 .child("CancelDonations")
  //                                                 .update({
  //                                               postId: {
  //                                                 "postId": postId,
  //                                                 "reason":
  //                                                     _responseController.text,
  //                                                 "timeStamp": time.getCurrentTime()()
  //                                                     .millisecondsSinceEpoch
  //                                               }
  //                                             });
  //                                           } else {
  //                                             databaseReference
  //                                                 .child("Users")
  //                                                 .child(uid)
  //                                                 .child("CancelDonations")
  //                                                 .update({
  //                                               postId: {
  //                                                 "postId": postId,
  //                                                 "reason":
  //                                                     _responseController.text,
  //                                                 "timeStamp": time.getCurrentTime()()
  //                                                     .millisecondsSinceEpoch
  //                                               }
  //                                             });
  //                                           }
  //                                           databaseReference
  //                                               .child("Users")
  //                                               .child(uid)
  //                                               .child("accepted")
  //                                               .child(postId)
  //                                               .remove();

  //                                           databaseReference
  //                                               .child("Users")
  //                                               .child(posterUid)
  //                                               .child("donorList")
  //                                               .child(postId)
  //                                               .child(uid)
  //                                               .update({
  //                                             "status": false,
  //                                           });

  //                                           setMode(() {
  //                                             currentView = 3;
  //                                           });

  //                                           setState(() {
  //                                             print("About to remove");
  //                                             acceptedPostList.removeAt(i);
  //                                           });
  //                                         } catch (e) {
  //                                           print(e);
  //                                         }
  //                                       }
  //                                     },
  //                                     color: CustomColor.red,
  //                                     shape: RoundedRectangleBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(15)),
  //                                     child: Padding(
  //                                         padding: EdgeInsets.symmetric(
  //                                             vertical: 50.h),
  //                                         child: Text(
  //                                           "Submit",
  //                                           style: TextStyle(
  //                                               color: Colors.white,
  //                                               letterSpacing: 0.5),
  //                                         ))))
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             case 3:
  //               return Padding(
  //                 padding: MediaQuery.of(context).viewInsets,
  //                 child: Container(
  //                   padding: EdgeInsets.all(66.w),
  //                   height: 680.h,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             height: 20.h,
  //                             width: 170.w,
  //                             decoration: BoxDecoration(
  //                                 color: CustomColor.grey,
  //                                 borderRadius: BorderRadius.circular(20)),
  //                           )
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 70.h,
  //                       ),
  //                       Image.asset(
  //                         "images/icons/cancelDonation.png",
  //                         height: 90.h,
  //                       ),
  //                       SizedBox(
  //                         height: 30.h,
  //                       ),
  //                       Text(
  //                         "Request Cancelled",
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       SizedBox(
  //                         height: 20.h,
  //                       ),
  //                       Text(
  //                         "Your accepted request is been cancelled.The person cannot contact you.",
  //                         textAlign: TextAlign.center,
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               );
  //           }
  //         });
  //       });
  // }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    // acceptedPosts();
    // getName();
  }

  Notify _notify;

  @override
  Widget build(BuildContext context) {
    _notify = Provider.of(context);
    return RefreshIndicator(
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      key: refreshKey,
      onRefresh: refreshList,
      child: PaginateFirestore(
          key: UniqueKey(),
          itemsPerPage: 10,
          itemBuilderType: PaginateBuilderType.listView,
          // listview and gridview
          itemBuilder: (index, context, documentSnapshot) {
            return buildAcceptedPostCard(documentSnapshot);
          },
          separator: Divider(),
          isLive: true,
          query: FirebaseFirestore.instance
              .collection("Post")
              .where("donors",
                  arrayContains: FirebaseAuth.instance.currentUser.uid)
              .orderBy("bloodRequiredDateTime", descending: true),
          emptyDisplay: buildNoPostWidget()),
    );
  }

  AcceptedPostCard buildAcceptedPostCard(DocumentSnapshot snapshot) {
    bool isFinalDonor = false;
    bool alreadyDonated = false;
    List finalDonors = snapshot.data()["finalDonors"] ?? [];
    if (finalDonors.contains(uid)) {
      isFinalDonor = true;
    }
    List<dynamic> donatedRequests = snapshot.data()["donationRequest"] ?? [];
    print("donationRequest:::::::::::");
    print(donatedRequests);
    donatedRequests.forEach((element) {
      for (var key in element.keys.toList()) {
        if (key == uid) {
          alreadyDonated = true;
        }
      }
      print(element);
    });
    print(alreadyDonated);

    return AcceptedPostCard(
      alreadyDonated: alreadyDonated,
      expired: snapshot.data()["expired"],
      requirement: snapshot.data()["requirementType"],
      bloodGrp: snapshot.data()["requiredBloodGrp"],
      requiredDateAndTime: DateFormat('dd MMM yy, hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              snapshot.data()["bloodRequiredDateTime"].millisecondsSinceEpoch)),
      // _commonUtilFunctions.convertDateTimeDisplay(acceptedPostIdDetails[i]["bloodRequiredDate"]) + " " + acceptedPostIdDetails[i]["bloodRequiredTime"].toString(),
      purpose: snapshot.data()["purpose"],
      requiredUnits: snapshot.data()["requiredUnits"].toString(),
      cityName: snapshot.data()["hospitalCity"],
      patientName: snapshot.data()["patientName"],
      location: (Geolocator.distanceBetween(
                  snapshot.data()["hospitalLocation"]["geopoint"].latitude,
                  snapshot.data()["hospitalLocation"]["geopoint"].longitude,
                  _notify.currLoc.latitude,
                  _notify.currLoc.longitude) /
              1000)
          .floor()
          .toString(),
      age: snapshot.data()["patientAge"],
      areaName: snapshot.data()["hospitalArea"],
      hospitalName: snapshot.data()["hospitalName"],
      latLng: snapshot.data()["hospitalLocation"]["geopoint"],
      otherDeatials: snapshot.data()["otherDetails"],
      postId: snapshot.id,
      roomNumber: snapshot.data()["hospitalRoomNo"],
      patientAttender1: snapshot.data()["patientAttenderContact1"],
      patientAttender2: snapshot.data()["patientAttenderContact2"],
      patientAttender3: snapshot.data()["patientAttenderContact3"],
      patientAttenderName1: snapshot.data()["patientAttenderName1"],
      patientAttenderName2: snapshot.data()["patientAttenderName2"],
      patientAttenderName3: snapshot.data()["patientAttenderName3"],
      userCreatedUid: snapshot.data()["createdBy"],
      notDonors: snapshot.data()["notDonors"],
      isFinalDonor: isFinalDonor,
      document: snapshot,
      status: snapshot.data()["active"],
      // myBottomSheetCall: ()
      // => myBottomSheet(
      //     context, i ,
      //     acceptedPostList[i][postIds[i]]["postId"],
      //     acceptedPostList[i][postIds[i]]["userPostedUid"],
      //     LatLng(
      //         acceptedPostIdDetails[i]["hospitalLatLng"][0],
      //         acceptedPostIdDetails[i]["hospitalLatLng"][1]),
      //       acceptedPostIdDetails[i]["patientName"],
      //       acceptedPostIdDetails[i]["requiredBloodGrp"]),
      // onPress: () {
      //   Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreenPush(
      //     patientDetail: PatientDetails(
      //       posterPhone: acceptedPostIdDetails[i]["postedUserPhone"],
      //       patientName : acceptedPostIdDetails[i]["patientName"],
      //       reqDate :  acceptedPostIdDetails[i]["bloodRequiredDate"],
      //       reqTime: acceptedPostIdDetails[i]["bloodRequiredTime"],
      //       age: acceptedPostIdDetails[i]["patientAge"],
      //       reqBloodGroup : acceptedPostIdDetails[i]["requiredBloodGrp"],
      //       reqUnits: acceptedPostIdDetails[i]["requiredUnits"].toString(),
      //       hospitalName: acceptedPostIdDetails[i]["hospitalName"],
      //       hospitalCityName: acceptedPostIdDetails[i]["hospitalCityName"],
      //       areaName: acceptedPostIdDetails[i]["hospitalAreaName"],
      //       purpose: acceptedPostIdDetails[i]["purpose"],
      //       contact1:acceptedPostIdDetails[i]["patientAttender1"],
      //       contact2: acceptedPostIdDetails[i]["patientAttender2"],
      //       otherDetails:  acceptedPostIdDetails[i]["otherDetails"],
      //       imgUrl: acceptedPostIdDetails[i]["imageUrl"],
      //       postedUserName: acceptedPostIdDetails[i]["userName"],
      //       postId: acceptedPostIdDetails[i]["postId"],
      //       userPostedUid: acceptedPostList[i][postIds[i]]["userPostedUid"],
      //       hospitalCoordinates: LatLng(acceptedPostIdDetails[i]["hospitalLatLng"][0],acceptedPostIdDetails[i]["hospitalLatLng"][1])
      //     ),
      //   )));
      // },
    );
  }

  Center buildNoPostWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "You haven't accepted any post yet!!",
          style: TextStyle(color: CustomColor.grey, fontSize: 45.sp),
        ),
        SizedBox(
          height: 17.h,
        ),
        GestureDetector(
            onTap: refreshList,
            child: Text(
              "Refresh",
              style: TextStyle(color: CustomColor.red),
            )),
      ],
    ));
  }
}

class AcceptedPostCard extends StatelessWidget {
  final String bloodGrp;
  final String requirement;
  final String age;
  final DocumentSnapshot document;
  final String cityName;
  final String requiredDateAndTime;
  final String purpose;
  final String requiredUnits;
  final String location;
  final String patientName;
  final List<dynamic> notDonors;
  final bool isFinalDonor;
  final bool expired;
  final bool status;
  final String hospitalName,
      areaName,
      otherDeatials,
      postId,
      userCreatedUid,
      roomNumber,
      patientAttenderName1,
      patientAttender1,
      patientAttender2,
      patientAttenderName2,
      patientAttender3,
      patientAttenderName3;
  final GeoPoint latLng;
  final VoidCallback myBottomSheetCall;
  final VoidCallback onPress;
  final bool alreadyDonated;

  AcceptedPostCard({
    this.isFinalDonor,
    this.status,
    this.document,
    this.notDonors,
    this.hospitalName,
    this.areaName,
    this.latLng,
    this.expired,
    this.otherDeatials,
    this.patientAttender1,
    this.patientAttender2,
    this.patientAttender3,
    this.patientAttenderName1,
    this.patientAttenderName2,
    this.patientAttenderName3,
    this.roomNumber,
    this.bloodGrp,
    this.requirement,
    this.requiredDateAndTime,
    this.purpose,
    this.age,
    this.location,
    this.requiredUnits,
    this.cityName,
    this.patientName,
    this.onPress,
    this.myBottomSheetCall,
    this.postId,
    this.userCreatedUid,
    this.alreadyDonated,
    Key key,
  }) : super(key: key);
  Notify _notify;
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();

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
              "Are you sure you are not availble for donation?",
              style: TextStyle(fontSize: 42.sp, color: CustomColor.grey),
              textAlign: TextAlign.justify,
            ),
            contentPadding: EdgeInsets.all(35.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "Cancel",
                      style:
                          TextStyle(color: CustomColor.grey, fontSize: 50.sp),
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
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _notify = Provider.of<Notify>(context, listen: false);
    Color iconColor = Color(0xff535c68);
    CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
    bool active = true;
    if (notDonors != null) {
      notDonors.forEach((element) {
        if (element == FirebaseAuth.instance.currentUser.uid) {
          active = false;
        }
      });
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => NewPatientDetail(
              postId: document.id,
            ));
      },
      child: Column(
        children: [
          Card(
            elevation: 0,
            child: Container(
                padding: EdgeInsets.all(25.w),
                height: 450.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 103.h,
                            width: 103.h,
                            decoration: BoxDecoration(
                                color:
                                    active ? CustomColor.red : CustomColor.grey,
                                border: Border.all(
                                  color: active
                                      ? CustomColor.red
                                      : CustomColor.grey,
                                ),
                                borderRadius: BorderRadius.circular(80)),
                            child: Text(
                              bloodGrp,
                              style: TextStyle(
                                  fontSize: 43.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(
                            width: 60.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Requirement",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Required Date",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Required Units",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Purpose",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Patient Name",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Patient Age",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "City Name",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              ),
                              Text(
                                "Status",
                                style: TextStyle(
                                  fontSize: 33.sp,
                                  color:
                                      active ? Colors.black : CustomColor.grey,
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 33.sp,
                                    color: active
                                        ? Colors.black
                                        : CustomColor.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            child: Padding(
                              padding: EdgeInsets.only(left: 28.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    commonUtilFunctions
                                        .firstCaptial(requirement),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    requiredDateAndTime.toString(),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    requiredUnits.toString(),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    purpose.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    patientName.toString(),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    age.toString(),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    cityName.toString(),
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Text(
                                    "$location Km away",
                                    style: TextStyle(
                                      fontSize: 33.sp,
                                      color: active
                                          ? Colors.black
                                          : CustomColor.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 10.h,
                                        width: 10.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: status
                                              ? Colors.greenAccent
                                              : Colors.red,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Text(
                                        status ? "Active" : "Not Active",
                                        style: TextStyle(
                                          fontSize: 33.sp,
                                          color: active
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 40.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // GestureDetector(
                          //     onTap: () {
                          //       Get.to(() => NewPatientDetail(
                          //             postId: document.id,
                          //           ));
                          //     },
                          //     child: Icon(
                          //       Icons.remove_red_eye_outlined,
                          //       size: 20,
                          //       color: active ? iconColor : CustomColor.grey,
                          //     )),
                          (active && !isFinalDonor && !alreadyDonated)
                              ? GestureDetector(
                                  onTap: () {
                                    showCancelDialog(context);
                                  },
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    size: 20,
                                    color: iconColor,
                                  ))
                              : Container(),
                          status
                              ? InkWell(
                                  onTap: () async {
                                    String requiredDate =
                                        DateFormat('dd MMM yy').format(DateTime
                                            .fromMillisecondsSinceEpoch(document
                                                .data()["bloodRequiredDateTime"]
                                                .millisecondsSinceEpoch));
                                    String quote =
                                        "\n\n\"Donation Is A Small Act Of Kindness That Does Great And Big Wonders\"\n\n-Team Helping Hands";
                                    String msg =
                                        "$patientName requires $bloodGrp $requirement on $requiredDate\.\n\nClick the link below to see details.\n\n";
                                    commonUtilFunctions
                                        .loadingCircle("Loading...");
                                    String link = await _dynamicLinkService
                                        .createFirstPostLink(
                                            requirementType: requirement,
                                            postId: postId,
                                            bloodGrp: bloodGrp);
                                    Clipboard.setData(ClipboardData(
                                        text: msg + link + quote));
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
                                    print(link);
                                    Share.share(msg + link + quote);
                                  },
                                  child: Icon(
                                    Icons.share_outlined,
                                    size: 20,
                                    color: iconColor,
                                  ))
                              : Container(),
                          // active
                          //     ? InkWell(
                          //         onTap: () async {
                          //           String link = await _dynamicLinkService
                          //               .createFirstPostLink(
                          //                   postId: postId, bloodGrp: bloodGrp);
                          //           print(link);
                          //           Clipboard.setData(
                          //               new ClipboardData(text: link));
                          //           Get.back();
                          //           await Fluttertoast.showToast(
                          //               msg: "Link is copied to the clipboard.",
                          //               toastLength: Toast.LENGTH_LONG,
                          //               gravity: ToastGravity.CENTER,
                          //               timeInSecForIosWeb: 1,
                          //               backgroundColor: CustomColor.grey,
                          //               textColor: Colors.white,
                          //               fontSize: 16.0);
                          //         },
                          //         child: Icon(
                          //           Icons.copy,
                          //           size: 20,
                          //           color: Colors.black,
                          //         ))
                          //     : Container(),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
