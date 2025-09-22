import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../services/laravel_service.dart';
import '../../services/google_maps_service.dart';
import '../../providers/auth_provider.dart';
import '../map_selection_screen.dart';
import 'offers_screen.dart';
import 'widgets/map_selection_dialog.dart';
import 'widgets/trip_type_button.dart';
import 'widgets/fare_section.dart';
import 'widgets/delivery_time_section.dart';
import 'widgets/car_category_section.dart';
import 'widgets/payment_method_section.dart';
import 'package:saba2v2/widgets/delivery_request/note_section.dart';
import 'package:saba2v2/widgets/delivery_request/trip_type_section.dart';
import 'package:saba2v2/widgets/delivery_request/route_details_section.dart';
import 'package:saba2v2/widgets/estimated_duration_section.dart';

class DeliveryRequestScreen extends StatefulWidget {
  const DeliveryRequestScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _startingPointController = TextEditingController(); // للوجهات المتعددة
  final _passengersController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedGovernorate;
  String? _fromLocationUrl;
  String? _toLocationUrl;
  String? _startingPointUrl; // رابط نقطة الانطلاق للوجهات المتعددة
  String? _detectedGovernorateFromLocation; // المحافظة المستخرجة من موقع الانطلاق
  String _selectedTripType = 'ذهاب فقط'; // نوع الرحلة المختار
  
  // متغيرات الوجهات المتعددة
  List<Map<String, dynamic>> _multipleDestinations = [];
  
  // متغيرات السيكشنات الجديدة
  final _fareController = TextEditingController();

  String _deliveryTime = 'توصيل الآن';
  String _carCategory = 'اقتصادية';
  String _paymentMethod = 'كاش';
  int _estimatedDuration = 0;
  
  // متغيرات النظام المحدث للمسافات والأسعار
  LatLng? _fromLocationCoords;
  LatLng? _toLocationCoords;
  List<LatLng> _multipleLocationCoords = [];
  double? _estimatedPrice;
  int? _estimatedDurationMinutes;
  double? _totalDistanceKm;
  bool _isCalculatingRoute = false;
  DateTime? _scheduledDateTime;
  
