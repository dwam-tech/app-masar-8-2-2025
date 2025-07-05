import 'package:flutter/material.dart';
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
    'https://picsum.photos/id/1011/800/300',
    'https://picsum.photos/id/984/800/300',
    'https://picsum.photos/id/888/800/300',
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
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.positions.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _sliderImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _changeCity(String? newCity) async {
    if (newCity == null) return;
    if (newCity == _selectedCity) return;
    setState(() => _selectedCity = newCity);
    await context.read<AuthProvider>().updateCity(newCity);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          leadingWidth: 160,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  items: _cities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _changeCity,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/UserHomeScreen'),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
            ),
          ],
          title: const Text('الرئيسية'),
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
                  hintText: 'ابحث عن الخدمات أو المنتجات...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _sliderImages.length,
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
              const SizedBox(height: 16.0),
              // أنواع الخدمات
              SizedBox( width: double.infinity, child: const SectionTitle(title: "اختر الخدمة التي تريد")),

              const SizedBox(height: 8.0),
              Consumer<ServiceCategoryProvider>(
                builder: (context, provider, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 خدمات في كل سطر
                      crossAxisSpacing: 8.0, // المسافة بين الأعمدة
                      mainAxisSpacing: 8.0, // المسافة بين الصفوف
                      childAspectRatio: 1, // نسبة العرض للارتفاع لكل Card
                    ),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return ServiceCard(
                        imageUrl: category.imageUrl,
                        title: category.title,
                        onTap: () {
                          // توجيه حسب نوع الخدمة
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
              const SizedBox(height: 16.0),
              // مطاعم موصى بها
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SectionTitle(title: "افضل المطاعم"),
                  InkWell(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Text(
                          'المزيد',
                          style: TextStyle(color: Colors.orange),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.orange,
                          size: 18.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Consumer<RestaurantProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.recommendedRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = provider.recommendedRestaurants[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: RestaurantSliderCard(
                            id: restaurant.id,
                            imageUrl: restaurant.imageUrl,
                            name: restaurant.name,
                            category: restaurant.category,
                            location: restaurant.location,
                            onTap: () =>
                                context.go('/restaurant-details/${restaurant.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              // عقارات موصى بها
              const Text(
                'عقارات موصى بها',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              // Consumer<RealEstateProvider>(
              //   builder: (context, provider, child) {
              //     return Column(
              //       children: provider.recommendedRealEstates.map((realEstate) {
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
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        onTap: (index) {
          if (index == 1) context.go('/favorites');
          if (index == 2) context.go('/profile');
        },
      ),
    ),
  );
  }
}
