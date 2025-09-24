import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/security_permit_service.dart';

class SecurityPermitScreen extends StatefulWidget {
  const SecurityPermitScreen({super.key});

  @override
  State<SecurityPermitScreen> createState() => _SecurityPermitScreenState();
}

class _SecurityPermitScreenState extends State<SecurityPermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _travelDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Form data
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _nationalities = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  double _individualFee = 0.0;
  
  // Selected values
  int? _selectedNationalityId;
  int? _selectedCountryId;
  int _peopleCount = 1;
  String? _selectedPaymentMethod;
  
  // Images
  File? _passportImage;
  List<File> _residenceImages = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingFormData = true;
  
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _travelDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final data = await SecurityPermitService.getFormData();
      setState(() {
        _countries = List<Map<String, dynamic>>.from(data['countries'] ?? []);
        _nationalities = List<Map<String, dynamic>>.from(data['nationalities'] ?? []);
        _paymentMethods = List<Map<String, dynamic>>.from(data['payment_methods'] ?? []);
        _individualFee = (data['individual_fee'] ?? 0.0).toDouble();
        _isLoadingFormData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFormData = false;
      });
      _showErrorSnackBar('خطأ في تحميل بيانات النموذج: ${e.toString()}');
    }
  }

  Future<void> _selectDate() async {
    // حساب أقل تاريخ مسموح (3 أيام عمل من اليوم)
    DateTime minDate = DateTime.now();
    int workDaysAdded = 0;
    
    while (workDaysAdded < 3) {
      minDate = minDate.add(const Duration(days: 1));
      // تجاهل الجمعة (6) والسبت (7)
      if (minDate.weekday != DateTime.friday && minDate.weekday != DateTime.saturday) {
        workDaysAdded++;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'اختر تاريخ السفر',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _travelDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickPassportImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        setState(() {
          _passportImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('خطأ في اختيار صورة الجواز: ${e.toString()}');
    }
  }

  Future<void> _pickResidenceImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _residenceImages.addAll(images.map((image) => File(image.path)));
          // الحد الأقصى 5 صور
          if (_residenceImages.length > 5) {
            _residenceImages = _residenceImages.take(5).toList();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('خطأ في اختيار صور الإقامة: ${e.toString()}');
    }
  }

  void _removeResidenceImage(int index) {
    setState(() {
      _residenceImages.removeAt(index);
    });
  }

  double get _totalAmount => _individualFee * _peopleCount;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passportImage == null) {
      _showErrorSnackBar('يرجى اختيار صورة الجواز');
      return;
    }
    if (_selectedNationalityId == null) {
      _showErrorSnackBar('يرجى اختيار الجنسية');
      return;
    }
    if (_selectedCountryId == null) {
      _showErrorSnackBar('يرجى اختيار الدولة القادم منها');
      return;
    }
    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar('يرجى اختيار طريقة الدفع');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SecurityPermitService.submitPermit(
        travelDate: _travelDateController.text,
        nationalityId: _selectedNationalityId!,
        peopleCount: _peopleCount,
        countryId: _selectedCountryId!,
        passportImage: _passportImage!,
        residenceImages: _residenceImages.isNotEmpty ? _residenceImages : null,
        paymentMethod: _selectedPaymentMethod!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      if (!mounted) return;
      _showSuccessDialog();

    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('تم الإرسال بنجاح')
          ]
        ),
        content: const Text('تم إرسال طلب التصريح الأمني بنجاح. سيتم مراجعة طلبك والرد عليك قريباً.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('موافق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFormData) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text('استخراج تصريح أمني', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => context.pop()),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('استخراج تصريح أمني', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => context.pop()),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // تنبيه مهم
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B))
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'يجب إرسال طلب استخراج تصريح أمني خلال مدة لا تقل عن 3 أيام عمل قبل موعد السفر لا تتخللها الإجازات الرسمية.',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w500
                          )
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // تاريخ السفر
                _buildFormField(
                  label: 'تاريخ السفر',
                  child: TextFormField(
                    controller: _travelDateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: 'اختر تاريخ السفر',
                      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF10B981)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981))
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى اختيار تاريخ السفر' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // الجنسية
                _buildFormField(
                  label: 'الجنسية',
                  child: DropdownButtonFormField<int>(
                    value: _selectedNationalityId,
                    decoration: InputDecoration(
                      hintText: 'اختر الجنسية',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981))
                      ),
                    ),
                    items: _nationalities.map((nationality) => DropdownMenuItem<int>(
                      value: nationality['id'],
                      child: Text(nationality['name_ar']),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedNationalityId = value),
                    validator: (v) => v == null ? 'يرجى اختيار الجنسية' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // عدد الأفراد
                _buildFormField(
                  label: 'عدد الأفراد',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('عدد الأفراد', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _peopleCount > 1 ? () => setState(() => _peopleCount--) : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: _peopleCount > 1 ? const Color(0xFF10B981) : Colors.grey,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _peopleCount.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _peopleCount < 20 ? () => setState(() => _peopleCount++) : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: _peopleCount < 20 ? const Color(0xFF10B981) : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // قادم من دولة
                _buildFormField(
                  label: 'قادم من دولة',
                  child: DropdownButtonFormField<int>(
                    value: _selectedCountryId,
                    decoration: InputDecoration(
                      hintText: 'اختر الدولة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981))
                      ),
                    ),
                    items: _countries.map((country) => DropdownMenuItem<int>(
                      value: country['id'],
                      child: Text(country['name_ar']),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedCountryId = value),
                    validator: (v) => v == null ? 'يرجى اختيار الدولة' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // صورة الجواز
                _buildImageSection(
                  title: 'أضف صورة واضحة للجواز',
                  subtitle: 'مطلوبة',
                  image: _passportImage,
                  onTap: _pickPassportImage,
                  onRemove: () => setState(() => _passportImage = null),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // صور الإقامة
                _buildMultipleImagesSection(),
                const SizedBox(height: 24),

                // طريقة الدفع
                _buildFormField(
                  label: 'اختر طريقة الدفع',
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: InputDecoration(
                      hintText: 'اختر طريقة الدفع',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981))
                      ),
                    ),
                    items: _paymentMethods.map((method) => DropdownMenuItem<String>(
                      value: method['key'],
                      child: Text(method['label']),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                    validator: (v) => v == null ? 'يرجى اختيار طريقة الدفع' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // ملاحظات
                _buildFormField(
                  label: 'ملاحظات (اختيارية)',
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'أي ملاحظات إضافية...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981))
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ملخص التكلفة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!)
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('رسوم استخراج التصريح للفرد الواحد', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('${_individualFee.toStringAsFixed(0)} جنيه', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ]
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('عدد الأفراد: $_peopleCount', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('${(_individualFee * _peopleCount).toStringAsFixed(0)} جنيه', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ]
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${_totalAmount.toStringAsFixed(0)} جنيه', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
                        ]
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              ),
                              SizedBox(width: 12),
                              Text('جاري الإرسال...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Text('إرسال الطلب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        child
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    required bool isRequired
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(width: 8),
            Text('($subtitle)', style: TextStyle(fontSize: 14, color: isRequired ? Colors.red : Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image != null ? const Color(0xFF10B981) : Colors.grey[300]!,
                width: image != null ? 2 : 1
              )
            ),
            child: image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(image, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      ),
                      if (onRemove != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('اضغط لاختيار صورة', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('أضف صور إقامة أخرى إن وجدت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(width: 8),
            Text('(اختيارية)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        
        // عرض الصور المختارة
        if (_residenceImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _residenceImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _residenceImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeResidenceImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // زر إضافة صور
        GestureDetector(
          onTap: _residenceImages.length < 5 ? _pickResidenceImages : null,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: _residenceImages.length < 5 ? Colors.grey[50] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 24,
                  color: _residenceImages.length < 5 ? Colors.grey[600] : Colors.grey[400]
                ),
                const SizedBox(height: 4),
                Text(
                  _residenceImages.length < 5 
                      ? 'اضغط لإضافة صور الإقامة (${_residenceImages.length}/5)'
                      : 'تم الوصول للحد الأقصى (5 صور)',
                  style: TextStyle(
                    color: _residenceImages.length < 5 ? Colors.grey[600] : Colors.grey[400],
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}