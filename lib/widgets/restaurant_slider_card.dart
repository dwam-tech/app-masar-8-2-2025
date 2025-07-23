import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantSliderCard extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String location;
  final VoidCallback onTap;

  const RestaurantSliderCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 200, // زيادة الارتفاع لتجنب الـ overflow
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // صورة المطعم (يمين)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 90,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              // النصوص (شمال)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.orange),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}