import 'package:firebase_database/firebase_database.dart';

class ConstantVariables{

  int pageSize;


  ConstantVariables({this.pageSize});

  Future<ConstantVariables> getConstantsFromFirebase () async{
     DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child("AppConstants").once();
      return ConstantVariables(pageSize: snapshot.value["firstsLoad"] );
  }


  void setConstantsToFirebase() async{
    FirebaseDatabase.instance.reference().child("AppConstants").set({
      "firstsLoad": 4,
    });
  }


}