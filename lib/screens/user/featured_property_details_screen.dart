import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/featured_property.dart';
import '../../providers/featured_properties_provider.dart';
import '../../services/laravel_service.dart';
import '../../providers/auth_provider.dart';

class FeaturedPropertyDetailsScreen extends StatelessWidget {
  final String propertyId;

  const FeaturedPropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<FeaturedPropertiesProvider>(
        builder: (context, provider, child) {
          final property = provider.getFeaturedPropertyById(int.parse(propertyId));

          if (property == null) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title: const Text(
                  'تفاصيل العقار',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFFFC8700),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: Text(
                  'العقار غير موجود',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(
                property.address,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFFC8700),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة العقار
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        property.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // معلومات أساسية
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFFFC8700),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                property.address,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              property.type,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC8700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: const Color(0xFFFC8700),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatPrice(property.price)} جنيه',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFC8700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // المواصفات
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFFFC8700),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'المواصفات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // الصف الأول - الغرف والحمامات
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecCard(
                                Icons.bed,
                                'غرف النوم',
                                '${property.bedrooms}',
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSpecCard(
                                Icons.bathroom,
                                'الحمامات',
                                '${property.bathrooms}',
                                const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // الصف الثاني - المساحة والحالة
                        Row(
                          children: [
                            if (property.area.isNotEmpty)
                              Expanded(
                                child: _buildSpecCard(
                                  Icons.straighten,
                                  'المساحة',
                                  property.area,
                                  const Color(0xFF9C27B0),
                                ),
                              ),
                            if (property.area.isNotEmpty) const SizedBox(width: 12),
                            Expanded(
                              child: _buildSpecCard(
                                property.isReady ? Icons.check_circle : Icons.schedule,
                                'الحالة',
                                property.isReady ? 'جاهز' : 'غير جاهز',
                                property.isReady ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                        
                        // معلومات إضافية
                        if (property.view.isNotEmpty || property.paymentMethod.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          if (property.view.isNotEmpty)
                            _buildInfoRow(Icons.visibility, 'الإطلالة', property.view),
                          
                          if (property.view.isNotEmpty && property.paymentMethod.isNotEmpty)
                            const SizedBox(height: 12),
                          
                          if (property.paymentMethod.isNotEmpty)
                            _buildInfoRow(Icons.payment, 'طريقة الدفع', property.paymentMethod),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الوصف
                  if (property.description.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الوصف',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            property.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // معلومات المزود
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.05),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text(
                  //         'معلومات المزود',
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.black87,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),
                  //       Row(
                  //         children: [
                  //           Container(
                  //             width: 50,
                  //             height: 50,
                  //             decoration: BoxDecoration(
                  //               color: const Color(0xFFFC8700).withOpacity(0.1),
                  //               borderRadius: BorderRadius.circular(25),
                  //             ),
                  //             child: const Icon(
                  //               Icons.business,
                  //               color: Color(0xFFFC8700),
                  //               size: 24,
                  //             ),
                  //           ),
                  //           const SizedBox(width: 16),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   property.provider.name,
                  //                   style: const TextStyle(
                  //                     fontSize: 16,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.black87,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 4),
                  //                 Text(
                  //                   property.provider.phone,
                  //                   style: TextStyle(
                  //                     fontSize: 14,
                  //                     color: Colors.grey[600],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           IconButton(
                  //             onPressed: () {
                  //               // يمكن إضافة وظيفة الاتصال هنا
                  //             },
                  //             icon: const Icon(
                  //               Icons.phone,
                  //               color: Color(0xFFFC8700),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAppointmentDialog(context, property),
              backgroundColor: const Color(0xFFFC8700),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.calendar_today),
              label: const Text(
                'حجز موعد معاينة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFC8700),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFC8700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFC8700),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(String price) {
    try {
      final numPrice = double.parse(price);
      if (numPrice >= 1000000) {
        return '${(numPrice / 1000000).toStringAsFixed(1)} مليون';
      } else if (numPrice >= 1000) {
        return '${(numPrice / 1000).toStringAsFixed(0)} ألف';
      }
      return numPrice.toStringAsFixed(0);
    } catch (e) {
      return price;
    }
  }

  void _showAppointmentDialog(BuildContext context, FeaturedProperty property) {
    final TextEditingController noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: const Color(0xFFFC8700),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'حجز موعد معاينة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات العقار
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home,
                              color: const Color(0xFFFC8700),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                property.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // اختيار التاريخ
                      const Text(
                        'تاريخ المعاينة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: const Color(0xFFFC8700),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // اختيار الوقت
                      const Text(
                        'وقت المعاينة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (context, child) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: const Color(0xFFFC8700),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ملاحظات
                      const Text(
                        'ملاحظات (اختياري)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'أضف أي ملاحظات أو متطلبات خاصة...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFC8700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _bookAppointment(
                      context,
                      property.id,
                      selectedDate,
                      selectedTime,
                      noteController.text,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFC8700),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'حجز الموعد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _bookAppointment(
    BuildContext context,
    int propertyId,
    DateTime date,
    TimeOfDay time,
    String note,
  ) async {
    try {
      // إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFC8700),
          ),
        ),
      );

      // تنسيق التاريخ والوقت
      final DateTime appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final String formattedDateTime = 
          '${appointmentDateTime.year}-${appointmentDateTime.month.toString().padLeft(2, '0')}-${appointmentDateTime.day.toString().padLeft(2, '0')} ${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}';

      // الحصول على التوكن
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        Navigator.pop(context); // إغلاق مؤشر التحميل
        Navigator.pop(context); // إغلاق النافذة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // إرسال الطلب
      final response = await LaravelService.post(
        '/appointments',
        data: {
          'property_id': propertyId,
          'date': formattedDateTime,
          'note': note.isEmpty ? 'أرغب في معاينة العقار في هذا الوقت' : note,
        },
        token: token,
      );

      Navigator.pop(context); // إغلاق مؤشر التحميل
      Navigator.pop(context); // إغلاق النافذة

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حجز الموعد بنجاح'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'موافق',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'فشل في حجز الموعد');
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق مؤشر التحميل
      Navigator.pop(context); // إغلاق النافذة
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حجز الموعد: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'موافق',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}