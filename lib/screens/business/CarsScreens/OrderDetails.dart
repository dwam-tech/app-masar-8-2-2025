import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isTripStarted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripState();
  }

  Future<void> _loadTripState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isTripStarted = prefs.getBool('trip_started') ?? false;
      isLoading = false;
    });
  }

  Future<void> _setTripState(bool started) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trip_started', started);
    setState(() {
      isTripStarted = started;
    });
  }

  // لمنع الخروج بالزر الخلفي أثناء الرحلة
  Future<bool> _onWillPop() async {
    if (isTripStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا يمكنك الخروج أثناء الرحلة!"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isLoading) {
      // أثناء التحميل من SharedPreferences
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            automaticallyImplyLeading: false, // حذف زر الرجوع
            title: const Text(
              "تفاصيل الطلب",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (!isTripStarted)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // صورة الخريطة

              // الكارد السفلي
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.09),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصف الأول: نوع الطلب والسعر
                      Row(
                        children: [
                          const Text("# نوع الطلب: ",
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                          const Text("توصيل",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          const Spacer(),
                          Text("2800 جم",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                                fontSize: 17,
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // العميل وأزرار التواصل
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                                "https://randomuser.me/api/portraits/men/32.jpg"),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "عبدالله حماد",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const Spacer(),
                          _ContactButton(
                            icon: Icons.chat_bubble_outline,
                            color: Colors.orange,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 10),
                          _ContactButton(
                            icon: Icons.call,
                            color: Colors.orange,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // من
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.orange, size: 20),
                          const SizedBox(width: 5),
                          const Text("من", style: TextStyle(color: Colors.black54, fontSize: 14)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("شيراتون - مصر الجديدة",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // إلى
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.orange, size: 20),
                          const SizedBox(width: 5),
                          const Text("إلى", style: TextStyle(color: Colors.black54, fontSize: 14)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("التجمع الخامس - القاهرة",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // زر الرحلة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!isTripStarted) {
                              await _setTripState(true);
                            } else {
                              // إنهاء الرحلة
                              await _setTripState(false);
                              if (mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/RealStateHomeScreen', // غيرها لمسار الهوم
                                      (route) => false,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTripStarted ? Colors.red : const Color(0xFFFC8700),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isTripStarted ? "إنهاء الرحلة" : "ابدأ الرحلة",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
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

// زر التواصل الدائري
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({required this.icon, required this.color, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.11),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
