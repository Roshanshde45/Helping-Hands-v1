import 'package:flutter/material.dart';

import 'Model/Colors.dart';

class MockLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Icon(
                  Icons.error_outline_outlined,
                  color: CustomColor.red,
                  size: 50,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                  child: Text(
                "Fake Location Detected",
                textAlign: TextAlign.center,
                style: TextStyle(color: CustomColor.darkGrey, fontSize: 26),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "Please stop the fake gps app and continue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: CustomColor.grey, fontSize: 22),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
