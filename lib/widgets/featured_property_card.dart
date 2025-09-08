// lib/widgets/featured_property_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/featured_property.dart';

class FeaturedPropertyCard extends StatelessWidget {
  final FeaturedProperty property;
  final VoidCallback? onTap;
  final bool isHorizontalLayout;

  const FeaturedPropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.isHorizontalLayout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: isHorizontalLayout ? 200 : null,
          margin: isHorizontalLayout 
              ? const EdgeInsets.only(left: 12)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة العقار مع شارة "الأفضل"
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: isHorizontalLayout ? 130 : 160,
                      child: CachedNetworkImage(
                        imageUrl: property.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFC8700),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'صورة غير متاحة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // شارة "الأفضل"
                  if (property.theBest)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFC8700), Color(0xFFFF9500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFC8700).withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الأفضل',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // زر المفضلة
                  // Positioned(
                  //   top: 12,
                  //   left: 12,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.95),
                  //       shape: BoxShape.circle,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.1),
                  //           blurRadius: 6,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: const Icon(
                  //       Icons.favorite_border,
                  //       size: 18,
                  //       color: Colors.red,
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              // Property Information
              isHorizontalLayout 
                ? Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // نوع العقار
                        Text(
                          property.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // السعر
                        Text(
                          _formatPrice(property.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // العنوان
                        Text(
                          property.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // تفاصيل العقار
                        Row(
                          children: [
                            _buildPropertyDetail(
                              Icons.bed,
                              '${property.bedrooms}',
                              'غرفة',
                            ),
                            const SizedBox(width: 8),
                            _buildPropertyDetail(
                              Icons.bathroom,
                              '${property.bathrooms}',
                              'حمام',
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // نوع العقار
                          Text(
                            property.type,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // السعر
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC8700).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFC8700).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${_formatPrice(property.price)} جنيه',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFC8700),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // العنوان
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  property.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // تفاصيل العقار
                          Row(
                            children: [
                              Expanded(
                                child: _buildPropertyDetail(
                                  Icons.bed_outlined,
                                  '${property.bedrooms}',
                                  'غرفة',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPropertyDetail(
                                  Icons.bathroom_outlined,
                                  '${property.bathrooms}',
                                  'حمام',
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (property.area.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      property.area,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
      ),
    );
  }

  Widget _buildPropertyDetail(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$value $label',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final numPrice = double.parse(price);
      if (numPrice >= 1000000) {
        return '${(numPrice / 1000000).toStringAsFixed(1)} مليون';
      } else if (numPrice >= 1000) {
        return '${(numPrice / 1000).toStringAsFixed(0)} ألف';
      } else {
        return numPrice.toStringAsFixed(0);
      }
    } catch (e) {
      return price;
    }
  }
}