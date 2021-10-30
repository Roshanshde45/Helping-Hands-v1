import 'package:cloud_firestore/cloud_firestore.dart';

class DonorChatDetails{
  String donorName;
  String donorProfilePic;
  String donorUid;
  String chatRoomId;
  String patientName;
  String bloodGrp;
  Timestamp lastSeen;
  String lastMsg;

  DonorChatDetails(
      {
        this.donorName,
        this.donorProfilePic,
        this.donorUid,
        this.chatRoomId,
        this.patientName,
        this.bloodGrp,
        this.lastSeen,
        this.lastMsg
      });
}