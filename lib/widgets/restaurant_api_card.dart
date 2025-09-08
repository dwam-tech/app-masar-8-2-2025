import 'package:flutter/material.dart';

class RestaurantApiCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const RestaurantApiCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final restaurantDetail = restaurant['restaurant_detail'] ?? {};
    final name = restaurantDetail['restaurant_name'] ?? restaurant['name'] ?? 'مطعم غير محدد';
    final logoImage = restaurantDetail['logo_image'] ?? '';
    final cuisineTypes = restaurantDetail['cuisine_types'] ?? [];
    final specialty = cuisineTypes.isNotEmpty ? cuisineTypes.join(', ') : 'متنوع';
    final city = restaurant['governorate'] ?? 'غير محدد';
    final isApproved = restaurant['is_approved'] == 1;
    final isBest = restaurant['the_best'] == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المطعم
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: logoImage.isNotEmpty
                    ? Image.network(
                        logoImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            
            // محتوى البطاقة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المطعم مع الشارات
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBest)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'الأفضل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isApproved)
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // نوع المطبخ
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // الموقع
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // معلومات إضافية
                  Row(
                    children: [
                      // حالة التوصيل
                      if (restaurantDetail['delivery_available'] == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                size: 14,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'توصيل',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // حالة الحجز
                      if (restaurantDetail['table_reservation_available'] == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.table_restaurant,
                                size: 14,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حجز',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}