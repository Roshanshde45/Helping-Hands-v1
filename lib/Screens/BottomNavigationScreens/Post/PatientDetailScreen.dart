// import 'package:bd_app/Model/PatientDetails.dart';
// import 'package:bd_app/services/DynamicLinkService.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flushbar/flushbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:share/share.dart';

// class PatientDetailScreen extends StatefulWidget {
//   PatientDetails patientDetail;
//   final int index;
//   PatientDetailScreen({this.patientDetail,this.index});
//   @override
//   _PatientDetailScreenState createState() => _PatientDetailScreenState();
// }

// class _PatientDetailScreenState extends State<PatientDetailScreen> {
//   final databaseReference = FirebaseDatabase.instance.reference();
//   final DynamicLinkService _dynamicLinkService = DynamicLinkService();
//   String uid,phone;
//   Position _currentPosition;
//   int dateTimestamp;
//   String cityName;
//   String _name;

//   Future<void> setToDonorList(
//       {int index,
//       String postedUserUid,
//       String postId,
//       String patientName}) async{
//     try {
//       DataSnapshot mySnap = await databaseReference.child("Users").child(uid).once();
//       DataSnapshot snapshot = await databaseReference.child("Users").child(postedUserUid).child("donorList").child(postId).once();
//       if(snapshot != null && snapshot.value != null){
//         databaseReference.child("Users").child(postedUserUid).child("donorList").child(postId).update({
//           uid: {
//             "donorName": mySnap.value["name"],
//             "age": calculateAge(mySnap.value["dob"]),
//             "location": "10Km",
//             "cityName": cityName,
//             "responseDate": dateTimestamp,
//             "bloodGrp": mySnap.value["bloodGrp"],
//             "lastDonated": mySnap.value["lastDonated"],
//             "phone": phone,
//             "donorUid": uid,
//             "profileImageUrl":mySnap.value["profilePic"],
//             "patientName": patientName,
//             "postId": postId,
//             "status": true,
//           }
//         });
//       }else{
//         databaseReference.child("Users").child(postedUserUid).child("donorList").child(postId).set({
//           uid: {
//             "donorName": mySnap.value["name"],
//             "age": calculateAge(mySnap.value["dob"]),
//             "location": "10Km",
//             "cityName": cityName,
//             "responseDate": dateTimestamp,
//             "bloodGrp": mySnap.value["bloodGrp"],
//             "lastDonated": mySnap.value["lastDonated"],
//             "phone": phone,
//             "donorUid": uid,
//             "profileImageUrl": mySnap.value["profilePic"],
//             "patientName": patientName,
//             "postId": postId,
//             "status": true,
//           }
//         });
//       }
//     }catch(e){
//     }
//   }

//   saveAcceptedPost(
//       {String postId,
//       String posterUid,
//       String posterPhone,
//       String bloodGrp}) async{
//     databaseReference.child("Users").child(uid).child("accepted").update({
//       postId: {
//         "postId": postId,
//         "userPostedUid": posterUid,
//         "userPostedPhone": posterPhone,
//         "timeStamp": time.getCurrentTime()().millisecondsSinceEpoch,
//         "bloodGrp" : bloodGrp,
//       }
//     });
//   }
//   Future<void> getName() async {
//     databaseReference.child("Users").child(uid).once().then((snapshot) {
//       setState(() {
//         _name = snapshot.value["name"];
//       });
//     });
//   }

//   Future<void> setToNotifications(
//       {String notifyUserUid, String patientName, String postId}) async{
//     // print("Inside setToNotifications");
//     List notifList = [];
//     List temp = [];
//     DataSnapshot snap = await databaseReference.child("Users").child(notifyUserUid).once();
//     try{
//       if(snap != null && snap.value != null){
//         if(snap.value["notifications"] != null) {
//           temp = snap.value["notifications"];
//           // print("Temp List length: ${temp.length}");
//           for(var i = 0; i < temp.length;i++) {
//             notifList.add(snap.value["notifications"][i]);
//           }
//           notifList.add({
//             "donorName" :_name,
//             "sendTo": snap.value["name"],
//             "postId": postId,
//             "timeStamp": time.getCurrentTime()().millisecondsSinceEpoch,
//             "patientName": patientName,
//             "tag": "donorAppeared",
//           });
//           databaseReference.child("Users").child(notifyUserUid).update({
//             "notifications": notifList
//           });

//         }else{
//           notifList.add({
//             "donorName" :_name,
//             "sendTo": snap.value["name"],
//             "postId": postId,
//             "timeStamp": time.getCurrentTime()().millisecondsSinceEpoch,
//             "patientName": patientName,
//             "tag": "donorAppeared",
//           });
//           databaseReference.child("Users").child(notifyUserUid).update({
//             "notifications": notifList
//           });
//         }
//       }else{
//         print("Snap value NULL");
//       }
//     }catch(e){
//     }
//   }

