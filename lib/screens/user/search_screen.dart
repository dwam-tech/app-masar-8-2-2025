import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/public_properties_provider.dart';
import '../../widgets/restaurant_api_card.dart';
import '../../widgets/featured_property_card.dart';
import '../../models/featured_property.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedCategory = 'restaurants'; // 'restaurants' or 'properties'
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  List<String> _availableFilters = [];
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    if (_selectedCategory == 'restaurants') {
      _loadRestaurantData();
    } else {
      _loadPropertyData();
    }
  }

  void _loadRestaurantData() {
    context.read<RestaurantProvider>().fetchAllRestaurants().then((_) {
      _loadRestaurantFilters();
      setState(() => _isLoading = false);
    });
  }

  void _loadPropertyData() {
    context.read<PublicPropertiesProvider>().fetchPublicProperties().then((_) {
      _loadPropertyFilters();
      setState(() => _isLoading = false);
    });
  }
  
  void _loadFilters() {
    if (_selectedCategory == 'restaurants') {
      _loadRestaurantFilters();
    } else {
      _loadPropertyFilters();
    }
  }

  void _loadRestaurantFilters() {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    Set<String> cuisines = {};
    Set<String> cities = {};
    
    for (var restaurant in provider.allRestaurants) {
      final restaurantDetail = restaurant['restaurant_detail'] ?? {};
      final cuisineTypes = restaurantDetail['cuisine_types'] ?? [];
      for (var cuisine in cuisineTypes) {
        cuisines.add(cuisine);
      }
      
      final city = restaurant['governorate'] ?? '';
      if (city.isNotEmpty) {
        cities.add(city);
      }
    }
    
    setState(() {
      _availableFilters = [...cuisines.toList(), ...cities.toList()]..sort();
    });
  }
  
  void _loadPropertyFilters() {
    final provider = Provider.of<PublicPropertiesProvider>(context, listen: false);
    Set<String> types = {};
    Set<String> areas = {};
    
    for (var property in provider.publicProperties) {
      if (property.type.isNotEmpty) {
        types.add(property.type);
      }
      // استخراج المدينة من العنوان
      final addressParts = property.address.split(',');
      if (addressParts.isNotEmpty) {
        areas.add(addressParts.last.trim());
      }
    }
    
    setState(() {
      _availableFilters = [...types, ...areas].toList();
      _availableFilters.sort(); // ترتيب أبجدي
    });
  }
  
  void _updateCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _selectedFilters.clear();
      _isLoading = true;
    });
    
    if (category == 'restaurants') {
      await Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
    } else {
      await Provider.of<PublicPropertiesProvider>(context, listen: false).fetchPublicProperties();
    }
    
    _loadFilters();
    
    setState(() {
      _isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'البحث والاستكشاف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Selection
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _updateCategory('restaurants'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedCategory == 'restaurants' 
                              ? Color(0xFFFC8700) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: _selectedCategory == 'restaurants' 
                                  ? Colors.white 
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'المطاعم',
                              style: TextStyle(
                                color: _selectedCategory == 'restaurants' 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _updateCategory('properties'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedCategory == 'properties' 
                              ? Color(0xFFFC8700) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: _selectedCategory == 'properties' 
                                  ? Colors.white 
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'العقارات',
                              style: TextStyle(
                                color: _selectedCategory == 'properties' 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Search Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _selectedCategory == 'restaurants' 
                    ? 'ابحث عن مطعم...' 
                    : 'ابحث عن عقار...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Color(0xFFFC8700)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          // Filters
          if (_availableFilters.isNotEmpty && !_isLoading)
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Color(0xFFFC8700), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'الفلاتر المتاحة:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableFilters.map((filter) {
                        final isSelected = _selectedFilters.contains(filter);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedFilters.remove(filter);
                              } else {
                                _selectedFilters.add(filter);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Color(0xFFFC8700) 
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Color(0xFFFC8700) 
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedFilters.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilters.clear();
                            });
                          },
                          child: Text(
                            'مسح جميع الفلاتر',
                            style: TextStyle(
                              color: Color(0xFFFC8700),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          
          // Results
          Expanded(
            child: _isLoading 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFFC8700),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _selectedCategory == 'restaurants' 
                    ? _buildRestaurantResults() 
                    : _buildPropertyResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantResults() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        var restaurants = provider.allRestaurants;
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          restaurants = restaurants.where((restaurant) {
            final name = restaurant['restaurant_detail']?['restaurant_name'] ?? '';
            final city = restaurant['governorate'] ?? '';
            return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   city.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        // Apply selected filters
        if (_selectedFilters.isNotEmpty) {
          restaurants = restaurants.where((restaurant) {
            final restaurantDetail = restaurant['restaurant_detail'] ?? {};
            final cuisineTypes = restaurantDetail['cuisine_types'] ?? [];
            final city = restaurant['governorate'] ?? '';
            
            return _selectedFilters.any((filter) =>
                cuisineTypes.contains(filter) || city == filter);
          }).toList();
        }
        
        if (restaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
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
          padding: EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: RestaurantApiCard(
                restaurant: restaurant,
                onTap: () {
              context.push('/restaurant-details/${restaurant['id']}');
            },
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildPropertyResults() {
    return Consumer<PublicPropertiesProvider>(
      builder: (context, provider, child) {
        var properties = provider.publicProperties;
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          properties = properties.where((property) {
            return property.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   property.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   property.description.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        // Apply selected filters
        if (_selectedFilters.isNotEmpty) {
          properties = properties.where((property) {
            final addressParts = property.address.split(',');
            final city = addressParts.isNotEmpty ? addressParts.last.trim() : '';
            
            return _selectedFilters.any((filter) =>
                property.type == filter || city == filter);
          }).toList();
        }
        
        if (properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
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
          padding: EdgeInsets.all(16),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: FeaturedPropertyCard(
                property: property,
                isHorizontalLayout: false,
                onTap: () {
                  context.push('/propertyDetails/${property.id}');
                },
              ),
            );
          },
        );
      },
    );
  }
}