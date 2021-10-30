import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/Widgets/dialogBoxesWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NewRecommendations extends StatefulWidget {
  @override
  _NewRecommendationsState createState() => _NewRecommendationsState();
}

class _NewRecommendationsState extends State<NewRecommendations> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DialogBoxesWidget _dialogBoxesWidget = DialogBoxesWidget();
  String uid, message, phone;
  Time time;
  Future<void> saveRecommendation() async {
    String timeStamp = time.getCurrentTime().millisecondsSinceEpoch.toString();
    try {
      databaseReference.child("Recommendations").update({
        timeStamp: {
          "recommendation": message.trim(),
          "userShared": uid,
          "phone": phone,
        }
      });
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    phone = FirebaseAuth.instance.currentUser.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
          title: Text(
            "New Recommendation",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: time.offset == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(40.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 35.h,
                          ),
                          Text(
                            "Something missing?",
                            style: TextStyle(
                                color: Colors.red, fontSize: 60.sp),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Text(
                            "Recommend a new feature to Helping Hands App",
                            style: TextStyle(
                                color: CustomColor.red, fontSize: 43.sp),
                          ),
                          SizedBox(
                            height: 55.h,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Your Message",
                            ),
                            validator: (val) {
                              if (val.trim().isEmpty) {
                                return "Field should not be empty";
                              }
                            },
                            onSaved: (val) {
                              setState(() {
                                message = val;
                              });
                            },
                            maxLines: 5,
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(30.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ignore: deprecated_member_use
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  saveRecommendation();
                                  _formKey.currentState.reset();
                                  _dialogBoxesWidget.showDonateDialog(context);
                                }
                              },
                              child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 35.h),
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 48.sp),
                                  )),
                              color: CustomColor.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          )
                        ],
                      ),),),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all( 30.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ignore: deprecated_member_use
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            _formKey.currentState.save();
                            saveRecommendation();
                            _formKey.currentState.reset();
                            showDonateDialog(context);
                          }
                        }, child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 35.h),
                          child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 48.sp),)),color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),),
                    )
                  ],
                ),
              ),
            ),
          ],
        )
    );
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
                              Get.back();
                              Get.back();
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
