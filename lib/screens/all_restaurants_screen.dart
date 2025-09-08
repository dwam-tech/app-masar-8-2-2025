import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_api_card.dart';
import '../screens/user/restaurant-details.dart';

class AllRestaurantsScreen extends StatefulWidget {
  const AllRestaurantsScreen({Key? key}) : super(key: key);

  @override
  State<AllRestaurantsScreen> createState() => _AllRestaurantsScreenState();
}

class _AllRestaurantsScreenState extends State<AllRestaurantsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // جلب جميع المطاعم عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchAllRestaurants();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<RestaurantProvider>();
      if (provider.canLoadMoreAllRestaurants && !provider.allRestaurantsLoading) {
        provider.fetchAllRestaurants(loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'جميع المطاعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.allRestaurantsLoading && provider.allRestaurants.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
            );
          }

          if (provider.allRestaurantsError != null && provider.allRestaurants.isEmpty) {
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
                    'حدث خطأ في تحميل المطاعم',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.allRestaurantsError!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.fetchAllRestaurants(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (provider.allRestaurants.isEmpty) {
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
                    'لا توجد مطاعم متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllRestaurants(),
            color: const Color(0xFFFF6B35),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.allRestaurants.length + 
                         (provider.allRestaurantsLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.allRestaurants.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      ),
                    ),
                  );
                }

                final restaurant = provider.allRestaurants[index];
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
            ),
          );
        },
      ),
    );
  }
}