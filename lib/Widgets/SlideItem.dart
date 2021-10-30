import 'package:bd_app/Model/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 280,
          height: 280,
          child: Image.asset(slideList[index].imageUrl, height: 280),
        ),
        SizedBox(
          height: 60.h,
        ),
        new Text(
          slideList[index].title,
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontFamily: "OpenSans"),
        ),
        SizedBox(
          height: 30.h,
        ),
        Text(
          slideList[index].description,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(
                0xff8395a7,
              ),
              fontFamily: "OpenSans"),
        ),
      ],
    );
  }
}
