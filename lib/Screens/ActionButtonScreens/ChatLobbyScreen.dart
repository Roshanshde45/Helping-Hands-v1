import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Model/DonorChatDetails.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ChatLobbyScreen extends StatefulWidget {
  @override
  _ChatLobbyScreenState createState() => _ChatLobbyScreenState();
}

class _ChatLobbyScreenState extends State<ChatLobbyScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  String uid, chatRoomId, donorUid, donorName, donorProfilePic;
  List<DonorChatDetails> allChatsDetailList = [];
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  bool loaded = false;

  Future getAllActiveInteractionChats() async {
    List chatsList = [];
    int chatIdLength;
    String uid1, uid2;
    String donorResultUid;
    List<DonorChatDetails> allChatsDetailList = [];
    String patientName, bloodGrp, lastMsg;
    Timestamp lastSeen;
    QuerySnapshot snapshot;
    DocumentSnapshot snap;
    DocumentSnapshot snapPatientDetails;
    snapshot = await FirebaseFirestore.instance.collection("ChatRooms").get();
    for (var doc in snapshot.docs) {
      print(doc.id);
      if (doc.id.contains(uid)) {
        print(":::::::::GOT ONE:::::::::");
        chatsList.add(doc.id);
      }
    }

    print("ChatListIds::::::: $chatsList");
    for (var i = 0; i < chatsList.length; i++) {
      if (chatsList[i].toString().length < 1) {
        print("No ChatId Got");
      } else {
        chatIdLength = chatsList[i].toString().length;
        uid1 = chatsList[i]
            .toString()
            .substring(0, chatsList[i].toString().indexOf('_'));
        uid2 = chatsList[i]
            .toString()
            .substring(chatsList[i].toString().indexOf('_') + 1, chatIdLength);
        if (uid1 == this.uid) {
          donorResultUid = uid2;
        } else {
          donorResultUid = uid1;
        }
      }
      print("Result UID: $donorResultUid");

      snapPatientDetails = await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(chatsList[i])
          .get();
      snap = await FirebaseFirestore.instance
          .collection("Profile")
          .doc(donorResultUid)
          .get();
      if (snapPatientDetails.exists) {
        lastSeen = snapPatientDetails.data()["lastMessageSendTs"];
        lastMsg = snapPatientDetails.data()["lastMessage"];
      }
      if (snap != null && snap.data() != null) {
        allChatsDetailList.add(DonorChatDetails(
          donorName: snap.data()["name"],
          donorProfilePic: snap.data()["profilePic"],
          donorUid: donorResultUid,
          chatRoomId: chatsList[i],
          lastSeen: snap.data()["lastOpened"],
          lastMsg: lastMsg,
        ));
      }
      print("CHATROOM ID: ${chatsList[i]}");
    }
    setState(() {
      this.allChatsDetailList = allChatsDetailList;
      loaded = true;
    });
  }

  String getDonorUid(String chatId) {
    print("::::Inside GetDonorId");
    print("ChatRoomId: $chatId");
    int chatIdLength;
    String uid1, uid2;
    if (chatId.length < 1) {
      print("No ChatId Got");
    } else {
      chatIdLength = chatId.length;
      uid1 = chatId.substring(0, chatId.indexOf('_'));
      uid2 = chatId.substring(chatId.indexOf('_') + 1, chatIdLength);
      if (uid1 == this.uid) {
        setState(() {
          return uid2;
        });
      } else {
        return uid1;
      }
    }
  }

  getDonorData() async {
    String donorName, donorProfilePic;
    DataSnapshot snap;
    snap = await databaseReference.child("Users").child(donorUid).once();
    if (snap != null && snap.value) {
      donorName = snap.value["name"];
      donorProfilePic = snap.value["profilePic"];
      setState(() {
        this.donorName = donorName;
        this.donorProfilePic = donorProfilePic;
      });
    }
  }

  Widget chatListWidget({String donorUid, String chatRoomId, String lastMsg}) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("Profile")
            .doc(donorUid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text("Loading"),
            );
          }
          return ListTile(
            onTap: () {
              print(":::::::::::::::Passing Data:::::::::::::::");
              print("Name: $donorName");
              print("profilePic : $donorProfilePic");
              print("uid : $donorUid");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          donorName: snapshot.data["name"],
                          donorProfilePic: snapshot.data["profilePic"],
                          donorUid: donorUid,
                          chatRoomId: chatRoomId,
                          phone: snapshot.data["phone"])));
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: snapshot.data["profilePic"] != null
                  ? FadeInImage.assetNetwork(
                      placeholder: "images/person.png",
                      image: snapshot.data["profilePic"],
                      height: 116.h,
                      width: 116.w,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "images/person.png",
                      height: 120.h,
                    ),
            ),
            title: Text(
              snapshot.data["name"],
            ),
            subtitle: Text(
              lastMsg != null ? lastMsg : "",
              style: TextStyle(fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        });
  }

  Future<Null> refreshList() async {
    setState(() {});
    refreshChangeListener.refreshed = true;
    return null;
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: refreshList,
          child: PaginateFirestore(
            key: UniqueKey(),
            isLive: true,
            itemsPerPage: 5,
            listeners: [refreshChangeListener],
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (index, context, documentSnapshot) {
              String chatRoomId = documentSnapshot.id;
              String uid1 = chatRoomId.substring(0, chatRoomId.indexOf('_'));
              String uid2 = chatRoomId.substring(
                  chatRoomId.indexOf('_') + 1, chatRoomId.length);
              return chatListWidget(
                  donorUid: uid1 != uid ? uid1 : uid2,
                  chatRoomId: chatRoomId,
                  lastMsg: documentSnapshot.data()["lastMessage"]);
            },
            emptyDisplay: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/icons/chat.png",
                    height: 700.h,
                  ),
                  Text(
                    "Your chats will appear here.",
                    style: TextStyle(color: CustomColor.grey, fontSize: 45.sp),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Go to homepage",
                      style: TextStyle(color: CustomColor.red, fontSize: 40.sp),
                    ),
                  )
                ],
              ),
            ),
            query: FirebaseFirestore.instance
                .collection("ChatRooms")
                .where("users", arrayContains: uid)
                .orderBy("lastMessageSendTs", descending: true),
          ),
        ));
  }
}
