import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:bd_app/timeLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String donorName, donorProfilePic, donorUid, chatRoomId, phone;

  ChatScreen(
      {this.donorName,
      this.donorProfilePic,
      this.donorUid,
      this.chatRoomId,
      this.phone});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController sendMessageTextController = TextEditingController();
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  final databaseReference = FirebaseFirestore.instance;
  bool chatExists = false;
  String uid;
  Stream messageStream;
  Timestamp lastSeen;
  bool loaded = false;
  String myName, myProfilePic, myUid;
  Time time;

  getMyInfoFromFb() async {
    String myName, myProfilePic, chatId;
    DocumentSnapshot snap;
    snap = await databaseReference.collection("Profile").doc(uid).get();
    if (snap != null && snap.data() != null) {
      myName = snap.data()["name"];
      myProfilePic = snap.data()["profilePic"];
      setState(() {
        this.myName = myName;
        this.myProfilePic = myProfilePic;
      });
    }
  }

  addMessage(bool sendClicked) async {
    print(":::::::::::::::::::::::::::::");
    print(widget.chatRoomId);
    if (sendMessageTextController.text != "") {
      String message = sendMessageTextController.text.trim();

      var lastMessageTs = time.getCurrentTime();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": uid,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(widget.chatRoomId)
          .collection("Chats")
          .doc()
          .set(messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": uid,
          "lastMessage": sendMessageTextController.text,
        };

        FirebaseFirestore.instance
            .collection("ChatRooms")
            .doc(widget.chatRoomId)
            .update(lastMessageInfo);

        if (sendClicked) {
          sendMessageTextController.text = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe, Timestamp ts) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Column(
          crossAxisAlignment:
              sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomRight:
                        sendByMe ? Radius.circular(0) : Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft:
                        sendByMe ? Radius.circular(24) : Radius.circular(0),
                  ),
                  color: sendByMe ? CustomColor.red : Color(0xfff1f0f0),
                ),
                padding: EdgeInsets.all(13),
                child: Text(
                  message,
                  style:
                      TextStyle(color: sendByMe ? Colors.white : Colors.black),
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                commonUtilFunctions.extractTimeFromTimeStamp(ts),
                style: TextStyle(color: CustomColor.grey, fontSize: 33.sp),
                textAlign: sendByMe ? TextAlign.end : TextAlign.start,
              ),
            )
          ],
        )),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], uid == ds["sendBy"], ds["ts"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessages() async {
    Stream tempMessageStream;
    tempMessageStream = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomId)
        .collection("Chats")
        .orderBy("ts", descending: true)
        .snapshots();
    setState(() {
      messageStream = tempMessageStream;
    });
  }

  // Future getLastSeen() async{
  //   String chatRoomId = widget.chatRoomId;
  //   String docId;
  //   List uidsArray = chatRoomId.split("_");
  //   if(uidsArray[0] == uid){
  //     docId = uidsArray[1];
  //   }else{
  //     docId = uidsArray[0];
  //   }
  //   databaseReference.collection("Profile").doc(docId).get().then((value) => {
  //     setState(() {
  //       lastSeen = value.data()["lastOpened"];
  //     })
  //   });
  // }

  @override
  void initState() {
    // getLastSeen();
    print(widget.chatRoomId);
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
    getMyInfoFromFb();
    getAndSetMessages();
  }

  @override
  Widget build(BuildContext context) {
    time = Provider.of<Time>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.phone,
              color: CustomColor.red,
            ),
            onPressed: () {
              commonUtilFunctions.makePhoneCall(widget.phone, false);
            },
            tooltip: "Call",
          )
        ],
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: widget.donorProfilePic != null
                  ? FadeInImage.assetNetwork(
                      placeholder: "images/person.png",
                      image: widget.donorProfilePic,
                      height: 37,
                      width: 37,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "images/person.png",
                      height: 120.h,
                      color: Colors.white,
                    ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.donorName,
                  style: TextStyle(fontSize: 42.sp, color: Colors.black),
                ),
                // Text("last seen ${commonUtilFunctions.timeStampToDate(lastSeen).toString()}",style: TextStyle(
                //   fontSize: 34.sp,
                //   fontStyle: FontStyle.italic
                // ),)
              ],
            )
          ],
        ),
      ),
      body: TimeLoading(
        child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Stack(
            children: [
              chatMessages(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 33.w),
                  decoration: BoxDecoration(color: Color(0xffced6e0)),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none),
                        controller: sendMessageTextController,
                        minLines: 1,
                        maxLines: null,
                      )),
                      GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Icon(Icons.send))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
