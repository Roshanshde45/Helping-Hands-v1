import 'package:bd_app/Model/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'OTPScreen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final String referalCode;
  PhoneAuthScreen({this.referalCode});
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String phoneNum;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.h,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "images/phone.png",
                height: 205.h,
                color: CustomColor.red,
              ),
            ),
            // Lottie.network(
            //   "https://assets2.lottiefiles.com/private_files/lf30_gva1sgii.json",
            //   height: 130,
            //   repeat: true,
            //   reverse: false,
            //   animate: true,
            // ),
            SizedBox(
              height: 67.h,
            ),
            Text(
              "Mobile Number",
              style: TextStyle(fontSize: 65.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40.h,
            ),
            RichText(
              text: TextSpan(
                  text: "We will send you an ",
                  style: TextStyle(color: CustomColor.grey),
                  children: [
                    TextSpan(
                        text: " One Time Password\n",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(
                        text: " on this mobile number",
                        style: TextStyle(color: CustomColor.grey)),
                  ]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 80.h,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColor.lightGrey),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "+91",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: CustomColor.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Form(
                      key: _formKey,
                      child: Flexible(
                        child: TextFormField(
                          maxLength: 10,
                          autofocus: true,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your Phone number";
                            } else if (val.length < 10) {
                              return "Enter valid number";
                            }
                          },
                          onSaved: (val) {
                            setState(() {
                              phoneNum = val;
                            });
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              hintText: "Enter Phone Number",
                              hintStyle: TextStyle()),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 40,
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
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        showAlertDialog(context);

                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => OTPScreen(phoneNum)));
                      }
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text("Get OTP")),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          title: Text("For verification we will be sending OTP to this number",
              style: TextStyle(fontSize: 17)),
          content: Text(
            "+91 " + phoneNum,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            FlatButton(
              child: Text(
                "Edit",
                //    style: TextStyle(color: CustomColor.red.shade700, fontSize: 16.5),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
                child: Text(
                  "OK",
                  //    style: TextStyle(color: CustomColor.red.shade700, fontSize: 16.5),
                ),
                onPressed: () {
                  Get.offAll(OTPScreen(phoneNum,widget.referalCode));
                })
          ],
        );
      },
    );
  }
}
