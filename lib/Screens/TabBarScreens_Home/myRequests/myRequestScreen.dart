import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/postBloodRequirement.dart';
import 'package:bd_app/Screens/FeedBackScreen.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/myRequests/DonorListScreen.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/Widgets/loadingPost.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import "package:get/get_utils/src/extensions/string_extensions.dart";

import 'editPostBloodRequirement.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class myRequestScreen extends StatefulWidget {
  @override
  _myRequestScreenState createState() => _myRequestScreenState();
}

class _myRequestScreenState extends State<myRequestScreen> {
  // @override
  // bool get wantKeepAlive => true;

  final databaseReference = FirebaseDatabase.instance.reference();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  // RefreshController _refreshController = RefreshController(initialRefresh: false);
  String uid;
  bool loaded = false;
  List myRequestPostList = [];
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> getMyRequests() async {
    setState(() {
      loaded = false;
    });
    print("Entered getMy Request");
    DataSnapshot snap;
    DataSnapshot postSnapshot;
    List myReqList = [];
    List myReqPostList = [];
    snap = await databaseReference.child("Users").child(uid).once();
    // print(snap.value["myRequest"]);
    if (snap.value["myRequest"] != null) {
      myReqList = snap.value["myRequest"];
      print(myReqList.length);
    } else {
      print("List is null");
    }
    if (myReqList.length >= 1) {
      for (var i = 0; i < myReqList.length; i++) {
        postSnapshot =
            await databaseReference.child("Post").child(myReqList[i]).once();
        myReqPostList.add(postSnapshot.value);
      }
      setState(() {
        myRequestPostList = myReqPostList;
        loaded = true;
        print("Loaded: $loaded");
      });
    } else {
      setState(() {
        loaded = true;
      });
    }
  }

  Future<Null> refreshList() async {
    setState(() {});
    refreshChangeListener.refreshed = true;
    return null;
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    print(uid);
    // getMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    Notify _notify = Provider.of<Notify>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        // triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: refreshList,
        key: refreshKey,
        child: PaginateFirestore(
          key: UniqueKey(),
          isLive: true,
          itemsPerPage: 10,
          itemBuilderType: PaginateBuilderType.listView,
          separator: Divider(),
          itemBuilder: (index, context, documentSnapshot) {
            return buildMyRequestPostCard(documentSnapshot);
          },
          listeners: [refreshChangeListener],
          emptyDisplay: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You haven't posted any requests yet!!",
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
          query: FirebaseFirestore.instance
              .collection("Post")
              .where("createdBy", isEqualTo: uid)
              .orderBy("bloodRequiredDateTime", descending: true),

          // to fetch real-time data
        ),
        // child: loaded ? myRequestPostList.length > 0 ? SingleChildScrollView(
        //   child: ListView.builder(
        //       itemCount: myRequestPostList.length,
        //       scrollDirection: Axis.vertical,
        //       shrinkWrap: true,
        //       physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        //       itemBuilder: (context, i) => await buildMyRequestPostCard(i)
        //   ),
        // ):
        //: loadingPost()
      ),
    );
  }

  Widget buildMyRequestPostCard(DocumentSnapshot postSnapshots) {
    List listOfDonors = postSnapshots.data()["donors"] ?? [];
    List listOfNotDOnors = postSnapshots.data()["notDonors"] ?? [];
    bool isThereDonor = false;
    if ((listOfDonors.length - listOfNotDOnors.length) > 0) {
      isThereDonor = true;
    }
    return myRequestPostCard(
      requirement: postSnapshots.data()["requirementType"],
      // status: postSnapshots.data()["status"],
      snapshot: postSnapshots,
      status: postSnapshots.data()["active"],
      expired: postSnapshots.data()["expired"],
      donors: isThereDonor,
      requiredDateAndTime: DateFormat('dd MMM yyyy').format(
          DateTime.fromMillisecondsSinceEpoch(postSnapshots
              .data()["bloodRequiredDateTime"]
              .millisecondsSinceEpoch)),
      // requiredDateAndTime: _commonUtilFunctions.convertDateTimeDisplay(
      //         postSnapshots.data()["bloodRequiredDate"]) +
      //     "  " +
      //     postSnapshots.data()["bloodRequiredTime"],
      purpose: postSnapshots.data()["purpose"],
      requiredUnit: postSnapshots.data()["requiredUnits"].toString(),
      // cityName: postSnapshots.data()["hospitalCityName"],
      cityName: postSnapshots.data()["hospitalCity"].toString(),
      patientName: postSnapshots.data()["patientName"],
      bloodGrp: postSnapshots.data()["requiredBloodGrp"],
      postId: postSnapshots.data()["postId"].toString(),
      shareOnpress: () async {
        String requiredDate;
        requiredDate = DateFormat('dd MMM yy').format(
            DateTime.fromMillisecondsSinceEpoch(postSnapshots
                .data()["bloodRequiredDateTime"]
                .millisecondsSinceEpoch));
        String quote =
            "\n\n\"Donation Is A Small Act Of Kindness That Does Great And Big Wonders\"\n\n-Team Helping Hands";
        String msg =
            "${postSnapshots.data()["patientName"]} requires ${postSnapshots.data()["requiredBloodGrp"]} ${postSnapshots.data()["requirementType"]} on $requiredDate\.\n\nClick the link below to see details.\n\n";
        _commonUtilFunctions.loadingCircle("Loading...");
        String link = await _dynamicLinkService.createFirstPostLink(
            postId: postSnapshots.id,
            requirementType: postSnapshots.data()["requirementType"],
            bloodGrp: postSnapshots.data()["requiredBloodGrp"]);
        Clipboard.setData(ClipboardData(text: msg + link + quote));
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
    );
  }
}

