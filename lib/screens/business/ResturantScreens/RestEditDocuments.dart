import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Resteditdocuments extends StatefulWidget {
  const Resteditdocuments({super.key});

  @override
  State<Resteditdocuments> createState() => _ResteditdocumentsState();
}

class _ResteditdocumentsState extends State<Resteditdocuments> {
  bool isEditMode = false;

  // بيانات وهمية placeholder (تبدلها ببياناتك عند الربط مع backend)
  Map<String, String?> docs = {
    'ownerIdFront': null,
    'ownerIdBack': null,
    'restaurantLicenseFront': null,
    'restaurantLicenseBack': null,
    'crPhotoFront': null,
    'crPhotoBack': null,
    'vatPhotoFront': null,
    'vatPhotoBack': null,
  };
  bool includesVat = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0XFFF5F5F5),
        appBar: AppBar(
          title: const Text('مستندات المطعم', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
            onPressed: () => context.go("/RestaurantEditProfile"),
          ),
          actions: [
            IconButton(
              icon: Icon(isEditMode ? Icons.save : Icons.edit, color: Colors.orange),
              tooltip: isEditMode ? 'حفظ' : 'تعديل',
              onPressed: () {
                setState(() {
                  // لو في وضع التعديل وخلصت: ممكن هنا تضيف كود الحفظ الفعلي
                  isEditMode = !isEditMode;
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'صور هوية المالك'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة أمامية', 'ownerIdFront'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة خلفية', 'ownerIdBack'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'صور رخصة المطعم'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة أمامية', 'restaurantLicenseFront'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة خلفية', 'restaurantLicenseBack'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'صور السجل التجاري'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة أمامية', 'crPhotoFront'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة خلفية', 'crPhotoBack'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'ضريبة القيمة المضافة'),
                  const SizedBox(height: 12),
                  _buildVatRow(context),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'صور ضريبة القيمة المضافة'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة أمامية', 'vatPhotoFront'),
                  const SizedBox(height: 12),
                  _buildImageRow('صورة خلفية', 'vatPhotoBack'),
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
    final placeholderImage = 'https://via.placeholder.com/110x80.png?text=Image';
    final imagePath = docs[key];
    return Row(
      children: [
        Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey[100],
            image: imagePath != null
                ? DecorationImage(
                image: NetworkImage(imagePath), fit: BoxFit.cover)
                : null,
          ),
          child: imagePath == null
              ? Center(
            child: Icon(Icons.image_outlined,
                color: Colors.orange.shade200, size: 40),
          )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        if (isEditMode)
          TextButton.icon(
            icon: const Icon(Icons.upload_file, color: Colors.orange),
            label: const Text('رفع/تغيير',
                style: TextStyle(color: Colors.orange)),
            onPressed: () {
              // هنا هتضيف كود رفع الصورة الفعلي لاحقاً
              setState(() {
                docs[key] = placeholderImage; // بس عشان توضيح التجربة
              });
            },
          ),
      ],
    );
  }

  Widget _buildVatRow(BuildContext context) {
    if (!isEditMode) {
      return Row(
        children: [
          Icon(
            includesVat ? Icons.check_circle : Icons.cancel,
            color: includesVat ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            includesVat
                ? 'نعم، الأسعار تشمل الضريبة'
                : 'لا، الأسعار لا تشمل الضريبة',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: RadioListTile<bool>(
              title: const Text('تشمل الضريبة'),
              value: true,
              groupValue: includesVat,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => includesVat = val!),
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              title: const Text('لا تشمل الضريبة'),
              value: false,
              groupValue: includesVat,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => includesVat = val!),
            ),
          ),
        ],
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
