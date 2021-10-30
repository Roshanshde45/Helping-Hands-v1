import 'package:flutter/material.dart';

const kThemeBlueColor = Color.fromRGBO(0,171,237,1.0);
const kThemeGreenColor = Color.fromRGBO(138,196,63,1.0);
const kShadowColor = Color.fromRGBO(242, 243, 244 , 1.0);
//var bordrRadius =

const kStandardDecoration = BoxDecoration(
  color: Colors.white,
  boxShadow: [BoxShadow(offset: Offset(3,3,),blurRadius: 3.0,color: kShadowColor)],
  borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0),topRight:Radius.circular(5.0),
  bottomLeft: Radius.circular(5.0),bottomRight: Radius.circular(5.0))
);

const kStateList = [];