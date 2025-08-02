import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late String _selectedCity;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
    'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
  ];

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
    final authProvider = context.read<AuthProvider>();
    final storedCity = authProvider.userData?['city'];
    if (storedCity != null && _cities.contains(storedCity)) {
      _selectedCity = storedCity;
    } else {
      _selectedCity = _cities.first;
    }
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _sliderImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
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
    setState(() => _selectedCity = newCity);
    // await context.read<AuthProvider>().updateCity(newCity);
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
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // خلفية بيضاء
                        hintText: 'ما الذي تبحث عنه؟',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBBB6B0), // لون باهت للهينت
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF5D554A)), // لون الأيقونة كمان باهت
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

                    // --- Slider & Dashes ---
                    SizedBox(
                      height: 170,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _sliderImages.length,
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              itemBuilder: (context, index) {
                                final url = _sliderImages[index];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _sliderIndicator(),
                        ],
                      ),
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
                                if (category.title == 'مطاعم') {
                                  context.go('/restaurant-home');
                                }
                                if (category.title == 'عقارات') {
                                  context.go('/real-state-home');
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
                          onTap: () {},
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
                    const Text(
                      'عقارات موصى بها',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    // Consumer<RealEstateProvider>(
                    //   builder: (context, provider, child) {
                    //     return Column(
                    //       children: provider.recommendedRestaurants.map((realEstate) {
                    //         return RealEstateCard(
                    //           imageUrl: realEstate.imageUrl,
                    //           title: realEstate.title,
                    //           price: realEstate.price,
                    //           rating: realEstate.rating,
                    //           onTap: () =>
                    //               context.go('/real-estate-details/${realEstate.id}'),
                    //         );
                    //       }).toList(),
                    //     );
                    //   },
                    // )


                    PropertiesHotelsRowCards(),

                  ],
                ),
              ),
            ),
            bottomNavigationBar: MyBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                // السلوك الافتراضي إذا لم يكن هناك مسار
                print('Tapped index: $index');
              },
              routes: [
                '/UserHomeScreen',      // مسار الصفحة الرئيسية
              null,      // مسار السلة
                null,         // طلباتي ليس لها مسار بعد
                '/SettingsUser',  // مسار الإعدادات
              ],
            )
          ),
        );
      },
    );
  }

  Widget _sliderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sliderImages.length, (index) {
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
          badge: "5",
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
          badge: "3",
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 12.0 : 10.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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

class RestaurantRowCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Horizontal Scroll for Restaurant Cards
          Container(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,

              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 2),
                  child: _buildRestaurantCard(
                    _getRestaurantData(index)['name']!,
                    _getRestaurantData(index)['specialty']!,
                    _getRestaurantData(index)['city']!,
                    _getRestaurantData(index)['imageUrl']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getRestaurantData(int index) {
    List<Map<String, String>> restaurants = [
      {
        'name': 'مطعم الشيف أحمد',
        'specialty': 'بيتزا إيطالية',
        'city': 'القاهرة',
        'imageUrl': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300&h=200&fit=crop',
      },
      {
        'name': 'برجر هاوس',
        'specialty': 'برجر أمريكي',
        'city': 'الجيزة',
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&h=200&fit=crop',
      },
      {
        'name': 'مطعم البحر المتوسط',
        'specialty': 'مأكولات بحرية',
        'city': 'الإسكندرية',
        'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&h=200&fit=crop',
      },
      {
        'name': 'كنتاكي الشرق',
        'specialty': 'دجاج مقلي',
        'city': 'الشرقية',
        'imageUrl': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300&h=200&fit=crop',
      },
      {
        'name': 'مطعم الأصالة',
        'specialty': 'مأكولات شرقية',
        'city': 'الإسماعيلية',
        'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&h=200&fit=crop',
      },
    ];
    return restaurants[index];
  }

  Widget _buildRestaurantCard(
      String restaurantName,
      String specialty,
      String city,
      String imageUrl,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 330, // عرض ثابت للكارت
      height: 125,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المطعم - الجزء الأيمن
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              width: 120,
              height: 125,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
          ),

          // معلومات المطعم - الجزء الأيسر
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اسم المطعم
                  Text(
                    restaurantName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // التخصص
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // المحافظة
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        city,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
    );
  }
}


class PropertiesHotelsRowCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Horizontal Scroll for Properties & Hotels Cards
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  child: _buildPropertyHotelCard(
                    _getPropertyHotelData(index)['name']!,
                    _getPropertyHotelData(index)['serviceType']!,
                    _getPropertyHotelData(index)['city']!,
                    _getPropertyHotelData(index)['imageUrl']!,
                    _getPropertyHotelData(index)['type']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getPropertyHotelData(int index) {
    List<Map<String, String>> propertiesAndHotels = [
      // عقارات
      {
        'name': 'شقة في التجمع الخامس',
        'serviceType': 'للبيع',
        'city': 'القاهرة',
        'imageUrl': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=300&h=200&fit=crop',
        'type': 'property',
      },
      {
        'name': 'فيلا في مدينة نصر',
        'serviceType': 'للإيجار',
        'city': 'القاهرة',
        'imageUrl': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=300&h=200&fit=crop',
        'type': 'property',
      },
      {
        'name': 'شقة في المعادي',
        'serviceType': 'للبيع',
        'city': 'القاهرة',
        'imageUrl': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=300&h=200&fit=crop',
        'type': 'property',
      },
      // فنادق
      {
        'name': 'فندق الأهرام',
        'serviceType': 'حجز غرف',
        'city': 'الجيزة',
        'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300&h=200&fit=crop',
        'type': 'hotel',
      },
      {
        'name': 'فندق البحر الأحمر',
        'serviceType': 'منتجع سياحي',
        'city': 'الغردقة',
        'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=300&h=200&fit=crop',
        'type': 'hotel',
      },
      {
        'name': 'فندق الإسكندرية',
        'serviceType': 'إقامة فندقية',
        'city': 'الإسكندرية',
        'imageUrl': 'https://images.unsplash.com/photo-1455587734955-081b22074882?w=300&h=200&fit=crop',
        'type': 'hotel',
      },
    ];
    return propertiesAndHotels[index];
  }

  Widget _buildPropertyHotelCard(
      String name,
      String serviceType,
      String city,
      String imageUrl,
      String type,
      ) {
    return Container(
      width: 200,
      height: 220,
      margin: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة العقار أو الفندق مع زر المفضلة
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  width: 200,
                  height: 120,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          type == 'property' ? Icons.home : Icons.hotel,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // زر المفضلة في اليمين فوق
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),

          // معلومات العقار أو الفندق
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // اسم العقار أو الفندق
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // المحافظة
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
                    ],
                  ),

                  // التقييم
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '(124)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
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
        'icon': 'assets/icons/cart.svg',
        'label': 'السلة',
        'route': routes.isNotEmpty && routes.length > 1 ? routes[1] : null,
      },
      {
        'icon': 'assets/icons/Nav_Menu_provider.svg',
        'label': 'طلباتي',
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
                        SvgPicture.asset(
                          item['icon'],
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
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