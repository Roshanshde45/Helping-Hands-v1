import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/LifePoints.dart';
import 'package:bd_app/Screens/RepeatingScreens/DonorListScreenLinkPush.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/myRequests/DonorListScreen.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:path/path.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final databaseReference = FirebaseFirestore.instance;
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  String uid;
  bool loaded = false;
  List notificationsList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  // Future<void> getAllNotification() async {
  //   List temp = [];
  //   List notifyList = [];

  //   QuerySnapshot snapshot = await databaseReference
  //       .collection("Profile")
  //       .doc(uid)
  //       .collection("notifications").orderBy("timeStamp",descending: true)
  //       .get();

  //   print("Notification List Length: ${notifyList.length}");

  //   for(var doc in snapshot.docs){
  //     notifyList.add(doc);
  //   }
  //   setState(() {
  //     this.notificationsList = notifyList;
  //     loaded = true;
  //   });
  //   print("Notification List Length: ${snapshot.docs.length}");

  // }

  // Widget donorAppearedCard(DocumentSnapshot snapshot) {
  //   return Material(
  //     child: InkWell(
  //       onTap: () {
  //         // Navigator.push(context, MaterialPageRoute(builder: (context) => DonorListScreen(
  //         //   postID: notificationsList[index]["postId"],
  //         // )));
  //       },
  //       child: Card(
  //         elevation: 0,
  //         color: CustomColor.grey[200],
  //         child: Container(
  //           alignment: Alignment.centerLeft,
  //           padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 50.3.h),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Image.asset("images/icons/volunteer.png",height: 80.h,),
  //                   SizedBox(width: 20.w,),
  //                   Flexible(
  //                     child: RichText(text: TextSpan(
  //                         children: [
  //                           TextSpan(text: snapshot.data()["donorName"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 42.sp),),
  //                           TextSpan(text: " is ready to donate for ",style: TextStyle(color: Colors.black)),
  //                           TextSpan(text: snapshot.data()["patientName"],style: TextStyle(fontSize: 42.sp,fontWeight: FontWeight.bold,color: Colors.black))
  //                         ]
  //                     )),
  //                   )
  //                 ],
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 // crossAxisAlignment: CrossAxisAlignment.baseline,
  //                 children: [
  //                   SizedBox(width: 87.w,),
  //                   Text(_commonUtilFunctions.convertDateTimeDisplay(snapshot.data()["timeStamp"]),style: TextStyle(color: CustomColor.grey),)
  //                 ],
  //               )
  //             ],
  //           ),),),
  //     ),
  //   );
  // }

  Widget donorAppearedCard(
      BuildContext context, DocumentSnapshot snapshot, String postId) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (postId != null) {
              Get.to(DonorListScreen(
                postId: postId,
              ));
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            child: Container(
              child: Row(
                children: [
                  Image.asset(
                    "images/icons/okicon.png",
                    height: 80.h,
                    // color: CustomColor.red,
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: RichText(
                              maxLines: 2,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: snapshot.data()["donorName"],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 38.sp,
                                    fontFamily: "OpenSans",
                                  ),
                                ),
                                TextSpan(
                                    text: " is ready to donate for ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "OpenSans",
                                    )),
                                TextSpan(
                                    text: snapshot.data()["patientName"],
                                    style: TextStyle(
                                        fontSize: 38.sp, color: Colors.black))
                              ])),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Click here to view you donor list.",
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                            Text(
                              _commonUtilFunctions.convertDateTimeDisplay(
                                  snapshot.data()["timeStamp"]),
                              style: TextStyle(
                                  fontSize: 28.sp, color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget newMessageCard() {
    return Card(
      elevation: 0,
      color: Color(0xffdfe6e9),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 50.3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  "images/icons/new_message.png",
                  height: 70.h,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    // TextSpan(text:notificationsList[index]["donorName"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 40.sp),),
                    TextSpan(
                        text: "You have received a new message from ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 42.sp,
                        )),
                    TextSpan(
                        text: "name",
                        style: TextStyle(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))
                  ])),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget lifePointsReceivedCard(DocumentSnapshot snapshot) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(LifePointsScreen());
          },
          child: Card(
            elevation: 0,
            // color: Color(0xffdfe6e9),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Row(
                children: [
                  Image.asset(
                    "images/icons/heart_attack.png",
                    height: 80.h,
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Received ${snapshot.data()["points"]} "
                            "Life Points ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 38.sp,
                              fontFamily: "OpenSans",
                            )),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Click here to view you life points.",
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                            Text(
                              _commonUtilFunctions.convertDateTimeDisplay(
                                  snapshot.data()["timeStamp"]),
                              style: TextStyle(
                                  fontSize: 28.sp, color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget requirementChangesCard(
      BuildContext context, DocumentSnapshot snapshot) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(NewPatientDetail(
              postId: snapshot.data()["postId"],
            ));
          },
          child: Card(
            elevation: 0,
            // color: Color(0xffdfe6e9),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Container(
                child: Row(
                  children: [
                    Image.asset(
                      "images/icons/edit.png",
                      height: 80.h,
                      // color: CustomColor.red,
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "Requirement updated for patient "
                              "${snapshot.data()["patientName"]}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 38.sp,
                                fontFamily: "OpenSans",
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Click here to view the requirement.",
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontFamily: "OpenSans",
                                ),
                              ),
                              Text(
                                _commonUtilFunctions.convertDateTimeDisplay(
                                    snapshot.data()["timeStamp"]),
                                style: TextStyle(
                                    fontSize: 28.sp, color: Colors.grey),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget requestingForConfirmationCard(
      BuildContext context, DocumentSnapshot snapshot) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(DonorListScreen(
              postId: snapshot.data()["requestForPostId"],
            ));
          },
          child: Card(
            elevation: 0,
            // color: Color(0xffdfe6e9),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Row(
                children: [
                  Image.asset(
                    "images/icons/confirmation.png",
                    height: 80.h,
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "User is requesting you to confirm his donation.",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 38.sp,
                            fontFamily: "OpenSans",
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Click here to view.",
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                            Text(
                              _commonUtilFunctions.convertDateTimeDisplay(
                                  snapshot.data()["timeStamp"]),
                              style: TextStyle(
                                  fontSize: 28.sp, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget acceptanceForConfirmationCard(
      BuildContext context, DocumentSnapshot snapshot) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(LifePointsScreen());
          },
          child: Card(
            elevation: 0,
            // color: Color(0xffdfe6e9),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Row(
                children: [
                  Image.asset(
                    "images/icons/checked.png",
                    height: 75.h,
                    color: CustomColor.red,
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Thank you for being a donor. You are credited with ${snapshot.data()["points"]} Life Points",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 38.sp,
                              fontFamily: "OpenSans",
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Click here to view points.",
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                            Text(
                              _commonUtilFunctions.convertDateTimeDisplay(
                                  snapshot.data()["timeStamp"]),
                              style: TextStyle(
                                  fontSize: 28.sp, color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
    // getAllNotification();
  }

  Future<Null> refreshList() async {
    // refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        // triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: refreshList,
        key: refreshKey,
        child: PaginateFirestore(
          isLive: true,
          key: UniqueKey(),
          itemsPerPage: 10,
          itemBuilderType: PaginateBuilderType.listView,
          // listview and gridview
          // ignore: missing_return
          separator: Divider(
            indent: 10,
            endIndent: 10,
          ),
          // ignore: missing_return
          itemBuilder: (index, context, documentSnapshot) {
            switch (documentSnapshot.data()["tag"]) {
              case "da":
                return donorAppearedCard(context, documentSnapshot,
                    documentSnapshot.data()["postId"]);
                break;
              case "NewMessage":
                return newMessageCard();
                break;
              case "lp":
                return lifePointsReceivedCard(documentSnapshot);
                break;
              case "Update":
                return requirementChangesCard(context, documentSnapshot);
                break;
              case "Request":
                return requestingForConfirmationCard(context, documentSnapshot);
                break;
              case "Accepted":
                return acceptanceForConfirmationCard(context, documentSnapshot);
                break;
              default:
                print("Something went wrong");
            }
          },
          emptyDisplay: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/notification.png",
                height: 200,
              ),
              Text(
                "No notification yet!",
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
                ),
              ),
            ],
          )),

          // orderBy is compulsary to enable pagination
          query: databaseReference
              .collection("Profile")
              .doc(uid)
              .collection("notifications")
              .orderBy("timeStamp", descending: true),

          // to fetch real-time data
        ),

        //: loadingPost()
      ),
      // body: loaded ? notificationsList.length > 0 ? Container(
      //   padding: EdgeInsets.all(24.w),
      //   child: ListView.builder(
      //     itemCount: notificationsList.length,
      //       // ignore: missing_return
      //       itemBuilder: (context,index) {
      //         switch(notificationsList[index]["tag"]) {
      //           case "da": return donorAppearedCard(index);
      //             break;
      //           case "NewMessage": return newMessageCard();
      //             break;
      //           case "lp": return lifePointsReceivedCard(index);
      //           default: print("Something went wrong");
      //         }
      //       }
      //   )
      // ):Center(child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Icon(Icons.notifications_active_outlined,size: 50,),
      //     SizedBox(height: 15.h,),
      //     Text("No Notifications",style: TextStyle(color: CustomColor.grey,fontSize: 44.sp),)
      //   ],
      // ),): Center(child: SpinKitThreeBounce(size: 25,color: CustomColor.red,),)
    );
  }
}
