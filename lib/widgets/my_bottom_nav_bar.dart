import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final List<String?> routes;

  const MyBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
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
        'route': routes.isNotEmpty && routes.length > 0 ? routes[0] : '/user-home',
      },
      {
        'icon': 'assets/icons/Nav_Menu_provider.svg',
        'label': 'طلباتي',
        'route': routes.isNotEmpty && routes.length > 1 ? routes[1] : '/my-orders',
      },
      {
        'icon': 'assets/icons/cart.svg',
        'label': 'السلة',
        'route': routes.isNotEmpty && routes.length > 2 ? routes[2] : '/cart',
      },
      {
        'icon': 'assets/icons/menu.svg',
        'label': 'الإعدادات',
        'route': routes.isNotEmpty && routes.length > 3 ? routes[3] : '/settings',
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
                final selected = index == currentIndex;
                final mainColor = selected ? orangeColor : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () {
                    if (item['route'] != null) {
                      context.go(item['route']);
                    } else if (onTap != null) {
                      onTap!(index);
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
                            // إضافة مؤشر السلة للتبويب الثالث (السلة)
                            if (index == 2)
                              Consumer<CartProvider>(
                                builder: (context, cartProvider, child) {
                                  final totalItems = cartProvider.totalItems;
                                  if (totalItems > 0) {
                                    return Positioned(
                                      right: -6,
                                      top: -6,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            totalItems > 9 ? '9+' : totalItems.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
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