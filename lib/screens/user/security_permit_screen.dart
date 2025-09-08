import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// --- استيراد الملفات الأساسية التي يعتمد عليها الكود ---
import '../../services/image_upload_service.dart'; // افترض وجود هذا الملف
import '../../services/security_permit_service.dart';
import '../../config/constants.dart'; // ملف الثوابت الموحد

class SecurityPermitScreen extends StatefulWidget {
  const SecurityPermitScreen({super.key});

  @override
  State<SecurityPermitScreen> createState() => _SecurityPermitScreenState();
}

class _SecurityPermitScreenState extends State<SecurityPermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // سنقوم بإنشاء instance من services
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Controllers
  final TextEditingController _travelDateController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _peopleCountController = TextEditingController();
  final TextEditingController _comingFromController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Images
  File? _passportImage;
  File? _otherDocumentImage;
  
  // Loading state
  bool _isLoading = false;
  
  DateTime? _selectedDate;

  @override
  void dispose() {
    _travelDateController.dispose();
    _nationalityController.dispose();
    _peopleCountController.dispose();
    _comingFromController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _travelDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage(bool isPassport) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() {
          if (isPassport) _passportImage = File(image.path);
          else _otherDocumentImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('خطأ في اختيار الصورة: ${e.toString()}');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passportImage == null) {
      _showErrorSnackBar('يرجى اختيار صورة الجواز');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final passportImageUrl = await _imageUploadService.uploadImage(_passportImage!);
      String? otherDocumentImageUrl;
      if (_otherDocumentImage != null) {
        otherDocumentImageUrl = await _imageUploadService.uploadImage(_otherDocumentImage!);
      }
      
      final requestData = {
        'travel_date': _travelDateController.text,
        'nationality': _nationalityController.text,
        'people_count': int.parse(_peopleCountController.text),
        'coming_from': _comingFromController.text,
        'passport_image': passportImageUrl,
        'other_document_image': otherDocumentImageUrl,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      await SecurityPermitService.submitPermit(requestData);
      
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
        title: const Row(children: [ Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('تم الإرسال بنجاح') ]),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF59E0B))),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Expanded(child: Text('يجب ملء استخراج تصريح أمني خلال جدة قبل 30 يوم على الأقل من موعد السفر', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى اختيار تاريخ السفر' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'الجنسية',
                  child: DropdownButtonFormField<String>(
                    value: _nationalityController.text.isNotEmpty ? _nationalityController.text : null,
                    decoration: InputDecoration(
                      hintText: 'اختر الجنسية',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
                    ),
                    items: const ['مصري', 'سعودي', 'إماراتي', 'كويتي', 'قطري', 'بحريني', 'عماني', 'أردني', 'لبناني', 'سوري', 'عراقي', 'فلسطيني', 'يمني', 'ليبي', 'تونسي', 'جزائري', 'مغربي', 'سوداني', 'أخرى']
                        .map((nat) => DropdownMenuItem(value: nat, child: Text(nat))).toList(),
                    onChanged: (v) => setState(() => _nationalityController.text = v ?? ''),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى اختيار الجنسية' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'عدد الأفراد',
                  child: DropdownButtonFormField<int>(
                    value: _peopleCountController.text.isNotEmpty ? int.tryParse(_peopleCountController.text) : null,
                    decoration: InputDecoration(
                      hintText: 'اختر عدد الأفراد',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
                    ),
                    items: List.generate(10, (i) => i + 1).map((c) => DropdownMenuItem(value: c, child: Text('$c ${c == 1 ? 'فرد' : 'أفراد'}'))).toList(),
                    onChanged: (v) => setState(() => _peopleCountController.text = v?.toString() ?? ''),
                    validator: (v) => v == null ? 'يرجى اختيار عدد الأفراد' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'قادم من أي دولة',
                  child: TextFormField(
                    controller: _comingFromController,
                    decoration: InputDecoration(
                      hintText: 'مثال: الإمارات',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الدولة القادم منها' : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildImageSection(title: 'صورة الجواز', subtitle: 'مطلوبة', image: _passportImage, onTap: () => _pickImage(true), isRequired: true),
                const SizedBox(height: 16),
                _buildImageSection(title: 'صور أقامة أخرى إن وجد', subtitle: 'اختيارية', image: _otherDocumentImage, onTap: () => _pickImage(false), isRequired: false),
                const SizedBox(height: 24),
                _buildFormField(
                  label: 'ملاحظات (اختيارية)',
                  child: TextFormField(controller: _notesController, maxLines: 4, decoration: InputDecoration(hintText: 'أي ملاحظات إضافية...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 12), Text('جاري الإرسال...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))],
                          )
                        : const Text('اختر طريقة الدفع', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: const Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('رسوم استخراج التصريح الواحد', style: TextStyle(fontWeight: FontWeight.w500)), Text('\$100', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)))]),
                      SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('\$100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981)))]),
                    ],
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
      children: [Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 8), child],
    );
  }

  Widget _buildImageSection({required String title, required String subtitle, required File? image, required VoidCallback onTap, required bool isRequired}) {
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
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: image != null ? const Color(0xFF10B981) : Colors.grey[300]!, width: image != null ? 2 : 1)),
            child: image != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(image, fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]), const SizedBox(height: 8), Text('اضغط لاختيار صورة', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))],
                  ),
          ),
        ),
      ],
    );
  }
}