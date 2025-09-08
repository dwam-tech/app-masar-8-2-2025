import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/hotel_search_provider.dart';
import '../../models/hotel_offer.dart';
import '../../utils/hotel_theme.dart';

class HotelResultsScreen extends StatefulWidget {
  @override
  State<HotelResultsScreen> createState() => _HotelResultsScreenState();
}

class _HotelResultsScreenState extends State<HotelResultsScreen> {
  String _sortBy = 'السعر';
  bool _showFilters = false;
  
  // فلاتر
  double? _maxPriceFilter;
  double? _minRatingFilter;
  bool _freeCancellationOnly = false;
  final _hotelNameFilterController = TextEditingController();

  @override
  void dispose() {
    _hotelNameFilterController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelSearchProvider>();
    final results = provider.results;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HotelTheme.backgroundColor,
        appBar: AppBar(
          title: Row(
            children: [
              HotelTheme.buildIconWithBackground(
                  Icons.hotel,
                  backgroundColor: HotelTheme.primaryOrange.withOpacity(0.1),
                  iconColor: HotelTheme.primaryOrange,
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  provider.getCityNameFromCode(provider.lastSearchCityCode ?? ''),
                  style: HotelTheme.headingSmall.copyWith(
                    color: HotelTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (provider.lastSearchCheckInDate != null && provider.lastSearchCheckOutDate != null) ...[
                Icon(
                  Icons.calendar_today,
                  color: HotelTheme.primaryOrange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${_formatDate(provider.lastSearchCheckInDate!)} - ${_formatDate(provider.lastSearchCheckOutDate!)}',
                    style: HotelTheme.bodySmall.copyWith(
                      color: HotelTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: HotelTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showFilters 
                        ? HotelTheme.primaryOrange.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: _showFilters 
                        ? HotelTheme.primaryOrange
                        : HotelTheme.textPrimary,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
              ),
            ),
          ],
        ),
      body: Column(
        children: [
          // Filter Section
          if (_showFilters) _buildFilterSection(),
          
          // Sort Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: HotelTheme.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ترتيب حسب:',
                  style: HotelTheme.bodyMedium.copyWith(
                    color: HotelTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: HotelTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: HotelTheme.primaryOrange.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: HotelTheme.primaryOrange,
                      size: 20,
                    ),
                    items: ['السعر', 'التقييم', 'المسافة', 'الاسم'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: HotelTheme.bodyMedium.copyWith(
                            color: HotelTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _sortBy = newValue!);
                      _sortResults();
                    },
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HotelTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hotel,
                        color: HotelTheme.primaryOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${results.length} فندق',
                        style: HotelTheme.bodySmall.copyWith(
                          color: HotelTheme.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results List
          Expanded(
            child: provider.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: HotelTheme.primaryOrange,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'جاري البحث عن الفنادق...',
                          style: HotelTheme.bodyMedium.copyWith(
                            color: HotelTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : provider.error != null
                    ? Center(child: _buildErrorWidget(provider.error!))
                    : results.isEmpty
                        ? Center(child: _buildEmptyResultsWidget())
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: results.length,
                            itemBuilder: (ctx, idx) {
                              final hotel = results[idx];
                              return _buildHotelCard(hotel);
                            },
                          ),
          ),
        ],
      ),
    ));
  }

  // =========================================================================
  // ============================ ويدجت الفلاتر (مُحَدَّث) =============================
  // =========================================================================
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: HotelTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: HotelTheme.lightGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                HotelTheme.buildIconWithBackground(
                  Icons.filter_list,
                  backgroundColor: HotelTheme.primaryOrange.withOpacity(0.1),
                  iconColor: HotelTheme.primaryOrange,
                ),
                const SizedBox(width: 12),
                Text(
                  'فلاتر البحث',
                  style: HotelTheme.headingMedium.copyWith(
                    color: HotelTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Content (wrapped in SingleChildScrollView for keyboard)
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  // -- تحسين --
                  // استخدام Wrap لجعل الفلاتر متجاوبة
                  // ستظهر الفلاتر بجانب بعضها على الشاشات الكبيرة، وتحت بعضها على الشاشات الصغيرة
                  Wrap(
                    spacing: 16.0,      // المسافة الأفقية بين العناصر
                    runSpacing: 20.0,    // المسافة العمودية عندما تنتقل العناصر لسطر جديد
                    children: [
                      // Price Filter
                      _buildResponsiveFilterItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحد الأقصى للسعر',
                              style: HotelTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: HotelTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: HotelTheme.inputDecoration.copyWith(
                                hintText: 'مثال: 500',
                                hintStyle: HotelTheme.bodyMedium.copyWith(
                                  color: HotelTheme.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: HotelTheme.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              onChanged: (value) {
                                _maxPriceFilter = double.tryParse(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Rating Filter
                      _buildResponsiveFilterItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التقييم الأدنى',
                              style: HotelTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: HotelTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<double?>(
                              value: _minRatingFilter,
                              decoration: HotelTheme.inputDecoration.copyWith(
                                hintText: 'اختر التقييم',
                                hintStyle: HotelTheme.bodyMedium.copyWith(
                                  color: HotelTheme.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.star,
                                  color: HotelTheme.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(value: null, child: Text('أي تقييم', style: HotelTheme.bodyMedium)),
                                _buildRatingMenuItem(3.0, "3.0 فأكثر", 3),
                                _buildRatingMenuItem(4.0, "4.0 فأكثر", 4),
                                _buildRatingMenuItem(4.5, "4.5 فأكثر", 4, hasHalf: true),
                              ],
                              onChanged: (value) {
                                setState(() => _minRatingFilter = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Hotel Name Filter
                  Text(
                    'اسم الفندق',
                    style: HotelTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: HotelTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hotelNameFilterController,
                    decoration: HotelTheme.inputDecoration.copyWith(
                      hintText: 'ابحث باسم الفندق',
                      hintStyle: HotelTheme.bodyMedium.copyWith(
                        color: HotelTheme.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: HotelTheme.primaryOrange,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Free Cancellation Filter
                  Container(
                    decoration: BoxDecoration(
                      color: HotelTheme.primaryOrange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HotelTheme.primaryOrange.withOpacity(0.1),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        'إلغاء مجاني فقط',
                        style: HotelTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'عرض الفنادق التي تسمح بالإلغاء المجاني',
                        style: HotelTheme.bodySmall.copyWith(
                          color: HotelTheme.textSecondary,
                        ),
                      ),
                      value: _freeCancellationOnly,
                      onChanged: (value) {
                        setState(() => _freeCancellationOnly = value ?? false);
                      },
                      activeColor: HotelTheme.primaryOrange,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: 'تطبيق الفلاتر',
                          icon: Icons.check,
                          onPressed: _applyFilters,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          text: 'إعادة تعيين',
                          icon: Icons.refresh,
                          onPressed: _resetFilters,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مساعد لإنشاء عنصر فلتر متجاوب
  Widget _buildResponsiveFilterItem({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // إذا كانت الشاشة واسعة، اجعل العرض نصف المساحة المتاحة
        // إذا كانت ضيقة، اجعل العرض يملأ الشاشة
        final bool isWide = constraints.maxWidth > 350;
        return SizedBox(
          width: isWide ? (constraints.maxWidth / 2) - 8 : double.infinity,
          child: child,
        );
      },
    );
  }

  // ويدجت مساعد لإنشاء عناصر قائمة التقييم
  DropdownMenuItem<double> _buildRatingMenuItem(double value, String text, int starCount, {bool hasHalf = false}) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Text(text, style: HotelTheme.bodyMedium),
          const SizedBox(width: 8),
          ...List.generate(starCount, (index) => Icon(
            Icons.star,
            size: 14,
            color: HotelTheme.primaryOrange,
          )),
          if (hasHalf)
            Icon(
              Icons.star_half,
              size: 14,
              color: HotelTheme.primaryOrange,
            ),
        ],
      ),
    );
  }

  // ويدجت مساعد لإنشاء الأزرار الرئيسية والثانوية
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? null : Colors.white,
      foregroundColor: isPrimary ? Colors.white : HotelTheme.primaryOrange,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: isPrimary ? BorderSide.none : BorderSide(color: HotelTheme.primaryOrange, width: 1.5),
    );

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: HotelTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return Container(
      height: 60,
      decoration: isPrimary ? BoxDecoration(
        gradient: HotelTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ) : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }


  Widget _buildHotelCard(HotelOffer hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: HotelTheme.elevatedCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed('hotelDetails', extra: hotel);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Image with overlay
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      color: HotelTheme.backgroundColor,
                    ),
                    child: hotel.mainPhoto != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              hotel.mainPhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                            ),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.5, 0.7, 1.0],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                  ),
                  // Rating badge
                  if (hotel.rating != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildBadge(
                        text: hotel.rating!.toStringAsFixed(1), 
                        icon: Icons.star, 
                        gradient: HotelTheme.primaryGradient
                      ),
                    ),
                  // Free cancellation badge
                  if (hotel.freeCancellation)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildBadge(
                        text: 'إلغاء مجاني', 
                        icon: Icons.check_circle, 
                        color: Colors.green,
                        fontSize: 11
                      ),
                    ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name and Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name,
                            style: HotelTheme.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hotel.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: HotelTheme.lightGradient,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: HotelTheme.primaryOrange.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              hotel.category!,
                              style: HotelTheme.bodySmall.copyWith(
                                color: HotelTheme.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Address & Distance
                    if (hotel.address != null)
                      _buildInfoRow(icon: Icons.location_on, text: hotel.address!),
                    if (hotel.distanceDisplay.isNotEmpty)
                      _buildInfoRow(icon: Icons.directions_walk, text: hotel.distanceDisplay),

                    // Amenities
                    if (hotel.amenities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: hotel.amenities.take(4).map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: HotelTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: HotelTheme.primaryOrange.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: HotelTheme.bodySmall.copyWith(
                                color: HotelTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Price section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: HotelTheme.lightGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HotelTheme.primaryOrange.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.formattedPrice,
                                style: HotelTheme.headingMedium.copyWith(
                                  color: HotelTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'لكل ليلة',
                                style: HotelTheme.bodySmall.copyWith(
                                  color: HotelTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: HotelTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'عرض التفاصيل',
                                  style: HotelTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: HotelTheme.textSecondary, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: HotelTheme.bodySmall.copyWith(color: HotelTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadge({
    required String text, 
    required IconData icon,
    Gradient? gradient,
    Color? color,
    double fontSize = 12
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient != null ? HotelTheme.primaryOrange : color ?? Colors.black).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: HotelTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
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
    
    // اختيار صورة عشوائية بناءً على الوقت الحالي
    final randomIndex = DateTime.now().millisecondsSinceEpoch % hotelImages.length;
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SvgPicture.asset(
          hotelImages[randomIndex],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      ),
      );
  }

  Widget _buildErrorWidget(String error) {
    return _buildStatusCard(
      icon: Icons.error_outline,
      iconColor: Colors.red,
      title: 'حدث خطأ في البحث',
      message: error,
      buttonText: 'العودة للبحث',
      onPressed: () => context.pop(),
    );
  }
  
  Widget _buildEmptyResultsWidget() {
    return _buildStatusCard(
      icon: Icons.hotel_outlined,
      iconColor: HotelTheme.primaryOrange,
      title: 'لا توجد فنادق متاحة',
      message: 'جرب تعديل معايير البحث أو اختيار تواريخ أخرى',
      buttonText: 'بحث جديد',
      onPressed: () => context.pop(),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: HotelTheme.cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: iconColor),
          ),
          const SizedBox(height: 24),
          Text(title, style: HotelTheme.headingMedium.copyWith(color: HotelTheme.textPrimary)),
          const SizedBox(height: 12),
          Text(message, style: HotelTheme.bodyMedium.copyWith(color: HotelTheme.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          _buildActionButton(
            text: buttonText,
            icon: Icons.arrow_back,
            onPressed: onPressed,
            isPrimary: true,
          )
        ],
      ),
    );
  }


  void _sortResults() {
    context.read<HotelSearchProvider>().sortResults(_sortBy);
  }

  void _applyFilters() {
    context.read<HotelSearchProvider>().filterResults(
      maxPrice: _maxPriceFilter,
      minRating: _minRatingFilter,
      hotelName: _hotelNameFilterController.text.trim().isNotEmpty ? _hotelNameFilterController.text.trim() : null,
      freeCancellation: _freeCancellationOnly,
    );
    setState(() => _showFilters = false);
  }

  void _resetFilters() {
    setState(() {
      _maxPriceFilter = null;
      _minRatingFilter = null;
      _freeCancellationOnly = false;
      _hotelNameFilterController.clear();
    });
    context.read<HotelSearchProvider>().resetFilters();
    setState(() => _showFilters = false);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}";
    } catch (e) {
      return dateString;
    }
  }
}