import 'package:bd_app/Model/slide.dart';
import 'package:bd_app/Screens/OnBoardUser/PhoneAuthScreen.dart';
import 'package:bd_app/Widgets/SlideDots.dart';
import 'package:bd_app/Widgets/SlideItem.dart';
import 'package:bd_app/appUpdate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class GettingStartedScreen extends StatefulWidget {
  final String referalCode;
  GettingStartedScreen({this.referalCode});
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  int _currentPage = 0;
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(_currentPage,
            duration: Duration(milliseconds: 500), curve: Curves.decelerate);
      }
    });
  }

  _onChangeed(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(35.w),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: slideList.length,
                      itemBuilder: (context, i) => SlideItem(i),
                      onPageChanged: _onChangeed,
                    ),
                    Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 55.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i = 0; i < slideList.length; i++)
                                if (i == _currentPage)
                                  SlideDots(true)
                                else
                                  SlideDots(false)
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 70.h,
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 25.h),
                            child: Text("Continue",
                                style: TextStyle(
                                    fontSize: 45.sp, fontWeight: FontWeight.bold,
                                color: Colors.white)),
                          ),
                          onPressed: pushToPhoneAuth,
                          // splashColor: Colors.red[200],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pushToPhoneAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
    );
  }
}