  // قائمة المحافظات المصرية
  final List<String> _egyptianGovernorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'البحر الأحمر',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'الشرقية',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'قنا',
    'شمال سيناء',
    'سوهاج'
  ];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _passengersController.dispose();
    _notesController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  // فتح خريطة Google Maps لاختيار الموقع
  Future<void> _selectLocationOnMap(bool isFromLocation) async {
    try {
      // الحصول على الموقع الحالي
      Position? currentPosition;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          currentPosition = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        print('خطأ في الحصول على الموقع: $e');
      }

      // إعداد الموقع الافتراضي (القاهرة)
      final LatLng initialPosition = currentPosition != null 
          ? LatLng(currentPosition.latitude, currentPosition.longitude)
          : const LatLng(30.0444, 31.2357); // القاهرة

      final result = await showDialog<LatLng>(
        context: context,
        builder: (context) => MapSelectionDialog(initialPosition: initialPosition),
      );

      if (result != null) {
        // تحويل الإحداثيات إلى عنوان
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            result.latitude, 
            result.longitude
          );
          
          String address = '';
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          } else {
            address = 'الموقع المحدد على الخريطة';
          }

          // إنشاء رابط Google Maps
          final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';

          if (isFromLocation) {
            _fromLocationController.text = address;
            _fromLocationUrl = googleMapsUrl;
            _fromLocationCoords = result; // حفظ الإحداثيات
            
            // استخراج المحافظة من موقع الانطلاق (بدون تحديث تلقائي)
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              String? detectedGovernorate = _extractGovernorateFromPlacemark(place);
              
              if (detectedGovernorate != null) {
                setState(() {
                  _detectedGovernorateFromLocation = detectedGovernorate;
                  // لا نحدث _selectedGovernorate تلقائياً، سيتم التحديث عند اختيار المستخدم
                });
              }
            }
          } else {
            _toLocationController.text = address;
            _toLocationUrl = googleMapsUrl;
            _toLocationCoords = result; // حفظ الإحداثيات
          }
          
          // حساب المسار والسعر تلقائياً إذا تم تحديد المواقع المطلوبة
          _calculateRouteAndPrice();
        } catch (e) {
          print('خطأ في تحويل الإحداثيات: $e');
          // في حالة فشل تحويل الإحداثيات، استخدم الإحداثيات مباشرة
          final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';
          final String address = 'الموقع المحدد: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
          
          if (isFromLocation) {
            _fromLocationController.text = address;
            _fromLocationUrl = googleMapsUrl;
          } else {
            _toLocationController.text = address;
            _toLocationUrl = googleMapsUrl;
          }
        }
      }
    } catch (e) {
      _showDialog('خطأ', 'حدث خطأ أثناء فتح الخريطة: $e');
    }
  }

  // حساب المسافة والسعر بناءً على نوع الرحلة
  Future<void> _calculateRouteAndPrice() async {
    if (_selectedTripType == null) return;
    
    setState(() {
      _isCalculatingRoute = true;
      _estimatedPrice = null;
      _estimatedDurationMinutes = null;
      _totalDistanceKm = null;
    });
    
    try {
      Map<String, dynamic> result;
      
      switch (_selectedTripType) {
        case 'ذهاب فقط':
          if (_fromLocationCoords != null && _toLocationCoords != null) {
            result = await GoogleMapsService.calculateDistanceAndTime(
              origin: _fromLocationCoords!,
              destination: _toLocationCoords!,
            );
          } else {
            return; // لا توجد مواقع كافية للحساب
          }
          break;
          
        case 'ذهاب وعودة':
          if (_fromLocationCoords != null && _toLocationCoords != null) {
            result = await GoogleMapsService.calculateRoundTripRoute(
              origin: _fromLocationCoords!,
              destination: _toLocationCoords!,
            );
          } else {
            return; // لا توجد مواقع كافية للحساب
          }
          break;
          
        case 'وجهات متعددة':
          if (_fromLocationCoords != null && _multipleLocationCoords.isNotEmpty) {
            result = await GoogleMapsService.calculateMultipleDestinationsRoute(
              startPoint: _fromLocationCoords!,
              destinations: _multipleLocationCoords,
            );
          } else {
            return; // لا توجد مواقع كافية للحساب
          }
          break;
          
        default:
          return;
      }
      
      if (result['success']) {
        setState(() {
          _estimatedPrice = result['estimated_price'].toDouble();
          _estimatedDurationMinutes = result['total_duration_minutes'] ?? result['duration_minutes'];
          _totalDistanceKm = result['total_distance_km'] ?? result['distance_km'];
          
          // تحديث حقل السعر المقترح
          _fareController.text = _estimatedPrice!.toStringAsFixed(0);
        });
      } else {
        print('خطأ في حساب المسار: ${result['error']}');
      }
    } catch (e) {
      print('خطأ في حساب المسار: $e');
    } finally {
      setState(() {
        _isCalculatingRoute = false;
      });
    }
  }

  Future<void> _submitDeliveryRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // التحقق من صحة الوجهات المتعددة إذا تم اختيارها
    if (_selectedTripType == 'وجهات متعددة') {
      if (_startingPointController.text.isEmpty) {
        _showDialog('خطأ', 'يرجى تحديد نقطة الانطلاق');
        return;
      }
      if (_multipleDestinations.isEmpty) {
        _showDialog('خطأ', 'يرجى إضافة محطة واحدة على الأقل');
        return;
      }
      for (int i = 0; i < _multipleDestinations.length; i++) {
        if (_multipleDestinations[i]['controller'].text.isEmpty) {
          _showDialog('خطأ', 'يرجى تحديد موقع ${_multipleDestinations[i]['name']}');
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // جلب التوكن باستخدام LaravelService
      final laravelService = LaravelService();
      final token = await laravelService.getToken();

      if (token == null) {
        _showDialog('خطأ', 'برجاء تسجيل الدخول أولاً');
        return;
      }

      // إعداد بيانات الطلب حسب نوع الرحلة
      Map<String, dynamic> requestData;
      
      // تحويل نوع الرحلة إلى القيم المتوقعة في الباك إند
      String backendTripType;
      switch (_selectedTripType) {
        case 'ذهاب فقط':
          backendTripType = 'one_way';
          break;
        case 'ذهاب وعودة':
          backendTripType = 'round_trip';
          break;
        case 'وجهات متعددة':
          backendTripType = 'multiple_destinations';
          break;
        default:
          backendTripType = 'one_way';
      }
      
      // تحويل فئة السيارة إلى القيم المتوقعة في الباك إند
      String backendCarCategory;
      switch (_carCategory) {
        case 'اقتصادية':
          backendCarCategory = 'economy';
          break;
        case 'مريحة':
          backendCarCategory = 'comfort';
          break;
        case 'فاخرة':
          backendCarCategory = 'premium';
          break;
        case 'فان':
          backendCarCategory = 'van';
          break;
        default:
          backendCarCategory = 'economy';
      }
      
      // تحويل طريقة الدفع إلى القيم المتوقعة في الباك إند
      String backendPaymentMethod;
      switch (_paymentMethod) {
        case 'كاش':
          backendPaymentMethod = 'cash';
          break;
        case 'تحويل بنكي':
          backendPaymentMethod = 'bank_transfer';
          break;
        case 'كارت':
          backendPaymentMethod = 'card';
          break;
        default:
          backendPaymentMethod = 'cash';
      }
      
      // تحديد وقت التوصيل
      DateTime deliveryDateTime;
      if (_deliveryTime == 'توصيل الآن') {
        deliveryDateTime = DateTime.now().add(Duration(minutes: 15)); // إضافة 15 دقيقة للوقت الحالي
      } else if (_scheduledDateTime != null) {
        deliveryDateTime = _scheduledDateTime!;
      } else {
        deliveryDateTime = DateTime.now().add(Duration(minutes: 15));
      }
      
      if (_selectedTripType == 'وجهات متعددة') {
        // إعداد بيانات الوجهات المتعددة
        List<Map<String, dynamic>> destinations = [];
        
        // إضافة نقطة الانطلاق كأول وجهة (pickup point)
        if (_startingPointController.text.isNotEmpty) {
          destinations.add({
            'location_name': _startingPointController.text,
            'latitude': _fromLocationCoords?.latitude,
            'longitude': _fromLocationCoords?.longitude,
            'address': _startingPointController.text,
            'is_pickup_point': true,
            'is_dropoff_point': false,
          });
        }
        
        // إضافة باقي الوجهات
        for (int i = 0; i < _multipleDestinations.length; i++) {
          var destination = _multipleDestinations[i];
          LatLng? coords = i < _multipleLocationCoords.length ? _multipleLocationCoords[i] : null;
          
          destinations.add({
            'location_name': destination['controller'].text,
            'latitude': coords?.latitude,
            'longitude': coords?.longitude,
            'address': destination['controller'].text,
            'is_pickup_point': false,
            'is_dropoff_point': true,
          });
        }
        
        requestData = {
          'trip_type': backendTripType,
          'delivery_time': deliveryDateTime.toIso8601String(),
          'car_category': backendCarCategory,
          'payment_method': backendPaymentMethod,
          'price': _fareController.text.isNotEmpty ? double.tryParse(_fareController.text) : _estimatedPrice,
          'client_notes': _notesController.text,
          'phone': Provider.of<AuthProvider>(context, listen: false).userPhone ?? '',
          'destinations': destinations,
        };
      } else {
        // إعداد بيانات الرحلة التقليدية (ذهاب فقط أو ذهاب وعودة)
        List<Map<String, dynamic>> destinations = [];
        
        // إضافة نقطة الانطلاق
        if (_fromLocationController.text.isNotEmpty) {
          destinations.add({
            'location_name': _fromLocationController.text,
            'latitude': _fromLocationCoords?.latitude,
            'longitude': _fromLocationCoords?.longitude,
            'address': _fromLocationController.text,
            'is_pickup_point': true,
            'is_dropoff_point': false,
          });
        }
        
        // إضافة نقطة الوصول
        if (_toLocationController.text.isNotEmpty) {
          destinations.add({
            'location_name': _toLocationController.text,
            'latitude': _toLocationCoords?.latitude,
            'longitude': _toLocationCoords?.longitude,
            'address': _toLocationController.text,
            'is_pickup_point': false,
            'is_dropoff_point': true,
          });
        }
        
        requestData = {
          'trip_type': backendTripType,
          'delivery_time': deliveryDateTime.toIso8601String(),
          'car_category': backendCarCategory,
          'payment_method': backendPaymentMethod,
          'price': _fareController.text.isNotEmpty ? double.tryParse(_fareController.text) : _estimatedPrice,
          'client_notes': _notesController.text,
          'phone': Provider.of<AuthProvider>(context, listen: false).userPhone ?? '',
          'destinations': destinations,
        };
      }

      // إرسال الطلب باستخدام LaravelService
      final result = await LaravelService.post(
        '/delivery/requests',
        data: requestData,
        token: token,
      );

      if (result['status'] == true) {
        // طباعة الاستجابة للتحقق من هيكل البيانات
        print('Response result: $result');
        
        // التنقل إلى صفحة العروض مع تمرير معرف الطلب
        // استخراج معرف الطلب من الاستجابة - الخادم يرجع البيانات في data.delivery_request
        dynamic requestId;
        if (result['data'] != null && result['data']['delivery_request'] != null && result['data']['delivery_request']['id'] != null) {
          requestId = result['data']['delivery_request']['id'];
        } else if (result['delivery_request'] != null && result['delivery_request']['id'] != null) {
          requestId = result['delivery_request']['id'];
        } else if (result['data'] != null && result['data']['id'] != null) {
          requestId = result['data']['id'];
        } else if (result['id'] != null) {
          requestId = result['id'];
        }
        
        // طباعة تفاصيل إضافية للتشخيص
        print('Full response structure: ${result.keys}');
        if (result['data'] != null && result['data']['delivery_request'] != null) {
          print('data.delivery_request keys: ${result['data']['delivery_request'].keys}');
          print('data.delivery_request id: ${result['data']['delivery_request']['id']}');
        }
        
        print('Extracted requestId: $requestId');
        
        _clearForm();
        
        // إظهار رسالة النجاح ثم التنقل
        if (requestId != null) {
          _showSuccessDialogAndNavigate('تم إرسال طلب التوصيل بنجاح', requestId);
        } else {
          _showDialog('تحذير', 'تم إرسال الطلب بنجاح ولكن لم يتم العثور على معرف الطلب');
        }
      } else {
        _showDialog('خطأ', result['message'] ?? 'فشل في إرسال الطلب');
      }
    } catch (e) {
      _showDialog('خطأ', 'حدث خطأ أثناء إرسال الطلب: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _fromLocationController.clear();
    _toLocationController.clear();
    _startingPointController.clear();
    _passengersController.clear();
    _notesController.clear();
    _fareController.clear();
    
    // مسح قائمة الوجهات المتعددة
    for (var destination in _multipleDestinations) {
      destination['controller'].dispose();
    }
    
    setState(() {
      _selectedGovernorate = null;
      _fromLocationUrl = null;
      _toLocationUrl = null;
      _startingPointUrl = null;
      _detectedGovernorateFromLocation = null;
      _selectedTripType = 'ذهاب فقط';
      _multipleDestinations.clear();
  
      _deliveryTime = 'توصيل الآن';
      _carCategory = 'اقتصادية';
      _paymentMethod = 'كاش';
      _estimatedDuration = 0;
    });
  }

  void _onTripTypeSelected(String title) {
    setState(() {
      _selectedTripType = title;
    });
    // إعادة حساب المسار عند تغيير نوع الرحلة
    _calculateRouteAndPrice();
  }

  // إضافة محطة جديدة للوجهات المتعددة
  void _addDestination() {
    setState(() {
      _multipleDestinations.add({
        'controller': TextEditingController(),
        'locationUrl': null,
        'name': 'المحطة ${_multipleDestinations.length + 1}',
      });
    });
  }

  // حذف محطة من الوجهات المتعددة
  void _removeDestination(int index) {
    setState(() {
      _multipleDestinations[index]['controller'].dispose();
      _multipleDestinations.removeAt(index);
      
      // حذف الإحداثيات المقابلة إذا كانت موجودة
      if (index < _multipleLocationCoords.length) {
        _multipleLocationCoords.removeAt(index);
      }
      
      // إعادة ترقيم المحطات
      for (int i = 0; i < _multipleDestinations.length; i++) {
        _multipleDestinations[i]['name'] = 'المحطة ${i + 1}';
      }
    });
    
    // إعادة حساب المسار والسعر بعد حذف المحطة
    _calculateRouteAndPrice();
  }

  // اختيار نقطة الانطلاق من الخريطة
  void _selectStartingPointOnMap() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapSelectionScreen(
            title: 'اختيار نقطة الانطلاق',
          ),
        ),
      );

      if (result != null) {
        final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';
        final String address = 'الموقع المحدد: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
        
        setState(() {
          _startingPointController.text = address;
          _startingPointUrl = googleMapsUrl;
          
          // تحديث إحداثيات نقطة الانطلاق
          _fromLocationCoords = LatLng(result.latitude, result.longitude);
        });
        
        // إعادة حساب المسار والسعر تلقائياً عند تحديد نقطة الانطلاق
        _calculateRouteAndPrice();
      }
    } catch (e) {
      _showDialog('خطأ', 'حدث خطأ أثناء فتح الخريطة: $e');
    }
  }

  // اختيار موقع للوجهات المتعددة
  void _selectMultipleDestinationOnMap(int index) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapSelectionScreen(
            title: 'اختيار الوجهة',
          ),
        ),
      );

      if (result != null) {
        final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';
        final String address = 'الموقع المحدد: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
        
        setState(() {
          _multipleDestinations[index]['controller'].text = address;
          _multipleDestinations[index]['locationUrl'] = googleMapsUrl;
          
          // تحديث إحداثيات الوجهة
          if (index < _multipleLocationCoords.length) {
            _multipleLocationCoords[index] = LatLng(result.latitude, result.longitude);
          } else {
            _multipleLocationCoords.add(LatLng(result.latitude, result.longitude));
          }
        });
        
        // إعادة حساب المسار والسعر تلقائياً عند تحديد موقع جديد
        _calculateRouteAndPrice();
      }
    } catch (e) {
      _showDialog('خطأ', 'حدث خطأ أثناء فتح الخريطة: $e');
    }
  }

  // استخراج المحافظة من بيانات الموقع بطريقة محسنة
  String? _extractGovernorateFromPlacemark(Placemark place) {
    // تجميع النص الكامل للعنوان
    String fullAddress = [
      place.name ?? '',
      place.street ?? '',
      place.locality ?? '',
      place.subLocality ?? '',
      place.subAdministrativeArea ?? '',
      place.administrativeArea ?? '',
      place.country ?? '',
    ].where((text) => text.isNotEmpty).join(' ').toLowerCase();

    // قائمة المحافظات مرتبة حسب الأولوية (الأكثر تحديداً أولاً)
    final Map<String, List<String>> governorateKeywords = {
      'الإسماعيلية': ['ismailia', 'الإسماعيلية', 'اسماعيلية', 'ismailiya'],
      'بورسعيد': ['port said', 'بورسعيد', 'بور سعيد', 'portsaid'],
      'جنوب سيناء': ['south sinai', 'جنوب سيناء', 'شرم الشيخ', 'dahab', 'دهب'],
      'شمال سيناء': ['north sinai', 'شمال سيناء', 'العريش', 'el arish'],
      'البحر الأحمر': ['red sea', 'البحر الأحمر', 'hurghada', 'الغردقة', 'marsa alam'],
      'الوادي الجديد': ['new valley', 'الوادي الجديد', 'kharga', 'الخارجة'],
      'مطروح': ['matrouh', 'مطروح', 'marsa matrouh', 'مرسى مطروح'],
      'أسوان': ['aswan', 'أسوان', 'اسوان'],
      'الأقصر': ['luxor', 'الأقصر', 'اقصر'],
      'قنا': ['qena', 'قنا'],
      'سوهاج': ['sohag', 'سوهاج'],
      'أسيوط': ['asyut', 'أسيوط', 'اسيوط'],
      'المنيا': ['minya', 'المنيا', 'منيا'],
      'بني سويف': ['beni suef', 'بني سويف'],
      'الفيوم': ['faiyum', 'الفيوم', 'فيوم'],
      'الجيزة': ['giza', 'الجيزة', 'جيزة', '6th october', 'اكتوبر'],
      'القاهرة': ['cairo', 'القاهرة', 'قاهرة', 'new cairo', 'القاهرة الجديدة'],
      'القليوبية': ['qalyubia', 'القليوبية', 'قليوبية', 'shubra', 'شبرا'],
      'الشرقية': ['sharqia', 'الشرقية', 'شرقية', 'zagazig', 'الزقازيق'],
      'الدقهلية': ['dakahlia', 'الدقهلية', 'دقهلية', 'mansoura', 'المنصورة'],
      'دمياط': ['damietta', 'دمياط'],
      'كفر الشيخ': ['kafr el-sheikh', 'كفر الشيخ'],
      'الغربية': ['gharbia', 'الغربية', 'غربية', 'tanta', 'طنطا'],
      'المنوفية': ['monufia', 'المنوفية', 'منوفية', 'shebin el kom'],
      'البحيرة': ['beheira', 'البحيرة', 'بحيرة', 'damanhour', 'دمنهور'],
      'الإسكندرية': ['alexandria', 'الإسكندرية', 'اسكندرية', 'alex'],
      'السويس': ['suez', 'السويس'],
    };

    // البحث المباشر في النص الكامل
    for (String governorate in governorateKeywords.keys) {
      List<String> keywords = governorateKeywords[governorate]!;
      
      for (String keyword in keywords) {
        if (fullAddress.contains(keyword.toLowerCase())) {
          return governorate;
        }
      }
    }

    // البحث الاحتياطي في الحقول المنفصلة
    String adminArea = (place.administrativeArea ?? '').toLowerCase();
    if (adminArea.isNotEmpty) {
      for (String governorate in governorateKeywords.keys) {
        List<String> keywords = governorateKeywords[governorate]!;
        for (String keyword in keywords) {
          if (adminArea.contains(keyword.toLowerCase()) || 
              keyword.toLowerCase().contains(adminArea)) {
            return governorate;
          }
        }
      }
    }

    return null;
  }

  // التحقق من تطابق المحافظة المختارة مع موقع الانطلاق
  void _checkGovernorateMatch(String? selectedGovernorate) {
    if (_detectedGovernorateFromLocation != null && 
        selectedGovernorate != null && 
        selectedGovernorate != _detectedGovernorateFromLocation) {
      _showWarningDialog(
        'تنبيه',
        'المحافظة المختارة ($selectedGovernorate) مختلفة عن المحافظة المستخرجة من موقع الانطلاق ($_detectedGovernorateFromLocation). هل تريد المتابعة؟',
        selectedGovernorate,
      );
    }
  }

  void _showWarningDialog(String title, String message, String selectedGovernorate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFFC8700)),
            ),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // العودة للمحافظة المستخرجة من الموقع
                  setState(() {
                    _selectedGovernorate = _detectedGovernorateFromLocation;
                  });
                },
                child: const Text(
                  'تراجع',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // الاحتفاظ بالمحافظة المختارة
                  setState(() {
                    _selectedGovernorate = selectedGovernorate;
                  });
                },
                child: const Text(
                  'متابعة',
                  style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFFC8700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (title == 'نجح') {
                    context.pop(); // العودة للصفحة السابقة
                  }
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialogAndNavigate(String message, dynamic requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'نجح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // أغلق الحوار أولاً
                  Navigator.of(context).pop();
                  
                  // التنقل باستخدام GoRouter
                   if (requestId != null && requestId.toString().isNotEmpty) {
                     GoRouter.of(this.context).go('/offers/${requestId.toString()}', extra: {
                       'fromLocation': _fromLocationController.text,
                       'toLocation': _toLocationController.text,
                       'requestedPrice': _estimatedPrice ?? 0.0,
                       'estimatedDurationMinutes': _estimatedDurationMinutes ?? 0,
                     });
                   } else {
                     GoRouter.of(this.context).go('/UserHomeScreen');
                   }
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // بناء واجهة الوجهات المتعددة
  Widget _buildMultipleDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // نقطة الانطلاق
        const Text(
          'نقطة الانطلاق',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectStartingPointOnMap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _startingPointController,
              decoration: InputDecoration(
                hintText: 'اضغط لاختيار نقطة الانطلاق من الخريطة',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.my_location, color: Color(0xFFFC8700)),
                suffixIcon: const Icon(Icons.map, color: Color(0xFFFC8700)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFC8700)),
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نقطة الانطلاق من الخريطة';
                }
                return null;
              },
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // المحطات
        if (_multipleDestinations.isNotEmpty) ...[
          for (int i = 0; i < _multipleDestinations.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _multipleDestinations[i]['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectMultipleDestinationOnMap(i),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _multipleDestinations[i]['controller'],
                            decoration: InputDecoration(
                              hintText: 'اضغط لاختيار ${_multipleDestinations[i]['name']} من الخريطة',
                              hintStyle: const TextStyle(fontFamily: 'Cairo'),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Color(0xFFFC8700),
                              ),
                              suffixIcon: const Icon(Icons.map, color: Color(0xFFFC8700)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFC8700)),
                              ),
                            ),
                            style: const TextStyle(fontFamily: 'Cairo'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى اختيار ${_multipleDestinations[i]['name']} من الخريطة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_multipleDestinations.length > 1)
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 25),
                    child: IconButton(
                      onPressed: () => _removeDestination(i),
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 28,
                      ),
                      tooltip: 'حذف المحطة',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
        
        // زر إضافة محطة جديدة
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addDestination,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFFC8700),
            ),
            label: const Text(
              'إضافة محطة جديدة',
              style: TextStyle(
                color: Color(0xFFFC8700),
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFC8700)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }















  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'طلب توصيلة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          backgroundColor: const Color(0xFFFC8700),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // سيكشن اختيار نوع الرحلة
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع الرحلة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TripTypeButton(
                            tripType: 'ذهاب فقط',
                            isSelected: _selectedTripType == 'ذهاب فقط',
                            onTap: () => _onTripTypeSelected('ذهاب فقط'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TripTypeButton(
                            tripType: 'ذهاب وعودة',
                            isSelected: _selectedTripType == 'ذهاب وعودة',
                            onTap: () => _onTripTypeSelected('ذهاب وعودة'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TripTypeButton(
                            tripType: 'وجهات متعددة',
                            isSelected: _selectedTripType == 'وجهات متعددة',
                            onTap: () => _onTripTypeSelected('وجهات متعددة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // رأس الصفحة

              // نموذج البيانات - يتغير حسب نوع الرحلة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _selectedTripType == 'وجهات متعددة'
                    ? _buildMultipleDestinationsSection()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // من
                          const Text(
                            'من',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectLocationOnMap(true),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _fromLocationController,
                                decoration: InputDecoration(
                                  hintText: 'اضغط لاختيار موقع الانطلاق من الخريطة',
                                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFC8700)),
                                  suffixIcon: const Icon(Icons.map, color: Color(0xFFFC8700)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFFC8700)),
                                  ),
                                ),
                                style: const TextStyle(fontFamily: 'Cairo'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى اختيار موقع الانطلاق من الخريطة';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // إلى
                          const Text(
                            'إلى',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectLocationOnMap(false),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _toLocationController,
                                decoration: InputDecoration(
                                  hintText: 'اضغط لاختيار موقع الوصول من الخريطة',
                                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                                  prefixIcon: const Icon(Icons.flag, color: Color(0xFFFC8700)),
                                  suffixIcon: const Icon(Icons.map, color: Color(0xFFFC8700)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFFC8700)),
                                  ),
                                ),
                                style: const TextStyle(fontFamily: 'Cairo'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى اختيار موقع الوصول من الخريطة';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // قسم عرض تفاصيل المسار والسعر المحسوب
              if (_isCalculatingRoute || _estimatedPrice != null)
                RouteDetailsSection(
                  isCalculatingRoute: _isCalculatingRoute,
                  totalDistanceKm: _totalDistanceKm,
                  estimatedDurationMinutes: _estimatedDurationMinutes,
                  estimatedPrice: _estimatedPrice,
                ),

              if (_isCalculatingRoute || _estimatedPrice != null) const SizedBox(height: 24),

              // سيكشن أجرة التوصيلة
              FareSection(fareController: _fareController, estimatedPrice: _estimatedPrice),

              const SizedBox(height: 24),

              // سيكشن وقت التوصيل
              DeliveryTimeSection(
                deliveryTime: _deliveryTime,
                onDeliveryTimeChanged: (newTime) {
                  setState(() {
                    _deliveryTime = newTime;
                  });
                },
              ),

              const SizedBox(height: 24),

              // سيكشن فئة السيارة
              CarCategorySection(
                carCategory: _carCategory,
                onCarCategoryChanged: (newCategory) {
                  setState(() {
                    _carCategory = newCategory;
                  });
                },
              ),

              const SizedBox(height: 24),

              // سيكشن طريقة الدفع
              PaymentMethodSection(
                paymentMethod: _paymentMethod,
                onPaymentMethodChanged: (newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // سيكشن مدة الرحلة المتوقعة
              EstimatedDurationSection(estimatedDurationMinutes: _estimatedDurationMinutes),

              const SizedBox(height: 24),

              // عرض رقم الهاتف من البروفايل
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final userPhone = authProvider.userPhone;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFC8700), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Color(0xFFFC8700)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'رقم الهاتف',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              userPhone ?? 'غير محدد',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // حقل الملاحظات
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFC8700), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملاحظات إضافية (اختياري)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أدخل أي ملاحظات إضافية (اختياري)',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(Icons.note, color: Color(0xFFFC8700)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // زر الإرسال
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDeliveryRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC8700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                            'إرسال طلب التوصيلة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                ),
              ),
          ],
        ),
      ),
    )));
  }


}