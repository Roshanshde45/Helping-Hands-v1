import 'dart:io';
import 'package:bd_app/Model/Colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/EditUserDetails.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ViewUserDetailsScreen extends StatefulWidget {
  String name, email;
  File file;
  Map<String, dynamic> data;
  ViewUserDetailsScreen(this.data, [this.name, this.email, this.file]);

  @override
  _ViewUserDetailsScreenState createState() => _ViewUserDetailsScreenState();
}

class _ViewUserDetailsScreenState extends State<ViewUserDetailsScreen> {
  File _image;
  String name,
      contactNumber,
      email,
      bloodGrp,
      gender,
      emergencyContact1,
      emergencyContact2;

  bool donatedPlasma = false,
      donatedBlood = false,
      donatedPlatelets = false,
      gotCovid = false,
      donatePlasmaForCovid;

  int covidRecoveryDate;

  Timestamp dob, lastBloodDonated, lastPlasmaDonated, lastPlatelatesDonated;

  CommonUtilFunctions _commonUtilsFuctions = new CommonUtilFunctions();

  GestureDetector buildPhoto(BuildContext context) {
    return GestureDetector(
      child: Hero(
          tag: "profilePic",
          // child: Container(
          //   height: 100,
          //   width: 100,
          //   decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(100),
          //       color: Colors.white,
          //       boxShadow: [
          //         BoxShadow(
          //           color: CustomColor.grey,
          //           blurRadius: 5.0,
          //         ),
          //       ]),
          //   child: Stack(
          //     children: [
          //       Align(
          //         alignment: Alignment.center,
          //         child: (_image != null || widget.data != null)
          //             ? ClipRRect(
          //                 borderRadius: BorderRadius.circular(80),
          //                 child: (_image != null
          //                     ? Image.file(
          //                         _image,
          //                         fit: BoxFit.cover,
          //                         height: 325,
          //                         width: 325,
          //                       )
          //                     : CachedNetworkImage(
          //                         fit: BoxFit.cover,
          //                         height: 325,
          //                         width: 325,
          //                         imageUrl: widget.data["profilePic"],
          //                         placeholder: (context, url) {
          //                           return Image.asset(
          //                             "images/userbig.png",
          //                             color: CustomColor.grey[350],
          //                             height: 220,
          //                           );
          //                         },
          //                         errorWidget: (context, url, error) {
          //                           return Image.asset(
          //                             "images/userbig.png",
          //                             color: CustomColor.grey[350],
          //                             height: 220,
          //                           );
          //                         },
          //                       )),
          //               )
          //             : Image.asset(
          //                 "images/userbig.png",
          //                 color: CustomColor.grey[350],
          //                 height: 220,
          //               ),
          //       ),
          //     ],
          //   ),
          // ),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CustomColor.grey,
                    blurRadius: 10.0,
                    offset: Offset(0, 0),
                  )
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(60)),
              child: _image == null
                  ? CachedNetworkImage(
                      fit: BoxFit.fill,
                      useOldImageOnUrlChange: true,
                      imageUrl: widget.data["profilePic"],
                      progressIndicatorBuilder: (context, url, _) {
                        return CircularProfileAvatar(
                          widget.data["profilePic"],
                          backgroundColor: Colors.white,
                          child: Shimmer.fromColors(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(42),
                                    color: Colors.white),
                              ),
                              baseColor: CustomColor.grey,
                              highlightColor: CustomColor.lightGrey),
                        );
                      },
                    )
                  : Image.file(
                      _image,
                      fit: BoxFit.cover,
                      height: 110,
                    ),
            ),
          )),
    );
  }

  Widget personalDetailsWidget() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(28.w),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Personal Details",
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "OpenSans"),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Full Name",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Contact Number",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        contactNumber,
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Email Address",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        email.toString(),
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Date of Birth",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        _commonUtilsFuctions.timeStampToDate(dob),
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Blood Group",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        bloodGrp,
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Gender",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        gender,
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Emergency Contact 1",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        emergencyContact1,
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      (emergencyContact2 != null && emergencyContact2 != "")
                          ? Text(
                              "Emergency Contact 2",
                              style: TextStyle(
                                  fontSize: 33.sp, color: Colors.black),
                            )
                          : Container(),
                      (emergencyContact2 != null && emergencyContact2 != "")
                          ? Text(
                              emergencyContact2,
                              style: TextStyle(
                                  fontSize: 45.sp, color: CustomColor.darkGrey),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget donationDetails() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(28.w),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Donation Details",
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "OpenSans"),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Blood Donated",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        lastBloodDonated != null
                            ? _commonUtilsFuctions
                                .timeStampToDate(lastBloodDonated)
                            : "Not Donated",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Plasma Donated",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        lastPlasmaDonated != null
                            ? _commonUtilsFuctions
                                .timeStampToDate(lastPlasmaDonated)
                            : "Not Donated",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Platelets Donated",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        lastPlatelatesDonated != null
                            ? _commonUtilsFuctions
                                .timeStampToDate(lastPlatelatesDonated)
                            : "Not Donated",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // Widget covid19Details() {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     child: Container(
  //         alignment: Alignment.topLeft,
  //         padding: EdgeInsets.all(28.w),
  //         child: Container(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(
  //                 height: 20.h,
  //               ),
  //               Text(
  //                 "COVID-19 Details",
  //                 style: TextStyle(fontSize: 48.sp),
  //               ),
  //               Divider(),
  //               Padding(
  //                 padding: EdgeInsets.only(left: 20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Covid-19 Info",
  //                       style:
  //                           TextStyle(fontSize: 33.sp, color: CustomColor.grey[700]),
  //                     ),
  //                     Text(
  //                       gotCovid
  //                           ? "Infected and recoverd from COVID-19"
  //                           : "Not Infected",
  //                       style:
  //                           TextStyle(fontSize: 45.sp, color: CustomColor.grey[700]),
  //                     ),
  //                     SizedBox(
  //                       height: 25.h,
  //                     ),
  //                     covidRecoveryDate != null
  //                         ? Text(
  //                             "Recovery Date",
  //                             style: TextStyle(
  //                                 fontSize: 33.sp, color: CustomColor.grey[700]),
  //                           )
  //                         : Container(),
  //                     covidRecoveryDate != null
  //                         ? Text(
  //                             _commonUtilsFuctions
  //                                 .convertDateTimeDisplay(covidRecoveryDate),
  //                             style: TextStyle(
  //                                 fontSize: 45.sp, color: CustomColor.grey[700]),
  //                           )
  //                         : Container(),
  //                     SizedBox(
  //                       height: donatePlasmaForCovid != null ? 25.h : 0,
  //                     ),
  //                     donatePlasmaForCovid != null
  //                         ? Text(
  //                             "Donate Plasma for COVID-19 patients",
  //                             style: TextStyle(
  //                                 fontSize: 33.sp, color: CustomColor.grey[700]),
  //                           )
  //                         : Container(),
  //                     donatePlasmaForCovid != null
  //                         ? Text(
  //                             donatePlasmaForCovid ? "Yes" : "No",
  //                             style: TextStyle(
  //                                 fontSize: 45.sp, color: CustomColor.grey[700]),
  //                           )
  //                         : Container(),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )),
  //   );
  // }

  Widget donationAvailibility() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(28.w),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Donation Availibility",
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "OpenSans"),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Available for Blood Donation",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        donatedBlood ? "Yes" : "No",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Available for Plasma Donation",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        donatedPlasma ? "Yes" : "No",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        "Available for Platelets Donation",
                        style: TextStyle(fontSize: 33.sp, color: Colors.black),
                      ),
                      Text(
                        donatedPlatelets ? "Yes" : "No",
                        style: TextStyle(
                            fontSize: 45.sp, color: CustomColor.darkGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    contactNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    if (widget.data != null) {
      _image = widget.file;
      name = widget.data["name"];
      bloodGrp = widget.data["bloodGrp"];
      gender = widget.data["gender"];
      dob = widget.data["dob"];
      email = widget.data["email"];
      emergencyContact1 = widget.data["emergency1"];
      emergencyContact2 = widget.data["emergency2"];
      donatedBlood = widget.data["donateBlood"];
      donatedPlasma = widget.data["donatePlasma"];
      lastBloodDonated = widget.data["lastDonated"];
      lastPlasmaDonated = widget.data["lastPlasmaDonated"];
      gotCovid = widget.data["gotCovid"];
      covidRecoveryDate = widget.data["covidRecoverDate"];
      lastPlatelatesDonated = widget.data["lastPlateletsDonated"];
      donatedPlatelets = widget.data["donatePlatlets"];
      donatePlasmaForCovid = widget.data["donatePlasmaForCovid"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          widget.data != null
              ? IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Get.to(TakeUserDetailsScreen(widget.data));
                    // Get.to(EditUserDetails(widget.data));
                    Get.to(() => EditUserDetails(widget.data, widget.email));
                  })
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15))),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        gradient: LinearGradient(colors: [
                          Color(0xffC9D6FF),
                          Color(0xffE2E2E2),
                        ])),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.21,
                    child: buildPhoto(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 15.h,
                    ),
                    personalDetailsWidget(),
                    SizedBox(
                      height: 15.h,
                    ),
                    donationDetails(),
                    SizedBox(
                      height: 15.h,
                    ),
                    donationAvailibility(),
                    SizedBox(
                      height: 15.h,
                    ),
                    // covid19Details(),
                    SizedBox(
                      height: 80.h,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
