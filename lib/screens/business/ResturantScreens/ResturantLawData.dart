import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/router/app_router.dart';

class RestaurantLegalData {
  final bool includesVat;
  final String? ownerIdFront;
  final String? ownerIdBack;
  final String? restaurantLicenseFront;
  final String? restaurantLicenseBack;
  final String? crPhotoFront;
  final String? crPhotoBack;
  final String? vatPhotoFront;
  final String? vatPhotoBack;
  final String? profileImage; // إضافة حقل الصورة الشخصية

  RestaurantLegalData({
    required this.includesVat,
    this.ownerIdFront,
    this.ownerIdBack,
    this.restaurantLicenseFront,
    this.restaurantLicenseBack,
    this.crPhotoFront,
    this.crPhotoBack,
    this.vatPhotoFront,
    this.vatPhotoBack,
    this.profileImage,
  });

  RestaurantLegalData copyWith({
    bool? includesVat,
    String? ownerIdFront,
    String? ownerIdBack,
    String? restaurantLicenseFront,
    String? restaurantLicenseBack,
    String? crPhotoFront,
    String? crPhotoBack,
    String? vatPhotoFront,
    String? vatPhotoBack,
    String? profileImage,
  }) {
    return RestaurantLegalData(
      includesVat: includesVat ?? this.includesVat,
      ownerIdFront: ownerIdFront ?? this.ownerIdFront,
      ownerIdBack: ownerIdBack ?? this.ownerIdBack,
      restaurantLicenseFront: restaurantLicenseFront ?? this.restaurantLicenseFront,
      restaurantLicenseBack: restaurantLicenseBack ?? this.restaurantLicenseBack,
      crPhotoFront: crPhotoFront ?? this.crPhotoFront,
      crPhotoBack: crPhotoBack ?? this.crPhotoBack,
      vatPhotoFront: vatPhotoFront ?? this.vatPhotoFront,
      vatPhotoBack: vatPhotoBack ?? this.vatPhotoBack,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() => {
    'includes_vat': includesVat,
    'owner_id_front': ownerIdFront,
    'owner_id_back': ownerIdBack,
    'restaurant_license_front': restaurantLicenseFront,
    'restaurant_license_back': restaurantLicenseBack,
    'cr_photo_front': crPhotoFront,
    'cr_photo_back': crPhotoBack,
    'vat_photo_front': vatPhotoFront,
    'vat_photo_back': vatPhotoBack,
    'profile_image': profileImage,
  };
}

class ResturantLawData extends StatefulWidget {
  const ResturantLawData({super.key});

  @override
  State<ResturantLawData> createState() => _ResturantLawDataState();
}

class _ResturantLawDataState extends State<ResturantLawData> {
  late RestaurantLegalData _formData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _formData = RestaurantLegalData(includesVat: false);
  }

  Future<void> _pickFile(String fieldName) async {
    debugPrint('Picking file for: $fieldName');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File picker for $fieldName will be implemented')),
    );
  }

  void _handleVatSelection(bool value) {
    setState(() {
      _formData = _formData.copyWith(includesVat: value);
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('Submitting data: ${_formData.toJson()}');
      context.push('/ResturantInformation', extra: _formData);
    }
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
                child: ClipOval(
                  child: _formData.profileImage != null
                      ? Image.network(
                    _formData.profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 50, color: Colors.grey),
                  )
                      : const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickFile('profileImage'),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'إضافة صورة شخصية',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVatToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'هل تشمل الاسعار لديك ضريبة القيمة المضافة؟',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildToggleButton('نعم', true),
            const SizedBox(width: 12),
            _buildToggleButton('لا', false),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool value) {
    final isSelected = _formData.includesVat == value;
    return Expanded(
      child: InkWell(
        onTap: () => _handleVatSelection(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String title, List<Map<String, String>> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 12),
        ...fields.map((field) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ImagePickerRow(
              label: field['label']!,
              icon: Icons.image_outlined,
              fieldIdentifier: field['field']!,
              onTap: () => _pickFile(field['field']!),
            ),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF5F5F5),
      appBar: AppBar(
        title: const Text('المستندات المطلوبة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileImageSection(),
                    _buildImageSection('صور هوية المالك', [
                      {'label': 'صورة أمامية', 'field': 'ownerIdFront'},
                      {'label': 'صورة خلفية', 'field': 'ownerIdBack'},
                    ]),
                    const SizedBox(height: 24),
                    _buildImageSection('صور رخصة المطعم', [
                      {'label': 'صورة أمامية', 'field': 'restaurantLicenseFront'},
                      {'label': 'صورة خلفية', 'field': 'restaurantLicenseBack'},
                    ]),
                    const SizedBox(height: 24),
                    _buildImageSection('صور السجل التجاري', [
                      {'label': 'صورة أمامية', 'field': 'crPhotoFront'},
                      {'label': 'صورة خلفية', 'field': 'crPhotoBack'},
                    ]),
                    const SizedBox(height: 24),
                    _buildVatToggle(),
                    const SizedBox(height: 24),
                    _buildImageSection('صور ضريبة القيمة المضافة', [
                      {'label': 'صورة أمامية', 'field': 'vatPhotoFront'},
                      {'label': 'صورة خلفية', 'field': 'vatPhotoBack'},
                    ]),
                    const SizedBox(height: 32),
                    // إضافة مساحة إضافية قبل الزرار
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}