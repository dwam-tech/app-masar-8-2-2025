// // مسار الملف: lib/screens/driver_car_info.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:saba2v2/components/UI/image_picker_row.dart';
// import 'package:saba2v2/components/UI/section_title.dart';
// import 'package:saba2v2/components/UI/radio_group.dart';
// import 'package:saba2v2/providers/auth_provider.dart';

// class DriverCarInfo extends StatefulWidget {
//   final Map<String, dynamic> personData;

//   const DriverCarInfo({
//     super.key,
//     required this.personData,
//   });

//   @override
//   State<DriverCarInfo> createState() => _DriverCarInfoState();
// }

// class _DriverCarInfoState extends State<DriverCarInfo> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   // Car Type
//   String? _carType = 'اقتصادي';

//   // Controllers
//   final _carModelController = TextEditingController();
//   final _colorController = TextEditingController();
//   final _plateNumberController = TextEditingController();

//   // Image Paths and URLs for all 6 images
//   String? _driverLicenseFrontPath, _driverLicenseBackPath, _carRegFrontPath, _carRegBackPath, _carFrontPath, _carBackPath;
//   String? _driverLicenseFrontUrl, _driverLicenseBackUrl, _carRegFrontUrl, _carRegBackUrl, _carFrontUrl, _carBackUrl;

//   static const String _baseUrl = 'http://192.168.1.8:8000';

//   @override
//   void dispose() {
//     _carModelController.dispose();
//     _colorController.dispose();
//     _plateNumberController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickFile(String fieldIdentifier) async {
//     if (_isLoading) return;

//     PermissionStatus status = await Permission.photos.request();
//     if (!status.isGranted && Platform.isAndroid) {
//       status = await Permission.storage.request();
//     }

//     if (!status.isGranted) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')));
//       }
//       return;
//     }

//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result == null || result.files.isEmpty) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم اختيار أي صورة')));
//       }
//       return;
//     }

//     final path = result.files.single.path;
//     if (path != null) {
//       setState(() {
//         switch (fieldIdentifier) {
//           case 'driver_license_front': _driverLicenseFrontPath = path; break;
//           case 'driver_license_back': _driverLicenseBackPath = path; break;
//           case 'car_registration_front': _carRegFrontPath = path; break;
//           case 'car_registration_back': _carRegBackPath = path; break;
//           case 'car_front': _carFrontPath = path; break;
//           case 'car_back': _carBackPath = path; break;
//         }
//       });

//       final url = await _uploadFile(path);
//       if (url != null) {
//         setState(() {
//           switch (fieldIdentifier) {
//             case 'driver_license_front': _driverLicenseFrontUrl = url; break;
//             case 'driver_license_back': _driverLicenseBackUrl = url; break;
//             case 'car_registration_front': _carRegFrontUrl = url; break;
//             case 'car_registration_back': _carRegBackUrl = url; break;
//             case 'car_front': _carFrontUrl = url; break;
//             case 'car_back': _carBackUrl = url; break;
//           }
//         });
//       }
//     }
//   }

