import 'package:bd_app/provider/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petitparser/matcher.dart';
import 'package:provider/provider.dart';

class TimeLoading extends StatefulWidget {
  final Widget child;
  TimeLoading({this.child});
  @override
  _TimeLoadingState createState() => _TimeLoadingState();
}

class _TimeLoadingState extends State<TimeLoading> {
  Time time;

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    print("error" + time.error.toString());
    return time.offset == null
        ? Scaffold(
            body: Center(
              child: time.error
                  ? Text("No Internet")
                  : CircularProgressIndicator(),
            ),
          )
        : widget.child;
  }
}
