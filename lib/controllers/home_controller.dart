// import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rajesh_dada_padvi/controllers/authentication_controller.dart';
import 'package:rajesh_dada_padvi/models/Files/files_response_model.dart';
import 'package:rajesh_dada_padvi/models/complaint_payload_model.dart';
import 'package:rajesh_dada_padvi/models/emergency_contact_model.dart';
import 'package:rajesh_dada_padvi/models/login_payload_model.dart';
import 'package:rajesh_dada_padvi/repository/repository.dart';
import 'package:rajesh_dada_padvi/widgets/dropdown_value_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "home_controller.g.dart";

@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<HomeState> build() async {
    ref.keepAlive();
    HomeState newState = HomeState();
    var data = await ref.read(authenticationControllerProvider.future);

    var repository = await ref.read(repositoryProvider.future);
    newState.homeDataResponse = repository.getHomePageData();
    newState.certificateDataResponse = repository.getCertificateData();
    newState.emergencyContactsResponse = repository.getEmergencyContacts();
    newState.userName = data.userName.text;
    newState.loginResult = data.loginResult;
    return newState;
  }

  void updateSelectedFile(List<File>? selectedFiles) {
    update((p0) {
      p0.selectedFiles = selectedFiles;
      return p0;
    });
  }

  Future<ComplaintPayloadModel?> saveComplaint() async {
    try {
      var currentState = state.value;
      var repository = await ref.read(repositoryProvider.future);

      ComplaintPayloadModel payloadModel = ComplaintPayloadModel(
        fullName: currentState?.fullNameController.text,
        address: currentState?.addressController.text,
        mobileNumber: currentState?.mobileNumberController.text,
        tehsil: currentState?.talukaController.selectedItem,
        gender: currentState?.gendersController.selectedItem,
        yourMessage: currentState?.yourMessageController.text,
        // files can be handled here if needed
      );

      // final result = await repository.saveComplaint(payload: payloadModel);
      final result = await repository.saveComplaint(
        payload: payloadModel,
        attachments: currentState?.selectedFiles,
      );
      return result;
    } catch (e) {
      print("Error while saving complaint: $e");
      return null;
    }
  }

  Future<LoginPayloadModel?> adminSignIn() async {
    try {
      var currentState = state.value;
      var repository = await ref.read(repositoryProvider.future);

      LoginPayloadModel payloadModel = LoginPayloadModel(
        userName: currentState?.adminUsernameController.text,
        password: currentState?.adminPasswordController.text,
        // files can be handled here if needed
      );

      // final result = await repository.saveComplaint(payload: payloadModel);
      final result = await repository.adminSignIn(loginPayload: payloadModel);
      return result;
    } catch (e) {
      print("Error while saving complaint: $e");
      return null;
    }
  }
}

class HomeState {
  Future<FileResponseModel?>? homeDataResponse;
  Future<FileResponseModel?>? certificateDataResponse;
  Future<List<EmergencyContactModel>?>? emergencyContactsResponse;

  TextEditingController adminUsernameController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();

  String? userName;
  List<File>? selectedFiles;
  LoginPayloadModel? loginResult;

  //TextFields Controller
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController complaintMessageController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController yourMessageController = TextEditingController();

  //Dropdown Controllers
  DropdownValueController<String?> gendersController =
      DropdownValueController<String?>();
  DropdownValueController<String?> talukaController =
      DropdownValueController<String?>();

  //List
  Future<List<String>> gendersList = Future.value([
    "पुरुष / Male",
    "स्त्री / Female",
    "इतर / Unknown",
  ]);
  Future<List<String>> talukaList = Future.value([
    "तळोदा / Taloda",
    "शहादा / Shahada",
  ]); //"Akkalkuva", "Dhagaon", "Navapur", "Nandurbar",
}
