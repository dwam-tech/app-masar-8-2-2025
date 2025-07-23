import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RealStateEditProfile extends StatelessWidget {
  const RealStateEditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final orangeColor = const Color(0xFFFC8700);

    final items = [
      _SettingsItem(
        label: "المستندات",
        iconData: Icons.file_copy_outlined,
        trailing: Icons.chevron_left,
        router: '/RealStateEditDocuments',
      ),
      _SettingsItem(
        label: "بيانات المكتب",
        iconData: Icons.store_mall_directory_outlined,
        trailing: Icons.chevron_left,
        router: '/RealStateDataEdit',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            "تعديل البيانات",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.2 : 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          separatorBuilder: (c, i) => const Divider(height: 0, color: Color(0xFFF1F1F1)),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: Icon(
                                item.iconData,
                                size: 26,
                                color: orangeColor,
                              ),
                              title: Text(
                                item.label,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              trailing: item.customWidget ??
                                  (item.trailing != null
                                      ? Icon(Icons.arrow_forward_ios_rounded, color: orangeColor)
                                      : null),
                              onTap: (item.router.isNotEmpty)
                                  ? () => context.push(item.router)
                                  : null,
                              minLeadingWidth: 0,
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 2; // القائمة

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/RealStateHomeScreen');
          break;
        case 1:
          context.go('/RealStateAnalysisScreen');
          break;
        case 2:
          context.go('/SettingsProvider');
          break;

      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
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
              children: List.generate(navIcons.length, (idx) {
                final item = navIcons[idx];
                final selected = idx == currentIndex;
                Color mainColor =
                selected ? Colors.orange : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () => onItemTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          item["svg"]!,
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          colorFilter:
                          ColorFilter.mode(mainColor, BlendMode.srcIn),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          item["label"]!,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String label;
  final IconData iconData;
  final IconData? trailing;
  final Widget? customWidget;
  final String router;
  _SettingsItem({
    required this.label,
    required this.iconData,
    required this.router,
    this.trailing,
    this.customWidget,
  });
}
