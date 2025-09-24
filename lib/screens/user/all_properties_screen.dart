// lib/screens/user/all_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/public_properties_provider.dart';
import '../../widgets/featured_property_card.dart';
import '../../models/featured_property.dart';

class AllPropertiesScreen extends StatefulWidget {
  const AllPropertiesScreen({super.key});

  @override
  State<AllPropertiesScreen> createState() => _AllPropertiesScreenState();
}

class _AllPropertiesScreenState extends State<AllPropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedFilter = 'الكل';
  final List<String> _filterOptions = ['الكل', 'شقة', 'فيلا', 'محل تجاري'];
  List<FeaturedProperty> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    
    // تحميل العقارات عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PublicPropertiesProvider>(context, listen: false);
      provider.fetchPublicProperties().then((_) {
        _applyFilters();
      });
    });
    
    // إضافة مستمع للتمرير لتحميل المزيد
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<PublicPropertiesProvider>();
      if (provider.hasMoreData && !provider.isLoading) {
        provider.fetchPublicProperties(loadMore: true).then((_) => _applyFilters());
      }
    }
  }

  void _applyFilters() {
    final provider = context.read<PublicPropertiesProvider>();
    List<FeaturedProperty> properties = provider.publicProperties;

    // تطبيق البحث النصي
    if (_searchController.text.isNotEmpty) {
      // استخدام البحث الجديد من خلال API
      final provider = context.read<PublicPropertiesProvider>();
      provider.searchProperties(search: _searchController.text);
      properties = provider.searchResults;
    }

    // تطبيق الفلتر المحدد
    switch (_selectedFilter) {
      case 'الكل':
        // عرض جميع العقارات بدون فلترة
        break;
      default:
        properties = properties.where((p) => 
            p.type.toLowerCase().contains(_selectedFilter.toLowerCase())).toList();
    }

    setState(() {
      _filteredProperties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'جميع العقارات',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ),
        body: Consumer<PublicPropertiesProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // شريط البحث والفلاتر
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // شريط البحث
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن عقار...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => _applyFilters(),
                      ),
                      const SizedBox(height: 12),
                      
                      // فلاتر النوع
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filterOptions.length,
                          itemBuilder: (context, index) {
                            final filter = _filterOptions[index];
                            final isSelected = _selectedFilter == filter;
                            
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                  _applyFilters();
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: const Color(0xFFFC8700).withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? const Color(0xFFFC8700) 
                                      : Colors.grey[700],
                                  fontWeight: isSelected 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected 
                                      ? const Color(0xFFFC8700) 
                                      : Colors.grey[300]!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // عداد النتائج
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[50],
                  child: Text(
                    'تم العثور على ${_filteredProperties.length} عقار',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                
                // قائمة العقارات
                Expanded(
                  child: _buildPropertiesList(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPropertiesList(PublicPropertiesProvider provider) {
    if (provider.isLoading && provider.publicProperties.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFC8700),
        ),
      );
    }

    if (provider.error != null && provider.publicProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل العقارات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'حدث خطأ غير معروف',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refreshPublicProperties().then((_) => _applyFilters()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC8700),
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عقارات تطابق البحث',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب تغيير معايير البحث أو الفلاتر',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshPublicProperties();
        _applyFilters();
      },
      color: const Color(0xFFFC8700),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final property = _filteredProperties[index];
                  return FeaturedPropertyCard(
                    property: property,
                    onTap: () {
                      // الانتقال إلى صفحة تفاصيل العقار
                      context.push('/property-details/${property.id}');
                    },
                  );
                },
                childCount: _filteredProperties.length,
              ),
            ),
          ),
          if (provider.hasMoreData)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFC8700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}