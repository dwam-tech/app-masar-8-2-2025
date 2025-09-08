import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CarServiceSelectionScreen extends StatelessWidget {
  const CarServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'خدمة حجز سيارة',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // العنوان
              const Text(
                'اختار الخدمة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // خيارات الخدمة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // تأجير سيارة
                  _buildServiceOption(
                    context: context,
                    icon: 'assets/images/831213db05735fd4728fe40475de9d4a042eb257.png',
                    title: 'تأجير سيارة',
                    onTap: () {
                      // التنقل إلى صفحة تأجير السيارات
                      context.push('/car-rental');
                    },
                  ),
                  
                  // طلب توصيلة
                  _buildServiceOption(
                    context: context,
                    icon: 'assets/images/bf7d94285501a91ebf31912b64b8e8e809e132d1.png',
                    title: 'توصيلة',
                    onTap: () {
                      // التنقل إلى صفحة طلب التوصيلة
                      context.push('/delivery-request');
                    },
                  ),
                ],
              ),
              
              const Spacer(),
              
              // الرسم التوضيحي في الأسفل
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/28910691_7506747 1.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOption({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      title == 'تأجير سيارة' ? Icons.car_rental : Icons.local_taxi,
                      size: 50,
                      color: const Color(0xFFFC8700),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // النص
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}