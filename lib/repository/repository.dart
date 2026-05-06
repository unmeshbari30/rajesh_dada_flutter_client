import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:rajesh_dada_padvi/models/emergency_contact_model.dart';
import 'package:rajesh_dada_padvi/models/Files/files_response_model.dart';
import 'package:rajesh_dada_padvi/models/Files/mla_info_model.dart';
import 'package:rajesh_dada_padvi/models/complaint_payload_model.dart';
import 'package:rajesh_dada_padvi/models/complaint_response_model.dart';
import 'package:rajesh_dada_padvi/models/login_payload_model.dart';
import 'package:rajesh_dada_padvi/models/registration_payload_model.dart';
import 'package:rajesh_dada_padvi/models/registration_response_model.dart';
import 'package:rajesh_dada_padvi/providers/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository.g.dart';

class Repository {
  final Dio dio;

  Repository({required this.dio});

  Future<LoginPayloadModel?> loginUser({
    required LoginPayloadModel loginPayload,
  }) async {
    try {
      var details = jsonEncode(loginPayload.toJson());
      final response = await dio.post("/api/v1/signin", data: details);

      if (response.statusCode == 200) {
        final data = response.data;

        final res = LoginPayloadModel.fromJson(data);
        return res;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    return null;
  }

  Future<LoginPayloadModel?> adminSignIn({
    required LoginPayloadModel loginPayload,
  }) async {
    try {
      var details = jsonEncode(loginPayload.toJson());
      final response = await dio.post("/api/admin/signin", data: details);

      if (response.statusCode == 200) {
        final data = response.data;

        final res = LoginPayloadModel.fromJson(data);
        return res;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    return null;
  }

  Future<RegistrationResponseModel> registerUser(
    RegistrationPayloadModel registrationPaylaod,
  ) async {
    try {
      var details = jsonEncode(registrationPaylaod.toJson());
      final response = await dio.post("/api/v1/Register", data: details);

      if (response.statusCode == 200) {
        final data = response.data;

        final res = RegistrationResponseModel.fromJson(data);
        return res;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }
      if (response.statusCode == 400) {
        final data = response.data;
        final res = RegistrationResponseModel.fromJson(data);
        return res;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    return RegistrationResponseModel(
      firstName: null,
      lastName: null,
      message: null,
      username: null,
    );
  }

  Future<ComplaintPayloadModel?>? saveComplaint({
    required ComplaintPayloadModel payload,
    required List<File>? attachments,
  }) async {
    try {
      // // Prepare file attachments
      if (attachments != null && attachments.isNotEmpty) {
        List<FileElement> uploadAttachments = [];
        for (var file in attachments) {
          final bytes = await file.readAsBytes();
          final mimeType = lookupMimeType(file.path) ?? "";
          final lastModified = await file.lastModified();
          uploadAttachments.add(
            FileElement(
              base64Data: base64Encode(bytes),
              mimetype: mimeType,
              name:
                  "Attachment_${DateFormat('yyyyMMdd_HHmmss').format(lastModified)}.${mimeType.split("/").last}",
            ),
          );
        }
        // Update payload with attachments
        payload.files = uploadAttachments;
        var test = jsonEncode(payload.toJson());
        print("hey");
      }
      // Send request
      final response = await dio.post(
        "/api/v1/Complaints",
        data: jsonEncode(payload.toJson()),
      );
      // Handle response
      if (response.statusCode == 200 || response.statusCode == 400) {
        return ComplaintPayloadModel.fromJson(response.data);
      } else {
        print("Unexpected status code: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
        return null;
      }
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
    // Return an empty model in case of error
    return null;
  }

  Future<ComplaintResponseModel> getComplaints() async {
    try {
      final response = await dio.get("/api/v1/GetComplaints");

      if (response.statusCode == 200) {
        final data = response.data;

        final res = ComplaintResponseModel.fromJson(data);
        return res;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }
      if (response.statusCode == 400) {
        final data = response.data;
        final res = ComplaintResponseModel.fromJson(data);
        return res;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
    throw Exception("Failed to fetch complaints");
  }

  Future<FileResponseModel?> getAchievements() async {
    try {
      final response = await dio.get("/api/v1/achievements");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    // If everything fails, return null instead of throwing exception
    return null;
  }

  Future<FileResponseModel?> getGalleryData() async {
    try {
      final response = await dio.get("/api/v1/gallery");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    // If everything fails, return null instead of throwing exception
    return null;
  }

  Future<FileResponseModel?> getWomenEmpowermentData() async {
    try {
      final response = await dio.get("/api/v1/womens");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    // If everything fails, return null instead of throwing exception
    return null;
  }

  Future<FileResponseModel?> getHomePageData() async {
    try {
      final response = await dio.get("/api/v1/home");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    // If everything fails, return null instead of throwing exception
    return null;
  }

  Future<MlaInfoModel?> getMlaInfo() async {
    try {
      final response = await dio.get("/api/v1/mla-info");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = MlaInfoModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = MlaInfoModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    // If everything fails, return null instead of throwing exception
    return null;
  }

  Future<bool> deleteComplaintById(String id) async {
    try {
      final response = await dio.delete("/api/v1/Complaints/$id");
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<FileResponseModel?> getCertificateData() async {
    try {
      final response = await dio.get("/api/v1/certificate");

      if (response.statusCode == 200) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      } else {
        print("Server responded with status: ${response.statusCode}");
      }

      if (response.statusCode == 400) {
        final data = response.data;
        final result = FileResponseModel.fromJson(data);
        return result;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }

    return null;
  }

  Future<List<EmergencyContactModel>?> getEmergencyContacts() async {
    try {
      final response = await dio.get("/api/v1/emergency-contacts");
      if (response.statusCode == 200) {
        final result = EmergencyContactsResponse.fromJson(response.data);
        return result.contacts;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
    return null;
  }

  Future<EmergencyContactModel?> createEmergencyContact(
    EmergencyContactModel contact,
  ) async {
    try {
      final response = await dio.post(
        "/api/v1/emergency-contacts",
        data: jsonEncode(contact.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return EmergencyContactModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
    return null;
  }

  Future<EmergencyContactModel?> updateEmergencyContact(
    String id,
    EmergencyContactModel contact,
  ) async {
    try {
      final response = await dio.patch(
        "/api/v1/emergency-contacts/$id",
        data: jsonEncode(contact.toJson()),
      );
      if (response.statusCode == 200) {
        return EmergencyContactModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
    return null;
  }

  Future<bool> deleteEmergencyContact(String id) async {
    try {
      final response = await dio.delete("/api/v1/emergency-contacts/$id");
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
    } catch (e) {
      print("Unexpected error: $e");
    }
    return false;
  }
}

@riverpod
Future<Repository> repository(Ref ref) async {
  return Repository(dio: await ref.watch(dioProvider.future));
}
