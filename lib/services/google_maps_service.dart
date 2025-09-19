import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyBqBMvoAdJKoG_rPBhO8Da75gtw0Gc13Vc';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  
  // سعر الكيلومتر الثابت (يمكن تغييره لاحقاً)
  static const double _pricePerKm = 20.0;

  /// حساب المسافة والوقت بين نقطتين
  static Future<Map<String, dynamic>> calculateDistanceAndTime({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      final String url = '$_baseUrl/distancematrix/json'
          '?origins=${origin.latitude},${origin.longitude}'
          '&destinations=${destination.latitude},${destination.longitude}'
          '&mode=$travelMode'
          '&units=metric'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && 
            data['rows'].isNotEmpty && 
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK') {
            final distanceText = element['distance']['text'];
            final distanceValue = element['distance']['value']; // بالمتر
            final durationText = element['duration']['text'];
            final durationValue = element['duration']['value']; // بالثواني
            
            final distanceKm = distanceValue / 1000.0;
            final durationMinutes = (durationValue / 60.0).round();
            final estimatedPrice = (distanceKm * _pricePerKm).round();
            
            return {
              'success': true,
              'distance_text': distanceText,
              'distance_km': distanceKm,
              'duration_text': durationText,
              'duration_minutes': durationMinutes,
              'estimated_price': estimatedPrice,
            };
          }
        }
      }
      
      return {
        'success': false,
        'error': 'فشل في حساب المسافة والوقت',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// حساب المسافة والوقت للوجهات المتعددة
  static Future<Map<String, dynamic>> calculateMultipleDestinationsRoute({
    required LatLng startPoint,
    required List<LatLng> destinations,
    String travelMode = 'driving',
  }) async {
    try {
      double totalDistance = 0.0;
      int totalDuration = 0;
      List<Map<String, dynamic>> routeSegments = [];
      
      LatLng currentPoint = startPoint;
      
      // حساب المسافة من نقطة البداية إلى كل وجهة
      for (int i = 0; i < destinations.length; i++) {
        final result = await calculateDistanceAndTime(
          origin: currentPoint,
          destination: destinations[i],
          travelMode: travelMode,
        );
        
        if (result['success']) {
          totalDistance += result['distance_km'];
          totalDuration += (result['duration_minutes'] as num).toInt();
          
          routeSegments.add({
            'from': currentPoint,
            'to': destinations[i],
            'distance_km': result['distance_km'],
            'duration_minutes': result['duration_minutes'],
            'segment_index': i + 1,
          });
          
          currentPoint = destinations[i];
        } else {
          return {
            'success': false,
            'error': 'فشل في حساب المسافة للوجهة ${i + 1}',
          };
        }
      }
      
      final estimatedPrice = (totalDistance * _pricePerKm).round();
      
      return {
        'success': true,
        'total_distance_km': totalDistance,
        'total_duration_minutes': totalDuration,
        'estimated_price': estimatedPrice,
        'route_segments': routeSegments,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حساب الطريق: $e',
      };
    }
  }

  /// حساب المسافة والوقت لرحلة ذهاب وعودة
  static Future<Map<String, dynamic>> calculateRoundTripRoute({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      // حساب الذهاب
      final goingResult = await calculateDistanceAndTime(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
      );
      
      if (!goingResult['success']) {
        return goingResult;
      }
      
      // حساب العودة
      final returnResult = await calculateDistanceAndTime(
        origin: destination,
        destination: origin,
        travelMode: travelMode,
      );
      
      if (!returnResult['success']) {
        return returnResult;
      }
      
      final totalDistance = goingResult['distance_km'] + returnResult['distance_km'];
      final totalDuration = goingResult['duration_minutes'] + returnResult['duration_minutes'];
      final estimatedPrice = (totalDistance * _pricePerKm).round();
      
      return {
        'success': true,
        'total_distance_km': totalDistance,
        'total_duration_minutes': totalDuration,
        'estimated_price': estimatedPrice,
        'going_trip': {
          'distance_km': goingResult['distance_km'],
          'duration_minutes': goingResult['duration_minutes'],
        },
        'return_trip': {
          'distance_km': returnResult['distance_km'],
          'duration_minutes': returnResult['duration_minutes'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حساب رحلة الذهاب والعودة: $e',
      };
    }
  }

  /// الحصول على الاتجاهات المفصلة بين نقطتين
  static Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      final String url = '$_baseUrl/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&mode=$travelMode'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return {
            'success': true,
            'polyline': route['overview_polyline']['points'],
            'distance_text': leg['distance']['text'],
            'duration_text': leg['duration']['text'],
            'start_address': leg['start_address'],
            'end_address': leg['end_address'],
            'steps': leg['steps'],
          };
        }
      }
      
      return {
        'success': false,
        'error': 'فشل في الحصول على الاتجاهات',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الحصول على الاتجاهات: $e',
      };
    }
  }

  /// تحويل الإحداثيات إلى عنوان
  static Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final String url = '$_baseUrl/geocode/json'
          '?latlng=${coordinates.latitude},${coordinates.longitude}'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      
      return 'الموقع المحدد: ${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'الموقع المحدد: ${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
    }
  }

  /// البحث عن الأماكن
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final String url = '$_baseUrl/place/textsearch/json'
          '?query=${Uri.encodeComponent(query)}'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((place) => {
            'name': place['name'],
            'address': place['formatted_address'],
            'location': LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            'place_id': place['place_id'],
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}