import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';

import '../../models/MenuSection.dart'; // غيرها لمسار البروڤايدر الجديد

class RestaurantDetailsScreen extends StatelessWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final restaurant = context.read<RestaurantProvider>().getById(restaurantId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            // صورة الغلاف
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: Image.asset(
                    restaurant!.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            // كارت بيانات المطعم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // لوجو
                      ClipOval(
                        child: Image.asset(
                          restaurant!.logoUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            Text(restaurant.category, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange, size: 16),
                                Text('${restaurant.rating}', style: const TextStyle(color: Colors.orange)),
                                const SizedBox(width: 5),
                                Text('(${restaurant.reviews} تقييم)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 10),
                                Icon(Icons.location_on, color: Colors.grey, size: 16),
                                Text('${restaurant.distanceKm} كم', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // مواعيد العمل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.orange, size: 18),
                  const SizedBox(width: 5),
                  Text('${restaurant.openDays}  |  ${restaurant.openTime}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tabs للأقسام (ديناميكي حسب المينيو)
            _MenuTabs(menuSections: restaurant.menuSections),
          ],
        ),
      ),
    );
  }
}

// ودجت التابس والمينيو
class _MenuTabs extends StatefulWidget {
  final List<MenuSection> menuSections;
  const _MenuTabs({required this.menuSections});

  @override
  State<_MenuTabs> createState() => _MenuTabsState();
}

class _MenuTabsState extends State<_MenuTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.menuSections.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.black87,
          indicatorColor: Colors.orange,
          tabs: widget.menuSections
              .map((s) => Tab(child: Text(s.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))))
              .toList(),
        ),
        SizedBox(
          height: 260, // حسب تصميمك
          child: TabBarView(
            controller: _tabController,
            children: widget.menuSections.map((section) {
              return ListView.builder(
                itemCount: section.items.length,
                itemBuilder: (context, index) {
                  final item = section.items[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(item.imageUrl, width: 52, height: 52, fit: BoxFit.cover),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${item.basePrice.toStringAsFixed(0)} ج.م', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                      ],
                    ),
                    onTap: () {
                      // انتقل لصفحة تفاصيل المنتج
                      context.go('/menu-item-details/${item.id}');
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
