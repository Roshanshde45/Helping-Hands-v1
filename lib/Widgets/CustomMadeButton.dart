import 'package:bd_app/Model/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomMadeButton extends StatelessWidget {
  @required
  VoidCallback onPress;
  @required
  String buttonText;
  Color color;
  CustomMadeButton({
    this.onPress,
    this.buttonText,
    this.color = CustomColor.red,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ignore: deprecated_member_use
        Expanded(
          child: FlatButton(
            onPressed: onPress,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 35.h),
                child: Text(
                  buttonText,
                  style: TextStyle(color: Colors.white, fontSize: 48.sp),
                )),
            color: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )
      ],
    );
  }
}
