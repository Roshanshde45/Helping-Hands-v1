import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bd_app/Model/directionDetails.dart';
import 'package:bd_app/services/requestAssistant.dart';

class AssistantMethods {

  static Future<DirectionDetails> obtainDirectionsDetails(LatLng initialPosition, LatLng finalPosition) async {
    print("orign: ${double.parse((initialPosition.latitude).toStringAsFixed(7))} , ${double.parse((initialPosition.longitude).toStringAsFixed(7))}");
    print("orign: ${double.parse((finalPosition.latitude).toStringAsFixed(7))} , ${double.parse((finalPosition.longitude).toStringAsFixed(7))}");

    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${double.parse((initialPosition.latitude).toStringAsFixed(7))},${double.parse((initialPosition.longitude).toStringAsFixed(7))}&destination=${double.parse((finalPosition.latitude).toStringAsFixed(7))},${double.parse((finalPosition.latitude).toStringAsFixed(7))}&key=AIzaSyB6otpUQEuN_O-itOO-7VYH-e0kYL5vXPA";
    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == 'failed'){
      return null;
    }
    print("PRINT RES: ");
    print(res);
    DirectionDetails directionDetails = DirectionDetails();
    // directionDetails.encodedPoints = res['routes'][0]['overview_polyline']['points'];

    // directionDetails.distanceText = res['routes'][0]['legs'][0]['distance']['text'];
    // directionDetails.distanceValue = res['routes'][0]['legs'][0]['distance']['value'];
    //
    // directionDetails.durationText = res['routes'][0]['legs'][0]['duration']['text'];
    // directionDetails.durationValue = res['routes'][0]['legs'][0]['duration']['value'];

    return directionDetails;
  }
}