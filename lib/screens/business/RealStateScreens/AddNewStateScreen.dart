import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/custom_text_field.dart';
import 'package:saba2v2/components/UI/radio_group.dart' as custom;
import 'package:saba2v2/components/UI/action_row.dart';
import 'package:saba2v2/components/UI/custom_dropdown_field.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/components/UI/feature_row.dart';

enum PropertyType { villa, office, apartment }
enum PropertyStatus { forSale, forRent, sold }
enum FinishingStatus { newFinish, lux, superLux }

class AddNewStateScreen extends StatefulWidget {
  const AddNewStateScreen({super.key});

  @override
  State<AddNewStateScreen> createState() => _AddNewStateScreenState();
}

class _AddNewStateScreenState extends State<AddNewStateScreen> {
  PropertyType? _selectedPropertyType;
  PropertyStatus? _selectedPropertyStatus;
  FinishingStatus? _selectedFinishingStatus;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'كاش',
    'تقسيط',
    'تمويل عقاري',
    'أخرى'
  ];

  Future<void> _pickImage(String fieldIdentifier) async {
    print('طلب اختيار صورة لـ: $fieldIdentifier');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سيتم إضافة وظيفة اختيار الصور لـ $fieldIdentifier')));
  }

  Future<void> _pickLocation() async {
    print('طلب اختيار الموقع من جوجل ماب');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم إضافة وظيفة اختيار الموقع قريباً')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العقار'),
        
        actions: [
          TextButton(
            onPressed: () => context.go('/RealStateHomeScreen'),
            child: const Text('تخطي', style: TextStyle(color: Colors.orange)),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomTextField(hintText:'عنوان العقار'),
            const SizedBox(height: 12),
            const CustomTextField(hintText: 'رقم الوحدة', isNumeric: true),
            const Divider(height: 32, thickness: 1),

            custom.RadioGroup<PropertyType>(
              title: 'قم بتحديد نوع العقار',
              options: const {
                PropertyType.villa: 'فيلا',
                PropertyType.office: 'مكتب اداري',
                PropertyType.apartment: 'شقة',
              },
              groupValue: _selectedPropertyType,
              onChanged: (value) => setState(() => _selectedPropertyType = value),
            ),
            const Divider(height: 32, thickness: 1),

            custom.RadioGroup<PropertyStatus>(
              title: 'حالة العقار',
              options: const {
                PropertyStatus.forSale: 'جاهز للبيع',
                PropertyStatus.forRent: 'جاهز للإيجار',

              },
              groupValue: _selectedPropertyStatus,
              onChanged: (value) => setState(() => _selectedPropertyStatus = value),
            ),
            const Divider(height: 32, thickness: 1),

            custom.RadioGroup<FinishingStatus>(
              title: 'حالة التشطيب',
              options: const {
                FinishingStatus.newFinish: 'جديد',
                FinishingStatus.lux: 'لوكس',
                FinishingStatus.superLux: 'سوبر لوكس',
              },
              groupValue: _selectedFinishingStatus,
              onChanged: (value) => setState(() => _selectedFinishingStatus = value),
            ),
            const Divider(height: 32, thickness: 1),

            const SectionTitle(title: 'مميزات العقار'),
            FeatureRow(
              label: 'سنة البناء',
              onTap: () => print('فتح محرر لـ: سنة البناء'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'الدور',
              onTap: () => print('فتح محرر لـ: الدور'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'تطل على',
              onTap: () => print('فتح محرر لـ: تطل على'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'عدد الغرف',
              onTap: () => print('فتح محرر لـ: عدد الغرف'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'عدد الحمامات',
              onTap: () => print('فتح محرر لـ: عدد الحمامات'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'طول العقار',
              onTap: () => print('فتح محرر لـ: طول العقار'),
            ),
            const SizedBox(height: 12),
            FeatureRow(
              label: 'عرض العقار',
              onTap: () => print('فتح محرر لـ: عرض العقار'),
            ),
            const Divider(height: 32, thickness: 1),

            const SectionTitle(title: 'سعر العقار / مُقدم / م٢'),
            const CustomTextField(hintText: 'سعر العقار', isNumeric: true),
            const SizedBox(height: 12),
            const CustomTextField(hintText: 'المُقدم', isNumeric: true),
            const SizedBox(height: 12),
            const CustomTextField(hintText: 'سعر م٢', isNumeric: true),
            const SizedBox(height: 12),
            CustomDropdownField(
              hint: 'اختيار طريقة الدفع',
              items: _paymentMethods,
              value: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value),
            ),
            const Divider(height: 32, thickness: 1),

            const SectionTitle(title: 'وصف العقار وصوره'),
            ActionRow(
              label: 'ارفاق صور العروض الرئيسية',
              icon: Icons.image_outlined,
              onTap: () => _pickImage('mainImages'),
            ),
            const SizedBox(height: 12),
            ActionRow(
              label: 'ارفاق الصورة البارزة',
              icon: Icons.image_outlined,
              onTap: () => _pickImage('featuredImage'),
            ),
            const SizedBox(height: 12),
            ActionRow(
              label: 'ارفاق الصور الداخلية',
              icon: Icons.image_outlined,
              onTap: () => _pickImage('internalImages'),
            ),
            const SizedBox(height: 12),
            const CustomTextField(
              hintText: 'وصف العقار بشكل مفصل',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ActionRow(
              label: 'أضف موقع العقار علي جوجل ماب',
              icon: Icons.location_on_outlined,
              onTap: _pickLocation,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('جاري إضافة العقار...')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
              ),
              child: const Text(
                'إضافة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}