import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'emergency_contact_model.g.dart';

EmergencyContactsResponse emergencyContactsResponseFromJson(String str) =>
    EmergencyContactsResponse.fromJson(json.decode(str));

String emergencyContactsResponseToJson(EmergencyContactsResponse data) =>
    json.encode(data.toJson());

@JsonSerializable()
class EmergencyContactsResponse {
  @JsonKey(name: "contacts")
  List<EmergencyContactModel>? contacts;

  EmergencyContactsResponse({this.contacts});

  factory EmergencyContactsResponse.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactsResponseToJson(this);
}

@JsonSerializable()
class EmergencyContactModel {
  @JsonKey(name: "_id")
  String? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "number")
  String? number;
  @JsonKey(name: "icon")
  String? icon;

  EmergencyContactModel({this.id, this.name, this.number, this.icon});

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactModelToJson(this);
}
