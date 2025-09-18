import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/conversation_provider.dart';
import '../../widgets/my_bottom_nav_bar.dart';

class SettingsUser extends StatefulWidget {
  const SettingsUser({super.key});

  @override
  State<SettingsUser> createState() => _SettingsUserState();
}

class _SettingsUserState extends State<SettingsUser> {
  bool isArabic = true; // متغير لتتبع اللغة الحالية

  Future<void> _logout(BuildContext context) async {
    final conversationProvider = context.read<ConversationProvider>();
    await context.read<AuthProvider>().logout(conversationProvider);
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final orangeColor = const Color(0xFFFC8700);

    final items = [
      _SettingsItem(
        label: "تغيير كلمة المرور",
        svgPath: "assets/icons/lock.svg",
        trailing: Icons.chevron_left,
        router: '/ChangeProfilePass',
      ),
      _SettingsItem(
        label: "اشعاراتي",
        svgPath: "assets/icons/notification.svg",
        customWidget: Switch(
          value: false,
          onChanged: (val) {},
          activeColor: orangeColor,
        ),
        router: '',
      ),
      _SettingsItem(
        label: "اللغة",
        svgPath: "assets/icons/language.svg", // يمكنك استخدام أيقونة اللغة أو أي أيقونة مناسبة
        customWidget: _buildLanguageToggle(orangeColor),
        router: '',
      ),
      _SettingsItem(
        label: "عن التطبيق",
        svgPath: "assets/icons/info.svg",
        trailing: Icons.chevron_left,
        router: '/AboutApp',
      ),
      _SettingsItem(
        label: "الشروط والأحكام",
        svgPath: "assets/icons/document.svg",
        trailing: Icons.chevron_left,
        router: '/TermsScreen',
      ),
      _SettingsItem(
        label: "الأسئلة الشائعة",
        svgPath: "assets/icons/question.svg",
        trailing: Icons.chevron_left,
        router: '/FAQScreen',
      ),
      _SettingsItem(
        label: "تواصل معنا",
        svgPath: "assets/icons/mail.svg",
        trailing: Icons.chevron_left,
        router: '/ContactUsScreen',
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
            "الإعدادات",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomNavigationBar: const MyBottomNavBar(
          currentIndex: 4, // Settings is at index 4 in the new navigation
        ),
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
                              leading: SvgPicture.asset(
                                item.svgPath,
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(orangeColor, BlendMode.srcIn),
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
                      const SizedBox(height: 32),
                      const Text(
                        "تابعونا على",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIcon(svgPath: "assets/icons/telephone_901122.svg"),
                          const SizedBox(width: 16),
                          _SocialIcon(svgPath: "assets/icons/youtube_246153.svg"),
                          const SizedBox(width: 16),
                          _SocialIcon(svgPath: "assets/icons/twitter_2335289.svg"),
                          const SizedBox(width: 16),
                          _SocialIcon(svgPath: "assets/icons/facebook-logo_1384879.svg"),
                        ],
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                          label: const Text(
                            "تسجيل الخروج",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  // دالة لبناء زرار تبديل اللغة
  Widget _buildLanguageToggle(Color orangeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isArabic = !isArabic;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: orangeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: orangeColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العربية
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isArabic ? orangeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "عربي",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isArabic ? Colors.white : orangeColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // الإنجليزية
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !isArabic ? orangeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "EN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: !isArabic ? Colors.white : orangeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String label;
  final String svgPath;
  final IconData? trailing;
  final Widget? customWidget;
  final String router;
  _SettingsItem({
    required this.label,
    required this.svgPath,
    required this.router,
    this.trailing,
    this.customWidget,
  });
}

class _SocialIcon extends StatelessWidget {
  final String svgPath;
  const _SocialIcon({required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(
        svgPath,
        width: 28,
        height: 28,
      ),
    );
  }
}