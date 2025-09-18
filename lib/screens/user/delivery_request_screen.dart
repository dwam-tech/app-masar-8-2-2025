import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/laravel_service.dart';
import '../map_selection_screen.dart';

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
  String? _customFare;
  String _deliveryTime = 'توصيل الآن';
  String _carCategory = 'اقتصادية';
  String _paymentMethod = 'كاش';
  int _estimatedDuration = 0;
  
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
        builder: (context) => _MapSelectionDialog(initialPosition: initialPosition),
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
          }
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
      
      if (_selectedTripType == 'وجهات متعددة') {
        // إعداد بيانات الوجهات المتعددة
        List<Map<String, String>> destinations = [];
        for (var destination in _multipleDestinations) {
          destinations.add({
            'location': destination['controller'].text,
            'location_url': destination['locationUrl'] ?? '',
            'name': destination['name'],
          });
        }
        
        requestData = {
          'type': 'delivery',
          'governorate': _selectedGovernorate,
          'request_data': {
            'trip_type': _selectedTripType,
            'starting_point': _startingPointController.text,
            'starting_point_url': _startingPointUrl,
            'destinations': destinations,
            'passengers': int.parse(_passengersController.text),
            'client_notes': _notesController.text,
            'governorate': _selectedGovernorate,
            'custom_fare': _customFare,
            'delivery_time': _deliveryTime,
            'car_category': _carCategory,
            'payment_method': _paymentMethod,
            'estimated_duration': _estimatedDuration,
          },
        };
      } else {
        // إعداد بيانات الرحلة التقليدية (ذهاب فقط أو ذهاب وعودة)
        requestData = {
          'type': 'delivery',
          'governorate': _selectedGovernorate,
          'request_data': {
            'trip_type': _selectedTripType,
            'from_location': _fromLocationController.text,
            'from_location_url': _fromLocationUrl,
            'to_location': _toLocationController.text,
            'to_location_url': _toLocationUrl,
            'passengers': int.parse(_passengersController.text),
            'client_notes': _notesController.text,
            'governorate': _selectedGovernorate,
            'custom_fare': _customFare,
            'delivery_time': _deliveryTime,
            'car_category': _carCategory,
            'payment_method': _paymentMethod,
            'estimated_duration': _estimatedDuration,
          },
        };
      }

      // إرسال الطلب باستخدام LaravelService
      final result = await LaravelService.post(
        '/service-requests',
        data: requestData,
        token: token,
      );

      if (result['status'] == true) {
        _showDialog('نجح', 'تم إرسال طلب التوصيل بنجاح');
        _clearForm();
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
      _customFare = null;
      _deliveryTime = 'توصيل الآن';
      _carCategory = 'اقتصادية';
      _paymentMethod = 'كاش';
      _estimatedDuration = 0;
    });
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
      // إعادة ترقيم المحطات
      for (int i = 0; i < _multipleDestinations.length; i++) {
        _multipleDestinations[i]['name'] = 'المحطة ${i + 1}';
      }
    });
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
        });
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
        });
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

  // بناء زر اختيار نوع الرحلة
  Widget _buildTripTypeButton(String tripType) {
    bool isSelected = _selectedTripType == tripType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTripType = tripType;
          // تنظيف الوجهات المتعددة عند تغيير نوع الرحلة
          if (tripType != 'وجهات متعددة') {
            for (var destination in _multipleDestinations) {
              destination['controller'].dispose();
            }
            _multipleDestinations.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFC8700) : Colors.grey[100],
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFFFC8700) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            Text(
              tripType,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  // بناء سيكشن أجرة التوصيلة
  Widget _buildFareSection() {
    return Container(
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
            'أجرة التوصيلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _customFare != null ? '$_customFare جنيه' : 'الأجرة الموصى بها',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (_customFare == null)
                  const Text(
                    '100 جنيه',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontFamily: 'Cairo',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showCustomFareDialog,
            child: const Text(
              'يمكنك اقتراح أجرة أخرى',
              style: TextStyle(
                color: Color(0xFFFC8700),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة إظهار حوار اقتراح أجرة مخصصة
  void _showCustomFareDialog() {
    final TextEditingController customFareController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'اقتراح أجرة مخصصة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'يمكنك اقتراح أجرة مختلفة للرحلة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: customFareController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'أدخل الأجرة المقترحة',
                    hintStyle: const TextStyle(fontFamily: 'Cairo'),
                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFFC8700)),
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
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (customFareController.text.isNotEmpty) {
                    setState(() {
                      _customFare = customFareController.text;
                      _fareController.text = '${customFareController.text} جنيه (مقترح)';
                    });
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8700),
                ),
                child: const Text(
                  'تأكيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // بناء سيكشن وقت التوصيل
  Widget _buildDeliveryTimeSection() {
    return Container(
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
            'وقت التوصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          // خيار توصيل الآن
          GestureDetector(
            onTap: () {
              setState(() {
                _deliveryTime = 'توصيل الآن';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: _deliveryTime == 'توصيل الآن' ? BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFC8700),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'توصيل الآن',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _deliveryTime == 'توصيل الآن' ? const Color(0xFFFC8700) : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: _deliveryTime == 'توصيل الآن'
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFC8700),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          // خيار تحديد الوقت
          GestureDetector(
            onTap: () {
              setState(() {
                _deliveryTime = 'تحديد الوقت';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: _deliveryTime == 'تحديد الوقت' ? BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFC8700),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تحديد الوقت',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _deliveryTime == 'تحديد الوقت' ? const Color(0xFFFC8700) : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: _deliveryTime == 'تحديد الوقت'
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFC8700),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // بناء سيكشن فئة السيارة
  Widget _buildCarCategorySection() {
    return Container(
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
            'فئة السيارة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          // خيار اقتصادية
          _buildCarCategoryRadioOption('اقتصادية'),
          // خيار مميزة
          _buildCarCategoryRadioOption('مميزة'),

        ],
      ),
    );
  }

  Widget _buildCarCategoryRadioOption(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _carCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: _carCategory == category ? BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFC8700),
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Color(0xFF333333),
              ),
            ),
            const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _carCategory == category ? const Color(0xFFFC8700) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: _carCategory == category
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFC8700),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }



  // بناء سيكشن طريقة الدفع
  Widget _buildPaymentMethodSection() {
    return Container(
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
            'طريقة الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _paymentMethod,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFFC8700),
                    size: 24,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: Color(0xFF333333),
                  ),
                  dropdownColor: Colors.white,
                  items: ['كاش', 'فيزا'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Cairo',
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _paymentMethod = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء سيكشن مدة الرحلة المتوقعة
  Widget _buildEstimatedDurationSection() {
    return Container(
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
            'مدة الرحلة المتوقعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFC8700),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _estimatedDuration > 0 
                        ? 'الرحلة تستغرق حوالي $_estimatedDuration دقيقة'
                        : 'الرحلة تستغرق حوالي 20 دقيقة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                          child: _buildTripTypeButton('ذهاب فقط'),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildTripTypeButton('ذهاب وعودة'),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildTripTypeButton('وجهات متعددة'),
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

              // سيكشن أجرة التوصيلة
              _buildFareSection(),

              const SizedBox(height: 24),

              // سيكشن وقت التوصيل
              _buildDeliveryTimeSection(),

              const SizedBox(height: 24),

              // سيكشن فئة السيارة
              _buildCarCategorySection(),

              const SizedBox(height: 24),

              // سيكشن طريقة الدفع
              _buildPaymentMethodSection(),

              const SizedBox(height: 24),

              // سيكشن مدة الرحلة المتوقعة
              _buildEstimatedDurationSection(),

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

// Dialog لاختيار الموقع من الخريطة
class _MapSelectionDialog extends StatefulWidget {
  final LatLng initialPosition;

  const _MapSelectionDialog({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<_MapSelectionDialog> createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<_MapSelectionDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Location> _searchResults = [];
  String? _selectedLocationName;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _markers.add(
      Marker(
        markerId: const MarkerId('selected'),
        position: widget.initialPosition,
        draggable: true,
        onDragEnd: (LatLng position) {
          setState(() {
            _selectedPosition = position;
            _selectedLocationName = null;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // البحث عن الموقع باستخدام الاسم
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations.take(5).toList(); // أخذ أول 5 نتائج فقط
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لم يتم العثور على نتائج للبحث: $query',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // اختيار موقع من نتائج البحث
  void _selectSearchResult(Location location, String query) {
    final LatLng position = LatLng(location.latitude, location.longitude);
    
    setState(() {
      _selectedPosition = position;
      _selectedLocationName = query;
      _searchResults.clear();
      _searchController.clear();
      
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _selectedPosition = newPosition;
              _selectedLocationName = null;
            });
          },
        ),
      );
    });

    // تحريك الكاميرا للموقع الجديد
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              // الطبقة الخلفية - Column الأصلي بدون نتائج البحث
              Column(
                children: [
                  // رأس الحوار
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFC8700),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: Colors.white),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'اختر الموقع من الخريطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  
                  // شريط البحث
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن عنوان أو منطقة...',
                              hintStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.grey,
                              ),
                              prefixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8700)),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.search, color: Color(0xFFFC8700)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults.clear();
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFFC8700), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            style: const TextStyle(fontFamily: 'Cairo'),
                            onChanged: (value) {
                              setState(() {});
                              if (value.isEmpty) {
                                setState(() {
                                  _searchResults.clear();
                                });
                              }
                            },
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _searchLocation(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_searchController.text.trim().isNotEmpty) {
                              _searchLocation(_searchController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFC8700),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'بحث',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // الخريطة
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.initialPosition,
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onTap: (LatLng position) {
                        setState(() {
                            _selectedPosition = position;
                            _selectedLocationName = null; // مسح اسم الموقع عند النقر على الخريطة
                            _markers.clear();
                            _markers.add(
                              Marker(
                                markerId: const MarkerId('selected'),
                                position: position,
                                draggable: true,
                                onDragEnd: (LatLng newPosition) {
                                  setState(() {
                                    _selectedPosition = newPosition;
                                    _selectedLocationName = null;
                                  });
                                },
                              ),
                            );
                          });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                  ),
                  
                  // معلومات الموقع المحدد
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFFC8700),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'الموقع المحدد:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // إظهار اسم الموقع إذا تم اختياره من البحث
                        if (_selectedLocationName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC8700).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFC8700).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFFFC8700),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedLocationName!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFC8700),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // الإحداثيات
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'خط العرض: ${_selectedPosition?.latitude.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'خط الطول: ${_selectedPosition?.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // أزرار التحكم
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Color(0xFFFC8700)),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                color: Color(0xFFFC8700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(_selectedPosition);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFC8700),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'تأكيد الاختيار',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // الطبقة العائمة - نتائج البحث
              if (_searchResults.isNotEmpty)
                Positioned(
                  top: 140.0, // المسافة من الحافة العلوية للـ Stack
                  right: 16.0, // الهامش الأيمن
                  left: 16.0, // الهامش الأيسر
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200, // حد أقصى لارتفاع قائمة النتائج
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFFFC8700),
                            size: 20,
                          ),
                          title: Text(
                            _searchController.text,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            _selectSearchResult(location, _searchController.text);
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}