//   Future<void> _determinePosition() async {
//     Position pos;
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permantly denied, we cannot request permissions.');
//     }

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse &&
//           permission != LocationPermission.always) {
//         return Future.error(
//             'Location permissions are denied (actual value: $permission).');
//       }
//     }
//     pos = await Geolocator.getCurrentPosition();
//     setState(() {
//       _currentPosition = pos;
//     });
//     cityNameExtracter(_currentPosition.latitude,_currentPosition.longitude);
//   }

//   Future<void> cityNameExtracter(double lat,double lng) async {
//     final coordinates = new Coordinates(lat, lng);
//     var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     var first = addresses.first;
//     print("${first.adminArea} : ${first.addressLine}");
//     setState(() {
//       cityName = first.adminArea;
//       // print("CITYNAME: $cityName");
//     });
//   }

//   String convertDateTimeDisplay(int timestamp) {
//     var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final DateFormat serverFormater = DateFormat('yMMMMd');
//     final String formatted = serverFormater.format(date);
//     return formatted;
//   }

//   DateTime convertTimeStampDisplay(int timestamp) {
//     DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     return date;
//   }

//   calculateAge(DateTime birthDate) {
//     DateTime currentDate = time.getCurrentTime()();
//     int age = currentDate.year - birthDate.year;
//     int month1 = currentDate.month;
//     int month2 = birthDate.month;
//     if (month2 > month1) {
//       age--;
//     } else if (month1 == month2) {
//       int day1 = currentDate.day;
//       int day2 = birthDate.day;
//       if (day2 > day1) {
//         age--;
//       }
//     }
//     return age;
//   }

//   Future<bool> showDonateDialog(BuildContext context, String postId) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return new AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.0)),
//             title: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 "Donate Blood",
//                 textAlign: TextAlign.start,
//               ),
//             ),
//             content: Padding(
//               padding: EdgeInsets.only(left: 12),
//               child: Text(
//                 "Thank you for being a donor.We will send your information to the requested person.By clicking OK you agree that you will respond to phone calls an in app messages.",
//                 style: TextStyle(fontSize: 42.sp,color: CustomColor.grey),
//               ),
//             ),
//             contentPadding: EdgeInsets.all(28.w),
//             actions: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   FlatButton(
//                     child: Text("Cancel",style: TextStyle(color: CustomColor.grey[500],fontSize: 50.sp),),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   FlatButton(
//                     child: Text("OK",style: TextStyle(color: CustomColor.red,fontSize: 50.sp),),
//                     color: Colors.white,
//                     onPressed: () async{
//                       print("OK");
//                       await saveAcceptedPost(
//                           postId: widget.patientDetail.postId,
//                           bloodGrp: widget.patientDetail.reqBloodGroup,
//                           posterUid: widget.patientDetail.uid,
//                           posterPhone: widget.patientDetail.posterPhone
//                       );
//                       await setToDonorList(
//                           index: widget.index,
//                           postedUserUid: widget.patientDetail.uid,
//                           postId: widget.patientDetail.postId,
//                           patientName: widget.patientDetail.patientName
//                       );
//                       Navigator.of(context).pop();
//                       Flushbar(
//                         title: "Accepted Request!!",
//                         message: "Thank you for being a donor.\nYou can check status of accepted request in Accepted Tab",
//                         duration: Duration(seconds: 3),
//                         flushbarStyle: FlushbarStyle.FLOATING,
//                         flushbarPosition: FlushbarPosition.TOP,
//                         isDismissible: false,
//                       )..show(context);

//                     },
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   )
//                 ],
//               )
//             ],
//           );
//         });
//   }

