import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/postBloodRequirement.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/LifePoints.dart';
import 'package:bd_app/Screens/FeedBackScreen.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/allRequest/postCard.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/myRequests/DonorListScreen.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bd_app/Screens/RepeatingScreens/EditPostDetailsBottomPush.dart';
import 'package:bd_app/services/Constants.dart';
import 'package:android_intent/android_intent.dart';

class AllRequestScreen extends StatefulWidget {
  @override
  _AllRequestScreenState createState() => _AllRequestScreenState();
}

class _AllRequestScreenState extends State<AllRequestScreen>
    with AutomaticKeepAliveClientMixin<AllRequestScreen> {
  @override
  bool get wantKeepAlive => true;
  int postType = 0;
  bool permissionEnabled = true;
  final databaseReference = FirebaseDatabase.instance.reference();
  final _firstore = FirebaseFirestore.instance;
  final geo = Geoflutterfire();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final controller = ScrollController();
  final CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  final _bloodGrpController = ScrollController();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  ConstantVariables _constantVariables = ConstantVariables();
  Time time;
  //floating filter vars
  static double _containerHeight = 40;

  // You don't need to change any of these variables
  var _fromTop = 0.0;
  var _controller = ScrollController();
  var _allowReverse = true, _allowForward = true;
  var _prevOffset = 0.0;
  var _prevForwardOffset = -_containerHeight;
  var _prevReverseOffset = 0.0;

  String currentDate,
      bloodGrp,
      userBloodGrp,
      phone,
      uid,
      _name,
      cityName,
      selectedBloodRequired;
  int PAGE_SIZE = 5;
  // int dateTimestamp;
  List<double> distances = [20.0, 40.0, 60.0, 80.0, 100.0];
  int selecctedDistanceIndex = 0;
  double prevoffset = 0;
  bool up = true;
  bool down = true;

  List<String> requirementTypeList = [
    "blood",
    // "plasmaForCovid",
    "plasma",
    "platelets"
  ];
  int selecctedrequirementTypeIndex = 0;

  Position _currentPosition;

  bool alreadyReported = false;
  bool loaded = false;

  List acceptedRequestArray = [];
  List myRequestArray = [];
  List<DocumentSnapshot> postsList = [];
  List<String> bloodGrpList = [];
  DataSnapshot snapshot;
  List dateArray = [];
  List bloodRequired = [
    {
      "time": "2hr",
      "colorSwitch": false,
    },
    {
      "time": "4hr",
      "colorSwitch": false,
    },
    {
      "time": "8hr",
      "colorSwitch": false,
    },
    {
      "time": "12hr",
      "colorSwitch": false,
    },
    {
      "time": "24hr",
      "colorSwitch": false,
    },
    {
      "time": "5 Days",
      "colorSwitch": false,
    },
  ];

  List bloodGroups = [
    {"bloodGrp": "A-", "colorBool": false},
    {"bloodGrp": "B-", "colorBool": false},
    {"bloodGrp": "AB-", "colorBool": false},
    {"bloodGrp": "O-", "colorBool": false},
    {"bloodGrp": "A+", "colorBool": false},
    {"bloodGrp": "B+", "colorBool": false},
    {"bloodGrp": "AB+", "colorBool": false},
    {"bloodGrp": "O+", "colorBool": false},
  ];

  int globalRequirementBloodType = 0;
  int globalPostTypeFil = 0;
  double globalDistance = 40;

  Future _checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text("Can't get current location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text(
                        'Ok',
                        style: TextStyle(color: CustomColor.red),
                      ),
                      onPressed: () async {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        await _gpsService();
                      })
                ],
              );
            });
      }
    } else {
      _determinePosition();
    }
  }

  Future _gpsService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
      return null;
    } else
      _determinePosition();

    return true;
  }

  Future<void> getName() async {
    try {
      _firstore.collection("Profile").doc(uid).get().then((snapshot) {
        setState(() {
          _name = snapshot.data()["name"];
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // void _listener() {
  //   double offset = _controller.position.pixels;
  //   print(offset);
  //   var direction = _controller.position.userScrollDirection;
  //   if (direction == ScrollDirection.reverse) {
  //     print("up");
  //     up = true;
  //     if (down) {
  //       down = false;
  //       prevoffset = offset;
  //       _prevReverseOffset = _fromTop;
  //     }
  //     if (_fromTop > (-_containerHeight))
  //       _fromTop = _prevReverseOffset - (-prevoffset + offset);

  //     if (_fromTop < (-_containerHeight)) _fromTop = (-_containerHeight);
  //   } else if (direction == ScrollDirection.forward) {
  //     down = true;
  //     if (up) {
  //       up = false;
  //       prevoffset = offset;
  //         _prevForwardOffset = _fromTop;
  //     }
  //     if (_fromTop < 0) _fromTop = _prevForwardOffset + (prevoffset - offset);

  //     if (_fromTop > 0) _fromTop = 0;
  //   } else if (direction == ScrollDirection.idle) {
  //     // prevoffset = offset;
  //   }
  //   setState(() {
  //     // _containerHeight = _containerHeight - _fromTop;
  //   });
  // }

  void _listener() {
    double offset = _controller.position.pixels;
    print(offset);
    var direction = _controller.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      print("up");
      up = true;
      if (down) {
        down = false;
        prevoffset = offset;
        _prevReverseOffset = _fromTop;
      }
      if (_fromTop > (-_containerHeight))
        _fromTop = _prevReverseOffset - (-prevoffset + offset);

      if (_fromTop < (-_containerHeight)) _fromTop = (-_containerHeight);
    } else if (direction == ScrollDirection.forward) {
      down = true;
      if (up) {
        up = false;
        prevoffset = offset;
        _prevForwardOffset = _fromTop;
      }
      if (_fromTop < 0) _fromTop = _prevForwardOffset + (prevoffset - offset);

      if (_fromTop > 0) _fromTop = 0;
    } else if (direction == ScrollDirection.idle) {
      // prevoffset = offset;
    }
    setState(() {
      // _containerHeight = _containerHeight - _fromTop;
    });
  }

  Future<void> reportPost(
      String postId, String reason, String methodUsed) async {
    setState(() {
      alreadyReported = false;
    });
    bool tempUserAlreadyReported = false;
    bool alreadyInReportedList = false;
    DataSnapshot snapshot =
        await databaseReference.child("ReportedPosts").once();
    // print("Reported Post: ${snapshot.value}");
    DataSnapshot userSnap = await databaseReference
        .child("Users")
        .child(uid)
        .child("ReportedPost")
        .once();
    List reportedPostList = [];
    List postIdList = [];
    if (userSnap != null && userSnap.value != null) {
      for (var key in (userSnap.value as Map).keys) {
        if (key == postId) {
          print(":::::::::SKIPPED::::::::::");
          print("Already posted");
          setState(() {
            alreadyReported = true;
          });
          tempUserAlreadyReported = true;
        }
      }
    } else {
      databaseReference.child("ReportedPosts").update({
        postId: {
          "totalCount": 1,
          "reason": {
            "RequirementFullFilled": reason == "RequirementFullFilled" ? 1 : 0,
            "WrongInfo": reason == "WrongInfo" ? 1 : 0,
            "Invalid": reason == "Invalid" ? 1 : 0,
          },
        }
      });

      databaseReference.child("Users").child(uid).child("ReportedPost").update({
        postId: {
          "verifiedMethod": methodUsed,
          "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
        }
      });
    }

    if (snapshot != null &&
        snapshot.value != null &&
        tempUserAlreadyReported != true) {
      if (snapshot.value[postId] != null) {
        int reqFullCount =
            snapshot.value[postId]["reason"]["RequirementFullFilled"];
        int wrongInfoCount = snapshot.value[postId]["reason"]["WrongInfo"];
        int InvalidCount = snapshot.value[postId]["reason"]["Invalid"];
        int total = reqFullCount + wrongInfoCount + InvalidCount + 1;

        databaseReference.child("ReportedPosts").update({
          postId: {
            "totalCount": total,
            "reason": {
              "RequirementFullFilled": reason == "RequirementFullFilled"
                  ? reqFullCount + 1
                  : reqFullCount,
              "WrongInfo":
                  reason == "WrongInfo" ? wrongInfoCount + 1 : wrongInfoCount,
              "Invalid": reason == "Invalid" ? InvalidCount + 1 : InvalidCount,
            },
          }
        });
        databaseReference
            .child("Users")
            .child(uid)
            .child("ReportedPost")
            .update({
          postId: {
            "verifiedMethod": methodUsed,
            "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
          }
        });
      } else {
        databaseReference.child("ReportedPosts").update({
          postId: {
            "totalCount": 1,
            "reason": {
              "RequirementFullFilled":
                  reason == "RequirementFullFilled" ? 1 : 0,
              "WrongInfo": reason == "WrongInfo" ? 1 : 0,
              "Invalid": reason == "Invalid" ? 1 : 0,
            },
          }
        });

        databaseReference
            .child("Users")
            .child(uid)
            .child("ReportedPost")
            .update({
          postId: {
            "verifiedMethod": methodUsed,
            "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
          }
        });
      }
    }
  }

  Future<Widget> myBottomSheet(
    BuildContext context,
    String postId,
    String myUid,
    String createdByUid,
    LatLng hospitalLocationCoordinate,
    String patientName,
    String bloodGrp,
    DocumentSnapshot postRequestData,
  ) {
    int currentView = 0;
    String response;
    String methodUsed;
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              // ignore: missing_return
              builder: (BuildContext context, StateSetter setMode) {
            switch (currentView) {
              case 0:
                return Wrap(
                  children: [
                    Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 66.w, vertical: 35.h),
                        // height: 645.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20.h,
                                  width: 170.w,
                                  decoration: BoxDecoration(
                                      color: CustomColor.lightGrey,
                                      borderRadius: BorderRadius.circular(20)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Row(
                              children: [
                                myUid != createdByUid
                                    ? Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          onTap: () {
                                            setMode(() {
                                              currentView = 1;
                                            });
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 15.h),
                                              child: Text(
                                                "Report...",
                                                style:
                                                    TextStyle(fontSize: 45.sp),
                                              )),
                                        ),
                                      )
                                    // : Expanded(
                                    //     child: InkWell(
                                    //       borderRadius: BorderRadius.circular(6),
                                    //       onTap: () {
                                    //         setMode(() {
                                    //           currentView = 5;
                                    //         });
                                    //       },
                                    //       child: Padding(
                                    //           padding: EdgeInsets.symmetric(
                                    //               horizontal: 20.w, vertical: 15.h),
                                    //           child: Text(
                                    //             "Cancel my request",
                                    //             style: TextStyle(fontSize: 45.sp),
                                    //           )),
                                    //     ),
                                    //   ),
                                    : Container()
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      String requiredDate;
                                      requiredDate = DateFormat('dd MMM yy')
                                          .format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  postRequestData
                                                      .data()[
                                                          "bloodRequiredDateTime"]
                                                      .millisecondsSinceEpoch));
                                      String quote =
                                          "\n\n\"Donation Is A Small Act Of Kindness That Does Great And Big Wonders\"\n\n-Team Helping Hands";
                                      String msg =
                                          "${postRequestData.data()["patientName"]} requires ${postRequestData.data()["requiredBloodGrp"]} ${postRequestData.data()["requirementType"]} on $requiredDate\.\n\nClick the link below to see details.\n\n";
                                      String link = await _dynamicLinkService
                                          .createFirstPostLink(
                                              requirementType: postRequestData
                                                  .data()["requirementType"],
                                              postId: postId,
                                              bloodGrp: bloodGrp);
                                      print(link);
                                      Clipboard.setData(new ClipboardData(
                                          text: msg + link + quote));
                                      Get.back();
                                      await Fluttertoast.showToast(
                                          msg:
                                              "Link is copied to the clipboard.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: CustomColor.grey,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "Copy Link",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: InkWell(
                            //         borderRadius: BorderRadius.circular(6),
                            //         onTap: () {
                            //           MapUtils.openMap(hospitalLocationCoordinate.latitude,hospitalLocationCoordinate.longitude);
                            //         },
                            //         child: Padding(
                            //             padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
                            //             child: Text("Directions to hospital",style: TextStyle(fontSize: 45.sp),)),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: 20.h,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      String requiredDate;
                                      requiredDate = DateFormat('dd MMM yy')
                                          .format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  postRequestData
                                                      .data()[
                                                          "bloodRequiredDateTime"]
                                                      .millisecondsSinceEpoch));
                                      String quote =
                                          "\n\n\"Donation Is A Small Act Of Kindness That Does Great And Big Wonders\"\n\n-Team Helping Hands";
                                      String msg =
                                          "${postRequestData.data()["patientName"]} requires ${postRequestData.data()["requiredBloodGrp"]} ${postRequestData.data()["requirementType"]} on $requiredDate\.\n\nClick the link below to see details.\n\n";
                                      String link = await _dynamicLinkService
                                          .createFirstPostLink(
                                              requirementType: postRequestData
                                                  .data()["requirementType"],
                                              postId: postId,
                                              bloodGrp: bloodGrp);
                                      print(link);
                                      Share.share(msg + link + quote);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "Share to...",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            myUid != createdByUid
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // children: [
                                    //   Expanded(
                                    //     child: InkWell(
                                    //       borderRadius: BorderRadius.circular(6),
                                    //       onTap: () {
                                    //         // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    //         //     PatientDetailScreen(
                                    //         //       patientDetail: PatientDetails(
                                    //         //         posterPhone: snapshot["postedUserPhone"],
                                    //         //         patientName : snapshot["patientName"],
                                    //         //         reqDate :  snapshot["bloodRequiredDate"].toString(),
                                    //         //         reqTime: snapshot["bloodRequiredTime"],
                                    //         //         age: snapshot["patientAge"],
                                    //         //         reqBloodGroup : snapshot["requiredBloodGrp"],
                                    //         //         reqUnits: snapshot["requiredUnits"].toString(),
                                    //         //         hospitalName: snapshot["hospitalName"],
                                    //         //         hospitalCityName: snapshot["hospitalCityName"],
                                    //         //         areaName: snapshot["hospitalAreaName"],
                                    //         //         purpose: snapshot["purpose"],
                                    //         //         contact1:snapshot["patientAttender1"],
                                    //         //         contact2: snapshot["patientAttender2"],
                                    //         //         otherDetails:  snapshot["otherDetails"],
                                    //         //         imgUrl: snapshot["imageUrl"],
                                    //         //         postedUserName: snapshot["userName"],
                                    //         //         postId: snapshot["postId"],
                                    //         //       ),
                                    //         //       index: index,
                                    //         //     )
                                    //         // )
                                    //         // );
                                    //       },
                                    //       child: Padding(
                                    //           padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
                                    //           child: Text("View Full Details",style: TextStyle(fontSize: 45.sp),)),
                                    //     ),
                                    //   )
                                    // ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        PostRequirement(
                                                            postRequestData,
                                                            postRequestData
                                                                    .data()[
                                                                "expired"])));
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 15.h),
                                              child: Text(
                                                "Edit",
                                                style:
                                                    TextStyle(fontSize: 45.sp),
                                              )),
                                        ),
                                      )
                                    ],
                                  ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     Expanded(
                            //       child: InkWell(
                            //         borderRadius: BorderRadius.circular(6),
                            //         onTap: () {
                            //
                            //         },
                            //         child: Padding(
                            //             padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
                            //             child: Text("Edit",style: TextStyle(fontSize: 45.sp),)),
                            //       ),
                            //     )
                            //   ],
                            // )
                          ],
                        ),
                      ),
                    )
                  ],
                );
                break;
              case 1:
                return Wrap(
                  children: [
                    Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: EdgeInsets.all(66.w),
                        // height: 680.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20.h,
                                  width: 170.w,
                                  decoration: BoxDecoration(
                                      color: CustomColor.grey,
                                      borderRadius: BorderRadius.circular(20)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 70.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 15.h),
                                      child: Text(
                                        "Have you verified?",
                                        style: TextStyle(
                                            fontSize: 45.sp,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      setMode(() {
                                        currentView = 2;
                                        methodUsed = "Call";
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "yes, verified on Call",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      setMode(() {
                                        currentView = 2;
                                        methodUsed = "Message";
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "yes, verified on message",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
                break;
              case 2:
                return Wrap(
                  children: [
                    Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: EdgeInsets.all(66.w),
                        // height: 680.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20.h,
                                  width: 170.w,
                                  decoration: BoxDecoration(
                                      color: CustomColor.grey,
                                      borderRadius: BorderRadius.circular(20)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 70.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 15.h),
                                      child: Text(
                                        "Why are you reporting this post?",
                                        style: TextStyle(
                                            fontSize: 45.sp,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      await reportPost(postId,
                                          "RequirementFullFilled", methodUsed);
                                      setMode(() {
                                        currentView =
                                            this.alreadyReported ? 4 : 3;
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "Requirement Fulfilled",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      await reportPost(
                                          postId, "WrongInfo", methodUsed);
                                      setMode(() {
                                        currentView =
                                            this.alreadyReported ? 4 : 3;
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "Wrong Info",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      await reportPost(
                                          postId, "Invalid", methodUsed);
                                      setMode(() {
                                        currentView =
                                            this.alreadyReported ? 4 : 3;
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 15.h),
                                        child: Text(
                                          "Its Invalid",
                                          style: TextStyle(fontSize: 45.sp),
                                        )),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
                break;
              case 3:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Image.asset(
                          "images/icons/checked.png",
                          height: 90.h,
                          color: Colors.greenAccent,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Text(
                          "Thanks for letting us know",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "Your feedback is important in helping us keep the\nHelping Hands community safe.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
                break;
              case 4:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Image.asset(
                          "images/icons/alert.png",
                          height: 90.h,
                          color: CustomColor.red,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Text(
                          "Thanks for letting us know",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "But you have already reported this post.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
                break;
              case 5:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 15.h),
                                  child: Text(
                                    "Do you want to cancel your request?",
                                    style: TextStyle(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => FeedBackScreen(
                                                postId: postId,
                                                uid: uid,
                                              ))).then((value) {
                                    // setMode(() {
                                    //   currentView = 6;
                                    // });
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "Yes, my requirement is fulfilled.",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  setMode(() {
                                    currentView = 7;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "No",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 6:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Image.asset(
                          "images/icons/visibility.png",
                          height: 90.h,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Text(
                          "Post Hidden",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "Ok we have removed your post from the feed.\nBut you can still see it in your \" My Request \" tab.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
              case 7:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 15.h),
                                  child: Text(
                                    "Why do you want to cancel your request ?",
                                    style: TextStyle(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  await databaseReference
                                      .child("Users")
                                      .child(uid)
                                      .child("HiddenPosts")
                                      .update({
                                    time
                                        .getCurrentTime()
                                        .millisecondsSinceEpoch
                                        .toString(): {
                                      "forPostId": postId,
                                      "reason": "No Requirement"
                                    }
                                  });
                                  print(":::::HiddenPost Saved::::::");
                                  databaseReference
                                      .child("Post")
                                      .child(postId)
                                      .update({
                                    "status": false,
                                  });
                                  print(":::::Status made false:::::");
                                  setMode(() {
                                    currentView = 6;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "No Requirement",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  await databaseReference
                                      .child("Users")
                                      .child(uid)
                                      .child("HiddenPosts")
                                      .update({
                                    time
                                        .getCurrentTime()
                                        .millisecondsSinceEpoch
                                        .toString(): {
                                      "forPostId": postId,
                                      "reason": "I just want to cancel"
                                    }
                                  });
                                  print(":::::HiddenPost Saved::::::");
                                  databaseReference
                                      .child("Post")
                                      .child(postId)
                                      .update({
                                    "status": false,
                                  });
                                  print(":::::Status made false:::::");
                                  setMode(() {
                                    currentView = 6;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    child: Text(
                                      "I just want to cancel",
                                      style: TextStyle(fontSize: 45.sp),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              case 8:
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(66.w),
                    height: 680.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20.h,
                              width: 170.w,
                              decoration: BoxDecoration(
                                  color: CustomColor.grey,
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 70.h,
                        ),
                        Image.asset(
                          "images/icons/like.png",
                          height: 90.h,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Text(
                          "Post Hidden",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "Ok we have removed your post from the feed.\nBut you can still see it in your \" My Request \" tab.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
              default:
                print("Something went wrong");
            }
          });
        });
  }

  void selectedGrpFunc(String grp) {
    List<String> bgList = [];
    List indices = [];

    print(grp);

    switch (grp) {
      case "A-":
        {
          indices = [0, 2, 4, 6];
        }
        break;
      case "B-":
        {
          indices = [1, 2, 5, 6];
        }
        break;
      case "AB-":
        {
          indices = [2, 6];
        }
        break;
      case "O-":
        {
          indices = [0, 1, 2, 3, 4, 5, 6, 7];
        }
        break;
      case "A+":
        {
          indices = [4, 6];
        }
        break;
      case "B+":
        {
          indices = [5, 6];
        }
        break;
      case "AB+":
        {
          indices = [6];
        }
        break;
      case "O+":
        {
          indices = [4, 5, 6, 7];
        }
    }
    print(indices.length);

    for (var i = 0; i <= 7; i++) {
      for (var j = 0; j < indices.length; j++) {
        if (i == indices[j]) {
          bgList.add(bloodGroups[i]["bloodGrp"]);
          print("Blood GroupList: $bloodGrpList");
          setState(() {
            bloodGroups[i]["colorBool"] = true;
            bloodGrpList = bgList;
          });
        }
      }
    }
  }

  void selectedBloodRequiredFunc(int j) {
    for (var i = 0; i <= 6; i++) {
      setState(() {
        bloodRequired[i]["colorSwitch"] = false;
      });
      print(bloodRequired[i]["colorSwitch"]);
    }
    print("Done Loop");
    setState(() {
      bloodRequired[j]["colorSwitch"] = !bloodRequired[j]["colorSwitch"];
      selectedBloodRequired = bloodRequired[j]["time"];
    });
  }

  void addBloodGrp(int index) {
    if (bloodGroups[index]["colorBool"] == true) {
      setState(() {
        bloodGroups[index]["colorBool"] = false;
        bloodGrpList.remove(bloodGroups[index]["bloodGrp"]);
        getPostsList();
      });
    } else {
      setState(() {
        bloodGrpList.add(bloodGroups[index]["bloodGrp"]);
        bloodGroups[index]["colorBool"] = true;
        getPostsList();
      });
    }
  }

  // Future<void> getPosts() async{
  //   setState(() {
  //     loaded = false;
  //   });
  //   print("GET POSTS CALLED");
  //   DataSnapshot snap;
  //   var postsList = [];
  //   var myList = [];
  //   snap = await databaseReference.child("Post").once();
  //   if(snap != null && snap.value != null){
  //     for (var key in (snap.value as Map).keys) {
  //       for( var i =0; i < bloodGrpList.length;i++){
  //         if(snap.value[key]["requiredBloodGrp"] == bloodGrpList[i]){
  //           postsList.add(snap.value[key]);
  //         }
  //       }
  //     }
  //     for(var j = 0; j<acceptedRequestArray.length;j++) {
  //       for(var k = 0;k < postsList.length;k++) {
  //         if(postsList[k]["postId"] == acceptedRequestArray[j]){
  //           postsList[k]["myPost"] = "No";
  //           postsList.removeAt(k);
  //         }
  //       }
  //     }
  //
  //     for(var j = 0; j < myRequestArray.length; j++) {
  //       for(var k = 0; k < postsList.length; k++) {
  //         if(postsList[k]["postId"] == myRequestArray[j]){
  //           postsList[k]["myPost"] = "Yes";
  //         }
  //       }
  //     }
  //
  //     if(mounted){
  //       setState(() {e
  //         snapshot = snap;
  //         this.postsList = postsList;
  //         loaded = true;
  //       });
  //     }
  //   }
  // }
  int a = 0;
  Future<List> getPostsList() async {
    stream.listen((List<DocumentSnapshot> documentList) {
      print("called");
      print(a);
      a++;
      print("length");
      print(documentList.length);
      List<DocumentSnapshot> _lists = documentList;
      _lists.removeWhere((element) {
        List<dynamic> donors = element.data()["donors"];
        if (donors != null) {
          if (donors.contains(FirebaseAuth.instance.currentUser.uid)) {
            return true;
          }
        }
        return false;
      });
      _lists.sort((a, b) {
        Timestamp aStamp = a.data()["bloodRequiredDateTime"];
        Timestamp bStamp = b.data()["bloodRequiredDateTime"];
        if (aStamp.millisecondsSinceEpoch > bStamp.millisecondsSinceEpoch) {
          return 1;
        }
        return 0;
      });
      setState(() {
        //      if (_lists.length > 0) {
        //   _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        //    _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        //   _lists.add(_lists[0]);
        // }
        postsList = _lists;
      });
    });
    // print("Inside getPostsList");
    // List finalListofPosts = [];
    // DataSnapshot snap;
    // var postsList = [];
    // try {
    //   snap = await databaseReference.child("Post").once();
    //   bloodGrpList.add("Any");
    //   print(snap.value);
    //   if (snap != null && snap.value != null) {
    //     for (var key in (snap.value as Map).keys) {
    //       if (bloodGrpList.contains(snap.value[key]["requiredBloodGrp"]) &&
    //           snap.value[key]["status"] == true) {
    //         postsList.add(snap.value[key]);
    //       }
    //     }
    //     print("1::");
    //     for (var j = 0; j < acceptedRequestArray.length; j++) {
    //       for (var k = 0; k < postsList.length; k++) {
    //         if (postsList[k]["postId"] == acceptedRequestArray[j]) {
    //           postsList[k]["myPost"] = "No";
    //           postsList.removeAt(k);
    //         }
    //       }
    //     }
    //     print("2::");
    //     for (var j = 0; j < myRequestArray.length; j++) {
    //       for (var k = 0; k < postsList.length; k++) {
    //         if (postsList[k]["postId"] == myRequestArray[j]) {
    //           postsList[k]["myPost"] = "Yes";
    //         }
    //       }
    //     }
    //     // for(var g = 0; g < postsList.length; g++){
    //     //   if(postsList[g]["status"] == true){
    //     //     finalListofPosts.add(postsList[g]);
    //     //   }
    //     // }
    //     print("3::");
    //     for (var x = 0; x < postsList.length; x++) {
    //       if (dateArray.contains(_commonUtilFunctions
    //           .convertDateTimeDisplay(postsList[x]["bloodRequiredDate"]))) {
    //         finalListofPosts.add(postsList[x]);
    //       }
    //     }
    //     finalListofPosts.sort((a, b) {
    //       return a["bloodRequiredDate"].compareTo(b["bloodRequiredDate"]);
    //     });
    //     print("Total relevant posts: ${finalListofPosts.length}");

    //     setState(() {
    //       snapshot = snap;
    //       this.postsList = finalListofPosts;
    //       loaded = true;
    //     });
    //   }
    //   // return postsList;
    // } catch (e) {
    //   print(e);
    //   setState(() {
    //     loaded = true;
    //   });
    //   // return [];
    // }
  }

  Future<void> setToNotifications(
      {String notifyUserUid,
      String patientName,
      String postId,
      String donorName}) async {
    print("Nofity UID: $notifyUserUid");
    print("PatientName: $patientName");
    print("postId: $postId");
    print("donorName: $donorName");
    try {
      _firstore
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

  Future<void> getUserBloodGrp() async {
    Future.delayed(Duration(seconds: 2));
    DocumentSnapshot snap;
    snap = await _firstore.collection("Profile").doc(uid).get();
    this.setState(() {
      userBloodGrp = snap.data()["bloodGrp"];
    });
    selectedGrpFunc(userBloodGrp);
    getNearByPost(0, 0);
  }

  void getNearByPost(int allOrMyPosts, int requirementTypeIndex) async {
    List<String> requirementTypeList = ["all", "blood", "plasma", "platelets"];
    print("Post Type: $postType");
    List<String> finalGroups = [];
    if (allOrMyPosts == 0) {
      bloodGroups.forEach((element) {
        finalGroups.add(element["bloodGrp"]);
      });
    } else {
      bloodGroups.forEach((element) {
        if (element["colorBool"]) {
          finalGroups.add(element["bloodGrp"]);
        }
      });
    }

    if (_notify.currLoc == null) {
      await _notify.gpsService();
    }
    GeoFirePoint center = geo.point(
        latitude: _notify.currLoc.latitude,
        longitude: _notify.currLoc.longitude);
    finalGroups.add("Any");
    if (requirementTypeIndex == 0) {
      //All Posts
      stream = radius.switchMap((rad) {
        var collectionReference = _firstore
            .collection('Post')
            .where("active", isEqualTo: true)
            .where(
              "donors",
            )
            .where("requiredBloodGrp", whereIn: finalGroups);
        return geo.collection(collectionRef: collectionReference).within(
            center: center,
            radius: rad,
            field: 'hospitalLocation',
            strictMode: true);
      });
    } else {
      //I can Donate
      stream = radius.switchMap((rad) {
        var collectionReference = _firstore
            .collection('Post')
            .where("active", isEqualTo: true)
            .where("requirementType",
                isEqualTo: requirementTypeList[requirementTypeIndex])
            .where(
              "donors",
            )
            .where("requiredBloodGrp", whereIn: finalGroups);
        return geo.collection(collectionRef: collectionReference).within(
            center: center,
            radius: rad,
            field: 'hospitalLocation',
            strictMode: true);
      });
    }
    getPostsList();
  }

  Future<void> getMyRequestArray() async {
    List MyReqList = [];
    List resultMyReqList = [];
    DataSnapshot snap;
    snap = await databaseReference.child("Users").child(uid).once();
    if (snap != null && snap.value != null) {
      if (snap.value["myRequest"] != null) {
        MyReqList = snap.value["myRequest"];
        if (MyReqList != null) {
          for (var i = 0; i < MyReqList.length; i++) {
            resultMyReqList.add(snap.value["myRequest"][i]);
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        myRequestArray = resultMyReqList;
      });
    }
  }

  saveAcceptedPost(String postId, String posterUid, String posterPhone,
      String bloodGrp) async {
    databaseReference.child("Users").child(uid).child("accepted").update({
      postId: {
        "postId": postId,
        "userPostedUid": posterUid,
        "userPostedPhone": posterPhone,
        "timeStamp": time.getCurrentTime().millisecondsSinceEpoch,
        "bloodGrp": bloodGrp,
      }
    });
  }

  Future<void> _determinePosition() async {
    Position pos;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _checkGps();
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      print(
          "Location permissions are permanently denied, we cannot request permissions.");
    } else {
      pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
      });
      cityNameExtracter(_currentPosition.latitude, _currentPosition.longitude);
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _checkGps();
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    if (permission != LocationPermission.deniedForever) {
      pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
      });
      cityNameExtracter(_currentPosition.latitude, _currentPosition.longitude);
    }
  }

  Future<void> cityNameExtracter(double lat, double lng) async {
    final coordinates = new geocoder.Coordinates(lat, lng);
    var addresses =
        await geocoder.Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      cityName = first.adminArea;
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    await getMyRequestArray();
    await getPostsList();
    setState(() {});
    return null;
  }

  setInitialConstants() async {
    ConstantVariables variables =
        await _constantVariables.getConstantsFromFirebase();
    this.PAGE_SIZE = variables.pageSize;
  }

  Stream<List<DocumentSnapshot>> stream;
  final radius = BehaviorSubject<double>.seeded(20);

  Widget floatingFilterWidget() {
    return Positioned(
      top: _fromTop,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 1,
        child: Container(
          // color: Colors.blue,
          height: _containerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: CustomColor.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Container(
              //   color: Colors.white,
              //   padding: EdgeInsets.all(10),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Container(
              //           height: 18,
              //           child: FittedBox(
              //               child: Text(
              //             "Please Donate...",
              //             style: TextStyle(
              //               fontFamily: "OpenSans",
              //             ),
              //           ))),
              //       SizedBox(
              //         height: 6,
              //       ),
              //       SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         controller: _bloodGrpController,
              //         child: Row(children: [
              //           for (int ind = 0;
              //               ind < requirementTypeList.length;
              //               ind++)
              //             Padding(
              //               padding: EdgeInsets.only(right: 15),
              //               child: GestureDetector(
              //                 onTap: () {
              //                   setState(() {
              //                     selecctedrequirementTypeIndex = ind;
              //                   });
              //                   getNearByPost();
              //                 },
              //                 child: AnimatedContainer(
              //                   duration: Duration(microseconds: 93000),
              //                   height: 33,
              //                   alignment: Alignment.center,
              //                   padding: EdgeInsets.symmetric(
              //                       horizontal: 19, vertical: 0),
              //                   decoration: BoxDecoration(
              //                       borderRadius:
              //                           BorderRadius.all(Radius.circular(40)),
              //                       color: ind == selecctedrequirementTypeIndex
              //                           ? CustomColor.red
              //                           : Colors.white,
              //                       border: Border.all(
              //                           color:
              //                               ind == selecctedrequirementTypeIndex
              //                                   ? CustomColor.red
              //                                   : CustomColor.lightGrey)),
              //                   child: FittedBox(
              //                     child: Text(
              //                       _commonUtilFunctions
              //                           .firstCaptial(requirementTypeList[ind])
              //                           .toString(),
              //                       style: TextStyle(
              //                           color:
              //                               ind != selecctedrequirementTypeIndex
              //                                   ? CustomColor.grey
              //                                   : Colors.white),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             )
              //         ]),
              //       ),
              //       SizedBox(
              //         height: 10,
              //       ),
              //       Container(
              //           height: 18,
              //           child: FittedBox(
              //               child: Text(
              //             "Distance within",
              //             style: TextStyle(
              //               fontFamily: "OpenSans",
              //             ),
              //           ))),
              //       SizedBox(
              //         height: 6,
              //       ),
              //       SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         controller: _bloodGrpController,
              //         child: Row(children: [
              //           for (int ind = 0; ind < distances.length; ind++)
              //             Padding(
              //               padding: EdgeInsets.only(right: 15),
              //               child: GestureDetector(
              //                 onTap: () {
              //                   setState(() {
              //                     selecctedDistanceIndex = ind;
              //                   });
              //                   radius.add(distances[selecctedDistanceIndex]);
              //                 },
              //                 child: AnimatedContainer(
              //                   duration: Duration(microseconds: 93000),
              //                   alignment: Alignment.center,
              //                   height: 40,
              //                   width: 40,
              //                   decoration: BoxDecoration(
              //                       borderRadius:
              //                           BorderRadius.all(Radius.circular(100)),
              //                       color: ind == selecctedDistanceIndex
              //                           ? CustomColor.red
              //                           : Colors.white,
              //                       border: Border.all(
              //                           color: ind == selecctedDistanceIndex
              //                               ? CustomColor.red
              //                               : CustomColor.lightGrey)),
              //                   child: FittedBox(
              //                     child: Column(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Text(
              //                           distances[ind].toInt().toString(),
              //                           style: TextStyle(
              //                             color: ind != selecctedDistanceIndex
              //                                 ? CustomColor.grey
              //                                 : Colors.white,
              //                             fontWeight: FontWeight.bold,
              //                             fontSize: 43.sp,
              //                           ),
              //                         ),
              //                         Text(
              //                           "KM",
              //                           style: TextStyle(
              //                               color: ind != selecctedDistanceIndex
              //                                   ? CustomColor.grey
              //                                   : Colors.white,
              //                               fontSize: 25.sp,
              //                               fontWeight: FontWeight.bold),
              //                         )
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             )
              //         ]),
              //       ),
              //       // SizedBox(
              //       //   height: 10,
              //       // ),
              //     ],
              //   ),
              // ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        height: 40,
                        color: CustomColor.lightGrey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 25.w),
                              // child: Text(DateFormat.yMMMMEEEEd().format(time.getCurrentTime()()),style: TextStyle(fontWeight: FontWeight.w400),)),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Container(
                                    // height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 34.sp),
                                        children: <TextSpan>[
                                          // TextSpan(
                                          //     text: "$userBloodGrp",
                                          //     style: TextStyle(
                                          //         color: CustomColor.red,
                                          //         fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  "You can donate to $bloodGrpList",
                                              style: TextStyle(
                                                  color: Colors.black))
                                        ],
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 25.w),
                              child: GestureDetector(
                                onTap: () => filterBottomSheet(context),
                                child: Icon(
                                  Icons.tune_outlined,
                                  size: 21,
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _listener() {
  //   double offset = _controller.offset;
  //   var direction = _controller.position.userScrollDirection;
  //   var difference;
  //   print(offset);

  //   setState(() {
  //     if (direction == ScrollDirection.reverse) {
  //       print("Forward");
  //       _allowForward = true;
  //       if (_allowReverse) {
  //         _allowReverse = false;
  //         _prevOffset = offset;
  //         _prevForwardOffset = _fromTop;
  //       }

  //       difference = _prevOffset - offset;
  //       _fromTop = _prevForwardOffset + difference;
  //       if (_fromTop < -_containerHeight) {
  //         _fromTop = -_containerHeight;
  //       }
  //     } else if (direction == ScrollDirection.forward) {
  //       print("Reverse");
  //       _allowReverse = true;
  //       if (_allowForward) {
  //         _allowForward = false;
  //         _prevOffset = offset;
  //         _prevReverseOffset = _fromTop;
  //       }

  //       difference = offset - _prevOffset;
  //       _fromTop = _prevReverseOffset - difference;
  //       if (_fromTop > 0) _fromTop = 0;
  //     }
  //   });
  //   print("difference: $difference");
  //   print("_prevForwardOffset: $_prevForwardOffset");
  //   print("_prevReverseOffset: $_prevReverseOffset");
  //   print("FromTop: $_fromTop");
  // }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    phone = FirebaseAuth.instance.currentUser.phoneNumber;
    // setInitialConstants();
    super.initState();
    getName();
    // dateTimestamp = time.getCurrentTime().millisecondsSinceEpoch;
    getUserBloodGrp();
    _checkGps();
    getMyRequestArray();
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    radius.close();
    // TODO: implement dispose
    super.dispose();
  }

  Notify _notify;

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    // _containerHeight = MediaQuery.of(context).size.height * 0.257;
    _notify = Provider.of<Notify>(context);
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(
        message: 'Please wait ...',
        borderRadius: 6.0,
        backgroundColor: Colors.white,
        progressWidget: Container(
          child: SpinKitThreeBounce(
            size: 45,
            color: CustomColor.red,
          ),
          height: 20,
          width: 20,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return (_notify.currLoc == null || _notify.dynamicValue == null)
        ? TimeLoading(
            child: Scaffold(
              body: Center(
                child: Text("Loading"),
              ),
            ),
          )
        : TimeLoading(
            child: Scaffold(
              backgroundColor: Colors.white,
              // floatingActionButton: FloatingActionButton(
              //   heroTag: null,
              //   onPressed: () {
              //     Get.to(PostRequirement());
              //   },
              //   child: Icon(Icons.add),
              // ),
              body: Stack(
                children: [buildDataBody(), floatingFilterWidget()],
              ),
            ),
          );
  }

  Container buildDataBody() {
    return Container(
        padding: EdgeInsets.only(top: (_containerHeight + _fromTop)),
        child: Container(
          child: buildRefreshIndicator(),
        ));
  }

  RefreshIndicator buildRefreshIndicator() {
    return RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: postsList.length > 0
            ? Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: ListView.separated(

                    // padding: EdgeInsets.only(top: _containerHeight),
                    physics: ClampingScrollPhysics(),
                    controller: _controller,
                    itemCount: postsList.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(
                          indent: 10,
                          endIndent: 10,
                        ),
                    itemBuilder: (context, index) {
                      final DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy');
                      return buildPostsCard(index, context);
                    }),
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No posts to show in ${distances[selecctedDistanceIndex].floor()} Km\n Try increasing distance.",
                    style: TextStyle(
                      color: CustomColor.grey,
                      fontFamily: "OpenSans",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )));
  }

  PostsCard buildPostsCard(int index, BuildContext context) {
    return PostsCard(
        onPress: () {
          List finalGroups = [];
          bloodGroups.forEach((element) {
            if (element["colorBool"]) {
              finalGroups.add(element["bloodGrp"]);
            }
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPatientDetail(
                        postId: postsList[index].id,
                        bloodGroups: finalGroups,
                      )));
        },
        hospitalLatLng: LatLng(
          postsList[index].data()["hospitalLocation"]["geopoint"].latitude,
          postsList[index].data()["hospitalLocation"]["geopoint"].longitude,
        ),
        postId: postsList[index].id,
        patientAttenderContact1:
            postsList[index].data()["patientAttenderContact1"],
        patientAttenderContact2:
            postsList[index].data()["patientAttenderContact2"],
        patientAttenderContact3:
            postsList[index].data()["patientAttenderContact3"],
        patientAttenderName1: postsList[index].data()["patientAttenderName1"],
        patientAttenderName2: postsList[index].data()["patientAttenderName2"],
        patientAttenderName3: postsList[index].data()["patientAttenderName3"],
        hospitalName: postsList[index].data()["hospitalName"],
        hospitalAreaName: postsList[index].data()["hospitalArea"],
        hospitalCityName: postsList[index].data()["hospitalCity"],
        userCreatedUid: postsList[index].data()["createdBy"],
        requirement: postsList[index].data()["requirementType"],
        myPost: true,
        expired: postsList[index].data()["expired"],
        patientName: postsList[index].data()["patientName"],
        age: int.parse(postsList[index].data()["patientAge"]),
        otherDetails: postsList[index].data()["otherDetails"],
        reqUnits: postsList[index].data()["requiredUnits"].toString(),
        purpose: postsList[index].data()["purpose"],
        reqDate: DateFormat('dd MMM yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(postsList[index]
                .data()["bloodRequiredDateTime"]
                .millisecondsSinceEpoch)),
        roomNumber: postsList[index].data()["hospitalRoomNo"],
        // reqDate: _commonUtilFunctions
        //     .convertDateTimeDisplay(postsList[index]["bloodRequiredDate"]),
        snapshot: postsList[index],
        bloodRequired: postsList[index].data()["requiredBloodGrp"],
        locationDistance:
            (Geolocator.distanceBetween(postsList[index].data()["hospitalLocation"]["geopoint"].latitude, postsList[index].data()["hospitalLocation"]["geopoint"].longitude, _notify.currLoc.latitude, _notify.currLoc.longitude) / 1000)
                .floor()
                .toString(),
        onPressed: () {
          isEligible(postsList[index]);
        },
        onTapped: () => myBottomSheet(
            context,
            postsList[index].id,
            uid,
            postsList[index].data()["createdBy"],
            LatLng(
                postsList[index].data()["hospitalLocation"]["geopoint"].latitude,
                postsList[index].data()["hospitalLocation"]["geopoint"].longitude),
            postsList[index].data()["patientName"],
            postsList[index].data()["requiredBloodGrp"],
            postsList[index]));
  }

  void isEligible(DocumentSnapshot snapshot) async {
    _commonUtilFunctions.loadingCircle("Please wait...");
    final _userData = await FirebaseFirestore.instance
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    Get.back();
    if (_userData == null) {
      _commonUtilFunctions.showError(context);
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
        showDonateDialog(
            context,
            snapshot.id,
            _name,
            index,
            snapshot.data()["patientName"],
            snapshot.data()["createdBy"],
            snapshot.data()["requiredBloodGrp"]);
      } else {
        await Fluttertoast.showToast(
            msg:
                "You can only donate ${snapshot.data()["requirementType"]} after " +
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

  Future<bool> showDonateDialog(
      BuildContext context,
      String postId,
      String userAcceptingName,
      int index,
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
              "Thank you for being a donor.We will send your information "
              "to the requested person.By clicking OK you agree that you "
              "will respond to phone calls an in app messages.",
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
                  "Confirm",
                  style: TextStyle(color: Colors.red, fontSize: 50.sp),
                ),
                color: Colors.white,
                onPressed: () {
                  _firstore.collection("Post").doc(postId).update({
                    'donors': FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser.uid]),
                    'response time': FieldValue.arrayUnion([
                      {
                        FirebaseAuth.instance.currentUser.uid:
                            time.getCurrentTimeStamp()
                      }
                    ]),
                  });
                  setToNotifications(
                      notifyUserUid: posterUid,
                      patientName: patientName,
                      postId: postId,
                      donorName: userAcceptingName);
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          );
        });
  }

  filterBottomSheet(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    int requirementBloodType = globalRequirementBloodType;
    int postTypeFil = globalPostTypeFil;
    double _distance = globalDistance;
    List<String> _bloodType = ["All Post", "I can donate"];
    List<String> _requirementType = ["All", "Blood", "Plasma", "Platelets"];
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setMode) {
              return Wrap(
                children: [
                  Container(
                    // height: screenHeight * 0.4,
                    child: Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(43.w, 50.h, 25.w, 0),
                        // height: screenHeight * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20.h,
                                  width: 170.w,
                                  decoration: BoxDecoration(
                                      color: CustomColor.lightGrey,
                                      borderRadius: BorderRadius.circular(20)),
                                )
                              ],
                            ),
                            SizedBox(height: 30.h),
                            Text(
                              "Filter by blood type",
                              style: TextStyle(fontSize: 38.sp),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            FlutterToggleTab(
                              unSelectedBackgroundColors: [
                                Colors.grey.shade200
                              ],
                              // width in percent, to set full width just set to 100
                              width: screenWidth * 0.14,
                              borderRadius: 30,
                              height: 80.h,
                              initialIndex: postTypeFil,

                              // selectedColors: [Colors.blue],
                              selectedTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w700),
                              unSelectedTextStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w500),
                              labels: _bloodType,
                              selectedLabelIndex: (index) {
                                setMode(() {
                                  postTypeFil = index;
                                });
                                print("Post TYpe: $postTypeFil");
                              },
                            ),
                            SizedBox(
                              height: 50.h,
                            ),
                            Text(
                              "Filter by requirement type",
                              style: TextStyle(fontSize: 38.sp),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            FlutterToggleTab(
                              unSelectedBackgroundColors: [
                                Colors.grey.shade200
                              ],
                              // width in percent, to set full width just set to 100
                              width: screenWidth * 0.2,
                              borderRadius: 30,
                              height: 80.h,
                              initialIndex: requirementBloodType,
                              // selectedColors: [Colors.blue],
                              selectedTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w700),
                              unSelectedTextStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w500),
                              labels: _requirementType,
                              selectedLabelIndex: (index) {
                                setMode(() {
                                  requirementBloodType = index;
                                });
                                print(
                                    "Requirement Blood Type: $requirementBloodType");
                              },
                            ),
                            SizedBox(
                              height: 50.h,
                            ),
                            Text(
                              "Filter by distance (Km)",
                              style: TextStyle(fontSize: 38.sp),
                            ),
                            SfSlider(
                              min: 20.0,
                              max: 100.0,
                              value: _distance,
                              interval: 20,
                              showTicks: false,
                              stepSize: 20,
                              showLabels: true,
                              enableTooltip: true,
                              minorTicksPerInterval: 0,
                              onChanged: (dynamic value) {
                                setMode(() {
                                  _distance = value;
                                });
                                print("Distance: $_distance");
                              },
                            ),
                            SizedBox(
                              height: 45.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side:
                                              BorderSide(color: Colors.red)))),
                              onPressed: () {
                                print("Distance: $_distance");
                                print("postTypeFil : $postTypeFil");
                                print(
                                    "requirementBloodType : $requirementBloodType");

                                setState(() {
                                  globalRequirementBloodType =
                                      requirementBloodType;
                                  globalPostTypeFil = postTypeFil;
                                  globalDistance = _distance;
                                  radius.add(_distance);
                                  getNearByPost(
                                      postTypeFil, requirementBloodType);
                                });
                                Get.back();
                              },
                              child: Text("Apply Filter"),
                              // style: CustomButtonStyle.buildButtonStyle(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              );
            }));
  }
}
