import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MyApplication extends StatefulWidget {
  @override
  _MyApplicationState createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  getToken() {
    _firebaseMessaging.getToken().then((deviceToken) => print(deviceToken));
  }

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async{
        print("onMessage: $message");
      },
        onResume: (Map<String, dynamic> message) async{
        print("onResume: $message");
    },
        onLaunch: (Map<String, dynamic> message) async{
        print("onLaunch: $message");
    }
    );
  }

  _setMessage(Map<String,dynamic> message) {
    final notification = message["notification"];
    final data = message["data"];
    final String title = notification["title"];
    final String body = notification["body"];
    // final String mMessage = data[]
  }

  @override
  void initState() {
    super.initState();
    getToken();
    _configureFirebaseListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Title"),
      ),
    );
  }
}

class Message {
  String title;
  String body;
  String message;

  Message({this.title, this.body, this.message});
}
