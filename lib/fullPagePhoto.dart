import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class FullScreenPhoto extends StatelessWidget {
  String donorPic;
  FullScreenPhoto(this.donorPic);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      // ),
      body: Stack(
        children: [
          FullScreenPage(
            backgroundColor: Colors.black,
            disposeLevel: DisposeLevel.High,
            backgroundIsTransparent: false,
            child: PinchZoom(
              image: CachedNetworkImage(
                imageUrl: donorPic,
                progressIndicatorBuilder: (_, __, ___) {
                  return Image.asset("images/person.png");
                },

                // height: 150.h,
                // width: 150.h,
                // fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 40,
            child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                }),
          )
        ],
      ),
    );
    // );
  }
}
