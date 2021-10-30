import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Profile/EditUserDetails.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:bd_app/Screens/EditProfileScreen.dart';
import 'package:bd_app/Screens/OnBoardUser/UserEmailScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' show get;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'UserBloodDetailScreen.dart';

class OTPScreen extends StatefulWidget {
  final phone;
  final referalCode;
  OTPScreen(this.phone, [this.referalCode]);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String _verificationCode;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final databaseReference = FirebaseFirestore.instance;
  Timer _timer;
  int _start = 60;
  int forceResendingToken;
  bool dataExist = false;
  ProgressDialog pr;
  bool codeSent = false;
  int _forceResendingToken;
  String pin;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>[
      'email',
    ],
  );

  Future<GoogleSignInAccount> _handleSignIn() async {
    try {
      GoogleSignInAccount _account = await _googleSignIn.signIn();
      return _account;
    } catch (error) {
      print(error);
    }
    return null;
  }

  verifyPhone() async {
    print("Verify Function Triggered");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91 ${widget.phone}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("verfication completed");
        bool userDataExist = false;
        await pr.show();
        // try {
        UserCredential _userCred = await FirebaseAuth.instance
            .signInWithCredential(credential)
            .catchError((onError) {
          // showSnackBar(msg: 'Something Wrong');
          pr.hide();
          FocusScope.of(context).unfocus();
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text('Invalid OTP!!!')));
        });
        // .then((value) async {
        // print("Printing Value: ${value.user.uid}");

        if (_userCred != null) {
          await checkUserDataExist(_userCred.user.uid);
          print("DataExist: $dataExist");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!codeSent) {
          Get.back();
        } else {
          pr.hide();
        }
        print("error" + e.toString());
      },
      codeSent: (String verificationID, [int forceResendingToken]) {
        print("code sent");
        setState(() {
          this._verificationCode = verificationID;
          _forceResendingToken = forceResendingToken;
          codeSent = true;
        });

        Get.back();
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      timeout: Duration(seconds: 60),
      forceResendingToken: _forceResendingToken,
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _start = 0;
          });
          _timer.cancel();
        } else {
          if (this.mounted) {
            setState(() {
              _start--;
            });
          }
        }
      },
    );
  }

  Future<void> checkUserDataExist(String uid) async {
    print(":::::::Entered Function to check for data::::::UID: $uid");
    DocumentSnapshot snap;

    snap = await databaseReference
        .collection("Profile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    pr.hide();
    if (snap.exists) {
      // Get.back();
      // Get.off(DashboardScreen());

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
          (route) => false);
    } else {
      GoogleSignInAccount _account;
      for (;;) {
        _account = await _handleSignIn();
        if (_account != null) {
          break;
        }
      }

      if (_account != null) {
        // Get.back();
        File url = await _asyncMethod(_account.photoUrl);
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => TakeUserDetailsScreen(null,
        //             _account.displayName, _account.email, url)),
        //     (route) => false);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => EditUserDetails(
                    null, _account.displayName, _account.email, url)),
            (route) => false);
      }
    }
  }

  Future<File> _asyncMethod(String url) async {
    //comment out the next two lines to prevent the device from getting
    // the image from the web in order to prove that the picture is
    // coming from the device instead of the web.
    // <-- 1
    print("url");
    print(url);
    var response = await get(url); // <--2
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    await Directory(firstPath).create(recursive: true); // <-- 1
    File file2 = new File(filePathAndName); // <-- 2
    file2.writeAsBytesSync(response.bodyBytes, flush: true); // <-- 3
    return file2;
  }

  @override
  void initState() {
    print("ints");
    print(widget.phone);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 20,
                ),
                Text("Sending...")
              ],
            ),
          ),
        ),
      );
    });
    verifyPhone();
    startTimer();
    super.initState();
  }

  // _OTPScreenState() {
  //   verifyPhone();

  // }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: 'Validating...',
        borderRadius: 6.0,
        backgroundColor: Colors.white,
        progressWidget: Container(
          child: SpinKitRing(
            size: 45,
            color: CustomColor.red,
            lineWidth: 2.3,
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
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(235, 236, 237, 1),
      borderRadius: BorderRadius.circular(5.0),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(30.w),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 170.h,
            ),
            Image.asset(
              "images/email.png",
              height: 205.h,
              color: CustomColor.red,
            ),
            SizedBox(
              height: 60.h,
            ),
            Text(
              "OTP Verification",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30.h,
            ),
            RichText(
              text: TextSpan(
                  text: "Enter the OTP sent to ",
                  style: TextStyle(color: CustomColor.grey),
                  children: [
                    TextSpan(
                        text: "+91 ${widget.phone}\n",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 80.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 70.w),
              child: PinPut(
                eachFieldWidth: 43.0,
                eachFieldHeight: 52.0,
                autofocus: true,
                withCursor: true,
                fieldsCount: 6,
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: pinPutDecoration,
                selectedFieldDecoration: pinPutDecoration,
                followingFieldDecoration: pinPutDecoration,
                pinAnimationType: PinAnimationType.scale,
                textStyle: const TextStyle(color: Colors.black, fontSize: 20.0),
                onChanged: (text) {
                  pin = text;
                },
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                    padding: EdgeInsets.only(right: 60.w, top: 10.h),
                    child: Text(
                      "0:$_start sec",
                      style: TextStyle(color: CustomColor.red, fontSize: 40.sp),
                      textAlign: TextAlign.end,
                    )),
              ],
            ),
            SizedBox(
              height: 50.h,
            ),
            GestureDetector(
              onTap: _start != 0
                  ? () {}
                  : () {
                      if (this.mounted) {
                        verifyPhone();
                        setState(() {
                          _start = 60;
                        });
                      }
                      // verifyPhone();
                      startTimer();
                    },
              child: RichText(
                  text: TextSpan(
                      text: "Did'nt receive the verification OTP?",
                      style: TextStyle(color: CustomColor.grey),
                      children: [
                    TextSpan(
                      text: " Resend OTP",
                      style: TextStyle(
                          color:
                              _start != 0 ? CustomColor.grey : CustomColor.red),
                    )
                  ])),
            ),
            SizedBox(
              height: 50.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: CustomColor.red)))),
                    onPressed: () async {
                      if (codeSent) {
                        bool userDataExist = false;
                        await pr.show();
                        // try {
                        UserCredential _userCred = await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode,
                                smsCode: pin))
                            .catchError((onError) {
                          // showSnackBar(msg: 'Something Wrong');
                          pr.hide();
                          FocusScope.of(context).unfocus();
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text('Invalid OTP!!!')));
                        });
                        // .then((value) async {
                        // print("Printing Value: ${value.user.uid}");

                        if (_userCred != null) {
                          await checkUserDataExist(_userCred.user.uid);
                          print("DataExist: $dataExist");
                        }
                        //   else
                        //   {

                        // });
                        // }
                        // catch (e) {
                        //   pr.hide();
                        //   FocusScope.of(context).unfocus();
                        //   _scaffoldKey.currentState.showSnackBar(
                        //       SnackBar(content: Text('Invalid OTP!!!')));
                        // }
                      }
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text("Submit")),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