//   @override
//   void initState() {
//     uid = FirebaseAuth.instance.currentUser.uid;
//     phone = FirebaseAuth.instance.currentUser.phoneNumber;
//     super.initState();
//     dateTimestamp = time.getCurrentTime()().millisecondsSinceEpoch;
//     _determinePosition();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Patient details"),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 30.w),
//             child: Row(
//               children: [
//                 Container(
//                   alignment: Alignment.center,
//                   height: 90.h,
//                   width: 200.w,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12)
//                   ),
//                   child: GestureDetector(
//                     onTap: () async{
//                       String link = await _dynamicLinkService.createFirstPostLink(postId: widget.patientDetail.postId,bloodGrp: widget.patientDetail.reqBloodGroup);
//                       print(link);
//                       Share.share(link, subject: 'Request');
//                     },
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.share,color: Colors.black,size: 20,),
//                         SizedBox(width: 10.w,),
//                         Text("Share",style: TextStyle(color: Colors.black),)
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             padding: EdgeInsets.all(30.w),
//             alignment: Alignment.topCenter,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                Container(
//                  alignment: Alignment.center,
//                  child: Column(
//                    children: [
//                      SizedBox(height: 50.h,),
//                      Container(
//                        alignment: Alignment.center,
//                        padding: EdgeInsets.all(15.w),
//                        height: 188.h,
//                        width: 188.h,
//                        decoration: BoxDecoration(
//                            color: CustomColor.red,
//                            border: Border.all(color: CustomColor.red),
//                            borderRadius: BorderRadius.circular(80)
//                        ),
//                        child: Text(widget.patientDetail.reqBloodGroup,style: TextStyle(color: Colors.white,fontSize: 62.sp,fontWeight: FontWeight.bold),),
//                      ),
//                      SizedBox(height: 80.h,),
//                      Container(
//                        alignment: Alignment.center,
//                        padding: EdgeInsets.symmetric(horizontal: 40.w),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: [
//                            Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: [
//                                Text("Required Date",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Required Time",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Patient Name",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Required Blood Group",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Required Units",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Hospital Name",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Hospital City Name",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Area Name",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Purpose",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Contact Number 1",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Contact Number 2",style: TextStyle(fontSize: 38.sp),),
//                                SizedBox(height: 10.h,),
//                                Text("Other Details",style: TextStyle(fontSize: 38.sp),),
//                              ],
//                            ),
//                            SizedBox(height: 30.w,),
//                            Padding(
//                              padding: EdgeInsets.only(left: 30.w),
//                              child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: [
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                  SizedBox(height: 10.h,),
//                                  Text(":"),
//                                ],
//                              ),
//                            ),
//                            Padding(
//                              padding: EdgeInsets.only(left: 30.w),
//                              child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: [
//                                  Text("${convertDateTimeDisplay(widget.patientDetail.reqDate)}",style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text("${widget.patientDetail.reqTime}",style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.patientName,style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.reqBloodGroup,style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.reqUnits.toString(),style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.hospitalName,style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.hospitalCityName,style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  SizedBox(width: 410.w,
//                                      child: Text(widget.patientDetail.areaName,style: TextStyle(fontSize: 38.sp),overflow: TextOverflow.ellipsis,)),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.purpose,style: TextStyle(fontSize: 38.sp),),
//                                  SizedBox(height: 10.h,),
//                                  Row(children: [
//                                    Text(widget.patientDetail.contact1,style: TextStyle(fontSize: 38.sp),),
//                                  ],),
//                                  SizedBox(height: 10.h,),
//                                  Row(
//                                    children: [
//                                      Text(widget.patientDetail.contact2,style: TextStyle(fontSize: 38.sp),),
//                                    ],
//                                  ),
//                                  SizedBox(height: 10.h,),
//                                  Text(widget.patientDetail.otherDetails,style: TextStyle(fontSize: 38.sp),),
//                                ],
//                              ),
//                            )
//                          ],
//                        ),
//                      ),
//                      SizedBox(height: 80.h,),
//                      Padding(
//                        padding: EdgeInsets.only(left: 120.w),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: [
//                            Container(
//                              height: 120.h,
//                              width: 120.h,
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(80),
//                                color: CustomColor.red,
//                              ),
//                              child: Stack(
//                                children: [
//                                  Align(
//                                    alignment: Alignment.center,
//                                    child: ClipRRect(
//                                      borderRadius: BorderRadius.circular(60),
//                                      child: widget.patientDetail.imgUrl != null ? FadeInImage.assetNetwork(
//                                        placeholder: "images/person.png",
//                                        image: widget.patientDetail.imgUrl,
//                                        height: 325.h,
//                                        width: 325.w,
//                                        fit: BoxFit.cover,
//                                      ): Image.asset("images/person.png",height: 130.h,color: Colors.white,),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                            SizedBox(width: 10.w,),
//                            Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: [
//                                Text("Posted By",style: TextStyle(color: CustomColor.grey,fontSize: 30.sp),),
//                                Text(widget.patientDetail.postedUserName,style: TextStyle(color: CustomColor.red,fontWeight: FontWeight.bold,fontSize: 33.sp),)
//                              ],
//                            )
//                          ],
//                        ),
//                      ),
//                    ],
//                  ),
//                )
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Row(
//               children: [
//                 Expanded(
//                     child: FlatButton(
//                       color: CustomColor.red,
//                       onPressed: () {
//                         showDonateDialog(context,widget.patientDetail.postId);
//                       },
//                       child: Padding(
//                           padding: EdgeInsets.symmetric(vertical: 17),
//                           child: Text("I'll Donate",style: TextStyle(color: Colors.white,fontSize: 47.sp),)),
//                     ))
//               ],
//             ),
//           )
//         ],
//       )
//     );
//   }
// }
