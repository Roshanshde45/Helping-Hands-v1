import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({Key key, this.child}) : super(key: key);
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  Time _time;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int a = 1;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    
    Notify _notify = Provider.of(context, listen: false);
    a++;
     print('aaa state = $state ' + a.toString() + " " + _notify.checkTime.toString());
    if (state == AppLifecycleState.resumed && _notify.checkTime) {
     
      _time.fetchTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    _time = Provider.of<Time>(context, listen: false);
    return Container(
      child: widget.child,
    );
  }
}
