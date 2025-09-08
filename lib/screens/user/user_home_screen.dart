import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/service_category_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/providers/real_estate_provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saba2v2/widgets/service_card.dart';
import 'package:saba2v2/widgets/restaurant_card.dart';
import 'package:saba2v2/widgets/restaurant_slider_card.dart';
import 'package:saba2v2/widgets/real_estate_card.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';
import 'package:saba2v2/providers/cart_provider.dart';
import 'package:saba2v2/providers/featured_properties_provider.dart';
import 'package:saba2v2/providers/banner_provider.dart';
import 'package:saba2v2/widgets/featured_properties_row.dart';
import 'package:saba2v2/screens/all_restaurants_screen.dart';
import 'package:saba2v2/screens/user/all_properties_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _selectedCity = 'القاهرة'; // قيمة افتراضية
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

  // Responsive breakpoints
  static const double _tabletBreakpoint = 768.0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    
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
    });
    
    // جلب البانرات من API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().fetchBanners();
    });
    
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final banners = context.read<BannerProvider>().banners;
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
                    // شريط البحث
                    GestureDetector(
                      onTap: () {
                        context.push('/search');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFDEDCD9)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF5D554A)),
                            const SizedBox(width: 8),
                            const Text(
                              'ما الذي تبحث عنه؟',
                              style: TextStyle(
                                color: Color(0xFFBBB6B0),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // --- Slider & Dashes ---
                    Consumer<BannerProvider>(
                      builder: (context, bannerProvider, child) {
                        final banners = bannerProvider.banners;
                        
                        if (bannerProvider.isLoading) {
                          return const SizedBox(
                            height: 170,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFC8700),
                              ),
                            ),
                          );
                        }
                        
                        if (banners.isEmpty) {
                          return const SizedBox(
                            height: 170,
                            child: Center(
                              child: Text(
                                'لا توجد بانرات متاحة',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
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
                                  itemCount: banners.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentPage = index);
                                  },
                                  itemBuilder: (context, index) {
                                    final url = banners[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFFFC8700),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.grey,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _sliderIndicator(banners.length),
                            ],
                          ),
                        );
                      },
                    ),


                    SizedBox(
                      width: double.infinity,
                      child: const SectionTitle(title: "اختر الخدمة التي تريد"),
                    ),
                    Consumer<ServiceCategoryProvider>(
                      builder: (context, provider, child) {
                        final screenWidth = MediaQuery.of(context).size.width;

                        // لو عايز أعمدة أكتر في التابلت
                        int crossAxisCount = 3;
                        if (screenWidth >= 900) {
                          crossAxisCount = 6;
                        } else if (screenWidth >= 600) {
                          crossAxisCount = 4;
                        }

                        // العرض الافتراضي للبند الواحد (عشان childAspectRatio)
                        double childWidth = screenWidth / crossAxisCount;
                        double childHeight = screenWidth < 600 ? 150 : 180; // أو حسب اللي يناسب تصميمك

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childWidth / childHeight,
                          ),
                          itemCount: provider.categories.length,
                          itemBuilder: (context, index) {
                            final category = provider.categories[index];
                            return ServiceCard(
                              imageUrl: category.imageUrl,
                              title: category.title,
                              onTap: () {
                                if (category.title == 'توصيل') {
                                  context.go('/delivery');
                                }
                                if (category.title == 'تأجير السيارات') {
                                  context.push('/car-service-selection');
                                }
                                if (category.title == 'المطاعم') {
                                  context.push('/user-restaurants');
                                }
                                if (category.title == 'عقارات') {
                                  context.go('/real-state-home');
                                }
                                if (category.title == 'بحث عقارات') {
                                  context.push('/all-properties');
                                }
                                if (category.title == 'تصريح أمني') {
                                  context.push('/security-permit');
                                }
                                if (category.title == 'حجز الطيران') {
                                  context.push('/flight-search');
                                }
                                if (category.title == 'حجز الفنادق') {
                                  context.push('/hotel-search');
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                    // مطاعم موصى بها
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: SectionTitle(title: "افضل المطاعم"),
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
                                  decoration: TextDecoration.underline, // نوع الزخرفة (تحت الخط)
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationColor:  Color(0xFFFC8700),     // لون الخط السفلي
// شكل الخط (solid/dotted/dashed)

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
                    // Consumer<RestaurantProvider>(
                    //   builder: (context, provider, child) {
                    //     return SizedBox(
                    //       height: 113,
                    //       child: ListView.builder(
                    //         scrollDirection: Axis.horizontal,
                    //         itemCount: provider.restaurants.length,
                    //         itemBuilder: (context, index) {
                    //           final restaurant = provider.restaurants[index];
                    //           return Padding(
                    //             padding: const EdgeInsets.only(left: 8.0),
                    //             child: RestaurantSliderCard(
                    //               id: restaurant.id,
                    //               imageUrl: restaurant.imageUrl,
                    //               name: restaurant.name,
                    //               category: restaurant.category,
                    //               location: restaurant.location,
                    //               // لو حابب تضيف التقييم والمسافة أو اللوجو مررهم هنا
                    //               // logoUrl: restaurant.logoUrl,
                    //               // distanceKm: restaurant.distanceKm,
                    //               // rating: restaurant.rating,
                    //               onTap: () => context.go('/restaurant-details/${restaurant.id}'),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
                    RestaurantRowCards(),
                    const SizedBox(height: 16.0),
                    // عقارات موصى بها
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'عقارات موصى بها',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // الانتقال إلى صفحة جميع العقارات المميزة
                            context.push('/featured-properties');
                          },
                          child: const Text(
                            'عرض الكل',
                            style: TextStyle(
                              color: Color(0xFFFC8700),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // استخدام العقارات المميزة الجديدة
                    const FeaturedPropertiesRow(),

                    const SizedBox(height: 16.0),

                  ],
                ),
              ),
            ),
            bottomNavigationBar: MyBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                // السلوك الافتراضي إذا لم يكن هناك مسار
              },
              routes: [
                '/UserHomeScreen',      // مسار الصفحة الرئيسية
                '/my-orders',           // مسار طلباتي
                '/cart',                // مسار السلة
                '/SettingsUser',        // مسار الإعدادات
              ],
            )
          ),
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
                Container(
                  padding: const EdgeInsets.only(top: 11, bottom: 11, right: 12, left: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
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
                            textAlign: TextAlign.right,
                          ),
                        ))
                            .toList(),
                        onChanged: _changeCity,
                      ),
                    ),
                  ),
                )
              ],
            ),
            _buildActionButtons(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.message_outlined,
          badge: "",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ConversationsListScreen(),
              ),
            );
          },
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 16.0 : 12.0),
        _buildActionButton(
          icon: Icons.notifications_outlined,
          badge: "",
          onTap: () => context.push("/NotificationsScreen"),
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String badge,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Container(
      width: isTablet ? 48.0 : 44.0,
      height: isTablet ? 48.0 : 44.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(
            icon,
            size: isTablet ? 24.0 : 20.0,
            color: const Color(0xFFFC8700),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Text(
      "الرئيسية",
      style: TextStyle(
        fontSize: isTablet ? 24.0 : 20.0,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F2937),
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
    // جلب أفضل المطاعم عند تهيئة الويدجت
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
              // Horizontal Scroll for Restaurant Cards
              Container(
                height: 120, // ارتفاع محدث للتصميم الأفقي الجديد
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



  Widget _buildRestaurantCard(
      Map<String, dynamic> restaurant,
      BuildContext context,
      ) {
    
    final restaurantDetail = restaurant['restaurant_detail'] ?? {};
    
    final name = restaurantDetail['restaurant_name'] ?? restaurant['name'] ?? 'مطعم غير محدد';
    final logoImage = restaurantDetail['logo_image'] ?? '';
    final cuisineTypes = restaurantDetail['cuisine_types'] ?? [];
    final specialty = cuisineTypes.isNotEmpty ? cuisineTypes.first : 'متنوع';
    final city = restaurant['governorate'] ?? 'غير محدد';
    final rating = restaurant['rating'] ?? 4.5; // افتراضي
    

    return GestureDetector(
      onTap: () {
        final restaurantId = restaurant['id']?.toString();
        if (restaurantId != null) {
          context.push('/restaurant-details/$restaurantId');
        }
      },
      child: Container(
        width: 280, // عرض أكبر للتصميم الأفقي
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
            // Restaurant Image - الجانب الأيمن
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
            // Restaurant Info - الجانب الأيسر
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // اسم المطعم
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
                    // نوع المطبخ
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
                    // المدينة والتقييم
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



class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String?> routes;

  const MyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.routes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final orangeColor = const Color(0xFFFC8700);

    final List<Map<String, dynamic>> navItems = [
      {
        'icon': 'assets/icons/home_icon_provider.svg',
        'label': 'الرئيسية',
        'route': routes.isNotEmpty && routes.length > 0 ? routes[0] : null,
      },
      {
        'icon': 'assets/icons/Nav_Menu_provider.svg',
        'label': 'طلباتي',
        'route': routes.isNotEmpty && routes.length > 1 ? routes[1] : null,
      },
      {
        'icon': 'assets/icons/cart.svg',
        'label': 'السلة',
        'route': routes.isNotEmpty && routes.length > 2 ? routes[2] : null,
      },
      {
        'icon': 'assets/icons/menu.svg',
        'label': 'الإعدادات',
        'route': routes.isNotEmpty && routes.length > 3 ? routes[3] : null,
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 10,
              horizontal: isTablet ? 20 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = index == 0; // Statically set Home (index 0) as active
                final mainColor = selected ? orangeColor : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () {
                    if (item['route'] != null) {
                      context.go(item['route']);
                    } else {
                      onTap(index);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? orangeColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              item['icon'],
                              height: isTablet ? 28 : 24,
                              width: isTablet ? 28 : 24,
                              colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
                            ),
                            // إضافة مؤشر السلة للتبويب الثاني (السلة)
                            if (index == 1)
                              Consumer<CartProvider>(
                                builder: (context, cartProvider, child) {
                                  final totalItems = cartProvider.totalItems;
                                  if (totalItems > 0) {
                                    return Positioned(
                                      right: -6,
                                      top: -6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}