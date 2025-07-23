import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.imageUrl, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final cardWidth = isTablet ? size.width * 0.16 : size.width * 0.27;
    final imgSize = isTablet ? size.width * 0.06 : size.width * 0.12;
    final fontSize = isTablet ? 20.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(right: isTablet ? 14.0 : 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 18 : 12),
                Image.asset(
                  imageUrl,
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: isTablet ? 16 : 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 14 : 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
