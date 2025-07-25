// مسار الملف: lib/screens/resturant_law_data.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';

// --- هذا الكلاس يبقى كما هو بدون أي تغيير ---
class RestaurantLegalData {
  final bool includesVat;
  final String? profileImage;
  final String? ownerIdFront;
  final String? ownerIdBack;
  final String? restaurantLicenseFront;
  final String? restaurantLicenseBack;
  final String? crPhotoFront;
  final String? crPhotoBack;
  final String? vatPhotoFront;
  final String? vatPhotoBack;

  RestaurantLegalData({
    required this.includesVat,
    this.profileImage,
    this.ownerIdFront,
    this.ownerIdBack,
    this.restaurantLicenseFront,
    this.restaurantLicenseBack,
    this.crPhotoFront,
    this.crPhotoBack,
    this.vatPhotoFront,
    this.vatPhotoBack,
  });

  RestaurantLegalData copyWith({
    bool? includesVat,
    String? profileImage,
    String? ownerIdFront,
    String? ownerIdBack,
    String? restaurantLicenseFront,
    String? restaurantLicenseBack,
    String? crPhotoFront,
    String? crPhotoBack,
    String? vatPhotoFront,
    String? vatPhotoBack,
  }) {
    return RestaurantLegalData(
      includesVat: includesVat ?? this.includesVat,
      profileImage: profileImage ?? this.profileImage,
      ownerIdFront: ownerIdFront ?? this.ownerIdFront,
      ownerIdBack: ownerIdBack ?? this.ownerIdBack,
      restaurantLicenseFront: restaurantLicenseFront ?? this.restaurantLicenseFront,
      restaurantLicenseBack: restaurantLicenseBack ?? this.restaurantLicenseBack,
      crPhotoFront: crPhotoFront ?? this.crPhotoFront,
      crPhotoBack: crPhotoBack ?? this.crPhotoBack,
      vatPhotoFront: vatPhotoFront ?? this.vatPhotoFront,
      vatPhotoBack: vatPhotoBack ?? this.vatPhotoBack,
    );
  }

 // داخل كلاس RestaurantLegalData

Map<String, dynamic> toJson() => {
  'vat_included': includesVat, // تم تصحيح الاسم
  'profile_image': profileImage,
  'owner_id_front_image': ownerIdFront, // تم تصحيح الاسم
  'owner_id_back_image': ownerIdBack, // تم تصحيح الاسم
  'license_front_image': restaurantLicenseFront, // تم تصحيح الاسم
  'license_back_image': restaurantLicenseBack, // تم تصحيح الاسم
  'commercial_register_front_image': crPhotoFront, // تم تصحيح الاسم
  'commercial_register_back_image': crPhotoBack, // تم تصحيح الاسم
  'vat_image_front': vatPhotoFront, // تم تصحيح الاسم
  'vat_image_back': vatPhotoBack, // تم تصحيح الاسم
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
  bool _isLoading = false;

  Map<String, String?> _localImagePaths = {};
  
  static const String _baseUrl = 'http://192.168.1.8:8000';

  @override
  void initState() {
    super.initState();
    _formData = RestaurantLegalData(includesVat: false);
  }

  Future<String?> _uploadFile(String filePath) async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('files[]', filePath));
      var response = await request.send().timeout(const Duration(seconds: 45));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['files'][0] as String;
      } else {
        throw Exception('فشل رفع الصورة');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(String fieldName) async {
    if (_isLoading) return;
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')));
      }
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path != null) {
      setState(() {
        _localImagePaths[fieldName] = path;
      });
      final url = await _uploadFile(path);
      if (url != null) {
        setState(() {
          switch (fieldName) {
            case 'profileImage': _formData = _formData.copyWith(profileImage: url); break;
            case 'ownerIdFront': _formData = _formData.copyWith(ownerIdFront: url); break;
            case 'ownerIdBack': _formData = _formData.copyWith(ownerIdBack: url); break;
            case 'restaurantLicenseFront': _formData = _formData.copyWith(restaurantLicenseFront: url); break;
            case 'restaurantLicenseBack': _formData = _formData.copyWith(restaurantLicenseBack: url); break;
            case 'crPhotoFront': _formData = _formData.copyWith(crPhotoFront: url); break;
            case 'crPhotoBack': _formData = _formData.copyWith(crPhotoBack: url); break;
            case 'vatPhotoFront': _formData = _formData.copyWith(vatPhotoFront: url); break;
            case 'vatPhotoBack': _formData = _formData.copyWith(vatPhotoBack: url); break;
          }
        });
      }
    }
  }
  
  void _removeFile(String fieldName) {
    if (_isLoading) return;
    setState(() {
      _localImagePaths[fieldName] = null;
      switch (fieldName) {
        case 'profileImage': _formData = _formData.copyWith(profileImage: null); break;
        case 'ownerIdFront': _formData = _formData.copyWith(ownerIdFront: null); break;
        case 'ownerIdBack': _formData = _formData.copyWith(ownerIdBack: null); break;
        case 'restaurantLicenseFront': _formData = _formData.copyWith(restaurantLicenseFront: null); break;
        case 'restaurantLicenseBack': _formData = _formData.copyWith(restaurantLicenseBack: null); break;
        case 'crPhotoFront': _formData = _formData.copyWith(crPhotoFront: null); break;
        case 'crPhotoBack': _formData = _formData.copyWith(crPhotoBack: null); break;
        case 'vatPhotoFront': _formData = _formData.copyWith(vatPhotoFront: null); break;
        case 'vatPhotoBack': _formData = _formData.copyWith(vatPhotoBack: null); break;
      }
    });
  }

  void _handleVatSelection(bool value) {
    setState(() => _formData = _formData.copyWith(includesVat: value));
  }

  void _submitForm() {
    // التحقق من رفع الصور (الصور الخاصة بالضريبة اختيارية)
    if (_formData.profileImage == null ||
        _formData.ownerIdFront == null ||
        _formData.ownerIdBack == null ||
        _formData.restaurantLicenseFront == null ||
        _formData.restaurantLicenseBack == null ||
        _formData.crPhotoFront == null ||
        _formData.crPhotoBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء رفع كل الصور المطلوبة (باستثناء صور الضريبة)')),
      );
      return;
    }

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
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _localImagePaths['profileImage'] != null
                    ? FileImage(File(_localImagePaths['profileImage']!))
                    : null,
                child: _localImagePaths['profileImage'] == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickFile('profileImage'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('إضافة صورة شخصية', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
          child: Text('هل تشمل الاسعار لديك ضريبة القيمة المضافة؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
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
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
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
          child: ImagePickerRow(
            label: field['label']!,
            icon: Icons.image_outlined,
            fieldIdentifier: field['field']!,
            onTap: () => _pickFile(field['field']!),
            imagePath: _localImagePaths[field['field']!],
            onRemove: () => _removeFile(field['field']!),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      appBar: AppBar(
        title: const Text('المستندات المطلوبة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
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
                        _buildImageSection('صور ضريبة القيمة المضافة (اختياري)', [
                          {'label': 'صورة أمامية', 'field': 'vatPhotoFront'},
                          {'label': 'صورة خلفية', 'field': 'vatPhotoBack'},
                        ]),
                        const SizedBox(height: 32),
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('التالي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
        ],
      ),
    );
  }
}