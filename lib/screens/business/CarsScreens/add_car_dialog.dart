import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saba2v2/services/car_api_service.dart';

class AddCarDialog extends StatefulWidget {
  final int carRentalId;
  final String ownerType;
  final CarApiService apiService;
  final VoidCallback onCarAdded;

  const AddCarDialog({
    Key? key,
    required this.carRentalId,
    required this.ownerType,
    required this.apiService,
    required this.onCarAdded,
  }) : super(key: key);

  @override
  _AddCarDialogState createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  final _formKey = GlobalKey<FormState>();

  final carTypeController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final plateNumberController = TextEditingController();
  final priceController = TextEditingController();

  File? licenseFrontImage,
      licenseBackImage,
      carLicenseFront,
      carLicenseBack,
      carImageFront,
      carImageBack;

  bool _isSaving = false;

  @override
  void dispose() {
    carTypeController.dispose();
    modelController.dispose();
    colorController.dispose();
    plateNumberController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final allImages = {
      "صورة الرخصة (وجه)": licenseFrontImage,
      "صورة الرخصة (خلف)": licenseBackImage,
      "استمارة السيارة (وجه)": carLicenseFront,
      "استمارة السيارة (خلف)": carLicenseBack,
      "صورة السيارة (أمام)": carImageFront,
      "صورة السيارة (خلف)": carImageBack,
    };

    if (allImages.containsValue(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("يرجى رفع جميع الصور المطلوبة (6 صور)"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, String> imageUrls = {};
      for (var entry in allImages.entries) {
        imageUrls[entry.key] = await widget.apiService.uploadImage(entry.value!);
      }

      final Map<String, dynamic> carData = {
        "car_rental_id": widget.carRentalId,
        "owner_type": widget.ownerType,
        "car_type": carTypeController.text,
        "car_model": modelController.text,
        "car_color": colorController.text,
        "car_plate_number": plateNumberController.text,
        "price": priceController.text,
        "license_front_image": imageUrls["صورة الرخصة (وجه)"],
        "license_back_image": imageUrls["صورة الرخصة (خلف)"],
        "car_license_front": imageUrls["استمارة السيارة (وجه)"],
        "car_license_back": imageUrls["استمارة السيارة (خلف)"],
        "car_image_front": imageUrls["صورة السيارة (أمام)"],
        "car_image_back": imageUrls["صورة السيارة (خلف)"],
      };

      await widget.apiService.addCar(carData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("تم إضافة السيارة بنجاح"),
              backgroundColor: Colors.green),
        );
        widget.onCarAdded();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("حدث خطأ أثناء الحفظ: $e"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على عرض الشاشة لجعل الحوار متجاوبًا
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      // --- (التحسين الأول) ---
      // تقليل الهامش الأفقي لجعل الحوار أعرض
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04, // 4% هامش على كل جانب
        vertical: 24.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          _buildContent(),
          if (_isSaving) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(20), // زيادة الحشو الداخلي لمظهر أفضل
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إضافة سيارة جديدة",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("بيانات السيارة"),
                _buildTextField(
                    controller: carTypeController,
                    label: "نوع السيارة",
                    icon: Icons.rv_hookup_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: modelController,
                    label: "موديل السيارة",
                    icon: Icons.directions_car_filled_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: colorController,
                    label: "لون السيارة",
                    icon: Icons.color_lens_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: plateNumberController,
                    label: "رقم لوحة السيارة",
                    icon: Icons.pin_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: priceController,
                  label: "السعر اليومي",
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                ),
                const Divider(height: 48, thickness: 1),
                _buildSectionTitle("الأوراق والصور المطلوبة"),

                // --- (التحسين الثاني) ---
                // تغيير الشبكة إلى 3 أعمدة لجعلها أعرض وأكثر إحكامًا
                GridView.count(
                  crossAxisCount: 2, // تم التغيير من 2 إلى 3
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9, // تعديل نسبة العرض إلى الارتفاع لتناسب 3 أعمدة
                  children: [

                    _buildImagePicker("صورة الرخصة (وجه)", licenseFrontImage,
                            (file) => setState(() => licenseFrontImage = file)),
                    _buildImagePicker("صورة الرخصة (خلف)", licenseBackImage,
                            (file) => setState(() => licenseBackImage = file)),
                    _buildImagePicker("استمارة السيارة (وجه)", carLicenseFront,
                            (file) => setState(() => carLicenseFront = file)),
                    _buildImagePicker("استمارة السيارة (خلف)", carLicenseBack,
                            (file) => setState(() => carLicenseBack = file)),
                    _buildImagePicker("صورة السيارة (أمام)", carImageFront,
                            (file) => setState(() => carImageFront = file)),
                    _buildImagePicker("صورة السيارة (خلف)", carImageBack,
                            (file) => setState(() => carImageBack = file)),
                  ],
                ),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildImagePicker(
      String title, File? imageFile, Function(File?) onImageSelected) {
    final picker = ImagePicker();

    Future<void> pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    }

    return GestureDetector(
      onTap: pickImage,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: imageFile == null
                  ? Theme.of(context).dividerColor
                  : Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(imageFile, fit: BoxFit.cover),
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: Colors.grey[600], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              if (imageFile != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onImageSelected(null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("إلغاء"),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _handleSaveCar,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("إضافة السيارة"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "جاري الحفظ...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}