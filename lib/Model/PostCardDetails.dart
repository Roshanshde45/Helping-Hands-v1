import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCardDetails {
  String userCreatedUid;
  String postId;
  String patientName;
  String patientAge;
  String requirement;
  String requirementDate;
  String requirementTime;
  String requiredBloodGrp;
  String requiredUnits;
  String purpose;
  String patientAttender1;
  String patientAttender2;
  String patientAttender3;
  String patientAttenderName1;
  String patientAttenderName2;
  String patientAttenderName3;
  String hospitalName;
  String hospitalCityName;
  String hospitalAreaName;
  LatLng hospitalLatLng;
  String otherDetails;
  String roomNumber;

  PostCardDetails ({
      this.userCreatedUid,
      this.postId,
      this.patientName,
      this.patientAge,
      this.requirement,
      this.requirementDate,
      this.requirementTime,
      this.requiredBloodGrp,
      this.requiredUnits,
      this.purpose,
      this.patientAttender1,
      this.patientAttender2,
      this.patientAttender3,
      this.patientAttenderName1,
      this.patientAttenderName2,
      this.patientAttenderName3,
      this.hospitalName,
      this.hospitalCityName,
      this.hospitalAreaName,
      this.hospitalLatLng,
      this.otherDetails,
      this.roomNumber,
  });
}