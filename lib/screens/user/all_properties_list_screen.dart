import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/public_properties_provider.dart';
import '../../widgets/public_property_card.dart';

class AllPropertiesListScreen extends StatefulWidget {
  const AllPropertiesListScreen({super.key});

  @override
  State<AllPropertiesListScreen> createState() => _AllPropertiesListScreenState();
}

class _AllPropertiesListScreenState extends State<AllPropertiesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // جلب العقارات عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicPropertiesProvider>().fetchPublicProperties();
    });
    
    // إضافة مستمع للتمرير لتحميل المزيد
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<PublicPropertiesProvider>();
      if (!provider.isLoading && provider.hasMoreData) {
        debugPrint('📄 تحميل المزيد من العقارات...');
        provider.fetchPublicProperties(loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'جميع العقارات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFFFC8700),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                // إضافة وظيفة الفلترة لاحقاً
              },
            ),
          ],
        ),
        body: Consumer<PublicPropertiesProvider>(
          builder: (context, provider, child) {
            debugPrint('🏠 عدد العقارات المحملة: ${provider.publicProperties.length}');
            
            if (provider.isLoading && provider.publicProperties.isEmpty) {
              return _buildLoadingState();
            }

            if (provider.error != null && provider.publicProperties.isEmpty) {
              return _buildErrorState(provider.error!);
            }

            if (provider.publicProperties.isEmpty) {
              return _buildEmptyState();
            }

            return _buildPropertiesList(provider);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8700)),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'جاري تحميل العقارات...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ في تحميل العقارات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<PublicPropertiesProvider>().refreshPublicProperties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC8700),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد عقارات متاحة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لم يتم العثور على أي عقارات في الوقت الحالي\nجرب المحاولة مرة أخرى',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<PublicPropertiesProvider>().refreshPublicProperties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC8700),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'تحديث',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList(PublicPropertiesProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshPublicProperties();
      },
      color: const Color(0xFFFC8700),
      child: Column(
        children: [
          // شريط المعلومات
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تم العثور على ${provider.publicProperties.length} عقار',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (provider.hasMoreData)
                  Text(
                    'المزيد متاح',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          // قائمة العقارات
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.publicProperties.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // إذا كان العنصر الأخير وهناك تحميل جاري
                if (index == provider.publicProperties.length && provider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8700)),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'جاري تحميل المزيد...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // عرض كارت العقار
                final property = provider.publicProperties[index];
                
                // إضافة تسجيل للتشخيص
                debugPrint('🏠 عرض العقار ${index + 1}: ${property.address} - ${property.type}');
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: PublicPropertyCard(
                    property: property,
                    onTap: () {
                      debugPrint('🏠 الانتقال إلى تفاصيل العقار: ${property.id}');
                      context.push('/property-details/${property.id}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}