import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/conversation_provider.dart';
import 'package:saba2v2/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';





class RealStateSettingsProvider extends StatefulWidget {
  const RealStateSettingsProvider({super.key});

  @override
  State<RealStateSettingsProvider> createState() =>
      _RealStateSettingsProviderState();
}

class _RealStateSettingsProviderState extends State<RealStateSettingsProvider> {
  bool isArabic = true; // متغير لتتبع اللغة الحالية

  Future<void> _logout(BuildContext context) async {
    final conversationProvider = context.read<ConversationProvider>();
    await context.read<AuthProvider>().logout(conversationProvider);
    if (context.mounted) {
      context.go('/login');
    }
  }

  // --- متغيرات الحالة لجلب الإعدادات ---
  final AuthService _authService = AuthService();
  Map<String, dynamic> _appSettings = {};
  bool _isLoadingSocials = true; // تتبع حالة تحميل روابط التواصل فقط
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // استدعاء دالة جلب الإعدادات
  }

  /// دالة لجلب الإعدادات من الـ API وتحديث الحالة
  Future<void> _loadSettings() async {
    try {
      final settings = await _authService.fetchSettings();
      if (mounted) {
        setState(() {
          _appSettings = settings;
          _isLoadingSocials = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoadingSocials = false;
        });
      }
    }
  }

  /// دالة لفتح الروابط أو الاتصال الهاتفي
  Future<void> _launchURL(String value, {bool isPhone = false}) async {
    Uri? uri;
    if (isPhone) {
      uri = Uri.parse('tel:$value');
    } else {
      uri = Uri.parse(value);
    }
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح هذا الرابط: $value')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final orangeColor = const Color(0xFFFC8700);

    final items = [
      _SettingsItem(
        label: "تعديل البيانات",
        svgPath: "assets/icons/user.svg",
        trailing: Icons.chevron_left,
        router: '/RealStateEditProfile',
      ),
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
        svgPath: "assets/icons/language.svg",
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
        bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal:
                        constraints.maxWidth > 600 ? constraints.maxWidth * 0.2 : 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          separatorBuilder: (c, i) =>
                              const Divider(height: 0, color: Color(0xFFF1F1F1)),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: SvgPicture.asset(
                                item.svgPath,
                                width: 24,
                                height: 24,
                                color: orangeColor,
                              ),
                              title: Text(
                                item.label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              trailing: item.customWidget ??
                                  (item.trailing != null
                                      ? Icon(Icons.arrow_forward_ios_rounded,
                                          color: orangeColor)
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
                      // --- الجزء الديناميكي لعرض أيقونات التواصل الاجتماعي ---
                      _buildSocialIconsWidget(),
                      const SizedBox(height: 36),
                      // زرار تسجيل الخروج
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
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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

  // --- ويدجت بناء أيقونات التواصل الاجتماعي ---
  Widget _buildSocialIconsWidget() {
    if (_isLoadingSocials) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFC8700)));
    }
    if (_errorMessage != null) {
      return Text('خطأ: $_errorMessage', style: const TextStyle(color: Colors.red));
    }

    // خريطة لربط مفاتيح الـ API بمسارات الأيقونات المحلية
    final Map<String, String> socialKeyToAssetMap = {
      'facebook_url': "assets/icons/facebook-logo_1384879.svg",
      'twitter_url': "assets/icons/twitter_2335289.svg",
      'youtube_url': "assets/icons/youtube_246153.svg",
      'contact_phones': "assets/icons/telephone_901122.svg",
    };

    List<Widget> socialIcons = [];
    
    socialKeyToAssetMap.forEach((key, assetPath) {
      if (_appSettings.containsKey(key) && _appSettings[key] != null && _appSettings[key].toString().isNotEmpty) {
        
        final value = _appSettings[key] is List ? _appSettings[key][0] : _appSettings[key];
        
        socialIcons.add(
          InkWell(
            onTap: () => _launchURL(value.toString(), isPhone: key == 'contact_phones'),
            borderRadius: BorderRadius.circular(12),
            child: _SocialIcon(svgPath: assetPath),
          )
        );
        socialIcons.add(const SizedBox(width: 16)); // مسافة بين الأيقونات
      }
    });

    if (socialIcons.isNotEmpty) {
      socialIcons.removeLast(); // إزالة آخر مسافة
    }

    if (socialIcons.isEmpty) {
      return const Text("لا توجد روابط حاليًا");
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialIcons,
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

  // دالة بناء شريط التنقل السفلي
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
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
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

// كلاس مساعد لعناصر قائمة الإعدادات
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

// ويدجت مساعد لأيقونات التواصل الاجتماعي
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