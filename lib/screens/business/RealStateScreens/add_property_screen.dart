import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/config/constants.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/services/property_service.dart';
import 'package:saba2v2/screens/location_picker_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _viewController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Dropdowns
  String? _selectedPropertyType = RealEstateConstants.propertyTypes.first;
  String? _selectedOwnershipType = RealEstateConstants.ownershipTypes.first;
  String? _selectedCurrency = 'SAR';
  String? _selectedPaymentMethod = 'كاش';
  bool _isReady = false;

  File? _selectedImageFile;
  bool _isSubmitting = false;
  String? _serverErrorMessage;

  // Lists
  final List<String> _currencies = const ['SAR', 'USD', 'AED', 'EGP', 'YER'];
  final List<String> _paymentMethods = const ['كاش', 'تقسيط', 'تمويل عقاري'];

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _viewController.dispose();
    _areaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() => _selectedImageFile = File(image.path));
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result is Map<String, dynamic>) {
      setState(() {
        _addressController.text = (result['address'] ?? '').toString();
        _latitudeController.text = (result['latitude'] ?? '').toString();
        _longitudeController.text = (result['longitude'] ?? '').toString();
      });
    }
  }

  String? _required(String? v, {String name = 'هذا الحقل'}) {
    if (v == null || v.trim().isEmpty) return '$name مطلوب';
    return null;
  }

  String? _intRequired(String? v, {String name = 'القيمة'}) {
    if (v == null || v.trim().isEmpty) return '$name مطلوب';
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'الرجاء إدخال رقم صحيح';
    if (parsed < 0) return 'القيمة يجب أن تكون موجبة';
    return null;
  }

  String? _doubleRequired(String? v, {String name = 'القيمة'}) {
    if (v == null || v.trim().isEmpty) return '$name مطلوب';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'الرجاء إدخال رقم عشري صحيح';
    return null;
  }

  // تحقق لعدد صحيح ضمن نطاق محدد (افتراضي 0..20)
  String? _intRange(String? v, {String name = 'القيمة', int min = 0, int max = 20}) {
    if (v == null || v.trim().isEmpty) return '$name مطلوب';
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'الرجاء إدخال رقم صحيح';
    if (parsed < min || parsed > max) return '$name يجب أن يكون بين $min و $max';
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() { _serverErrorMessage = null; });

    if (!_formKey.currentState!.validate()) return;
    // تأكيد اختيار الموقع من الخريطة قبل الإرسال
    final lat = double.tryParse(_latitudeController.text.trim());
    final lon = double.tryParse(_longitudeController.text.trim());
    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الموقع من الخريطة'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة للعقار'), backgroundColor: Colors.red),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final propertyService = PropertyService();

    setState(() { _isSubmitting = true; });
    try {
      // استدعاء الخدمة مباشرة لالتقاط رسائل التحقق التفصيلية
      await propertyService.addProperty(
        address: _addressController.text.trim(),
        type: _selectedPropertyType!,
        price: int.parse(_priceController.text.trim()),
        description: _descController.text.trim(),
        imageFile: _selectedImageFile!,
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        view: _viewController.text.trim(),
        paymentMethod: _selectedPaymentMethod!,
        area: _areaController.text.trim(),
        isReady: _isReady,
        contactPhone: auth.userPhone,
        currency: _selectedCurrency!,
        ownershipType: _selectedOwnershipType!,
        latitude: lat,
        longitude: lon,
      );

      // نجاح: حدث تحديث لقائمة العقارات
      await auth.fetchMyProperties();
      if (mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة العقار بنجاح'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('[AddPropertyScreen] submit error: $e');
      setState(() { _serverErrorMessage = e.toString(); });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إضافة العقار: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة عقار جديد'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('العودة للرئيسية', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImageFile == null
                        ? const Center(child: Text('اضغط لاختيار صورة العقار'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address + map picker
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    hintText: 'مثال: الرياض، حي العليا، شارع...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (v) => _required(v, name: 'العنوان'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('اختيار الموقع على الخريطة'),
                ),
                const SizedBox(height: 8),
                // عرض الإحداثيات المختارة بشكل غير قابل للتعديل
                if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text('تم اختيار الموقع: ${_latitudeController.text}, ${_longitudeController.text}')),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Property type
                DropdownButtonFormField<String>(
                  value: _selectedPropertyType,
                  items: RealEstateConstants.propertyTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(_arabicLabelForType(t))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPropertyType = v),
                  decoration: _dropdownDecoration('نوع العقار'),
                  validator: (v) => v == null ? 'يرجى اختيار نوع العقار' : null,
                ),
                const SizedBox(height: 12),

                // Ownership type
                DropdownButtonFormField<String>(
                  value: _selectedOwnershipType,
                  items: RealEstateConstants.ownershipTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(_arabicLabelForOwnership(t))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedOwnershipType = v),
                  decoration: _dropdownDecoration('نوع الملكية'),
                  validator: (v) => v == null ? 'يرجى اختيار نوع الملكية' : null,
                ),
                const SizedBox(height: 12),

                // Currency
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCurrency = v),
                  decoration: _dropdownDecoration('العملة'),
                  validator: (v) => v == null ? 'يرجى اختيار العملة' : null,
                ),
                const SizedBox(height: 12),

                // Payment method
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  items: _paymentMethods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                  decoration: _dropdownDecoration('طريقة الدفع'),
                  validator: (v) => v == null ? 'يرجى اختيار طريقة الدفع' : null,
                ),
                const SizedBox(height: 12),

                // Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('السعر'),
                  validator: (v) => _intRequired(v, name: 'السعر'),
                ),
                const SizedBox(height: 12),

                // Area
                TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('المساحة (م٢)'),
                  validator: (v) => _required(v, name: 'المساحة'),
                ),
                const SizedBox(height: 12),

                // Bedrooms
                TextFormField(
                  controller: _bedroomsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('عدد الغرف'),
                  validator: (v) => _intRange(v, name: 'عدد الغرف', min: 0, max: 20),
                ),
                const SizedBox(height: 12),

                // Bathrooms
                TextFormField(
                  controller: _bathroomsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('عدد الحمامات'),
                  validator: (v) => _intRange(v, name: 'عدد الحمامات', min: 0, max: 20),
                ),
                const SizedBox(height: 12),

                // View
                TextFormField(
                  controller: _viewController,
                  decoration: _inputDecoration('الإطلالة'),
                  validator: (v) => _required(v, name: 'الإطلالة'),
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: _inputDecoration('الوصف'),
                  validator: (v) => _required(v, name: 'الوصف'),
                ),
                const SizedBox(height: 12),

                // Readiness
                SwitchListTile(
                  value: _isReady,
                  onChanged: (v) => setState(() => _isReady = v),
                  title: const Text('جاهز للسكن'),
                ),
                const SizedBox(height: 12),

                // تم إخفاء حقول الإحداثيات؛ يتم تعيينها تلقائياً من الخريطة
                const SizedBox(height: 16),

                if (_serverErrorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _serverErrorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ العقار'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  String _arabicLabelForType(String type) {
    switch (type) {
      case 'apartment': return 'شقة';
      case 'villa': return 'فيلا';
      case 'townhouse': return 'توين هاوس';
      case 'office': return 'مكتب';
      case 'shop': return 'محل';
      default: return type;
    }
  }

  String _arabicLabelForOwnership(String type) {
    switch (type) {
      case 'freehold': return 'تمليك';
      case 'leasehold': return 'إيجار طويل الأجل';
      case 'usufruct': return 'انتفاع';
      default: return type;
    }
  }
}