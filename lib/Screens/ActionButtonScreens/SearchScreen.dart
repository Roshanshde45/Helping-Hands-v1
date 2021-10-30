import 'package:age/age.dart';
import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/ChatScreen.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/services/CommonUtilFuctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double _containerHeight = 244;

  // You don't need to change any of these variables
  double _fromTop = 0;
  var _controller = ScrollController();
  // var _allowReverse = true, _allowForward = true;
  // var _prevOffset = 0.0;
  // var _prevForwardOffset = -_containerHeight;
  // var _prevReverseOffset = 0.0;
  final geo = Geoflutterfire();
  String reqType = "Blood";
  Stream<List<DocumentSnapshot>> stream;
  final controller = ScrollController();
  final _server = FirebaseFirestore.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  final radius = BehaviorSubject<double>.seeded(20);
  final _bloodGrpController = ScrollController();
  final _radiusController = ScrollController();
  CommonUtilFunctions commonUtilFunctions = CommonUtilFunctions();
  String currentlySelectedType;
  int selectedRadius = 5;
  String uid;
  bool threeMonthLoaded = false;
  String userBloodGrp;
  bool selected3Month = false;
  List allUsersList = [];
  Set<String> bloodGrpList = {};
  List<DocumentSnapshot> profileList = [];
  LatLng currLoc;
  Notify _notify;
  var _prevForwardOffset;
  var _prevReverseOffset = 0.0;
  Time time;

  List bloodGroups = [
    {"bloodGrp": "Any", "colorBool": true},
    {"bloodGrp": "A-", "colorBool": false},
    {"bloodGrp": "B-", "colorBool": false},
    {"bloodGrp": "AB-", "colorBool": false},
    {"bloodGrp": "O-", "colorBool": false},
    {"bloodGrp": "A+", "colorBool": false},
    {"bloodGrp": "B+", "colorBool": false},
    {"bloodGrp": "AB+", "colorBool": false},
    {"bloodGrp": "O+", "colorBool": false},
  ];

  List typeList = [
    {
      "type": "Blood",
      "colorBool": true,
    },
    {
      "type": "Plasma",
      "colorBool": false,
    },
    {
      "type": "Platelets",
      "colorBool": false,
    },
  ];

  List radiusList = [
    {
      "radius": 5,
      "colorBool": true,
    },
    {
      "radius": 10,
      "colorBool": false,
    },
    {
      "radius": 20,
      "colorBool": false,
    },
    {
      "radius": 40,
      "colorBool": false,
    },
    {
      "radius": 50,
      "colorBool": false,
    }
  ];

  void selectedGrpFunc(String grp) {
    Set<String> bgList = {};
    List indices = [];

    print(grp);

    switch (grp) {
      case "Any":
        {
          indices = [1, 2, 3, 4, 5, 6, 7, 8];
        }
        break;
      case "A-":
        {
          indices = [1, 4];
        }
        break;
      case "B-":
        {
          indices = [2, 4];
        }
        break;
      case "AB-":
        {
          indices = [4, 1, 2, 3];
        }
        break;
      case "O-":
        {
          indices = [4];
        }
        break;
      case "A+":
        {
          indices = [4, 8, 1, 5];
        }
        break;
      case "B+":
        {
          indices = [4, 8, 2, 6];
        }
        break;
      case "AB+":
        {
          indices = [1, 2, 3, 4, 5, 6, 7, 8];
        }
        break;
      case "O+":
        {
          indices = [4, 8];
        }
    }
    print(indices.length);

    for (var i = 0; i <= 8; i++) {
      for (var j = 0; j < indices.length; j++) {
        if (i == indices[j]) {
          print("$i == ${indices[j]}");
          bgList.add(bloodGroups[i]["bloodGrp"]);

          setState(() {
            bloodGrpList = bgList;
          });
          print("Blood GroupList: $bloodGrpList");
        }
      }
    }
  }

  SelectedBloodGroup(int index) {
    for (int i = 0; i < bloodGroups.length; i++) {
      setState(() {
        bloodGroups[i]["colorBool"] = false;
      });
    }
    setState(() {
      bloodGroups[index]["colorBool"] = true;
      selectedGrpFunc(bloodGroups[index]["bloodGrp"]);
      // selectedBloodRequired = bloodGroups[index]["bloodGrp"];
    });
  }

  selectedRadiusfunc(int index) {
    for (int i = 0; i < radiusList.length; i++) {
      setState(() {
        radiusList[i]["colorBool"] = false;
      });
    }
    setState(() {
      radiusList[index]["colorBool"] = true;
      selectedRadius = radiusList[index]["radius"];
      radius.add(selectedRadius.toDouble());
      // getUserProfiles(currentlySelectedType);
    });
  }

  getUserProfiles(String type) async {
    print("Calling: getUsers");
    print("type: $type");
    print("radius: $selectedRadius");
    print(FirebaseAuth.instance.currentUser.phoneNumber);

    // await _notify.gpsService();
    List profileList = [];
    QuerySnapshot snapshot;
    if (_notify.currLoc == null) await _notify.gpsService();
    profileList.clear();
    switch (type) {
      case "Blood":
        {
          print("In case: Blood");
          GeoFirePoint center = geo.point(
              latitude: _notify.currLoc.latitude,
              longitude: _notify.currLoc.longitude);
          bloodGrpList.add('Any');
          stream = radius.switchMap((rad) {
            var collectionReference = _server
                .collection('Profile')
                .where('donateBlood', isEqualTo: true)
                .where("bloodGrp", whereIn: bloodGrpList.toList());
            return geo.collection(collectionRef: collectionReference).within(
                center: center, radius: rad, field: 'latLng', strictMode: true);
          });
          getProfileListFunc("Blood");
        }
        break;
      case "Plasma":
        {
          print("InCase: Plasma");
          GeoFirePoint center = geo.point(
              latitude: _notify.currLoc.latitude,
              longitude: _notify.currLoc.longitude);
          bloodGrpList.add('Any');
          stream = radius.switchMap((rad) {
            var collectionReference = _server
                .collection('Profile')
                .where('donatePlasma', isEqualTo: true)
                .where("bloodGrp", whereIn: bloodGrpList.toList());
            return geo.collection(collectionRef: collectionReference).within(
                center: center, radius: rad, field: 'latLng', strictMode: true);
          });
          getProfileListFunc("Plasma");
        }
        break;
      case "Platelets":
        {
          print("InCase: Platlets");
          GeoFirePoint center = geo.point(
              latitude: _notify.currLoc.latitude,
              longitude: _notify.currLoc.longitude);
          bloodGrpList.add('Any');
          stream = radius.switchMap((rad) {
            var collectionReference = _server
                .collection('Profile')
                .where('donatePlatlets', isEqualTo: true)
                .where("bloodGrp", whereIn: bloodGrpList.toList());
            return geo.collection(collectionRef: collectionReference).within(
                center: center, radius: rad, field: 'latLng', strictMode: true);
          });
          getProfileListFunc("Platelets");
        }
        break;
      default:
        {
          print("Something went wrong: Function: getUsers");
        }
    }
  }

  bool isEligible(DocumentSnapshot snapshot) {
    DateTime _firstDate = DateTime(2000);
    List<Timestamp> lastDates = [];
    if (snapshot.data()["lastDonated"] != null) {
      lastDates.add(snapshot.data()["lastDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    if (snapshot.data()["lastPlasmaDonated"] != null) {
      lastDates.add(snapshot.data()["lastPlasmaDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    if (snapshot.data()["lastPlateletsDonated"] != null) {
      lastDates.add(snapshot.data()["lastPlateletsDonated"]);
    } else {
      lastDates.add(Timestamp.fromMillisecondsSinceEpoch(
          DateTime(2000).millisecondsSinceEpoch));
    }

    List<Timestamp> temp = List.from(lastDates);
    print(lastDates);
    temp.sort((a, b) => a.compareTo(b));
    print(temp);
    int index = lastDates.indexOf(temp[2]);

    String lastDonated;

    if (index == 0) {
      lastDonated = "Blood";
    } else if (index == 1) {
      lastDonated = "Plasma";
    } else if (index == 2) {
      lastDonated = "Platelets";
    }

    print("lastDonated" + lastDonated);

    String key = lastDonated + "To" + currentlySelectedType;

    if (currentlySelectedType == "Blood" && lastDonated == "Blood") {
      key = key + (snapshot.data()["gender"] == "Male" ? "M" : "F");
    }

    print("dynamic value key" + key);

    _firstDate = lastDates[index]
        .toDate()
        .add(Duration(days: _notify.dynamicValue[key]));

    Timestamp _temp = time.getCurrentTimeStamp();
    if (_temp.millisecondsSinceEpoch > _firstDate.millisecondsSinceEpoch) {
      return true;
    } else {
      return false;
    }
  }

  getProfileListFunc(String type) {
    stream.listen((List<DocumentSnapshot> documentList) {
      List<DocumentSnapshot> _lists = documentList;
      print("Profile List Length: ${documentList.length}");
      if (_lists != null) {
        _lists.removeWhere((element) {
          if (element.id == FirebaseAuth.instance.currentUser.uid) {
            return true;
          }

          if (isEligible(element) == false) {
            return true;
          }
          return false;
        });
      }
      setState(() {
        profileList = _lists;
      });
    });
  }

  double prevoffset = 0;
  bool up = true;
  bool down = true;

  void _listener() {
    double offset = _controller.position.pixels;
    print(offset);
    var direction = _controller.position.userScrollDirection;
    setState(() {
      if (direction == ScrollDirection.reverse) {
        print("up");
        up = true;
        if (down) {
          down = false;
          prevoffset = offset;
          _prevReverseOffset = _fromTop;
        }
        if (_fromTop > (-_containerHeight))
          _fromTop = _prevReverseOffset - (-prevoffset + offset);

        if (_fromTop <= (-_containerHeight)) _fromTop = (-_containerHeight);
      } else if (direction == ScrollDirection.forward) {
        down = true;
        if (up) {
          up = false;
          prevoffset = offset;
          _prevForwardOffset = _fromTop;
        }
        if (_fromTop < 0) {
          _fromTop = _prevForwardOffset + (prevoffset - offset);
        }

        if (_fromTop >= 0) {
          _fromTop = 0;
        }
      } else if (direction == ScrollDirection.idle) {
        // prevoffset = offset;
      }
      print("from top");
      print(_fromTop);
    });

    // print("offset");
    // print(offset);

    // var difference;
    // print(offset);

    // setState(() {
    //   if (direction == ScrollDirection.reverse) {
    //     print("Forward");
    //     _allowForward = true;
    //     if (_allowReverse) {
    //       _allowReverse = false;
    //       _prevOffset = offset;
    //       _prevForwardOffset = _fromTop;
    //     }

    //     difference = _prevOffset - offset;
    //     _fromTop = _prevForwardOffset + difference;
    //     if (_fromTop < -_containerHeight) {
    //       _fromTop = -_containerHeight;
    //     }
    //   } else if (direction == ScrollDirection.forward) {
    //     print("Reverse");
    //     _allowReverse = true;
    //     if (_allowForward) {
    //       _allowForward = false;
    //       _prevOffset = offset;
    //       _prevReverseOffset = _fromTop;
    //     }

    //     difference = offset - _prevOffset;
    //     _fromTop = _prevReverseOffset - difference;
    //     if (_fromTop > 0) _fromTop = 0;
    //   }
    // });
    // print("difference: $difference");
    // print("_prevForwardOffset: $_prevForwardOffset");
    // print("_prevReverseOffset: $_prevReverseOffset");
    // print("FromTop: $_fromTop");
  }

  @override
  void dispose() {
    radius.close();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _prevForwardOffset = -_containerHeight;
    _notify = Provider.of<Notify>(context, listen: false);
    uid = FirebaseAuth.instance.currentUser.uid;
    currentlySelectedType = "Blood";
    SelectedBloodGroup(0);
    selectedRadiusfunc(0);
    _controller.addListener(_listener);
    getUserProfiles('Blood');
    super.initState();
  }

  Widget chipsCarryingWidget(int index, String title, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: AnimatedContainer(
        duration: Duration(microseconds: 93000),
        height: 90.h,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(
                color: typeList[index]["colorBool"]
                    ? CustomColor.red
                    : CustomColor.lightGrey,
                width: 1),
            borderRadius: BorderRadius.circular(20),
            color:
                typeList[index]["colorBool"] ? CustomColor.red : Colors.white),
        child: Text(
          title.toString(),
          style: TextStyle(
              color: typeList[index]["colorBool"]
                  ? Colors.white
                  : CustomColor.grey),
        ),
      ),
    );
  }

  Widget selectRequiredType() {
    return Container(
      height: 68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            child: FittedBox(
              child: Text(
                "Select Type",
                style: TextStyle(
                    fontSize: 34.sp,
                    fontFamily: "OpenSans",
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 40,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: typeList
                    .map((e) => FittedBox(
                          child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: chipsCarryingWidget(typeList.indexOf(e),
                                  typeList[typeList.indexOf(e)]["type"], () {
                                setState(() {
                                  for (int i = 0; i < typeList.length; i++) {
                                    typeList[i]["colorBool"] = false;
                                  }
                                  typeList[typeList.indexOf(e)]["colorBool"] =
                                      !typeList[typeList.indexOf(e)]
                                          ["colorBool"];
                                  currentlySelectedType =
                                      typeList[typeList.indexOf(e)]["type"];
                                  getUserProfiles(currentlySelectedType);
                                });
                              })),
                        ))
                    .toList()),
          ),
        ],
      ),
    );
  }

  Widget selectRequiredBloodGroup() {
    return Container(
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _bloodGrpController,
          child: Row(
            children: [
              Row(
                children: bloodGroups
                    .map((e) => Padding(
                          padding: EdgeInsets.only(right: 20.h),
                          child: GestureDetector(
                            onTap: () {
                              SelectedBloodGroup(bloodGroups.indexOf(e));
                              getUserProfiles(currentlySelectedType);
                            },
                            child: AnimatedContainer(
                              duration: Duration(microseconds: 93000),
                              alignment: Alignment.center,
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: bloodGroups[bloodGroups.indexOf(e)]
                                          ["colorBool"]
                                      ? CustomColor.red
                                      : Colors.white,
                                  border: Border.all(
                                      color: bloodGroups[bloodGroups.indexOf(e)]
                                              ["colorBool"]
                                          ? CustomColor.red
                                          : CustomColor.lightGrey),
                                  borderRadius: BorderRadius.circular(80)),
                              child: FittedBox(
                                child: Text(
                                  bloodGroups[bloodGroups.indexOf(e)]
                                      ["bloodGrp"],
                                  style: TextStyle(
                                      color: bloodGroups[bloodGroups.indexOf(e)]
                                              ["colorBool"]
                                          ? Colors.white
                                          : CustomColor.grey,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectRadiusWidget() {
    return Container(
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _radiusController,
          child: Row(
            children: [
              Row(
                children: radiusList
                    .map((e) => Padding(
                          padding: EdgeInsets.only(right: 20.h),
                          child: GestureDetector(
                            onTap: () {
                              selectedRadiusfunc(radiusList.indexOf(e));
                            },
                            child: AnimatedContainer(
                                duration: Duration(microseconds: 93000),
                                alignment: Alignment.center,
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: radiusList[radiusList.indexOf(e)]
                                            ["colorBool"]
                                        ? CustomColor.red
                                        : Colors.white,
                                    border: Border.all(
                                        color: radiusList[radiusList.indexOf(e)]
                                                ["colorBool"]
                                            ? CustomColor.red
                                            : CustomColor.lightGrey),
                                    borderRadius: BorderRadius.circular(80)),
                                child: FittedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        radiusList[radiusList.indexOf(e)]
                                                ["radius"]
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 43.sp,
                                            color: radiusList[radiusList
                                                    .indexOf(e)]["colorBool"]
                                                ? Colors.white
                                                : CustomColor.grey,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "KM",
                                        style: TextStyle(
                                            fontSize: 25.sp,
                                            color: radiusList[radiusList
                                                    .indexOf(e)]["colorBool"]
                                                ? Colors.white
                                                : CustomColor.grey,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewProfiles() {
    print("profiles length");
    print(profileList.length);
    print(profileList);
    return profileList.length <= 0
        ? Center(
            child: Text(
              "No Donors found under $selectedRadius Km\nTry increasing distance",
              style: TextStyle(fontFamily: "OpenSans", color: CustomColor.grey),
              textAlign: TextAlign.center,
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 3),
            child: ListView.separated(
                // padding: EdgeInsets.only(top: (_containerHeight)),
                controller: _controller,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: profileList.length,
                separatorBuilder: (context, index) => Divider(
                      indent: 10,
                      endIndent: 10,
                    ),
                itemBuilder: (context, index) {
                  return DonorSearchListCard(
                    currentType: currentlySelectedType,
                    name: profileList[index].data()["name"],
                    age: commonUtilFunctions
                        .calculateAge(profileList[index].data()["dob"], time)
                        .toString(),
                    lastBloodDonated:
                        profileList[index].data()["lastDonated"] != null
                            ? commonUtilFunctions.convertDateTimeDisplay(
                                profileList[index].data()["lastDonated"])
                            : null,
                    imgUrl: profileList[index].data()["profilePic"],
                    bloodGrp: profileList[index].data()["bloodGrp"],
                    lastOpened: profileList[index].data()["lastOpened"] != null
                        ? commonUtilFunctions.convertDateTimeDisplay(
                            profileList[index].data()["lastOpened"])
                        : null,
                    lastPlasmaDonated:
                        profileList[index].data()["lastPlasmaDonated"] != null
                            ? commonUtilFunctions.convertDateTimeDisplay(
                                profileList[index].data()["lastPlasmaDonated"])
                            : null,
                    lastPlatletsDonated: profileList[index]
                                .data()["lastPlateletsDonated"] !=
                            null
                        ? commonUtilFunctions.convertDateTimeDisplay(
                            profileList[index].data()["lastPlateletsDonated"])
                        : null,
                    lastLocation: commonUtilFunctions
                        .distanceBetweenCoordinates(
                            LatLng(
                              profileList[index]
                                  .data()["latLng"]["geopoint"]
                                  .latitude,
                              profileList[index]
                                  .data()["latLng"]["geopoint"]
                                  .longitude,
                            ),
                            LatLng(_notify.currLoc.latitude,
                                _notify.currLoc.longitude))
                        .floor()
                        .toString(),
                    // lastLocation: "12 Km",
                    onPressed: () async {
                      {
                        commonUtilFunctions.loadingCircle("Loading...");
                        print("::::::::::::::::::::::::::::::::::::::");
                        String uid1 = uid;
                        String uid2 = profileList[index].data()["uid"];
                        String donorId;
                        var OneWayChatRoomId =
                            commonUtilFunctions.getChatRoomIdByUid(uid1, uid2);
                        var ReverseChatRoomId =
                            commonUtilFunctions.getChatRoomIdByUid(uid2, uid1);
                        var ChatRoomId;
                        print("OneWayChatRoomId:  $OneWayChatRoomId");
                        print("OneWayChatRoomId:  $ReverseChatRoomId");
                        Map<String, dynamic> chatRoomInfo = {
                          "users": [uid, profileList[index].data()["uid"]],
                          // "bloodGrp": selectedBloodRequired,
                        };
                        final snapShot = await FirebaseFirestore.instance
                            .collection("ChatRooms")
                            .doc(OneWayChatRoomId)
                            .get();

                        final RevSnapShot = await FirebaseFirestore.instance
                            .collection("ChatRooms")
                            .doc(ReverseChatRoomId)
                            .get();

                        if (snapShot.exists) {
                          ChatRoomId = OneWayChatRoomId;
                          donorId = ChatRoomId.toString().replaceAll(uid, "");
                          donorId = donorId.replaceAll("_", "").trim();
                          print("Chat Already Exists");
                        } else if (RevSnapShot.exists) {
                          ChatRoomId = ReverseChatRoomId;
                          donorId = ChatRoomId.toString().replaceAll(uid, "");
                          donorId = donorId.replaceAll("_", "").trim();
                        } else {
                          ChatRoomId = OneWayChatRoomId;
                          donorId = ChatRoomId.toString().replaceAll(uid, "");
                          donorId = donorId.replaceAll("_", "").trim();
                          FirebaseFirestore.instance
                              .collection("ChatRooms")
                              .doc(ChatRoomId)
                              .set(chatRoomInfo);
                        }
                        print("ChatRoomId Passing: $ChatRoomId");
                        Get.back();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      donorName:
                                          profileList[index].data()["name"],
                                      donorProfilePic: profileList[index]
                                          .data()["profilePic"],
                                      donorUid:
                                          profileList[index].data()["uid"],
                                      chatRoomId: ChatRoomId,
                                      phone: profileList[index].data()["phone"],
                                    )));
                        print(":::::::::::::::::::::::::::::::::::::::::::");
                        print(chatRoomInfo);
                      }
                    },
                  );
                }),
          );
  }

  int a = 0;

  @override
  Widget build(BuildContext context) {
    time = Provider.of(context);

    print("in build");
    double height = MediaQuery.of(context).size.height;
    AppBar appBar = AppBar(
      title: Text(
        "Search Donors",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: CustomColor.red),
      elevation: 0,
    );
    // if (a == 0) {
    //   a = 1;
    // _containerHeight -= appBar.preferredSize.height;
    // }
    return (_notify.dynamicValue == null || time.offset == null)
        ? Scaffold(
            body: Center(
              child: Text("Loading"),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar,
            body: Stack(
              children: [
                Container(
                    padding:
                        EdgeInsets.only(top: (_containerHeight + _fromTop)),
                    child: listViewProfiles()),
                Positioned(
                  top: _fromTop,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    height: _containerHeight,
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: CustomColor.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        selectRequiredType(),
                        SizedBox(
                          height: 3,
                        ),
                        Container(
                          height: 18,
                          child: FittedBox(
                            child: Text(
                              "Select the patient blood group below to find nearby donors",
                              style: TextStyle(
                                fontSize: 34.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        selectRequiredBloodGroup(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 18,
                          child: FittedBox(
                            child: Text(
                              "Filter based on last updated location",
                              style: TextStyle(
                                fontSize: 34.sp,
                                fontFamily: "OpenSans",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        selectRadiusWidget(),
                        // SizedBox(
                        //   height: 70.h,
                        // ),
                      ],
                    ),
                  ),
                )
              ],
            ));
  }
}

class DonorSearchListCard extends StatelessWidget {
  final String name;
  final String age;
  final String lastBloodDonated;
  final String lastPlasmaDonated;
  final String lastPlatletsDonated;
  final String imgUrl;
  final String lastLocation;
  final String bloodGrp;
  final String currentType;
  final String lastOpened;
  final VoidCallback onPressed;

  const DonorSearchListCard({
    this.currentType,
    this.name,
    this.imgUrl,
    this.age,
    this.lastBloodDonated,
    this.lastPlasmaDonated,
    this.lastPlatletsDonated,
    this.lastLocation,
    this.bloodGrp,
    this.onPressed,
    this.lastOpened,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            child: Container(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: imgUrl != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: "images/person.png",
                                  height: 130.h,
                                  width: 130.h,
                                  image: imgUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "images/person.png",
                                  height: 130.h,
                                )),
                      SizedBox(
                        width: 30.w,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Blood Group",
                            style: TextStyle(fontSize: 33.sp),
                          ),
                          Text(
                            "Name",
                            style: TextStyle(fontSize: 33.sp),
                          ),
                          Text(
                            "Age",
                            style: TextStyle(fontSize: 33.sp),
                          ),
                          Text(
                            "Last Updated Location",
                            style: TextStyle(fontSize: 33.sp),
                          ),
                          currentType != "Blood"
                              ? Container()
                              : Text(
                                  "Last Blood Donated",
                                  style: TextStyle(fontSize: 33.sp),
                                ),
                          currentType != "Platelets"
                              ? Container()
                              : Text(
                                  "Last Platelets Donated",
                                  style: TextStyle(fontSize: 33.sp),
                                ),
                          currentType != "Plasma"
                              ? Container()
                              : Text(
                                  "Last Plasma Donated",
                                  style: TextStyle(fontSize: 33.sp),
                                ),
                          Text(
                            "Last Opened",
                            style: TextStyle(fontSize: 33.sp),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ":",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            Text(
                              ":",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            Text(
                              ":",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            Text(
                              ":",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            currentType != "Blood"
                                ? Container()
                                : Text(
                                    ":",
                                    style: TextStyle(fontSize: 33.sp),
                                  ),

                            currentType != "Platelets"
                                ? Container()
                                : Text(
                                    ":",
                                    style: TextStyle(fontSize: 33.sp),
                                  ),
                            currentType != "Plasma"
                                ? Container()
                                : Text(
                                    ":",
                                    style: TextStyle(fontSize: 33.sp),
                                  ),
                            Text(
                              ":",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            // Text(":",style: TextStyle(fontSize: 33.sp),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 28.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bloodGrp,
                              style: TextStyle(
                                  fontSize: 37.sp,
                                  color: CustomColor.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              name,
                              style: TextStyle(fontSize: 33.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "$age Yrs",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            Text(
                              "$lastLocation Km away",
                              style: TextStyle(fontSize: 33.sp),
                            ),
                            currentType != "Blood"
                                ? Container()
                                : lastBloodDonated != null
                                    ? Text(
                                        lastBloodDonated,
                                        style: TextStyle(fontSize: 33.sp),
                                      )
                                    : Text(
                                        "Haven't donated yet",
                                        style: TextStyle(fontSize: 33.sp),
                                      ),
                            currentType != "Platelets"
                                ? Container()
                                : lastPlatletsDonated != null
                                    ? Text(
                                        lastPlatletsDonated,
                                        style: TextStyle(fontSize: 33.sp),
                                      )
                                    : Text(
                                        "Haven't donated yet",
                                        style: TextStyle(fontSize: 33.sp),
                                      ),
                            currentType != "Plasma"
                                ? Container()
                                : lastPlasmaDonated != null
                                    ? Text(
                                        lastPlasmaDonated,
                                        style: TextStyle(fontSize: 33.sp),
                                      )
                                    : Text(
                                        "Haven't donated yet",
                                        style: TextStyle(fontSize: 33.sp),
                                      ),
                            Text(
                              lastOpened.toString(),
                              style: TextStyle(fontSize: 33.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: onPressed,
                    child: Icon(
                      Icons.question_answer_outlined,
                      color: CustomColor.red,
                    ))
              ],
            )),
          ),
        ],
      ),
    );
  }
}