//   Future<String?> _uploadFile(String filePath) async {
//     setState(() => _isLoading = true);
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
//       request.headers['Accept'] = 'application/json';
//       request.files.add(await http.MultipartFile.fromPath('files[]', filePath));
//       var response = await request.send().timeout(const Duration(seconds: 45));
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = await response.stream.bytesToString();
//         var jsonResponse = jsonDecode(responseData);
//         return jsonResponse['files'][0] as String;
//       } else {
//         throw Exception('فشل رفع الصورة');
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
//       }
//       return null;
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _removeFile(String fieldIdentifier) {
//     if (_isLoading) return;
//     setState(() {
//       switch (fieldIdentifier) {
//         case 'driver_license_front': _driverLicenseFrontPath = null; _driverLicenseFrontUrl = null; break;
//         case 'driver_license_back': _driverLicenseBackPath = null; _driverLicenseBackUrl = null; break;
//         case 'car_registration_front': _carRegFrontPath = null; _carRegFrontUrl = null; break;
//         case 'car_registration_back': _carRegBackPath = null; _carRegBackUrl = null; break;
//         case 'car_front': _carFrontPath = null; _carFrontUrl = null; break;
//         case 'car_back': _carBackPath = null; _carBackUrl = null; break;
//       }
//     });
//   }

//   Future<void> _onSubmit() async {
//     if (_isLoading) return;
//     if (!_formKey.currentState!.validate()) return;

//     if (_driverLicenseFrontUrl == null || _carRegFrontUrl == null || _driverLicenseBackUrl == null || _carRegBackUrl == null || _carFrontUrl == null || _carBackUrl == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء رفع كل الصور الستة المطلوبة')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       final result = await authProvider.registerDeliveryPerson(
//         // بيانات من widget.personData
//         fullName: widget.personData['fullName'],
//         email: widget.personData['email'],
//         password: widget.personData['password'],
//         phone: widget.personData['phone'],
//         governorate: widget.personData['governorate'], // تم التصحيح هنا
//         profileImageUrl: widget.personData['profileImageUrl'],
//         paymentMethods: widget.personData['paymentMethods'],
//         rentalTypes: widget.personData['rentalTypes'],
//         costPerKm: widget.personData['costPerKm'],
//         driverCost: widget.personData['driverCost'],
//         maxKmPerDay: widget.personData['maxKmPerDay'],
        
//         // بيانات من هذه الشاشة
//         carType: _carType!,
//         carModel: _carModelController.text.trim(),
//         carColor: _colorController.text.trim(), driverLicenseFrontImage: '', driverLicenseBackImage: '', carLicenseFrontImage: '', carLicenseBackImage: '', carImageFront: '', carImageBack: '', carPlateNumber: '',
        
//         // ملاحظة: الـ API يتوقع صورة واحدة لكل رخصة
//         // تأكدي من أن الـ Backend يتوقع هذه الأسماء
//         // driverLicenseImageUrl: _driverLicenseFrontUrl!,
//         // carLicenseImageUrl: _carRegFrontUrl!,
//         // // قد تحتاجين لإضافة الصور الأخرى إذا كان الـ Backend يتوقعها
//         // 'driver_license_back_image': _driverLicenseBackUrl!,
//         // 'car_license_back_image': _carRegBackUrl!,
//         // 'car_front_image': _carFrontUrl!,
//         // 'car_back_image': _carBackUrl!,
//       );

//       if (!mounted) return;

//       if (result['status'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل السائق بنجاح'), backgroundColor: Colors.green));
//         context.go('/RealStateHomeScreen');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'فشل التسجيل')));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ فادح: ${e.toString()}')));
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   String? _validateRequiredField(String? value, String fieldName) {
//     if (value == null || value.isEmpty) return '$fieldName مطلوب';
//     return null;
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String? Function(String?) validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         textAlign: TextAlign.right,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: label,
//           filled: true,
//           fillColor: Colors.grey[100],
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         ),
//         validator: validator,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تسجيل السيارة'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       backgroundColor: Colors.grey[50],
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Stack(
//           children: [
//             Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SectionTitle(title: 'صور رخصة القيادة سارية'),
//                       const SizedBox(height: 12),
//                       ImagePickerRow(label: 'صورة أمامية', icon: Icons.credit_card, fieldIdentifier: 'driver_license_front', onTap: () => _pickFile('driver_license_front'), imagePath: _driverLicenseFrontPath, onRemove: () => _removeFile('driver_license_front')),
//                       const SizedBox(height: 8),
//                       ImagePickerRow(label: 'صورة خلفية', icon: Icons.credit_card, fieldIdentifier: 'driver_license_back', onTap: () => _pickFile('driver_license_back'), imagePath: _driverLicenseBackPath, onRemove: () => _removeFile('driver_license_back')),
//                       const SizedBox(height: 20),
        
//                       const SectionTitle(title: 'صور رخصة السيارة سارية'),
//                       const SizedBox(height: 12),
//                       ImagePickerRow(label: 'صورة أمامية', icon: Icons.article, fieldIdentifier: 'car_registration_front', onTap: () => _pickFile('car_registration_front'), imagePath: _carRegFrontPath, onRemove: () => _removeFile('car_registration_front')),
//                       const SizedBox(height: 8),
//                       ImagePickerRow(label: 'صورة خلفية', icon: Icons.article, fieldIdentifier: 'car_registration_back', onTap: () => _pickFile('car_registration_back'), imagePath: _carRegBackPath, onRemove: () => _removeFile('car_registration_back')),
//                       const SizedBox(height: 20),
        
//                       const SectionTitle(title: 'صور أمامية وخلفية للسيارة'),
//                       const SizedBox(height: 12),
//                       ImagePickerRow(label: 'صورة أمامية', icon: Icons.camera_alt, fieldIdentifier: 'car_front', onTap: () => _pickFile('car_front'), imagePath: _carFrontPath, onRemove: () => _removeFile('car_front')),
//                       const SizedBox(height: 8),
//                       ImagePickerRow(label: 'صورة خلفية', icon: Icons.camera_alt, fieldIdentifier: 'car_back', onTap: () => _pickFile('car_back'), imagePath: _carBackPath, onRemove: () => _removeFile('car_back')),
                      
//                       const SizedBox(height: 16),
//                       RadioGroup(
//                         title: 'نوع السيارة',
//                         options: const {'اقتصادي': 'اقتصادي', 'مميز': 'مميز'},
//                         groupValue: _carType,
//                         onChanged: (value) => setState(() => _carType = value),
//                       ),
//                       const SizedBox(height: 20),
        
//                       const SectionTitle(title: 'معلومات السيارة'),
//                       const SizedBox(height: 12),
//                       _buildTextField(controller: _carModelController, label: 'موديل السيارة', validator: (value) => _validateRequiredField(value, 'موديل السيارة')),
//                       _buildTextField(controller: _colorController, label: 'لون السيارة', validator: (value) => _validateRequiredField(value, 'لون السيارة')),
//                       _buildTextField(controller: _plateNumberController, label: 'رقم اللوحة', validator: (value) => _validateRequiredField(value, 'رقم اللوحة')),
//                       const SizedBox(height: 24),
        
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: _isLoading ? null : _onSubmit,
//                           child: const Text('إرسال وإنشاء الحساب', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }