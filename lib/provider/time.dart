import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ntp/ntp.dart';

class Time extends ChangeNotifier {
  int offset;
  bool error = false;

  Time() {
    fetchTime();
  }

  void fetchTime() async {
    print("fetch time");
    offset = null;
    error = false;
    
    DateTime startDate = new DateTime.now().toLocal();
    try {
      offset = await NTP
          .getNtpOffset(localTime: startDate, timeout: Duration(seconds: 5))
          .then((value) async {
        error = false;
        return value;
      });
    } on SocketException {
      print("socket ex");
      error = true;
    }
    if (offset == null) {
      error = true;
    }
    print(
        'NTP DateTime offset align: ${startDate.add(new Duration(milliseconds: offset))}');
    notifyListeners();
  }

  DateTime getCurrentTime() {
    DateTime currentTime = DateTime.now();
    if (offset != null) {
      return currentTime.add(Duration(milliseconds: offset));
    } else {
      return currentTime;
    }
  }

  Timestamp getCurrentTimeStamp() {
    Timestamp time = Timestamp.now();
    if (offset != null) {
      return Timestamp.fromDate(
          time.toDate().add(Duration(milliseconds: offset)));
    } else {
      return time;
    }
  }
}
