import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/public_properties_provider.dart';
import 'package:saba2v2/models/featured_property.dart';
import 'package:saba2v2/widgets/real_estate_card.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  List<String> _availableFilters = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // استدعاء البيانات عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicPropertiesProvider>().fetchPublicProperties().then((_) {
        if (mounted) {
          _updateFilters();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    final provider = context.read<PublicPropertiesProvider>();
    if (provider.publicProperties.isEmpty) return; // تحقق أمني
    
    Set<String> types = {};
    Set<String> areas = {};

    for (var property in provider.publicProperties) {
      // إضافة أنواع العقارات
      types.add(property.type);
      
      // إضافة المناطق
      areas.add(property.area);
    }
    
    setState(() {
      _availableFilters = [
        ...types.map((e) => 'نوع: $e'),
        ...areas.map((e) => 'منطقة: $e'),
      ].toList()..sort();
    });
  }

  List<FeaturedProperty> _getFilteredResults(PublicPropertiesProvider provider) {
    var results = provider.publicProperties;
    
    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      results = results.where((property) {
        final description = property.description.toLowerCase();
        final type = property.type.toLowerCase();
        final area = property.area.toLowerCase();
        final address = property.address.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return description.contains(query) ||
               type.contains(query) ||
               area.contains(query) ||
               address.contains(query);
      }).toList();
    }

    // فلترة حسب الفلاتر المحددة
    if (_selectedFilters.isNotEmpty) {
      results = results.where((property) {
        final type = property.type;
        final area = property.area;
        
        return _selectedFilters.any((filter) {
          if (filter.startsWith('نوع: ')) {
            final filterType = filter.substring(5);
            return type == filterType;
          } else if (filter.startsWith('منطقة: ')) {
            final filterArea = filter.substring(7);
            return area == filterArea;
          }
          return false;
        });
      }).toList();
    }
    
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicPropertiesProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              title: const Text(
                'البحث في العقارات',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
            ),
            body: Column(
              children: [
                // شريط البحث
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عقار...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ),
                
                // الفلاتر
                if (_availableFilters.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الفلاتر:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_selectedFilters.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedFilters.clear());
                                },
                                child: const Text(
                                  'مسح الكل',
                                  style: TextStyle(color: Color(0xFF10B981)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableFilters.map((filter) {
                            final isSelected = _selectedFilters.contains(filter);
                            return FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedFilters.add(filter);
                                  } else {
                                    _selectedFilters.remove(filter);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF10B981),
                              backgroundColor: Colors.grey[100],
                              side: BorderSide(
                                color: isSelected 
                                    ? const Color(0xFF10B981) 
                                    : Colors.grey[300]!,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                
                // النتائج
                Expanded(
                  child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                      )
                    : _buildResults(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults(PublicPropertiesProvider provider) {
    final results = _getFilteredResults(provider);
    
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'جرب تغيير كلمات البحث أو الفلاتر',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final property = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RealEstateCard(
            imageUrl: property.imageUrl,
            title: property.type,
            price: property.price,
            rating: 4.5,
            onTap: () {
              context.push('/property-details/${property.id}');
            },
          ),
        );
      },
    );
  }
}