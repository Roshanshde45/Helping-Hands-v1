
import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}


final slideList = [
  Slide(
      imageUrl: "images/postSlide.png",
      title: "Post Blood Requirement",
      description: "Easily post and share your blood requirement and find nearby donors"
  ),
  Slide(
      imageUrl: "images/ready.png",
      title: "Find available donors",
      description: "Find available blood donors easily based on the last donated date."
  ),
  Slide(
      imageUrl: "images/nearby.png",
      title: "Find nearby donors",
      description: "Find nearby blood donors based on the location."
  ),
  Slide(
      imageUrl: "images/connect.png",
      title: "Call interested donors",
      description: "Easily find interested donors list and call them directly."
  ),
];