class myRequestPostCard extends StatelessWidget {
  final DocumentSnapshot snapshot;
  final String bloodGrp;
  final String requirement;
  final String requiredDateAndTime;
  final String purpose;
  final bool expired;
  final bool donors;
  final String requiredUnit;
  final String cityName;
  final String patientName;
  final PatientDetails patientDetails;
  final String postId;
  final bool status;
  final VoidCallback shareOnpress;

  const myRequestPostCard({
    this.donors,
    this.expired,
    this.snapshot,
    this.requirement,
    this.requiredDateAndTime,
    this.purpose,
    this.bloodGrp,
    this.requiredUnit,
    this.cityName,
    this.postId,
    this.patientDetails,
    this.patientName,
    this.shareOnpress,
    this.status,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
    Color iconColor = Color(0xff535c68);
    return GestureDetector(
      onTap: () {
        Get.to(NewPatientDetail(
          postId: snapshot.id,
        ));
      },
      child: Container(
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              child: Container(
                  padding: EdgeInsets.all(25.w),
                  height: 350.h,
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
                                  color: expired
                                      ? CustomColor.grey
                                      : CustomColor.red,
                                  border: Border.all(
                                    color: expired
                                        ? CustomColor.grey
                                        : CustomColor.red,
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
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "Required Date",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "Required Units",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "Patient Name",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "Purpose",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "City Name",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
                                ),
                                Text(
                                  "Status",
                                  style: TextStyle(
                                      fontSize: 33.sp,
                                      color: expired
                                          ? CustomColor.grey
                                          : Colors.black),
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
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
                                  ),
                                  Text(
                                    ":",
                                    style: TextStyle(
                                        fontSize: 33.sp,
                                        color: expired
                                            ? CustomColor.grey
                                            : Colors.black),
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
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    Text(
                                      requiredDateAndTime.toString(),
                                      style: TextStyle(
                                          fontSize: 33.sp,
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    Text(
                                      requiredUnit.toString(),
                                      style: TextStyle(
                                          fontSize: 33.sp,
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    Text(
                                      patientName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 33.sp,
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    Text(
                                      purpose,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 33.sp,
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    Text(
                                      cityName,
                                      style: TextStyle(
                                          fontSize: 33.sp,
                                          color: expired
                                              ? CustomColor.grey
                                              : Colors.black),
                                    ),
                                    status == null || status == true
                                        ? Row(
                                            children: [
                                              Container(
                                                height: 10.h,
                                                width: 10.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.greenAccent,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Text(
                                                "Active",
                                                style: TextStyle(
                                                    fontSize: 33.sp,
                                                    color: expired
                                                        ? CustomColor.grey
                                                        : Colors.black),
                                              )
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Container(
                                                height: 10.h,
                                                width: 10.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.red,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Text(
                                                "Not active",
                                                style: TextStyle(
                                                    fontSize: 33.sp,
                                                    color: expired
                                                        ? CustomColor.grey
                                                        : Colors.black),
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
                        padding: EdgeInsets.only(right: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                                onTap: () async {
                                  if (donors) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DonorListScreen(
                                                  postId: snapshot.id,
                                                  // postData: snapshot,
                                                  // donorList:
                                                  //     snapshot.data()["donors"],
                                                  // notDonors: snapshot
                                                  //     .data()["notDonors"],
                                                  // donorsRespones: snapshot
                                                  //     .data()["response time"],
                                                  // requirement: snapshot
                                                  //     .data()["requirementType"],
                                                )));
                                  } else {
                                    await Fluttertoast.showToast(
                                        msg: "No Donors",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: CustomColor.grey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Image.asset(
                                  "images/donorIcon.png",
                                  height: 50.h,
                                  color: donors
                                      ? CustomColor.red
                                      : CustomColor.grey,
                                )),
                            // GestureDetector(
                            //     onTap: () {
                            //       Get.to(
                            //         () => NewPatientDetail(
                            //           postId: snapshot.id,
                            //         ),
                            //       );
                            //     },
                            //     child: Icon(
                            //       Icons.remove_red_eye_outlined,
                            //       size: 20,
                            //       color: iconColor,
                            //     )),
                            // !expired
                            //     ? GestureDetector(
                            //         onTap: () {
                            //           Get.to(
                            //             () =>
                            //                 PostRequirement(snapshot, expired),
                            //           );
                            //         },
                            //         child: Icon(
                            //           Icons.edit_outlined,
                            //           size: 20,
                            //           color: iconColor,
                            //         ))
                            //     : Container(),
                            status
                                ? GestureDetector(
                                    onTap: shareOnpress,
                                    child: Icon(
                                      Icons.share_outlined,
                                      size: 20,
                                      color: iconColor,
                                    ))
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
