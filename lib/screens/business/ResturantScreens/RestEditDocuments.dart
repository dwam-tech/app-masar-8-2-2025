// lib/screens/rest_edit_documents.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saba2v2/providers/restaurant_profile_provider.dart'; // تأكد من أن المسار صحيح

class Resteditdocuments extends StatefulWidget {
  const Resteditdocuments({super.key});
  @override
  State<Resteditdocuments> createState() => _ResteditdocumentsState();
}

class _ResteditdocumentsState extends State<Resteditdocuments> {
  bool isEditMode = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // جلب البيانات الأولية عند تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProfileProvider>(context, listen: false).fetchDetails();
    });
  }

  /// دالة لاختيار صورة من المعرض ورفعها باستخدام الـ Provider
  Future<void> _pickAndUploadImage(String fieldKey) async {
    final provider = context.read<RestaurantProfileProvider>();
    // اختيار الصورة مع تحديد جودة لتقليل الحجم
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      // استدعاء دالة الرفع في الـ Provider
      await provider.uploadDocument(fieldKey, File(image.path));
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!), backgroundColor: Colors.red));
      }
    }
  }

  /// دالة لحفظ كل التغييرات (بما في ذلك حالة VAT والصور التي تم رفعها)
  Future<void> _saveAllChanges() async {
    final provider = context.read<RestaurantProfileProvider>();
    final success = await provider.saveChanges();
    
    if (mounted) {
      if(success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
        setState(() => isEditMode = false); // الخروج من وضع التعديل عند النجاح
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'فشل الحفظ'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer للاستماع للتغييرات في الـ Provider وإعادة بناء الواجهة
    return Consumer<RestaurantProfileProvider>(
      builder: (context, provider, child) {
        
        final details = provider.restaurantData?['restaurant_detail'];
        
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
                onPressed: () => context.pop() // استخدام context.pop() مع GoRouter
              ),
              actions: [
                if (provider.isLoading) const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 3)))
                ),
                if (!provider.isLoading) IconButton(
                  icon: Icon(isEditMode ? Icons.save : Icons.edit, color: Colors.orange),
                  tooltip: isEditMode ? 'حفظ' : 'تعديل',
                  onPressed: () {
                    if (isEditMode) {
                      _saveAllChanges();
                    } else {
                      setState(() => isEditMode = true);
                    }
                  },
                ),
              ],
            ),
            // عرض شاشة تحميل أولية أو شاشة خطأ
            body: provider.isLoading && provider.restaurantData == null
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : provider.error != null && provider.restaurantData == null
                ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("حدث خطأ: ${provider.error!}")))
                // عرض الواجهة الرئيسية بعد تحميل البيانات بنجاح
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(title: 'صور هوية المالك'),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة أمامية', 'owner_id_front_image', details),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة خلفية', 'owner_id_back_image', details),
                            
                            const SizedBox(height: 24),
                            _SectionTitle(title: 'صور رخصة المطعم'),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة أمامية', 'license_front_image', details),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة خلفية', 'license_back_image', details),
                            
                            const SizedBox(height: 24),
                            _SectionTitle(title: 'صور السجل التجاري'),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة أمامية', 'commercial_register_front_image', details),
                            const SizedBox(height: 12),
                            _buildImageRow('صورة خلفية', 'commercial_register_back_image', details),
                            
                            const SizedBox(height: 24),
                            _SectionTitle(title: 'ضريبة القيمة المضافة'),
                            const SizedBox(height: 12),
                            _buildVatRow(context, details, provider),
                            
                            if (details?['vat_included'] == 1 || details?['vat_included'] == true) ...[
                              const SizedBox(height: 24),
                              _SectionTitle(title: 'صور ضريبة القيمة المضافة'),
                              const SizedBox(height: 12),
                              _buildImageRow('صورة أمامية', 'vat_image_front', details),
                              const SizedBox(height: 12),
                              _buildImageRow('صورة خلفية', 'vat_image_back', details),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  // --- Widgets (مكتملة ومصححة) ---
  
  Widget _buildImageRow(String label, String apiKey, Map<String, dynamic>? details) {
    final imagePath = details?[apiKey];
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
          clipBehavior: Clip.antiAlias, // لضمان أن الصورة لا تتجاوز الحدود الدائرية
          child: (imagePath != null && imagePath.isNotEmpty)
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.orange)),
                errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.error_outline, color: Colors.red.shade200, size: 40)),
              )
            : Center(child: Icon(Icons.image_outlined, color: Colors.orange.shade200, size: 40)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
        if (isEditMode)
          TextButton.icon(
            icon: const Icon(Icons.upload_file, color: Colors.orange),
            label: const Text('رفع/تغيير', style: TextStyle(color: Colors.orange)),
            onPressed: () => _pickAndUploadImage(apiKey),
          ),
      ],
    );
  }

  Widget _buildVatRow(BuildContext context, Map<String, dynamic>? details, RestaurantProfileProvider provider) {
    // قراءة القيمة الحالية من الـ Provider. الـ API يعيد 1 أو 0
    bool includesVat = (details?['vat_included'] == 1 || details?['vat_included'] == true);

    if (!isEditMode) {
      return Row(
        children: [
          Icon(includesVat ? Icons.check_circle : Icons.cancel, color: includesVat ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Text(includesVat ? 'نعم، الأسعار تشمل الضريبة' : 'لا، الأسعار لا تشمل الضريبة', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: RadioListTile<bool>(
            title: const Text('تشمل الضريبة'),
            value: true,
            groupValue: includesVat,
            activeColor: Colors.orange,
            onChanged: (val) {
              if (val != null) {
                // تحديث الحالة في الـ Provider مباشرة
                provider.restaurantData?['restaurant_detail']?['vat_included'] = val ? 1 : 0; // إرسال 1 أو 0 للـ API
                provider.notifyListeners(); // إعادة بناء الواجهة لعكس التغيير
              }
            },
          )),
          Expanded(child: RadioListTile<bool>(
            title: const Text('لا تشمل الضريبة'),
            value: false,
            groupValue: includesVat,
            activeColor: Colors.orange,
            onChanged: (val) {
               if (val != null) {
                provider.restaurantData?['restaurant_detail']?['vat_included'] = val ? 1 : 0;
                provider.notifyListeners();
              }
            },
          )),
        ],
      );
    }
  }
}

/// Widget منفصل لعرض العناوين بشكل نظيف
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