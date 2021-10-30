// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:bd_app/Screens/OnBoardUser/TakeUserDetails.dart';

// class UserEmailScreen extends StatefulWidget {
//   @override
//   _UserEmailScreenState createState() => _UserEmailScreenState();
// }

// class _UserEmailScreenState extends State<UserEmailScreen> {
//   @override
//   Widget build(BuildContext context) {

//     final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
//       onPrimary: Colors.white,
//       primary: CustomColor.red,
//       minimumSize: Size(88, 36),
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//       ),
//     );

//     return Scaffold(
//       body: Container(
//         alignment: Alignment.topCenter,
//         padding: EdgeInsets.all(50.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               child: Column(
//                 children: [
//                   SizedBox(height: 250.h,),
//                   Text("Helping Hands",style: TextStyle(color: CustomColor.red,fontWeight: FontWeight.w400,fontSize: 120.sp),),
//                   SizedBox(height: 90.h,),
//                   Image.asset("images/icons/handshake.png",width: 800.h,),
//                 ],
//               ),
//             ),
//             Container(
//               alignment: Alignment.bottomCenter,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Donor will see you as",style: TextStyle(color: CustomColor.grey),),
//                   SizedBox(height: 30.h,),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         child: Row(
//                           children: [
//                             Container(
//                               height: 120.h,
//                               width: 120.h,
//                               decoration: BoxDecoration(
//                                 color: CustomColor.red,
//                                 borderRadius: BorderRadius.circular(70),
//                               ),
//                             ),
//                             SizedBox(width: 25.w,),
//                             Container(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text("Saurabh Ganguly"),
//                                           Text("saurabhganguly@gmail.com",style: TextStyle(color: CustomColor.grey[600],fontSize: 37.sp),),
//                                           Text("+91 8456845235",style: TextStyle(color: CustomColor.grey[600],fontSize: 37.sp),)
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                               )
//                             )

//                           ],
//                         ),
//                       ),
//                       IconButton(icon: Icon(Icons.edit,color: CustomColor.red,), onPressed: (){})
//                     ],
//                   ),
//                   SizedBox(height: 100.h,),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 100.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             style: raisedButtonStyle,
//                             onPressed: () {
//                               Navigator.push(context, MaterialPageRoute(builder: (_) => TakeUserDetailsScreen()));
//                             },
//                             child: Text('Continue'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
