// import 'package:flutter/material.dart';
// import 'package:saba2v2/models/car_model.dart';

// class CarDetailsScreen extends StatelessWidget {
//   final Car car;

//   const CarDetailsScreen({Key? key, required this.car}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('تفاصيل ${car.carType} ${car.carModel}'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- عرض البيانات النصية ---
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildDetailRow(Icons.directions_car, "النوع", car.carType),
//                     _buildDetailRow(Icons.category, "الموديل", car.carModel),
//                     _buildDetailRow(Icons.color_lens, "اللون", car.carColor),
//                     _buildDetailRow(Icons.pin, "رقم اللوحة", car.carPlateNumber),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
//             const Text("الصور والأوراق المرفقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const Divider(),
//             const SizedBox(height: 12),

//             // --- عرض جميع الصور الـ 6 ---
//             GridView.count(
//               crossAxisCount: 2, // عرض صورتين في كل صف
//               shrinkWrap: true, // لمنع الخطأ داخل SingleChildScrollView
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 4 / 3, // نسبة العرض إلى الارتفاع
//               children: [
//                 _buildImageTile("صورة السيارة (أمام)", car.carImageFront),
//                 _buildImageTile("صورة السيارة (خلف)", car.carImageBack),
//                 _buildImageTile("صورة الرخصة (وجه)", car.licenseFrontImage),
//                 _buildImageTile("صورة الرخصة (خلف)", car.licenseBackImage),
//                 _buildImageTile("استمارة السيارة (وجه)", car.carLicenseFront),
//                 _buildImageTile("استمارة السيارة (خلف)", car.carLicenseBack),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ويدجت مساعدة لعرض صف تفاصيل
//   Widget _buildDetailRow(IconData icon, String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey[600]),
//           const SizedBox(width: 16),
//           Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const Spacer(),
//           Text(value, style: const TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }
  
//   // ويدجت مساعدة لعرض مربع الصورة
//   Widget _buildImageTile(String title, String imageUrl) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
//         const SizedBox(height: 4),
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(7),
//               child: Image.network(
//                 imageUrl,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }