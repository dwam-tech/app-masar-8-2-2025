import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart';
import 'package:saba2v2/services/auth_service.dart'; // <-- استيراد مهم
import 'package:saba2v2/services/image_upload_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarRentalEditDocuments extends StatefulWidget {
  const CarRentalEditDocuments({super.key});

  @override
  State<CarRentalEditDocuments> createState() => _CarRentalEditDocumentsState();
}

class _CarRentalEditDocumentsState extends State<CarRentalEditDocuments> {
  bool isEditMode = false;
  bool _isInitializing = true;
  bool _isLoading = false;

  late CarRentalOfficeService _officeService;
  late ImageUploadService _imageUploadService;
  late AuthService _authService; // <-- إضافة الخدمة الجديدة
  int? _userId;
  final String logoKey = 'logo_image';

  final Map<String, String?> _documentUrls = {};
  final Map<String, File?> _newImageFiles = {};

  final String ownerIdFrontKey = 'owner_id_front_image';
  final String ownerIdBackKey = 'owner_id_back_image';
  final String licenseFrontKey = 'license_front_image';
  final String licenseBackKey = 'license_back_image';
  final String crFrontKey = 'commercial_register_front_image';
  final String crBackKey = 'commercial_register_back_image';
  final String vatFrontKey = 'vat_front_image';
  final String vatBackKey = 'vat_back_image';
  
  bool _initialIncludesVat = true;
  bool includesVat = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');
      if (token == null || userJsonString == null) throw Exception("بيانات المستخدم غير موجودة.");
      
      _officeService = CarRentalOfficeService(token: token);
      _imageUploadService = ImageUploadService();
      _authService = AuthService(); // <-- تهيئة الخدمة الجديدة
      
      final userMap = jsonDecode(userJsonString);
      final officeDetail = userMap['car_rental']?['office_detail'];
      if (officeDetail == null) throw Exception("تفاصيل المكتب غير موجودة.");
      
      _userId = userMap['id'];
      
      setState(() {
        _documentUrls[ownerIdFrontKey] = officeDetail[ownerIdFrontKey];
        _documentUrls[ownerIdBackKey] = officeDetail[ownerIdBackKey];
        _documentUrls[licenseFrontKey] = officeDetail[licenseFrontKey];
        _documentUrls[licenseBackKey] = officeDetail[licenseBackKey];
        _documentUrls[crFrontKey] = officeDetail[crFrontKey];
        _documentUrls[crBackKey] = officeDetail[crBackKey];
        _documentUrls[vatFrontKey] = officeDetail[vatFrontKey];
        _documentUrls[vatBackKey] = officeDetail[vatBackKey];
        includesVat = officeDetail['vat_included'] ?? true;
        _initialIncludesVat = includesVat;
      });
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isInitializing = false);
    }
  }
  
  Future<void> _pickImage(String key) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) setState(() => _newImageFiles[key] = File(pickedFile.path));
    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل اختيار الصورة: $e"), backgroundColor: Colors.red));
    }
  }

  /// --- [هذه هي الدالة النهائية التي تستخدم /api/user] ---
  Future<void> _handleSave() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطأ: معرّف المستخدم غير موجود.")));
      return;
    }
    
    final bool vatChanged = _initialIncludesVat != includesVat;
    if (_newImageFiles.isEmpty && !vatChanged) {
      setState(() => isEditMode = false);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (vatChanged) dataToUpdate['vat_included'] = includesVat.toString();
      
      if (_newImageFiles.isNotEmpty) {
        for (var entry in _newImageFiles.entries) {
          final newUrl = await _imageUploadService.uploadImage(entry.value!);
          dataToUpdate[entry.key] = newUrl;
        }
      }
      
      // 1. إرسال طلب التحديث (الذي يرد ببيانات ناقصة)
      final result = await _officeService.updateUserProfile(
        userId: _userId!,
        data: dataToUpdate,
      );

      if (result['status'] == true && mounted) {
        // 2. عند النجاح، جلب البيانات الكاملة والمحدثة من /api/user
        debugPrint("Update successful. Now fetching fresh user data from /api/user...");
        final freshUserData = await _authService.fetchCurrentUser();

        // 3. حفظ البيانات الكاملة والجديدة في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(freshUserData));
        debugPrint("SharedPreferences updated successfully with fresh data.");
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ التعديلات بنجاح"), backgroundColor: Colors.green));
        
        // 4. إعادة تحميل الشاشة بالبيانات الجديدة
        setState(() {
          isEditMode = false;
          _newImageFiles.clear();
          // استدعاء _loadInitialData سيقرأ الآن البيانات المحدثة
          _loadInitialData();
        });
      }
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الحفظ: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0XFFF5F5F5),
        appBar: AppBar(
          title: const Text('مستندات المكتب', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2.5))))
            else
              IconButton(
                icon: Icon(isEditMode ? Icons.save : Icons.edit, color: Colors.orange),
                tooltip: isEditMode ? 'حفظ' : 'تعديل',
                onPressed: () {
                  if (isEditMode) {
                    _handleSave();
                  } else {
                    setState(() => isEditMode = true);
                  }
                },
              ),
          ],
        ),
        body: _isInitializing
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(title: 'شعار المكتب'),
                        const SizedBox(height: 12),
                        _buildImageRow('شعار المكتب (Logo)', logoKey),
                        const SizedBox(height: 24),
                        _SectionTitle(title: 'صور السجل التجاري'),
                        const SizedBox(height: 12),
                        _buildImageRow('صورة أمامية', crFrontKey),
                        const SizedBox(height: 12),
                        _buildImageRow('صورة خلفية', crBackKey),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImageRow(String label, String key) {
    final newFile = _newImageFiles[key];
    final existingUrl = _documentUrls[key];
    return Row(
      children: [
        Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: newFile != null
                ? Image.file(newFile, fit: BoxFit.cover)
                : (existingUrl != null && existingUrl.isNotEmpty
                    ? Image.network(
                        existingUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, p) => p == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorBuilder: (c, e, s) => Icon(Icons.broken_image_outlined, color: Colors.red.shade200, size: 40),
                      )
                    : Center(child: Icon(Icons.image_outlined, color: Colors.orange.shade200, size: 40))
                ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
        if (isEditMode)
          TextButton.icon(
            icon: const Icon(Icons.upload_file, color: Colors.orange),
            label: const Text('رفع/تغيير', style: TextStyle(color: Colors.orange)),
            onPressed: () => _pickImage(key),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}





// import 'dart:convert';
// import 'package.flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // في الخطوة التالية، سنحتاج لهذه الملفات
// // import 'dart:io';
// // import 'package:image_picker/image_picker.dart';

// class CarRentalEditDocuments extends StatefulWidget {
//   const CarRentalEditDocuments({super.key});

//   @override
//   State<CarRentalEditDocuments> createState() => _CarRentalEditDocumentsState();
// }

// class _CarRentalEditDocumentsState extends State<CarRentalEditDocuments> {
//   bool isEditMode = false;
//   bool _isInitializing = true;
//   bool _isLoading = false;

//   // سيتم ملء هذه الخريطة بالروابط الحقيقية من SharedPreferences
//   Map<String, String?> docs = {
//     'owner_id_front_image': null,
//     'owner_id_back_image': null,
//     'license_front_image': null, // اسم مقترح
//     'license_back_image': null,  // اسم مقترح
//     'commercial_register_front_image': null,
//     'commercial_register_back_image': null,
//     'vat_front_image': null,     // اسم مقترح
//     'vat_back_image': null,      // اسم مقترح
//   };
  
//   bool includesVat = true; // سيتم تحديث هذه القيمة أيضًا

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userJsonString = prefs.getString('user_data');

//       if (userJsonString == null) throw Exception("بيانات المستخدم غير موجودة.");

//       final userMap = jsonDecode(userJsonString);
//       final officeDetail = userMap['car_rental']?['office_detail'];
      
//       if (officeDetail == null) throw Exception("تفاصيل المكتب غير موجودة.");
      
//       // ملء الخريطة بالروابط الحقيقية من SharedPreferences
//       // الكود سيحاول قراءة كل المفاتيح، إذا لم يجد مفتاحًا، ستبقى قيمته null
//       setState(() {
//         docs['owner_id_front_image'] = officeDetail['owner_id_front_image'];
//         docs['owner_id_back_image'] = officeDetail['owner_id_back_image'];
//         docs['license_front_image'] = officeDetail['license_front_image'];
//         docs['license_back_image'] = officeDetail['license_back_image'];
//         docs['commercial_register_front_image'] = officeDetail['commercial_register_front_image'];
//         docs['commercial_register_back_image'] = officeDetail['commercial_register_back_image'];
//         docs['vat_front_image'] = officeDetail['vat_front_image'];
//         docs['vat_back_image'] = officeDetail['vat_back_image'];
        
//         includesVat = officeDetail['vat_included'] ?? true;
//       });

//     } catch(e) {
//       if(mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
//       }
//     } finally {
//       if(mounted) setState(() => _isInitializing = false);
//     }
//   }

//   // سنقوم بتفعيل هاتين الدالتين في الخطوة التالية
//   Future<void> _handleSave() async {}
//   Future<void> _pickImage(String key) async {}

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: const Color(0XFFF5F5F5),
//         appBar: AppBar(
//           title: const Text('مستندات المكتب', style: TextStyle(fontWeight: FontWeight.bold)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
//             onPressed: () => context.pop(),
//           ),
//           actions: [
//             if (_isLoading)
//               const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2.5))))
//             else
//               IconButton(
//                 icon: Icon(isEditMode ? Icons.save : Icons.edit, color: Colors.orange),
//                 tooltip: isEditMode ? 'حفظ' : 'تعديل',
//                 onPressed: () {
//                   if (isEditMode) {
//                     _handleSave();
//                   } else {
//                     setState(() => isEditMode = true);
//                   }
//                 },
//               ),
//           ],
//         ),
//         body: _isInitializing
//             ? const Center(child: CircularProgressIndicator(color: Colors.orange))
//             : Padding(
//                 padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _SectionTitle(title: 'صور هوية المالك'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة أمامية', 'owner_id_front_image'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة خلفية', 'owner_id_back_image'),
//                         const SizedBox(height: 24),
//                         _SectionTitle(title: 'صور رخصة القيادة'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة أمامية', 'license_front_image'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة خلفية', 'license_back_image'),
//                         const SizedBox(height: 24),
//                         _SectionTitle(title: 'صور السجل التجاري'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة أمامية', 'commercial_register_front_image'),
//                         const SizedBox(height: 12),
//                         _buildImageRow('صورة خلفية', 'commercial_register_back_image'),
//                         const SizedBox(height: 24),
//                         _SectionTitle(title: 'ضريبة القيمة المضافة'),
//                         const SizedBox(height: 12),
//                         _buildVatRow(context),
//                         if (includesVat) ...[
//                           const SizedBox(height: 24),
//                           _SectionTitle(title: 'صور ضريبة القيمة المضافة'),
//                           const SizedBox(height: 12),
//                           _buildImageRow('صورة أمامية', 'vat_front_image'),
//                           const SizedBox(height: 12),
//                           _buildImageRow('صورة خلفية', 'vat_back_image'),
//                         ],
//                         const SizedBox(height: 15),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildImageRow(String label, String key) {
//     final imagePath = docs[key];
//     return Row(
//       children: [
//         Container(
//           width: 110,
//           height: 80,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//             color: Colors.grey[100],
//           ),
//           child: (imagePath != null && imagePath.isNotEmpty)
//               ? ClipRRect(
//                   borderRadius: BorderRadius.circular(11),
//                   child: Image.network(
//                     imagePath, 
//                     fit: BoxFit.cover,
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return const Center(child: CircularProgressIndicator(strokeWidth: 2));
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.broken_image_outlined, color: Colors.red.shade200, size: 40);
//                     },
//                   ),
//                 )
//               : Center(child: Icon(Icons.image_outlined, color: Colors.orange.shade200, size: 40)),
//         ),
//         const SizedBox(width: 14),
//         Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
//         if (isEditMode)
//           TextButton.icon(
//             icon: const Icon(Icons.upload_file, color: Colors.orange),
//             label: const Text('رفع/تغيير', style: TextStyle(color: Colors.orange)),
//             onPressed: () => _pickImage(key),
//           ),
//       ],
//     );
//   }

//   Widget _buildVatRow(BuildContext context) {
//     if (!isEditMode) {
//       return Row(
//         children: [
//           Icon(includesVat ? Icons.check_circle : Icons.cancel, color: includesVat ? Colors.green : Colors.red),
//           const SizedBox(width: 10),
//           Text(includesVat ? 'نعم، يوجد ضريبة قيمة مضافة' : 'لا يوجد ضريبة قيمة مضافة', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
//         ],
//       );
//     } else {
//       return Row(
//         children: [
//           Expanded(
//             child: RadioListTile<bool>(
//               title: const Text('نعم'),
//               value: true,
//               groupValue: includesVat,
//               activeColor: Colors.orange,
//               onChanged: (val) => setState(() => includesVat = val!),
//             ),
//           ),
//           Expanded(
//             child: RadioListTile<bool>(
//               title: const Text('لا'),
//               value: false,
//               groupValue: includesVat,
//               activeColor: Colors.orange,
//               onChanged: (val) => setState(() => includesVat = val!),
//             ),
//           ),
//         ],
//       );
//     }
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
//     );
//   }
// }