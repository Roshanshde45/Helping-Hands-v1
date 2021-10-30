import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DialogBoxesWidget{

  // Future<bool> showDonateDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return new AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20.0)),
  //           title: Align(
  //             alignment: Alignment.topCenter,
  //             child: Text(
  //               "Post updated successfully!!!",
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           content: Padding(
  //               padding: EdgeInsets.only(left: 12),
  //               child: Image.asset("images/done.png",height: 240.h,)
  //           ),
  //           contentPadding: EdgeInsets.all(28.w),
  //           actions: <Widget>[
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: <Widget>[
  //                 FlatButton(
  //                   child: Text("OK",style: TextStyle(color: Colors.red,fontSize: 50.sp),),
  //                   color: Colors.white,
  //                   onPressed: () {
  //
  //                   },
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10)),
  //                 )
  //               ],
  //             )
  //           ],
  //         );
  //       });
  // }


  Future<bool> showDialogToCloseRequest(BuildContext context, String postId) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Close Requirement",
                textAlign: TextAlign.start,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "Do you want to close the requirement and make it not visible from the list ?",
                style: TextStyle(fontSize: 42.sp,color: Colors.grey),
                textAlign: TextAlign.justify,
              ),
            ),
            contentPadding: EdgeInsets.all(28.w),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel",style: TextStyle(color: Colors.grey[500],fontSize: 50.sp),),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  FlatButton(
                    child: Text("OK",style: TextStyle(color: Colors.red,fontSize: 50.sp),),
                    color: Colors.white,
                    onPressed: () {
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


  Future<bool> showDonateDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Image.asset("images/icons/appreciation.png",height: 150.h,),
                    SizedBox(height: 30.h,),
                    Text(
                      "Let us Know how\n we're doing!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 50.sp),
                    ),
                    SizedBox(height: 30.h,),
                    Text(
                      "We are always trying to improve what we do and your feedback is invaluable!",
                      style: TextStyle(fontSize: 34.sp,color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: Text("OK",style: TextStyle(color: Colors.white,fontSize: 50.sp),),
                            color: Colors.red,
                            onPressed: () {

                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      ],
                    )
                  ],
                )
            ),
            contentPadding: EdgeInsets.all(28.w),

          );
        });
  }
}