import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/laravel_service.dart';

class CarRentalRequestScreen extends StatefulWidget {
  const CarRentalRequestScreen({Key? key}) : super(key: key);

  @override
  State<CarRentalRequestScreen> createState() => _CarRentalRequestScreenState();
}

class _CarRentalRequestScreenState extends State<CarRentalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _carModelController = TextEditingController();
  final _clientNotesController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedSource = 'مكتب';
  String _selectedRentalType = 'شهري';
  String _selectedDriver = 'بدون سائق';
  String _selectedCarCategory = 'مميزة';
  String? _selectedGovernorate;
  
  bool _isLoading = false;

  final List<String> _sources = ['مكتب', 'منزل', 'مطار', 'فندق'];
  final List<String> _rentalTypes = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];
  final List<String> _driverOptions = ['بدون سائق', 'مع سائق'];
  final List<String> _carCategories = ['اقتصادية', 'متوسطة', 'مميزة', 'فاخرة'];
  final List<String> _governorates = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر',
    'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا',
    'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف',
    'بورسعيد', 'دمياط', 'الشرقية', 'جنوب سيناء', 'كفر الشيخ', 'مطروح',
    'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج'
  ];

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _carModelController.dispose();
    _clientNotesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFC8700),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submitCarRentalRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // جلب التوكن باستخدام LaravelService
      final laravelService = LaravelService();
      final token = await laravelService.getToken();

      if (token == null) {
        _showDialog('خطأ', 'برجاء تسجيل الدخول أولاً', onConfirm: () {
          context.go('/login');
        });
        return;
      }

      // إعداد بيانات الطلب
      final requestData = {
        'type': 'rent',
        'request_data': {
          'source': _selectedSource,
          'governorate': _selectedGovernorate ?? '',
          'rental_type': _selectedRentalType,
          'from_date': _fromDateController.text,
          'to_date': _toDateController.text,
          'driver': _selectedDriver,
          'car_category': _selectedCarCategory,
          'car_model': _carModelController.text,
          'client_notes': _clientNotesController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
        },
      };

      // إرسال الطلب باستخدام LaravelService
      final result = await LaravelService.post(
        '/service-requests',
        data: requestData,
        token: token,
      );

      if (result['status'] == true) {
        _showDialog('نجح', 'تم إرسال طلب تأجير السيارة بنجاح');
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
    _fromDateController.clear();
    _toDateController.clear();
    _carModelController.clear();
    _clientNotesController.clear();
    _priceController.clear();
    setState(() {
      _selectedGovernorate = null;
      _selectedSource = 'مكتب';
      _selectedRentalType = 'شهري';
      _selectedDriver = 'بدون سائق';
      _selectedCarCategory = 'مميزة';
    });
  }

  void _showDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
            content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onConfirm != null) {
                    onConfirm();
                  } else if (title == 'نجح') {
                    context.pop(); // العودة للصفحة السابقة
                  }
                },
                child: const Text('موافق', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        );
      },
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
            'تأجير سيارة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          backgroundColor: const Color(0xFFFC8700),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
              // رأس الصفحة
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
                child: Column(
                  children: [
                    Icon(
                      Icons.car_rental,
                      size: 60,
                      color: const Color(0xFFFC8700),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تأجير سيارة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'املأ البيانات التالية لطلب خدمة تأجير السيارة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // نموذج البيانات
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // مصدر الاستلام
                    const Text(
                      'مصدر الاستلام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSource,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      items: _sources.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSource = newValue!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // المحافظة
                    const Text(
                      'المحافظة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: DropdownButtonFormField<String>(
                        value: _selectedGovernorate,
                        alignment: AlignmentDirectional.centerEnd,
                        decoration: InputDecoration(
                          labelText: 'المحافظة',
                          hintText: 'اختر المحافظة',
                          hintStyle: const TextStyle(fontFamily: 'Cairo'),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.location_city, color: Color(0xFFFC8700)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Color(0xFFFC8700), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                        iconSize: 28,
                        iconEnabledColor: Colors.grey[600],
                        items: _governorates.map((String governorate) {
                          return DropdownMenuItem<String>(
                            value: governorate,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              governorate,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGovernorate = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى اختيار المحافظة';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // نوع التأجير
                    const Text(
                      'نوع التأجير',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRentalType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      items: _rentalTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRentalType = newValue!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // تاريخ البداية
                    const Text(
                      'تاريخ البداية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fromDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_fromDateController),
                      decoration: InputDecoration(
                        hintText: 'اختر تاريخ البداية',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFFC8700)),
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
                          return 'يرجى اختيار تاريخ البداية';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // تاريخ النهاية
                    const Text(
                      'تاريخ النهاية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _toDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_toDateController),
                      decoration: InputDecoration(
                        hintText: 'اختر تاريخ النهاية',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFFC8700)),
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
                          return 'يرجى اختيار تاريخ النهاية';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // السائق
                    const Text(
                      'السائق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDriver,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      items: _driverOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDriver = newValue!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // فئة السيارة
                    const Text(
                      'فئة السيارة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCarCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      items: _carCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCarCategory = newValue!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // موديل السيارة
                    const Text(
                      'موديل السيارة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _carModelController,
                      decoration: InputDecoration(
                        hintText: 'أدخل موديل السيارة',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(Icons.directions_car, color: Color(0xFFFC8700)),
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
                          return 'يرجى إدخال موديل السيارة';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // السعر
                    const Text(
                      'السعر المتوقع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'أدخل السعر المتوقع',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال السعر المتوقع';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'يرجى إدخال سعر صحيح';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ملاحظات العميل
                    const Text(
                      'ملاحظات إضافية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _clientNotesController,
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
                  onPressed: _isLoading ? null : _submitCarRentalRequest,
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
                          'إرسال طلب تأجير السيارة',
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
      ),
      ),
    );
  }
}