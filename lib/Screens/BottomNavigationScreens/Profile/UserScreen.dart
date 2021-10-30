import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/FeedBackForm.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:mailto/mailto.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:get/get.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/NewRecommendationsScreen.dart';
import 'package:bd_app/Screens/EditProfileScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/LifePoints.dart';

import 'ViewUserDetailsScreen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String uid;
  bool loaded = false;
  String _name,
      _bloodGrp,
      _emergency1,
      _emergency2,
      _otherDetails,
      _email,
      _phone,
      referalCode;
  Timestamp _lastDonated, _dob;
  String imageUrl;
  bool FirstTimeUser = false;
  final databaseReference = FirebaseFirestore.instance;
  DynamicLinkService dynamicLinkService = DynamicLinkService();
  CommonUtilFunctions _commonUtilFunctions = CommonUtilFunctions();
  Map<String, dynamic> data;
  Notify _notify;
  Future<bool> getData() async {
    DocumentSnapshot snapshot = await databaseReference
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get(GetOptions(source: Source.cache));
    _notify.setUser(snapshot);
    print(snapshot.data());
    data = snapshot.data();
    print(
        ":::::::::::::::::::::::::::::::::::::PRINTING DATA::::::::::::::::::::::::::::");
    print(data);
    _name = snapshot.data()["name"];
    _email = snapshot.data()["email"];
    _bloodGrp = snapshot.data()["bloodGrp"];
    referalCode = snapshot.data()["referralCode"];

    if (snapshot.data()["lastDonated"] == null) {
    } else {
      _lastDonated = snapshot.data()["lastDonated"];
    }
    print(snapshot.data()["dob"]);
    if (snapshot.data()["dob"] != null) {
      _dob = snapshot.data()["dob"];
    } else {
      FirstTimeUser = true;
    }
    print(snapshot.data()["emergency1"]);
    if (snapshot.data()["emergency1"] != null) {
      _emergency1 = snapshot.data()["emergency1"];
    }
    print(snapshot.data()["emergency2"]);
    if (snapshot.data()["emergency2"] != null) {
      _emergency2 = snapshot.data()["emergency2"];
    }
    print(snapshot.data()["otherDetails"]);
    if (snapshot.data()["otherDetails"] != null) {
      _otherDetails = snapshot.data()["otherDetails"];
    }

    imageUrl = snapshot.data()["profilePic"];
    loaded = true;
    return true;
  }

  launchMailto() async {
    final mailtoLink = Mailto(
      to: ["goeleventhmile@gmail.com"],
      // cc: ['cc1@example.com', 'cc2@example.com'],
      // subject: 'mailto example subject',
      // body: 'mailto example body',
    );
    await launch('$mailtoLink');
  }

  @override
  void initState() {
    _notify = Provider.of<Notify>(context, listen: false);
    uid = FirebaseAuth.instance.currentUser.uid;
    _phone = FirebaseAuth.instance.currentUser.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Notify _notify = Provider.of<Notify>(context);
    return FutureBuilder<bool>(
        future: getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            body: true
                ? SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(50.w),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           ViewUserDetailsScreen(data)),
                              // ).then((value) => value ? getData() : null);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewUserDetailsScreen(data)));
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  Hero(
                                    tag: "profilePic",
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(300),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: CustomColor.grey,
                                              blurRadius: 5.0,
                                            ),
                                          ]),
                                      child: imageUrl != null
                                          ? Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder:
                                                          "images/person.png",
                                                      image: imageUrl,
                                                      height: 130,
                                                      width: 130,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                imageUrl == null
                                                    ? Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right:
                                                                        10.w),
                                                            child: Icon(
                                                              Icons.camera_alt,
                                                              color: Colors
                                                                  .redAccent,
                                                            )))
                                                    : Container()
                                              ],
                                            )
                                          : Image.asset("images/person.png"),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 66.sp,
                                            fontFamily: "OpenSans",
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            color: CustomColor.grey,
                                            size: 19,
                                          ),
                                          SizedBox(
                                            width: 17.w,
                                          ),
                                          Container(
                                            width: 500.w,
                                            child: Text(
                                              _email.toString(),
                                              style: TextStyle(
                                                  color: CustomColor.darkGrey,
                                                  fontFamily: "OpenSans",
                                                  fontWeight: FontWeight.w400),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: CustomColor.grey,
                                            size: 19,
                                          ),
                                          SizedBox(
                                            width: 17.w,
                                          ),
                                          Text(
                                            _phone,
                                            style: TextStyle(
                                                color: CustomColor.darkGrey,
                                                fontFamily: "OpenSans",
                                                fontWeight: FontWeight.w400),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70.h,
                          ),
                          Divider(),
                          TabHolder(
                            img: "images/donorIcon.png",
                            title: "Life Points",
                            onPress: () {
                              Get.to(() => LifePointsScreen(referalCode));
                            },
                          ),
                          // TabHolder(
                          //   img: "images/icons/share.png",
                          //   title: "Share with friends",
                          //   onPress: () async {
                          //     _commonUtilFunctions.loadingCircle("Loading...");
                          //     String shareLink = await dynamicLinkService
                          //         .createShareReferalLink(referalCode);
                          //     Get.back();
                          //     Share.share(shareLink);
                          //   },
                          // ),
                          TabHolder(
                            img: "images/icons/like.png",
                            title: "New Recommendations",
                            onPress: () async {
                              Get.to(NewRecommendations());
                            },
                          ),
                          TabHolder(
                            img: "images/icons/feedback.png",
                            title: "Feedback",
                            onPress: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FeedBackForm()));
                            },
                          ),
                          TabHolder(
                            img: "images/icons/contact.png",
                            title: "Contact Us",
                            onPress: launchMailto,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: TextButton(
                                onPressed: null,
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 35,
                                                  width: 35,
                                                  padding: EdgeInsets.all(6.5),
                                                  decoration: BoxDecoration(
                                                      color: CustomColor
                                                          .veryLightGrey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Image.asset(
                                                    "images/icons/gift.png",
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 30.w,
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Invite friends, get rewards",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "OpenSans",
                                                            fontSize: 43.sp),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Share your code ",
                                                            style: TextStyle(
                                                                color:
                                                                    CustomColor
                                                                        .grey,
                                                                fontFamily:
                                                                    "OpenSans",
                                                                // fontWeight: FontWeight.w400,
                                                                fontSize:
                                                                    30.sp),
                                                          ),
                                                          Text(
                                                            referalCode
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          InkWell(
                                                              onTap: () async {
                                                                Clipboard.setData(
                                                                    new ClipboardData(
                                                                        text:
                                                                            referalCode));
                                                                // Get.back();
                                                                await Fluttertoast.showToast(
                                                                    msg:
                                                                        "code is copied to the clipboard.",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_LONG,
                                                                    gravity: ToastGravity
                                                                        .BOTTOM,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        CustomColor
                                                                            .grey,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0);
                                                              },
                                                              child: Icon(
                                                                Icons.copy,
                                                                size: 20,
                                                                color: Colors
                                                                    .black,
                                                              ))
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            _commonUtilFunctions
                                                .loadingCircle("Loading...");
                                            String shareLink =
                                                await dynamicLinkService
                                                    .createShareReferalLink(
                                                        referalCode);
                                            Get.back();
                                            String msgText =
                                                "I’m inviting you to use the Helping Hands App, a platform made for people who are in need of blood, platelets, plasma. Here's my code ($referalCode) just enter it while signup and let's start saving lives\n";
                                            Share.share(
                                                msgText + "\n" + shareLink);
                                          },
                                          child: Text(
                                            "Share",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 40.sp),
                                          ),
                                        )
                                      ],
                                    )),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed))
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5);
                                      return null; // Use the component's default.
                                    },
                                  ),
                                )),
                          ),

                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 20.w),
                          //   child: Row(
                          //     children: [
                          //       Icon(
                          //         Icons.share,
                          //         color: Colors.white,
                          //       ),
                          //       SizedBox(
                          //         width: 20.w,
                          //       ),
                          //       Text(
                          //         "Share your code ",
                          //         style: TextStyle(
                          //             color: CustomColor.grey,
                          //             // fontWeight: FontWeight.w400,
                          //             fontSize: 42.sp),
                          //       ),
                          //       Text(referalCode),
                          //       SizedBox(width: 5,),
                          //       InkWell(
                          //           onTap: () async {
                          //
                          //             Clipboard.setData(
                          //                 new ClipboardData(text: referalCode));
                          //             // Get.back();
                          //             await Fluttertoast.showToast(
                          //                 msg: "code is copied to the clipboard.",
                          //                 toastLength: Toast.LENGTH_LONG,
                          //                 gravity: ToastGravity.CENTER,
                          //                 timeInSecForIosWeb: 1,
                          //                 backgroundColor: CustomColor.grey,
                          //                 textColor: Colors.white,
                          //                 fontSize: 16.0);
                          //           },
                          //           child: Icon(
                          //             Icons.copy,
                          //             size: 20,
                          //             color: Colors.black,
                          //           ))
                          //
                          //     ],
                          //   ),
                          // ),

                          // SizedBox(height: 15.h,),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 20.w),
                          //   child: TextButton(onPressed: () {
                          //     // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                          //   }, child: Padding(
                          //     padding: EdgeInsets.symmetric(vertical: 20.h),
                          //     child: Row(
                          //       children: [
                          //         Image.asset("images/icons/feature.png",height: 70.h,color: CustomColor.red,),
                          //         SizedBox(width: 20.w,),
                          //         Text("Request feature",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 46.sp),)
                          //       ],
                          //     ),
                          //   ),
                          //       style: ButtonStyle(
                          //         backgroundColor:  MaterialStateProperty.resolveWith<Color>(
                          //               (Set<MaterialState> states) {
                          //             if (states.contains(MaterialState.pressed))
                          //               return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                          //             return null; // Use the component's default.
                          //           },
                          //         ),
                          //       )
                          //   ),
                          // ),
                          // SizedBox(height: 15.h,),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        });
  }
}

class TabHolder extends StatelessWidget {
  final String img;
  final String title;
  final VoidCallback onPress;
  const TabHolder({
    this.img,
    this.title,
    this.onPress,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextButton(
          onPressed: onPress,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 35,
                  padding: EdgeInsets.all(6.5),
                  decoration: BoxDecoration(
                      color: CustomColor.veryLightGrey,
                      borderRadius: BorderRadius.circular(50)),
                  child: Image.asset(
                    img,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 30.w,
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: "OpenSans",
                      fontSize: 43.sp),
                )
              ],
            ),
          ),
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return CustomColor.lightGrey.withOpacity(0.5);
                return null; // Use the component's default.
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return CustomColor.lightGrey.withOpacity(0.5);
                return null; // Use the component's default.
              },
            ),
          )),
    );
  }
}
