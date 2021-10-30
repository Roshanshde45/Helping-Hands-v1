import 'package:bd_app/provider/server.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';

import 'Model/Colors.dart';

class AppUpdate extends StatefulWidget {
  final Widget child;

  AppUpdate({this.child});
  @override
  _AppUpdateState createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {
  @override
  void initState() {
    print("inits");
    Notify _notify;
    _notify = Provider.of(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_notify.critical_update || _notify.normal_update) {
        await showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () async {
              if (_notify.critical_update) return false;
              return true;
            },
            child: new AlertDialog(
              title: new Text(_notify.critical_update
                  ? "Critical Update"
                  : "Normal Update"),
              content: new Text(_notify.mess),
              actions: <Widget>[
                _notify.critical_update
                    ? Container()
                    : new FlatButton(
                        child: new Text(
                          "Cancel",
                          style: TextStyle(color: CustomColor.grey),
                        ),
                        onPressed: () {
                          if (!_notify.critical_update)
                            Navigator.of(context).pop();
                        },
                      ),
                new FlatButton(
                  child: new Text("Update"),
                  onPressed: () {
                   
                      LaunchReview.launch(writeReview: false);
                   
                  },
                ),
              ],
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
