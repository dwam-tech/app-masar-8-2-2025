import 'MenuSection.dart';

class Restaurant {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String location;
  final String logoUrl;
  final double distanceKm;
  final double rating;
  final int reviews;
  final String openDays;
  final String openTime;
  final List<MenuSection> menuSections;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.location,
    required this.logoUrl,
    required this.distanceKm,
    required this.rating,
    required this.reviews,
    required this.openDays,
    required this.openTime,
    required this.menuSections,
  });
}
