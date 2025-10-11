import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:saba2v2/config/constants.dart';
import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/components/realeState/enhanced_field.dart';

class PropertyForm extends StatefulWidget {
  final Property? property;

  const PropertyForm({super.key, this.property});

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _viewController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _areaController;

  // Add-only controllers
  late final TextEditingController _currencyController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  String? _selectedPropertyType;
  String? _selectedOwnershipType; // add-only
  bool _isReady = false;
  File? _selectedImageFile; // new image for add or edit

  @override
  void initState() {
    super.initState();
    final property = widget.property;

    _addressController = TextEditingController(text: property?.address ?? '');
    _priceController = TextEditingController(text: property?.price.toString() ?? '');
    _descController = TextEditingController(text: property?.description ?? '');
    _bedroomsController = TextEditingController(text: property?.bedrooms.toString() ?? '');
    _bathroomsController = TextEditingController(text: property?.bathrooms.toString() ?? '');
    _viewController = TextEditingController(text: property?.view ?? '');
    _paymentMethodController = TextEditingController(text: property?.paymentMethod ?? '');
    _areaController = TextEditingController(text: property?.area ?? '');

    _currencyController = TextEditingController(text: 'SAR');
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();

    _selectedPropertyType = property?.type ?? RealEstateConstants.propertyTypes.first;
    _selectedOwnershipType = RealEstateConstants.ownershipTypes.first;
    _isReady = property?.isReady ?? false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _viewController.dispose();
    _paymentMethodController.dispose();
    _areaController.dispose();
    _currencyController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  String? _requiredValidator(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    return null;
  }

  String? _intValidator(String? value, {String fieldName = 'القيمة'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'الرجاء إدخال رقم صحيح';
    if (parsed < 0) return 'القيمة يجب أن تكون موجبة';
    return null;
  }

  String? _doubleValidator(String? value, {String fieldName = 'القيمة'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'الرجاء إدخال رقم عشري صحيح';
    return null;
  }

  Future<void> _onSave() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.property == null) {
      // Add mode requires image
      if (_selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار صورة للعقار'), backgroundColor: Colors.red),
        );
        return;
      }

      final success = await auth.addProperty(
        address: _addressController.text.trim(),
        type: _selectedPropertyType!,
        price: int.parse(_priceController.text.trim()),
        description: _descController.text.trim(),
        imageFile: _selectedImageFile!,
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        view: _viewController.text.trim(),
        paymentMethod: _paymentMethodController.text.trim(),
        area: _areaController.text.trim(),
        isReady: _isReady,
        currency: _currencyController.text.trim(),
        ownershipType: _selectedOwnershipType!,
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
      );
      if (success && mounted) Navigator.of(context).pop(true);
    } else {
      // Edit mode
      final p = widget.property!;
      final updated = Property(
        id: p.id,
        address: _addressController.text.trim(),
        type: _selectedPropertyType ?? p.type,
        price: int.parse(_priceController.text.trim()),
        description: _descController.text.trim(),
        imageUrl: p.imageUrl,
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        view: _viewController.text.trim(),
        paymentMethod: _paymentMethodController.text.trim(),
        area: _areaController.text.trim(),
        isReady: _isReady,
      );

      final success = await auth.updateProperty(
        updatedProperty: updated,
        newImageFile: _selectedImageFile,
      );
      if (success && mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.orange.shade50]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(isEdit ? Icons.edit_location_alt : Icons.add_location_alt, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'تعديل بيانات العقار' : 'إضافة عقار جديد',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white))
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _selectedImageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                                  )
                                : isEdit && widget.property!.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(widget.property!.imageUrl, fit: BoxFit.cover),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.image, color: Colors.grey, size: 40),
                                            SizedBox(height: 8),
                                            Text('اضغط لاختيار صورة', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        EnhancedField(
                          icon: Icons.location_on,
                          label: 'العنوان',
                          controller: _addressController,
                          validator: (v) => _requiredValidator(v, fieldName: 'العنوان'),
                        ),
                        const SizedBox(height: 12),

                        // Property type
                        DropdownButtonFormField<String>(
                          value: _selectedPropertyType,
                          decoration: InputDecoration(
                            hintText: 'نوع العقار',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: RealEstateConstants.propertyTypes
                              .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPropertyType = val),
                          validator: (val) => val == null ? 'يرجى اختيار نوع العقار' : null,
                        ),
                        const SizedBox(height: 12),

                        // Price
                        EnhancedField(
                          icon: Icons.attach_money,
                          label: 'السعر',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => _intValidator(v, fieldName: 'السعر'),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        EnhancedField(
                          icon: Icons.notes,
                          label: 'الوصف',
                          controller: _descController,
                          maxLines: 3,
                          validator: (v) => _requiredValidator(v, fieldName: 'الوصف'),
                        ),
                        const SizedBox(height: 12),

                        // Bedrooms
                        EnhancedField(
                          icon: Icons.king_bed_outlined,
                          label: 'عدد الغرف',
                          controller: _bedroomsController,
                          keyboardType: TextInputType.number,
                          validator: (v) => _intValidator(v, fieldName: 'عدد الغرف'),
                        ),
                        const SizedBox(height: 12),

                        // Bathrooms
                        EnhancedField(
                          icon: Icons.bathtub_outlined,
                          label: 'عدد الحمامات',
                          controller: _bathroomsController,
                          keyboardType: TextInputType.number,
                          validator: (v) => _intValidator(v, fieldName: 'عدد الحمامات'),
                        ),
                        const SizedBox(height: 12),

                        // View
                        EnhancedField(
                          icon: Icons.remove_red_eye_outlined,
                          label: 'الإطلالة',
                          controller: _viewController,
                          validator: (v) => _requiredValidator(v, fieldName: 'الإطلالة'),
                        ),
                        const SizedBox(height: 12),

                        // Payment method
                        EnhancedField(
                          icon: Icons.payment,
                          label: 'طريقة الدفع',
                          controller: _paymentMethodController,
                          validator: (v) => _requiredValidator(v, fieldName: 'طريقة الدفع'),
                        ),
                        const SizedBox(height: 12),

                        // Area
                        EnhancedField(
                          icon: Icons.square_foot,
                          label: 'المساحة',
                          controller: _areaController,
                          validator: (v) => _requiredValidator(v, fieldName: 'المساحة'),
                        ),
                        const SizedBox(height: 8),

                        // Ready checkbox
                        Row(
                          children: [
                            Checkbox(value: _isReady, onChanged: (val) => setState(() => _isReady = val ?? false)),
                            const Text('جاهز', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ],
                        ),

                        if (!isEdit) ...[
                          const SizedBox(height: 12),
                          // Currency (add only)
                          EnhancedField(
                            icon: Icons.currency_exchange,
                            label: 'العملة',
                            controller: _currencyController,
                            validator: (v) => _requiredValidator(v, fieldName: 'العملة'),
                          ),
                          const SizedBox(height: 12),

                          // Ownership type (add only)
                          DropdownButtonFormField<String>(
                            value: _selectedOwnershipType,
                            decoration: InputDecoration(
                              hintText: 'نوع الملكية',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: RealEstateConstants.ownershipTypes
                                .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedOwnershipType = val),
                            validator: (val) => val == null ? 'يرجى اختيار نوع الملكية' : null,
                          ),
                          const SizedBox(height: 12),

                          // Latitude
                          EnhancedField(
                            icon: Icons.place,
                            label: 'خط العرض (Latitude)',
                            controller: _latitudeController,
                            keyboardType: TextInputType.number,
                            validator: (v) => _doubleValidator(v, fieldName: 'خط العرض'),
                          ),
                          const SizedBox(height: 12),

                          // Longitude
                          EnhancedField(
                            icon: Icons.place_outlined,
                            label: 'خط الطول (Longitude)',
                            controller: _longitudeController,
                            keyboardType: TextInputType.number,
                            validator: (v) => _doubleValidator(v, fieldName: 'خط الطول'),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _onSave,
                                child: Text(isEdit ? 'حفظ التعديلات' : 'حفظ العقار'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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