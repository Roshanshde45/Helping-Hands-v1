import 'package:google_maps_flutter/google_maps_flutter.dart';

class PatientDetails {
  String requirementType;
  String patientName;
  int reqDate;
  String reqTime;
  int age;
  String reqBloodGroup;
  String reqUnits;
  String hospitalName;
  String hospitalCityName;
  String areaName;
  String purpose;
  String contact1;
  String contact2;
  String contact3;
  String otherDetails;
  String cityName;
  String imgUrl;
  String hospitalRoomNumber;
  String postedUserName;
  String postId;
  String posterPhone;
  String uid;
  String hospitalAddress;
  String userPostedUid;
  LatLng hospitalCoordinates;

  PatientDetails(
      {this.requirementType,
      this.reqDate,
      this.reqTime,
      this.age,
      this.patientName,
      this.postId,
      this.reqBloodGroup,
      this.uid,
      this.cityName,
      this.hospitalRoomNumber,
      this.imgUrl,
      this.reqUnits,
      this.hospitalName,
      this.hospitalCityName,
      this.areaName,
      this.postedUserName,
      this.purpose,
      this.contact1,
      this.contact2,
      this.posterPhone,
      this.hospitalAddress,
      this.contact3,
      this.otherDetails,
      this.userPostedUid,
      this.hospitalCoordinates});
}
