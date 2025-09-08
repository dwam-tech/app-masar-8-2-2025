import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/widgets/restaurant_api_card.dart';
import 'package:saba2v2/screens/user/restaurant-details.dart';

class RestaurantSearchScreen extends StatefulWidget {
  const RestaurantSearchScreen({super.key});

  @override
  State<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen> {
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  List<String> _availableFilters = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRestaurants() {
    setState(() => _isLoading = true);
    context.read<RestaurantProvider>().fetchAllRestaurants().then((_) {
      _updateFilters();
      setState(() => _isLoading = false);
    });
  }

  void _updateFilters() {
    final provider = context.read<RestaurantProvider>();
    Set<String> cuisineTypes = {};
    Set<String> governorates = {};
    
    for (var restaurant in provider.allRestaurants) {
      final detail = restaurant['restaurant_detail'];
      if (detail != null) {
        // إضافة أنواع المطابخ
        final cuisines = detail['cuisine_types'] as List?;
        if (cuisines != null) {
          for (var cuisine in cuisines) {
            cuisineTypes.add(cuisine.toString());
          }
        }
      }
      
      // إضافة المحافظات
      final governorate = restaurant['governorate'];
      if (governorate != null) {
        governorates.add(governorate.toString());
      }
    }
    
    setState(() {
      _availableFilters = [
        ...cuisineTypes.map((e) => 'مطبخ: $e'),
        ...governorates.map((e) => 'محافظة: $e'),
      ]..sort();
    });
  }

  List<Map<String, dynamic>> _getFilteredResults() {
    final provider = context.read<RestaurantProvider>();
    var results = provider.allRestaurants;
    
    // تطبيق البحث النصي
    if (_searchQuery.isNotEmpty) {
      results = results.where((restaurant) {
        final detail = restaurant['restaurant_detail'];
        final name = detail?['restaurant_name']?.toString().toLowerCase() ?? '';
        final cuisines = detail?['cuisine_types']?.join(' ').toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || cuisines.contains(query);
      }).toList();
    }
    
    // تطبيق الفلاتر
    if (_selectedFilters.isNotEmpty) {
      results = results.where((restaurant) {
        final detail = restaurant['restaurant_detail'];
        final cuisines = detail?['cuisine_types'] ?? [];
        final governorate = restaurant['governorate']?.toString() ?? '';
        
        return _selectedFilters.any((filter) {
          if (filter.startsWith('مطبخ: ')) {
            final cuisineType = filter.substring(5);
            return cuisines.contains(cuisineType);
          } else if (filter.startsWith('محافظة: ')) {
            final gov = filter.substring(8);
            return governorate == gov;
          }
          return false;
        });
      }).toList();
    }
    
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'البحث في المطاعم',
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
                  hintText: 'ابحث عن مطعم أو نوع مطبخ...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFC8700)),
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
                    borderSide: const BorderSide(color: Color(0xFFFC8700)),
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
                              style: TextStyle(color: Color(0xFFFC8700)),
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
                          selectedColor: const Color(0xFFFC8700).withOpacity(0.2),
                          checkmarkColor: const Color(0xFFFC8700),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide(
                            color: isSelected 
                                ? const Color(0xFFFC8700) 
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
              child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFC8700),
                    ),
                  )
                : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final results = _getFilteredResults();
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty && _selectedFilters.isEmpty
                  ? 'لا توجد مطاعم متاحة'
                  : 'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_searchQuery.isNotEmpty || _selectedFilters.isNotEmpty)
              Text(
                'جرب تغيير كلمات البحث أو الفلاتر',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
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
        final restaurant = results[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RestaurantApiCard(
            restaurant: restaurant,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailsScreen(
                    restaurantId: restaurant['id'].toString(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}