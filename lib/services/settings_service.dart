import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class SettingsService {
  static const String baseUrl = AppConstants.baseUrl;

  /// جلب الإعدادات من API
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == true && responseData['settings'] != null) {
          return responseData['settings'];
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load settings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching settings: $e');
      }
      throw Exception('Error fetching settings: $e');
    }
  }

  /// جلب البانرات فقط
  Future<List<String>> getUserHomeBanners() async {
    try {
      final settings = await getSettings();
      
      if (settings['userHomeBanners'] != null) {
        final banners = settings['userHomeBanners'] as List;
        return banners.map((banner) => banner.toString().trim()).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching banners: $e');
      }
      return [];
    }
  }

  /// جلب معلومات "من نحن"
  Future<Map<String, String>> getAboutUs() async {
    try {
      final settings = await getSettings();
      
      if (settings['aboutUs'] != null) {
        final aboutUs = settings['aboutUs'] as Map<String, dynamic>;
        return aboutUs.map((key, value) => MapEntry(key, value.toString()));
      } else {
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching about us: $e');
      }
      return {};
    }
  }

  /// جلب الشروط والأحكام
  Future<Map<String, String>> getTermsAndConditions() async {
    try {
      final settings = await getSettings();
      
      if (settings['termsAndConditions'] != null) {
        final terms = settings['termsAndConditions'] as Map<String, dynamic>;
        return terms.map((key, value) => MapEntry(key, value.toString()));
      } else {
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching terms and conditions: $e');
      }
      return {};
    }
  }

  /// جلب الأسئلة الشائعة
  Future<Map<String, String>> getFAQs() async {
    try {
      final settings = await getSettings();
      
      if (settings['faqs'] != null) {
        final faqs = settings['faqs'] as Map<String, dynamic>;
        return faqs.map((key, value) => MapEntry(key, value.toString()));
      } else {
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching FAQs: $e');
      }
      return {};
    }
  }

  /// جلب روابط وسائل التواصل الاجتماعي
  Future<Map<String, String>> getSocialMedia() async {
    try {
      final settings = await getSettings();
      
      if (settings['socialMedia'] != null) {
        final socialMedia = settings['socialMedia'] as Map<String, dynamic>;
        return socialMedia.map((key, value) => MapEntry(key, value.toString()));
      } else {
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching social media: $e');
      }
      return {};
    }
  }
}