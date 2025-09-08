import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/hotel_offer.dart';

class HotelBookingScreen extends StatefulWidget {
  final HotelOffer hotel;

  const HotelBookingScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // بيانات الحجز
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  String _selectedTitle = 'السيد';
  String _selectedRoomType = 'غرفة مفردة';
  bool _needsTransport = false;
  bool _agreeToTerms = false;

  final List<String> _titles = ['السيد', 'السيدة', 'الآنسة'];
  final List<String> _roomTypes = ['غرفة مفردة', 'غرفة مزدوجة', 'جناح', 'غرفة عائلية'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'حجز الفندق',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // مؤشر التقدم
          _buildProgressIndicator(),
          
          // محتوى الصفحة
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildGuestInfoStep(),
                _buildBookingDetailsStep(),
                _buildPaymentStep(),
              ],
            ),
          ),
          
          // أزرار التنقل
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepIndicator(0, 'بيانات الضيف'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'تفاصيل الحجز'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'الدفع'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.orange : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.orange : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = _currentStep > step;
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: 24),
      color: isCompleted ? Colors.orange : Colors.grey[300],
    );
  }

  Widget _buildGuestInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('بيانات الضيف الرئيسي'),
            SizedBox(height: 20),
            
            // اللقب
            _buildDropdownField(
              label: 'اللقب',
              value: _selectedTitle,
              items: _titles,
              onChanged: (value) => setState(() => _selectedTitle = value!),
            ),
            
            SizedBox(height: 16),
            
            // الاسم الأول
            _buildTextFormField(
              controller: _firstNameController,
              label: 'الاسم الأول',
              hint: 'أدخل الاسم الأول',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم الأول مطلوب';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // الاسم الأخير
            _buildTextFormField(
              controller: _lastNameController,
              label: 'الاسم الأخير',
              hint: 'أدخل الاسم الأخير',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم الأخير مطلوب';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // البريد الإلكتروني
            _buildTextFormField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'البريد الإلكتروني مطلوب';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'البريد الإلكتروني غير صحيح';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // رقم الهاتف
            _buildTextFormField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '+20 1xxxxxxxxx',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'رقم الهاتف مطلوب';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('تفاصيل الحجز'),
          SizedBox(height: 20),
          
          // ملخص الفندق
          _buildHotelSummary(),
          
          SizedBox(height: 24),
          
          // نوع الغرفة
          _buildDropdownField(
            label: 'نوع الغرفة',
            value: _selectedRoomType,
            items: _roomTypes,
            onChanged: (value) => setState(() => _selectedRoomType = value!),
          ),
          
          SizedBox(height: 16),
          
          // خدمات إضافية
          _buildSectionTitle('خدمات إضافية'),
          SizedBox(height: 12),
          
          CheckboxListTile(
            title: Text('خدمة النقل من/إلى المطار'),
            subtitle: Text('رسوم إضافية قد تطبق'),
            value: _needsTransport,
            onChanged: (value) => setState(() => _needsTransport = value!),
            activeColor: Colors.orange,
            contentPadding: EdgeInsets.zero,
          ),
          
          SizedBox(height: 16),
          
          // طلبات خاصة
          _buildTextFormField(
            controller: _specialRequestsController,
            label: 'طلبات خاصة (اختياري)',
            hint: 'أي طلبات خاصة للفندق...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ملخص الحجز والدفع'),
          SizedBox(height: 20),
          
          // ملخص الحجز
          _buildBookingSummary(),
          
          SizedBox(height: 24),
          
          // طرق الدفع
          _buildSectionTitle('طريقة الدفع'),
          SizedBox(height: 16),
          
          _buildPaymentMethods(),
          
          SizedBox(height: 24),
          
          // الشروط والأحكام
          CheckboxListTile(
            title: Text('أوافق على الشروط والأحكام'),
            subtitle: Text('اقرأ الشروط والأحكام'),
            value: _agreeToTerms,
            onChanged: (value) => setState(() => _agreeToTerms = value!),
            activeColor: Colors.orange,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.hotel.mainPhoto != null
                    ? Image.network(
                        widget.hotel.mainPhoto!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            _buildPlaceholderImage(60),
                      )
                    : _buildPlaceholderImage(60),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.hotel.rating != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.hotel.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),
          
          _buildInfoRow('تاريخ الوصول', _formatDate(widget.hotel.checkInDate)),
          _buildInfoRow('تاريخ المغادرة', _formatDate(widget.hotel.checkOutDate)),
          _buildInfoRow('عدد الليالي', '${widget.hotel.nights} ليلة'),
          _buildInfoRow('عدد الضيوف', '${widget.hotel.adults} بالغ'),
          _buildInfoRow('عدد الغرف', '${widget.hotel.rooms} غرفة'),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    final totalPrice = widget.hotel.price * widget.hotel.nights;
    final taxes = totalPrice * 0.14; // ضريبة 14%
    final finalTotal = totalPrice + taxes;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildPriceRow('سعر الليلة الواحدة', '${widget.hotel.price.toStringAsFixed(0)} ${widget.hotel.currency}'),
          _buildPriceRow('عدد الليالي', '${widget.hotel.nights}'),
          _buildPriceRow('المجموع الفرعي', '${totalPrice.toStringAsFixed(0)} ${widget.hotel.currency}'),
          _buildPriceRow('الضرائب والرسوم', '${taxes.toStringAsFixed(0)} ${widget.hotel.currency}'),
          
          if (_needsTransport) 
            _buildPriceRow('خدمة النقل', '500 ${widget.hotel.currency}'),
          
          Divider(thickness: 2),
          _buildPriceRow(
            'المجموع الإجمالي', 
            '${(finalTotal + (_needsTransport ? 500 : 0)).toStringAsFixed(0)} ${widget.hotel.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentOption(
          icon: Icons.credit_card,
          title: 'بطاقة ائتمان',
          subtitle: 'Visa, MasterCard, American Express',
          isSelected: true,
        ),
        SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.account_balance,
          title: 'تحويل بنكي',
          subtitle: 'تحويل مباشر من البنك',
          isSelected: false,
        ),
        SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.payment,
          title: 'الدفع عند الوصول',
          subtitle: 'ادفع في الفندق مباشرة',
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.orange : Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.orange : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('السابق'),
              ),
            ),
            SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'تأكيد الحجز' : 'التالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(double size) {
    // قائمة الصور المتاحة
    final List<String> hotelImages = [
      'assets/images/hotel_1.svg',
      'assets/images/hotel_2.svg',
      'assets/images/hotel_3.svg',
      'assets/images/hotel_4.svg',
      'assets/images/hotel_5.svg',
      'assets/images/hotel_6.svg',
    ];
    
    // اختيار صورة بناءً على اسم الفندق لضمان الثبات
    final hotelNameHash = widget.hotel.name.hashCode;
    final imageIndex = hotelNameHash.abs() % hotelImages.length;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          hotelImages[imageIndex],
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 2) {
      if (_agreeToTerms) {
        _confirmBooking();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يجب الموافقة على الشروط والأحكام'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    
    try {
      // محاكاة عملية الحجز
      await Future.delayed(Duration(seconds: 2));
      
      // إظهار رسالة نجاح
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('تم الحجز بنجاح'),
            ],
          ),
          content: Text(
            'تم تأكيد حجزك في ${widget.hotel.name}. '
            'ستصلك رسالة تأكيد على البريد الإلكتروني.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                context.pop(); // إغلاق الحوار
                context.pop(); // العودة لشاشة التفاصيل
                context.pop(); // العودة لشاشة النتائج
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('موافق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحجز. حاول مرة أخرى.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}