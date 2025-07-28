// lib/screens/business/CarsScreens/car_data_edit.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saba2v2/models/car_model.dart';
import 'package:saba2v2/services/car_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarDataEdit extends StatefulWidget {
  final Car car;

  const CarDataEdit({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDataEdit> createState() => _CarDataEditState();
}

class _CarDataEditState extends State<CarDataEdit> {
  final _formKey = GlobalKey<FormState>();

  // وحدات تحكم للحقول النصية
  late TextEditingController typeController;
  late TextEditingController modelController;
  late TextEditingController colorController;
  late TextEditingController plateController;
  late TextEditingController governorateController;
  late TextEditingController priceController;

  // متغيرات لتخزين الصور الجديدة المختارة
  File? newCarImageFront,
      newCarImageBack,
      newCarLicenseFront,
      newCarLicenseBack,
      newLicenseFrontImage,
      newLicenseBackImage;

  late CarApiService _apiService;
  bool _isServiceInitialized = false;
  bool _isLoading = false;
  String _loadingMessage = "جاري حفظ التعديلات...";

  @override
  void initState() {
    super.initState();
    // تهيئة وحدات التحكم بالبيانات الحالية
    typeController = TextEditingController(text: widget.car.carType);
    modelController = TextEditingController(text: widget.car.carModel);
    colorController = TextEditingController(text: widget.car.carColor ?? '');
    plateController = TextEditingController(text: widget.car.carPlateNumber);
    governorateController = TextEditingController(text: widget.car.governorate);
    priceController = TextEditingController(text: widget.car.price.toString());

    // تهيئة خدمة الـ API
    _initializeService();
  }

  Future<void> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    setState(() {
      _apiService = CarApiService(token: token);
      _isServiceInitialized = true;
    });
  }

  @override
  void dispose() {
    typeController.dispose();
    modelController.dispose();
    colorController.dispose();
    plateController.dispose();
    governorateController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_isServiceInitialized || _isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = "جاري تحديث البيانات...";
    });

    try {
      final Map<String, String> finalImageUrls = {
        'car_image_front': widget.car.carImageFront,
        'car_image_back': widget.car.carImageBack ?? '',
        'car_license_front': widget.car.carLicenseFront ?? '',
        'car_license_back': widget.car.carLicenseBack ?? '',
        'license_front_image': widget.car.licenseFrontImage ?? '',
        'license_back_image': widget.car.licenseBackImage ?? '',
      };

      final Map<String, File?> newImagesToUpload = {
        'car_image_front': newCarImageFront,
        'car_image_back': newCarImageBack,
        'car_license_front': newCarLicenseFront,
        'car_license_back': newCarLicenseBack,
        'license_front_image': newLicenseFrontImage,
        'license_back_image': newLicenseBackImage,
      };

      for (var entry in newImagesToUpload.entries) {
        if (entry.value != null) {
          setState(() {
            _loadingMessage = "جاري رفع صورة (${entry.key})...";
          });
          final newUrl = await _apiService.uploadImage(entry.value!);
          finalImageUrls[entry.key] = newUrl;
        }
      }

      // 4. جهز البيانات النهائية
      final Map<String, dynamic> updatedData = {
        "car_type": typeController.text,
        "car_model": modelController.text,
        "car_color": colorController.text,
        "car_plate_number": plateController.text,
        "governorate": governorateController.text,
        "price": double.tryParse(priceController.text) ?? widget.car.price,
        "owner_type": widget.car.ownerType,

        // --- *** الإضافة المطلوبة هنا *** ---
        // إعادة تعيين حالة المراجعة إلى 0 (تحت المراجعة) عند كل تحديث
        "is_reviewed": 0,
        // --- نهاية الإضافة ---

        ...finalImageUrls, // دمج روابط الصور المحدثة
      };

      final updatedCar = await _apiService.updateCar(widget.car.id, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث البيانات، السيارة الآن قيد المراجعة'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedCar);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التحديث: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل بيانات السيارة"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: "حفظ التعديلات",
            onPressed: _isServiceInitialized ? _handleSave : null,
          )
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionHeader("معلومات السيارة", theme),
                  _buildTextField(controller: typeController, label: "نوع السيارة", icon: Icons.directions_car),
                  const SizedBox(height: 16),
                  _buildTextField(controller: modelController, label: "موديل السيارة", icon: Icons.calendar_today),
                  const SizedBox(height: 16),
                  _buildTextField(controller: colorController, label: "لون السيارة", icon: Icons.color_lens),
                  const SizedBox(height: 16),
                  _buildTextField(controller: plateController, label: "رقم اللوحة", icon: Icons.pin),
                  const SizedBox(height: 16),
                  _buildTextField(controller: governorateController, label: "المحافظة", icon: Icons.location_city),
                  const SizedBox(height: 16),
                  _buildTextField(controller: priceController, label: "السعر اليومي", icon: Icons.attach_money, keyboardType: TextInputType.number, validator: (v) => (double.tryParse(v??'0') ?? 0) <= 0 ? "سعر غير صالح" : null),
                  const Divider(height: 48),
                  _buildSectionHeader("تعديل الصور والمستندات", theme),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      _buildImagePicker("صورة السيارة (أمام)", widget.car.carImageFront, newCarImageFront, (file) => setState(() => newCarImageFront = file)),
                      _buildImagePicker("صورة السيارة (خلف)", widget.car.carImageBack, newCarImageBack, (file) => setState(() => newCarImageBack = file)),
                      _buildImagePicker("استمارة السيارة (وجه)", widget.car.carLicenseFront, newCarLicenseFront, (file) => setState(() => newCarLicenseFront = file)),
                      _buildImagePicker("استمارة السيارة (خلف)", widget.car.carLicenseBack, newCarLicenseBack, (file) => setState(() => newCarLicenseBack = file)),
                      _buildImagePicker("صورة الرخصة (وجه)", widget.car.licenseFrontImage, newLicenseFrontImage, (file) => setState(() => newLicenseFrontImage = file)),
                      _buildImagePicker("صورة الرخصة (خلف)", widget.car.licenseBackImage, newLicenseBackImage, (file) => setState(() => newLicenseBackImage = file)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("حفظ كل التعديلات", style: TextStyle(color: Colors.white)),
                    onPressed: _isServiceInitialized ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  // ودجات مساعدة (Builders)
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ?? (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.08),
      ),
    );
  }

  Widget _buildImagePicker(
      String title, String? currentImageUrl, File? newImageFile, Function(File?) onImageSelected) {
    final picker = ImagePicker();

    Future<void> pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      onImageSelected(pickedFile != null ? File(pickedFile.path) : null);
    }

    Widget imageWidget;
    if (newImageFile != null) {
      imageWidget = Image.file(newImageFile, fit: BoxFit.cover);
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      imageWidget = Image.network(currentImageUrl, fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30));
    } else {
      imageWidget = const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30);
    }

    return Tooltip(
      message: title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: pickImage,
                  splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            const SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}