import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class loadingPost extends StatelessWidget {
  const loadingPost({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        loadingCard(),
        loadingCard(),
        loadingCard(),
      ],
    );
  }
}

class loadingCard extends StatelessWidget {
  const loadingCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: Container(
        padding: EdgeInsets.all(25.w),
        height: 350.h,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 103.h,
                width: 103.h,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey[300]),
                    borderRadius: BorderRadius.circular(80)
                ),
              ),
              SizedBox(width: 35.w,),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                  ]
              ),
              Padding(
                padding: EdgeInsets.only(left: 28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        width: 200.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 90.w,right: 15.w),
                    child: Container(
                      alignment: Alignment.center,
                      width: 180.w,
                      height: 65.h,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]),
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                  ),
                  SizedBox(height: 50.h,),
                  Padding(
                    padding: EdgeInsets.only(left: 90.w,right: 15.w),
                    child: Container(
                      alignment: Alignment.center,
                      width: 180.w,
                      height: 65.h,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]),
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}