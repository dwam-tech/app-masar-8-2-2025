import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/widgets/restaurant_card.dart';
import 'package:saba2v2/widgets/service_card.dart';
import 'package:saba2v2/screens/all_restaurants_screen.dart';

class UserRestaurantHome extends StatefulWidget {
  const UserRestaurantHome({super.key});

  @override
  State<UserRestaurantHome> createState() => _UserRestaurantHomeState();
}

class _UserRestaurantHomeState extends State<UserRestaurantHome> {
  late String _selectedCity;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<String> _cities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'البحر الأحمر',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'الشرقية',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'قنا',
    'شمال سيناء',
    'سوهاج',
  ];

  static const double _tabletBreakpoint = 768.0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    restaurantProvider.fetchMenuSections();
    
    // تحديد المحافظة المختارة من بيانات المستخدم أو SharedPreferences
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storedCity = authProvider.userCity;
      
      if (storedCity != null && _cities.contains(storedCity)) {
        setState(() {
          _selectedCity = storedCity;
        });
      } else {
        // إذا لم توجد محافظة محفوظة، استخدم الأولى من القائمة
        final prefs = await SharedPreferences.getInstance();
        final savedCity = prefs.getString('selected_city') ?? _cities.first;
        setState(() {
          _selectedCity = savedCity;
        });
      }
      
      final restaurantProvider = context.read<RestaurantProvider>();
      restaurantProvider.fetchBanners();
      restaurantProvider.fetchCategories();
      restaurantProvider.fetchRestaurants();
      restaurantProvider.fetchBestRestaurants();
    });
    
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final restaurantProvider = context.read<RestaurantProvider>();
        final banners = restaurantProvider.banners;
        if (banners.isNotEmpty) {
          final nextPage = (_currentPage + 1) % banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _changeCity(String? newCity) async {
    if (newCity == null) return;
    if (newCity == _selectedCity) return;
    
    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFC8700)),
      ),
    );
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateCity(newCity);
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      
      if (success) {
        setState(() => _selectedCity = newCity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث المحافظة إلى $newCity'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحديث المحافظة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحديث المحافظة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(isTablet ? 88.0 : 76.0),
                  child: _buildAppBar(context, isTablet),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'ابحث عن مطعم أو نوع طعام...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFBBB6B0),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF5D554A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFFDEDCD9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFFDEDCD9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFFB3B3B3), width: 1.2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildBannersSection(restaurantProvider),
                        const SizedBox(height: 16.0),
                        const SectionTitle(title: "اختر نوع الطعام"),
                        const SizedBox(height: 8.0),
                        _buildFixedRestaurantCategories(context),
                        const SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: SectionTitle(title: "أفضل المطاعم"),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AllRestaurantsScreen(),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'المزيد',
                                    style: TextStyle(
                                      color: Color(0xFFFC8700),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationStyle: TextDecorationStyle.solid,
                                      decorationColor: Color(0xFFFC8700),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.orange,
                                    size: 18.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        _buildMenuSectionFilters(restaurantProvider),
                        const SizedBox(height: 16.0),
                        RestaurantRowCards(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sliderIndicator(int bannersLength) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(bannersLength, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 7,
          width: isActive ? 28 : 10,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : Colors.grey[350],
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildBannersSection(RestaurantProvider restaurantProvider) {
    if (restaurantProvider.bannersLoading) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (restaurantProvider.banners.isEmpty) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('لا توجد بانرات متاحة'),
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: restaurantProvider.banners.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final banner = restaurantProvider.banners[index];
                final imageUrl = banner['imageUrl'] ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _sliderIndicator(restaurantProvider.banners.length),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: isTablet ? 32.0 : 16.0,
          left: isTablet ? 32.0 : 16.0,
          top: isTablet ? 20.0 : 40.0,
          bottom: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFFFC8700),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.only(top: 11, bottom: 11, right: 12, left: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: _selectedCity,
                      customButton: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/UserCityIcon.svg",
                            height: isTablet ? 26 : 20,
                            width: isTablet ? 26 : 20,
                            color: const Color(0xFFFC8700),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCity,
                            style: TextStyle(
                              fontSize: isTablet ? 19 : 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.orange[700],
                          ),
                        ],
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        maxHeight: 250,
                        elevation: 2,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: _cities
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: TextStyle(fontSize: isTablet ? 18 : 14),
                                ),
                              ))
                          .toList(),
                      onChanged: _changeCity,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'المطاعم',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedRestaurantCategories(BuildContext context) {
    final List<Map<String, String>> categories = [
      {
        'title': 'حلويات',
        'image': 'assets/images/desserts.png',
        'route': '/restaurants/menu-section/حلويات',
      },
      {
        'title': 'دجاج مقلي',
        'image': 'assets/images/fried_chicken.png',
        'route': '/restaurants/menu-section/دجاج مقلي',
      },
      {
        'title': 'مشويات',
        'image': 'assets/images/grilled.png',
        'route': '/restaurants/menu-section/مشويات',
      },
      {
        'title': 'ايس كريم',
        'image': 'assets/images/ice_cream.png',
        'route': '/restaurants/menu-section/ايس كريم',
      },
      {
        'title': 'بيتزا',
        'image': 'assets/images/pizza_category.png',
        'route': '/restaurants/menu-section/بيتزا',
      },
      {
        'title': 'سيفود',
        'image': 'assets/images/seafood.png',
        'route': '/restaurants/menu-section/سيفود',
      },
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth >= 900) {
      crossAxisCount = 6;
    } else if (screenWidth >= 600) {
      crossAxisCount = 4;
    }
    double childWidth = screenWidth / crossAxisCount;
    double childHeight = screenWidth < 600 ? 150 : 180;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childWidth / childHeight,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ServiceCard(
          imageUrl: category['image']!,
          title: category['title']!,
          onTap: () {
            context.push(category['route']!);
          },
        );
      },
    );
  }

  Widget _buildMenuSectionFilters(RestaurantProvider provider) {
    if (provider.menuSectionsLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.menuSections.isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text('الكل'),
              selected: provider.selectedMenuSection == null,
              onSelected: (_) {
                provider.clearMenuSectionFilter();
              },
            ),
            ...provider.menuSections.map((section) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(section),
                    selected: provider.selectedMenuSection == section,
                    onSelected: (_) {
                      provider.fetchRestaurantsByMenuSection(section);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class RestaurantRowCards extends StatefulWidget {
  @override
  _RestaurantRowCardsState createState() => _RestaurantRowCardsState();
}

class _RestaurantRowCardsState extends State<RestaurantRowCards> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchBestRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        if (provider.bestRestaurantsLoading) {
          return Container(
            height: 130,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          );
        }

        if (provider.bestRestaurantsError != null) {
          return Container(
            height: 130,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'خطأ في تحميل المطاعم',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => provider.fetchBestRestaurants(),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.bestRestaurants.isEmpty) {
          return Container(
            height: 130,
            child: Center(
              child: Text(
                'لا توجد مطاعم متاحة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.bestRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.bestRestaurants[index];
                    return Container(
                      margin: EdgeInsets.only(right: 2),
                      child: _buildRestaurantCard(
                        restaurant,
                        context,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, BuildContext context) {
    final restaurantDetail = restaurant['restaurant_detail'] ?? {};
    final name = restaurantDetail['restaurant_name'] ?? restaurant['name'] ?? 'مطعم غير محدد';
    final logoImage = restaurantDetail['logo_image'] ?? '';
    final cuisineTypes = restaurantDetail['cuisine_types'] ?? [];
    final specialty = cuisineTypes.isNotEmpty ? cuisineTypes.first : 'متنوع';
    final city = restaurant['governorate'] ?? 'غير محدد';
    final rating = restaurant['rating'] ?? 4.5;

    return GestureDetector(
      onTap: () {
        final restaurantId = restaurant['id']?.toString();
        if (restaurantId != null) {
          context.push('/restaurant-details/$restaurantId');
        }
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: logoImage.isNotEmpty
                  ? Image.network(
                      logoImage,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange[100]!, Colors.orange[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.orange[600],
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[100]!, Colors.orange[200]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.orange[600],
                        size: 40,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!, width: 1),
                      ),
                      child: Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber[600],
                        ),
                        SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}