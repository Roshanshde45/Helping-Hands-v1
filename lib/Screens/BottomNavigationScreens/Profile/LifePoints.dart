import 'dart:ffi';

import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/NotificatonDetails.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';

// import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:share/share.dart';

class LifePointsScreen extends StatefulWidget {
  final String referalCode;
  LifePointsScreen([this.referalCode]);
  @override
  _LifePointsScreenState createState() => _LifePointsScreenState();
}

class _LifePointsScreenState extends State<LifePointsScreen> {
  final _server = FirebaseFirestore.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  DynamicLinkService _dynamicLinkService = DynamicLinkService();
  String totalLifePoints, uid;
  DocumentSnapshot _lastDocument;
  bool loaded = false;
  bool gettingMoreNotif = false;
  bool moreNotifAvailable = true;
  int perPage = 10;
  ScrollController scrollController = ScrollController();
  List<NotificationDetail> notificationList = [];
  List rewardNotifList = [];

  Future<void> getLifePointsData() async {
    DocumentSnapshot snapshot =
        await _server.collection("Profile").doc(uid).get();
    setState(() {
      totalLifePoints = snapshot.data()["lifePoints"].toString();
    });
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
    getLifePointsData();
  }

  Widget get roundedRectBorderWidget {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      padding: EdgeInsets.all(6),
      strokeCap: StrokeCap.butt,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Container(
          alignment: Alignment.center,
          height: 200.h,
          width: MediaQuery.of(context).size.width * 0.7,
          color: CustomColor.lightGrey,
          child: SelectableText(
            widget.referalCode.toString(),
            style: TextStyle(fontSize: 120.sp, fontFamily: "OpenSans"),
          ),
        ),
      ),
    );
  }

  Widget rewardPageListWidget() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(30.w, 20.w, 30.w, 0),
        child: PaginateFirestore(
          key: UniqueKey(),
          isLive: true,
          itemsPerPage: 10,
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (context, index, dataSnapshot) {
            return LifePointsTile(
              pointsReceived: dataSnapshot.data()["points"].toString(),
              timeReceived: commonUtilFunctions.convertDateTimeDisplay(
                  dataSnapshot.data()["timeStamp"]),
              recievedFrom: dataSnapshot.data()["receivedFrom"],
            );
          },
          query: FirebaseFirestore.instance
              .collection("Profile")
              .doc(uid)
              .collection("notifications")
              .where("badge",isEqualTo: "lifePoints")
              .orderBy("timeStamp", descending: true),
          emptyDisplay: Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roundedRectBorderWidget,
                SizedBox(
                  height: 20.h,
                ),
                InkWell(
                    onTap: () async {
                      Clipboard.setData(
                          ClipboardData(text: widget.referalCode));
                      await Fluttertoast.showToast(
                          msg: "Copied",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: CustomColor.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    child: Text("Copy")),
                Image.asset(
                  "images/lifepointsreward.png",
                  height: 600.h,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      "Your friend gets Life Points on sign up and you will also get Life points too everytime !",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "OpenSans"),
                    )),
                SizedBox(
                  height: 20.h,
                ),
                OutlinedButton.icon(
                    onPressed: () async {
                      String sharelink = await _dynamicLinkService
                          .createShareReferalLink(widget.referalCode);
                      Share.share(sharelink);
                    },
                    icon: Icon(Icons.share),
                    label: Text("Share"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Life Points",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(180.w, 20.h, 0, 0),
                  height: 250.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          stops: [
                            0.1,
                            0.9
                          ],
                          colors: [
                            CustomColor.red.withOpacity(.8),
                            CustomColor.red.withOpacity(.1)
                          ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalLifePoints.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 120.sp,
                            fontFamily: "Opensans",
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Total Points",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.sp,
                            // fontFamily: "Opensans",
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              rewardPageListWidget()
            ],
          ),
        ));
  }
}

class LifePointsTile extends StatelessWidget {
  final String pointsReceived;
  final String timeReceived;
  final String recievedFrom;

  const LifePointsTile({
    this.pointsReceived,
    this.timeReceived,
    this.recievedFrom,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 25.h),
      child: Container(
          height: 160.h,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/icons/heart_attack.png",
                          height: 90.h,
                        ),
                        SizedBox(
                          width: 30.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Received $pointsReceived Life Points",
                              style: TextStyle(
                                  fontSize: 40.sp, fontFamily: "OpenSans"),
                            ),
                            Text(
                              "Received from $recievedFrom",
                              style: TextStyle(
                                  fontSize: 30.sp, fontFamily: "OpenSans"),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeReceived,
                    style: TextStyle(fontSize: 30.sp, fontFamily: "OpenSans"),
                  )
                ],
              ),
              Divider()
            ],
          )),
    );
  }
}
