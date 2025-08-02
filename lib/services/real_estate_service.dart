import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RealEstateService {
  static const String baseUrl = 'http://192.168.1.7:8000';

  /// جلب بيانات المستخدم الحالية من الـ API
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('RealEstateService: User data fetched successfully');
        return data;
      } else {
        debugPrint('RealEstateService: Failed to fetch user data. Status: ${response.statusCode}');
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      debugPrint('RealEstateService: Error fetching user data: $e');
      throw Exception('Error fetching user data: $e');
    }
  }

  /// تحديث بيانات المكتب العقاري
  Future<bool> updateOfficeData({
    required String officeName,
    required String officeAddress,
    required String officePhone,
    required String governorate,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // جلب البيانات الحالية أولاً لمعرفة الـ ID
      final currentData = await getCurrentUserData();
      if (currentData == null) {
        throw Exception('Failed to get current user data');
      }

      final Map<String, dynamic> updateData = {
        'name': officeName,
        'email': email,
        'phone': officePhone,
        'governorate': governorate,
      };

      // تحديث البيانات الأساسية للمستخدم
      final userResponse = await http.put(
        Uri.parse('$baseUrl/api/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (userResponse.statusCode != 200) {
        debugPrint('RealEstateService: Failed to update user data. Status: ${userResponse.statusCode}');
        debugPrint('Response: ${userResponse.body}');
      }

      // تحديث بيانات المكتب العقاري
      final realEstateId = currentData['real_estate']?['id'];
      if (realEstateId != null && currentData['real_estate']?['office_detail'] != null) {
        final officeDetailId = currentData['real_estate']['office_detail']['id'];
        
        final officeUpdateData = {
          'office_name': officeName,
          'office_address': officeAddress,
          'office_phone': officePhone,
        };

        final officeResponse = await http.put(
          Uri.parse('$baseUrl/api/real-estate-office-details/$officeDetailId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(officeUpdateData),
        );

        if (officeResponse.statusCode == 200) {
          debugPrint('RealEstateService: Office data updated successfully');
          return true;
        } else {
          debugPrint('RealEstateService: Failed to update office data. Status: ${officeResponse.statusCode}');
          debugPrint('Response: ${officeResponse.body}');
        }
      }

      // إذا وصلنا هنا، فقد تم تحديث البيانات الأساسية على الأقل
      return userResponse.statusCode == 200;

    } catch (e) {
      debugPrint('RealEstateService: Error updating office data: $e');
      throw Exception('Error updating office data: $e');
    }
  }

  /// تحديث بيانات السمسار الفردي
  Future<bool> updateIndividualData({
    required String agentName,
    required String phone,
    required String governorate,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // جلب البيانات الحالية أولاً
      final currentData = await getCurrentUserData();
      if (currentData == null) {
        throw Exception('Failed to get current user data');
      }

      final Map<String, dynamic> updateData = {
        'name': agentName,
        'email': email,
        'phone': phone,
        'governorate': governorate,
      };

      // تحديث البيانات الأساسية للمستخدم
      final userResponse = await http.put(
        Uri.parse('$baseUrl/api/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (userResponse.statusCode != 200) {
        debugPrint('RealEstateService: Failed to update user data. Status: ${userResponse.statusCode}');
        debugPrint('Response: ${userResponse.body}');
      }

      // تحديث بيانات السمسار الفردي
      final realEstateId = currentData['real_estate']?['id'];
      if (realEstateId != null && currentData['real_estate']?['individual_detail'] != null) {
        final individualDetailId = currentData['real_estate']['individual_detail']['id'];
        
        final individualUpdateData = {
          'agent_name': agentName,
        };

        final individualResponse = await http.put(
          Uri.parse('$baseUrl/api/real-estate-individual-details/$individualDetailId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(individualUpdateData),
        );

        if (individualResponse.statusCode == 200) {
          debugPrint('RealEstateService: Individual data updated successfully');
          return true;
        } else {
          debugPrint('RealEstateService: Failed to update individual data. Status: ${individualResponse.statusCode}');
          debugPrint('Response: ${individualResponse.body}');
        }
      }

      // إذا وصلنا هنا، فقد تم تحديث البيانات الأساسية على الأقل
      return userResponse.statusCode == 200;

    } catch (e) {
      debugPrint('RealEstateService: Error updating individual data: $e');
      throw Exception('Error updating individual data: $e');
    }
  }

  /// رفع صورة جديدة
  Future<String?> uploadImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['status'] == true && data['files'] != null && data['files'].isNotEmpty) {
          return data['files'][0]['url'];
        }
      }
      
      debugPrint('RealEstateService: Failed to upload image. Status: ${response.statusCode}');
      debugPrint('Response: $responseBody');
      return null;
    } catch (e) {
      debugPrint('RealEstateService: Error uploading image: $e');
      return null;
    }
  }

  /// تحديث المستندات للمكتب العقاري
  Future<bool> updateOfficeDocuments({
    String? ownerIdFrontImage,
    String? ownerIdBackImage,
    String? commercialRegisterFrontImage,
    String? commercialRegisterBackImage,
    String? logoImage,
    String? officeImage,
    bool? taxEnabled,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final currentData = await getCurrentUserData();
      if (currentData == null || currentData['real_estate']?['office_detail'] == null) {
        throw Exception('Office data not found');
      }

      final officeDetailId = currentData['real_estate']['office_detail']['id'];
      
      final Map<String, dynamic> updateData = {};
      
      if (ownerIdFrontImage != null) updateData['owner_id_front_image'] = ownerIdFrontImage;
      if (ownerIdBackImage != null) updateData['owner_id_back_image'] = ownerIdBackImage;
      if (commercialRegisterFrontImage != null) updateData['commercial_register_front_image'] = commercialRegisterFrontImage;
      if (commercialRegisterBackImage != null) updateData['commercial_register_back_image'] = commercialRegisterBackImage;
      if (logoImage != null) updateData['logo_image'] = logoImage;
      if (officeImage != null) updateData['office_image'] = officeImage;
      if (taxEnabled != null) updateData['tax_enabled'] = taxEnabled ? 1 : 0;

      if (updateData.isEmpty) {
        return true; // لا توجد تحديثات
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/real-estate-office-details/$officeDetailId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        debugPrint('RealEstateService: Office documents updated successfully');
        return true;
      } else {
        debugPrint('RealEstateService: Failed to update office documents. Status: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('RealEstateService: Error updating office documents: $e');
      throw Exception('Error updating office documents: $e');
    }
  }

  /// تحديث المستندات للسمسار الفردي
  Future<bool> updateIndividualDocuments({
    String? profileImage,
    String? agentIdFrontImage,
    String? agentIdBackImage,
    String? taxCardFrontImage,
    String? taxCardBackImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final currentData = await getCurrentUserData();
      if (currentData == null || currentData['real_estate']?['individual_detail'] == null) {
        throw Exception('Individual data not found');
      }

      final individualDetailId = currentData['real_estate']['individual_detail']['id'];
      
      final Map<String, dynamic> updateData = {};
      
      if (profileImage != null) updateData['profile_image'] = profileImage;
      if (agentIdFrontImage != null) updateData['agent_id_front_image'] = agentIdFrontImage;
      if (agentIdBackImage != null) updateData['agent_id_back_image'] = agentIdBackImage;
      if (taxCardFrontImage != null) updateData['tax_card_front_image'] = taxCardFrontImage;
      if (taxCardBackImage != null) updateData['tax_card_back_image'] = taxCardBackImage;

      if (updateData.isEmpty) {
        return true; // لا توجد تحديثات
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/real-estate-individual-details/$individualDetailId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        debugPrint('RealEstateService: Individual documents updated successfully');
        return true;
      } else {
        debugPrint('RealEstateService: Failed to update individual documents. Status: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('RealEstateService: Error updating individual documents: $e');
      throw Exception('Error updating individual documents: $e');
    }
  }
}