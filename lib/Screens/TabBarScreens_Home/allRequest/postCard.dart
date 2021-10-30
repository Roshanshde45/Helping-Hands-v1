import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/PatientDetails.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bd_app/Model/PostCardDetails.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:get/get_utils/src/extensions/string_extensions.dart";

class PostsCard extends StatelessWidget {
  final String patientName;
  final String userCreatedUid;
  final VoidCallback onPressed;
  final String requirement;
  final VoidCallback onTapped;
  final VoidCallback onPress;
  final dynamic snapshot;
  final String reqDate;
  final String purpose;
  final int index;
  final String postId;
  final String bloodRequired;
  final int age;
  final String reqUnits;
  final bool myPost;
  final bool expired;
  final String locationDistance;
  final LatLng hospitalLatLng;
  final String patientAttenderContact1;
  final String patientAttenderContact2;
  final String patientAttenderContact3;
  final String patientAttenderName1;
  final String patientAttenderName2;
  final String patientAttenderName3;
  final String otherDetails;
  final String roomNumber;
  final String hospitalName;
  final String hospitalCityName;
  final String hospitalAreaName;
  const PostsCard({
    this.onPress,
    this.hospitalLatLng,
    this.userCreatedUid,
    this.requirement,
    this.patientName,
    this.bloodRequired,
    this.onTapped,
    this.index,
    this.onPressed,
    this.snapshot,
    this.postId,
    this.reqDate,
    this.age,
    this.purpose,
    this.reqUnits,
    this.expired,
    this.myPost,
    this.locationDistance,
    this.patientAttenderContact1,
    this.patientAttenderContact2,
    this.patientAttenderContact3,
    this.patientAttenderName1,
    this.patientAttenderName2,
    this.patientAttenderName3,
    this.otherDetails,
    this.roomNumber,
    this.hospitalName,
    this.hospitalCityName,
    this.hospitalAreaName,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
    return InkWell(
      onTap: onPress,
      onLongPress: onTapped,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        child: Row(
          children: [
            FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Profile")
                    .doc(userCreatedUid)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: 126.w,
                      height: 126.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: CustomColor.red),
                    );
                  }
                  return Container(
                    width: 126.w,
                    height: 126.w,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Center(
                        child: CachedNetworkImage(
                      imageUrl: snapshot.data["profilePic"],
                    )),
                    clipBehavior: Clip.hardEdge,
                  );
                }),
            SizedBox(
              width: 24.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: bloodRequired,
                            style: TextStyle(
                                color: CustomColor.red, fontSize: 40.sp)),
                        TextSpan(
                            text: " " +
                                commonUtilFunctions.firstCaptial(requirement) +
                                " required for ",
                            style: TextStyle(
                                color: Colors.black, fontSize: 40.sp)),
                        TextSpan(
                          text: commonUtilFunctions.firstCaptial(patientName),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.sp,
                            // fontStyle: FontStyle.italic,
                          ),
                        )
                      ])),
                  RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(children: [
                        TextSpan(
                            text:
                                "$reqDate   |   $reqUnits units  | $locationDistance KM",
                            style: TextStyle(
                                color: CustomColor.grey, fontSize: 30.sp)),
                        TextSpan(
                            text: "", style: TextStyle(color: Colors.green))
                      ])),
                ],
              ),
            ),
            IconButton(
                onPressed: onTapped, icon: Icon(Icons.more_vert_outlined))
          ],
        ),
      ),
      // child: Card(
      //   elevation: 0.0,
      //   color: Colors.white,
      //   child: Container(
      //     padding: EdgeInsets.all(10.w),
      //     child: Row(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Container(
      //           alignment: Alignment.center,
      //           height: 103.h,
      //           width: 103.h,
      //           decoration: BoxDecoration(
      //               color: Colors.red,
      //               border: Border.all(color: Colors.red),
      //               borderRadius: BorderRadius.circular(80)),
      //           child: Text(
      //             bloodRequired,
      //             style: TextStyle(
      //                 fontSize: 43.sp,
      //                 color: Colors.white,
      //                 fontWeight: FontWeight.w700),
      //           ),
      //         ),
      //         SizedBox(
      //           width: 20.w,
      //         ),
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               "Requirement",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             Text(
      //               "Patient Name",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             Text(
      //               "Required Date",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             // Text(
      //             //   "Required Time",
      //             //   style: TextStyle(fontSize: 33.sp),
      //             // ),
      //             Text(
      //               "Purpose",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             Text(
      //               "Age",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             Text(
      //               "Required Units",
      //               style: TextStyle(fontSize: 33.sp),
      //             ),
      //             Text(
      //               "Location",
      //               style: TextStyle(fontSize: 33.sp),
      //             )
      //           ],
      //         ),
      //         Padding(
      //           padding: EdgeInsets.only(left: 20.w),
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               // Text(
      //               //   ":",
      //               //   style: TextStyle(fontSize: 33.sp),
      //               // ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 ":",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Padding(
      //           padding: EdgeInsets.only(left: 25.w),
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                 commonUtilFunctions.firstCaptial(requirement),
      //                 style: TextStyle(fontSize: 33.sp),
      //                 overflow: TextOverflow.ellipsis,
      //               ),
      //               Text(
      //                 commonUtilFunctions.firstCaptial(patientName),
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 "$reqDate",
      //                 style: TextStyle(
      //                     fontSize: 33.sp,
      //                     color: Colors.red,
      //                     fontWeight: FontWeight.w500),
      //               ),
      //               // Text(
      //               //   "$reqTime",
      //               //   style: TextStyle(
      //               //       fontSize: 33.sp,
      //               //       color: Colors.red,
      //               //       fontWeight: FontWeight.w500),
      //               // ),
      //               Container(
      //                 width: 100,
      //                 child: Text(
      //                   commonUtilFunctions.firstCaptial(purpose),
      //                   overflow: TextOverflow.ellipsis,
      //                   style: TextStyle(fontSize: 33.sp),
      //                 ),
      //               ),
      //               Text(
      //                 "$age yr",
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 reqUnits.toString(),
      //                 style: TextStyle(fontSize: 33.sp),
      //               ),
      //               Text(
      //                 "$locationDistance Km away",
      //                 style: TextStyle(fontSize: 33.sp),
      //               )
      //             ],
      //           ),
      //         ),
      //         Expanded(
      //             child: SizedBox(
      //           width: 1,
      //         )),
      //         userCreatedUid == FirebaseAuth.instance.currentUser.uid
      //             ? Container()
      //             : Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Padding(
      //                     padding: EdgeInsets.only(left: 50.w),
      //                     child: myPost
      //                         ? GestureDetector(
      //                             onTap: () {
      //                               Navigator.push(
      //                                   context,
      //                                   MaterialPageRoute(
      //                                       builder: (context) =>
      //                                           NewPatientDetail(
      //                                             postId: postId,
      //                                           )));
      //                             },
      //                             child: Container(
      //                               alignment: Alignment.center,
      //                               width: 180.w,
      //                               height: 65.h,
      //                               decoration: BoxDecoration(
      //                                   border:
      //                                       Border.all(color: CustomColor.grey),
      //                                   borderRadius: BorderRadius.circular(5)),
      //                               child: Text(
      //                                 "View",
      //                                 style: TextStyle(
      //                                     fontSize: 33.sp, color: Colors.black),
      //                               ),
      //                             ),
      //                           )
      //                         : Container(
      //                             child: SizedBox(
      //                             width: 180.w,
      //                           )),
      //                   ),
      //                   SizedBox(
      //                     height: 40.h,
      //                   ),
      //                   myPost
      //                       ? Padding(
      //                           padding: EdgeInsets.only(left: 50.w),
      //                           child: GestureDetector(
      //                             onTap: onPressed,
      //                             child: Container(
      //                               alignment: Alignment.center,
      //                               width: 180.w,
      //                               height: 65.h,
      //                               decoration: BoxDecoration(
      //                                   color: CustomColor.red,
      //                                   borderRadius: BorderRadius.circular(5)),
      //                               child: Text(
      //                                 "i'll donate",
      //                                 style: TextStyle(
      //                                     fontSize: 33.sp, color: Colors.white),
      //                               ),
      //                             ),
      //                           ),
      //                         )
      //                       : Container(
      //                           width: 40.w,
      //                         ),
      //                 ],
      //               ),
      //         SizedBox(
      //           width: 10.w,
      //         ),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.end,
      //           children: [
      //             GestureDetector(
      //                 onTap: onTapped, child: Icon(Icons.more_vert)),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
