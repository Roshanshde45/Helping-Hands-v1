import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDetail{
  String donorName;
  Timestamp timeStamp;
  String messageSentPerson;
  String rewardReceivedFrom;
  String tag;
  String points;

  NotificationDetail({this.donorName, this.timeStamp, this.messageSentPerson, this.tag,this.points,this.rewardReceivedFrom});
}