// lib/widgets/featured_properties_row.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/featured_properties_provider.dart';
import '../widgets/featured_property_card.dart';

class FeaturedPropertiesRow extends StatefulWidget {
  const FeaturedPropertiesRow({Key? key}) : super(key: key);

  @override
  State<FeaturedPropertiesRow> createState() => _FeaturedPropertiesRowState();
}

class _FeaturedPropertiesRowState extends State<FeaturedPropertiesRow> {
  @override
  void initState() {
    super.initState();
    // جلب العقارات المميزة عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturedPropertiesProvider>().fetchFeaturedProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeaturedPropertiesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.featuredProperties.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.hasError && provider.featuredProperties.isEmpty) {
          return _buildErrorState(provider.errorMessage);
        }

        if (provider.featuredProperties.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPropertiesList(provider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3, // عرض 3 كاردات تحميل
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            height: 240,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // منطقة الصورة
                Container(
                  width: 200,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFC8700),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                // منطقة المعلومات
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 12),
            Text(
              'خطأ في تحميل العقارات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FeaturedPropertiesProvider>().fetchFeaturedProperties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد عقارات مميزة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة عقارات مميزة قريباً',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList(FeaturedPropertiesProvider provider) {
    // عرض أول 6 عقارات فقط في الصفحة الرئيسية
    final displayProperties = provider.getTopFeaturedProperties(limit: 6);

    return Container(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayProperties.length,
        itemBuilder: (context, index) {
          final property = displayProperties[index];
          return FeaturedPropertyCard(
            property: property,
            isHorizontalLayout: true,
            onTap: () {
              // الانتقال إلى صفحة تفاصيل العقار
              context.push('/propertyDetails/${property.id}');
            },
          );
        },
      ),
    );
  }
}