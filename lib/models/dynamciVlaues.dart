import 'package:json_annotation/json_annotation.dart';

part 'dynamciVlaues.g.dart';

@JsonSerializable()
class DynamciVlaues {
    DynamciVlaues();

    num plasmaToPlatelets;
    num bloodToPlatelets;
    num bloodToPlasma;
    num referralPoints;
    num bloodToBlood;
    num plasmaToPlasma;
    num plasmaToBlood;
    num plateletsToPlasma;
    num plateletsToPlatelets;
    num plateletsToBlood;
    
    factory DynamciVlaues.fromJson(Map<String,dynamic> json) => _$DynamciVlauesFromJson(json);
    Map<String, dynamic> toJson() => _$DynamciVlauesToJson(this);
}
