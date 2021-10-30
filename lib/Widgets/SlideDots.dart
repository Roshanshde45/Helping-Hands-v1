import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 170),
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      height: isActive ? 25.h : 15.h,
      width: isActive ? 40.w : 15.w,
      decoration: BoxDecoration(
        border: Border.all(color: isActive ? Colors.red : Colors.grey[400]),
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
