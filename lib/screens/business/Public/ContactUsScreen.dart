import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final orangeColor = const Color(0xFFFC8700);

    // روابط أيقونات التواصل
    final List<Map<String, String>> socialLinks = [
      {
        "svg": "assets/icons/telephone_901122.svg",
        "url": "tel:+20123456789", // مثال رقم هاتف
      },
      {
        "svg": "assets/icons/youtube_246153.svg",
        "url": "https://youtube.com",
      },
      {
        "svg": "assets/icons/twitter_2335289.svg",
        "url": "https://twitter.com",
      },
      {
        "svg": "assets/icons/facebook-logo_1384879.svg",
        "url": "https://facebook.com",
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          title: const Text('تواصل معنا', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 18,
            horizontal: isTablet ? screenWidth * 0.14 : 10,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildTextField('اسم'),
                    const SizedBox(height: 12),
                    _buildTextField('البريد الإلكتروني'),
                    const SizedBox(height: 12),
                    _buildTextField('رقم الجوال'),
                    const SizedBox(height: 12),
                    _buildTextField('الرسالة', minLines: 3, maxLines: 5),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // هنا يتم إضافة منطق الإرسال لاحقًا
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال الرسالة (عرض تجريبي)')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إرسال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "تابعونا على",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(socialLinks.length, (idx) {
                  final item = socialLinks[idx];
                  return Row(
                    children: [
                      _SocialIcon(
                        svgPath: item["svg"]!,
                        onTap: () => _launchURL(item["url"]!),
                      ),
                      if (idx != socialLinks.length - 1) const SizedBox(width: 16),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, {
        int minLines = 1,
        int maxLines = 1,
      }) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 15),
    );
  }

  static Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SocialIcon extends StatelessWidget {
  final String svgPath;
  final VoidCallback onTap;
  const _SocialIcon({required this.svgPath, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 7,
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
      ),
    );
  }
}
