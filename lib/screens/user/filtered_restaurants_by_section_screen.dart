import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';

class FilteredRestaurantsBySectionScreen extends StatefulWidget {
  final String section;
  const FilteredRestaurantsBySectionScreen({Key? key, required this.section}) : super(key: key);

  @override
  State<FilteredRestaurantsBySectionScreen> createState() => _FilteredRestaurantsBySectionScreenState();
}

class _FilteredRestaurantsBySectionScreenState extends State<FilteredRestaurantsBySectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurantsByMenuSection(widget.section);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مطاعم قسم ${widget.section}'),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Color(0xFF2C2C2C),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFC8700)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurantProvider, child) {
          final restaurants = restaurantProvider.filteredRestaurants;
          if (restaurantProvider.filteredRestaurantsLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFC8700)));
          }
          if (restaurants.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد مطاعم في هذا القسم حالياً.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return _buildRestaurantCard(restaurant, context);
            },
          );
        },
      ),
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
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
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
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 2),
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