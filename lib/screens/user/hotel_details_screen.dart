import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/hotel_offer.dart';

class HotelDetailsScreen extends StatefulWidget {
  final HotelOffer hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            // App Bar مع الصور
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(),
              ),
            ),

          // محتوى الصفحة
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfo(),
                _buildAmenities(),
                _buildContactInfo(),
                _buildNearbyAttractions(),
                _buildRoomTypes(),
                _buildLocation(),
                _buildPolicies(),
                SizedBox(height: 100), // مساحة للزر السفلي
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingBar(),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.hotel.photos.isNotEmpty 
        ? widget.hotel.photos 
        : [widget.hotel.mainPhoto ?? ''];

    // إزالة الصور الفارغة
    final validImages = images.where((img) => img.isNotEmpty).toList();
    
    if (validImages.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemCount: validImages.length,
          itemBuilder: (context, index) {
            return Image.network(
              validImages[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            );
          },
        ),
        
        // مؤشر الصور
        if (validImages.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: validImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),

        // عداد الصور
        if (validImages.length > 1)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${validImages.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
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
      width: double.infinity,
      height: double.infinity,
      child: SvgPicture.asset(
        hotelImages[imageIndex],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم الفندق والتقييم
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.hotel.category != null) ...[
                      SizedBox(height: 4),
                      Text(
                        widget.hotel.category!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.hotel.rating != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        widget.hotel.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 16),

          // العنوان
          if (widget.hotel.address != null) ...[
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hotel.address!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],

          // المسافة
          if (widget.hotel.distanceDisplay.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.directions, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  widget.hotel.distanceDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],

          // الوصف
          if (widget.hotel.description != null) ...[
            Text(
              'نبذة عن الفندق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.hotel.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    if (widget.hotel.contactPhone == null && 
        widget.hotel.contactEmail == null && 
        widget.hotel.website == null) {
      return SizedBox();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الاتصال',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          
          if (widget.hotel.contactPhone != null) ...[
            _buildContactItem(
              icon: Icons.phone,
              title: 'الهاتف',
              value: widget.hotel.contactPhone!,
              onTap: () {
                // يمكن إضافة وظيفة الاتصال هنا
              },
            ),
            SizedBox(height: 12),
          ],
          
          if (widget.hotel.contactEmail != null) ...[
            _buildContactItem(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              value: widget.hotel.contactEmail!,
              onTap: () {
                // يمكن إضافة وظيفة إرسال إيميل هنا
              },
            ),
            SizedBox(height: 12),
          ],
          
          if (widget.hotel.website != null) ...[
            _buildContactItem(
              icon: Icons.language,
              title: 'الموقع الإلكتروني',
              value: widget.hotel.website!,
              onTap: () {
                // يمكن إضافة وظيفة فتح الموقع هنا
              },
            ),
          ],
          
          if (widget.hotel.checkInTime != null || widget.hotel.checkOutTime != null) ...[
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'أوقات تسجيل الدخول والخروج',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            
            if (widget.hotel.checkInTime != null) ...[
              _buildContactItem(
                icon: Icons.login,
                title: 'تسجيل الدخول',
                value: widget.hotel.checkInTime!,
              ),
              SizedBox(height: 8),
            ],
            
            if (widget.hotel.checkOutTime != null) ...[
              _buildContactItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                value: widget.hotel.checkOutTime!,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: onTap != null ? Colors.orange : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildNearbyAttractions() {
    if (widget.hotel.nearbyAttractions.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعالم السياحية القريبة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          ...widget.hotel.nearbyAttractions.map((attraction) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      attraction,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoomTypes() {
    if (widget.hotel.roomTypes.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أنواع الغرف المتاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.hotel.roomTypes.map((roomType) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bed, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      roomType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    if (widget.hotel.amenities.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المرافق والخدمات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.hotel.amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getAmenityIcon(amenity), 
                         color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      amenity,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    if (widget.hotel.latitude == null || widget.hotel.longitude == null) {
      return SizedBox();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الموقع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'خريطة الموقع',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lat: ${widget.hotel.latitude!.toStringAsFixed(4)}, '
                    'Lng: ${widget.hotel.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAdditionalPolicies() {
    return [
      'يُمنع التدخين في جميع أنحاء الفندق',
      'الحيوانات الأليفة مسموحة بشروط معينة',
      'يجب إبراز بطاقة هوية صالحة عند تسجيل الوصول',
      'الأطفال تحت سن 12 عامًا يقيمون مجانًا مع الوالدين',
      'خدمة الواي فاي مجانية في جميع أنحاء الفندق',
      'يتم تطبيق رسوم إضافية على الخدمات الإضافية',
    ];
  }

  Widget _buildPolicies() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.policy, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'سياسات الفندق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // سياسة الإلغاء
          _buildPolicyItem(
            icon: widget.hotel.freeCancellation ? Icons.check_circle : Icons.cancel,
            title: 'سياسة الإلغاء',
            description: widget.hotel.freeCancellation 
                ? 'إلغاء مجاني'
                : 'إلغاء غير مجاني',
            color: widget.hotel.freeCancellation ? Colors.green : Colors.red,
          ),
          
          if (widget.hotel.cancellationPolicy != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                widget.hotel.cancellationPolicy!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          // عرض سياسات إضافية ثابتة
          if (_getAdditionalPolicies().isNotEmpty) ...[
            SizedBox(height: 20),
            Text(
              'سياسات إضافية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            ..._getAdditionalPolicies().asMap().entries.map((entry) {
              final index = entry.key;
              final policy = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        policy,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          
          SizedBox(height: 16),
          
          // تفاصيل الحجز
          _buildPolicyItem(
            icon: Icons.calendar_today,
            title: 'تواريخ الإقامة',
            description: '${_formatDate(widget.hotel.checkInDate)} - ${_formatDate(widget.hotel.checkOutDate)}',
            color: Colors.blue,
          ),
          
          SizedBox(height: 12),
          
          _buildPolicyItem(
            icon: Icons.nights_stay,
            title: 'عدد الليالي',
            description: '${widget.hotel.nights} ليلة',
            color: Colors.purple,
          ),
          
          SizedBox(height: 12),
          
          _buildPolicyItem(
            icon: Icons.people,
            title: 'عدد الضيوف',
            description: '${widget.hotel.adults} بالغ - ${widget.hotel.rooms} غرفة',
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingBar() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hotel.formattedPrice,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'لكل ليلة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                context.push('/hotel-booking', extra: widget.hotel);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'احجز الآن',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();
    if (amenityLower.contains('واي فاي') || amenityLower.contains('wifi')) {
      return Icons.wifi;
    } else if (amenityLower.contains('مسبح') || amenityLower.contains('pool')) {
      return Icons.pool;
    } else if (amenityLower.contains('مطعم') || amenityLower.contains('restaurant')) {
      return Icons.restaurant;
    } else if (amenityLower.contains('سبا') || amenityLower.contains('spa')) {
      return Icons.spa;
    } else if (amenityLower.contains('جيم') || amenityLower.contains('gym')) {
      return Icons.fitness_center;
    } else if (amenityLower.contains('موقف') || amenityLower.contains('parking')) {
      return Icons.local_parking;
    } else if (amenityLower.contains('مكيف') || amenityLower.contains('air')) {
      return Icons.ac_unit;
    } else {
      return Icons.check_circle;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }
}