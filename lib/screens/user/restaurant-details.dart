import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/public_restaurant.dart';
import 'package:saba2v2/models/MenuSection.dart';
import 'package:saba2v2/models/MenuItem.dart';
import 'package:saba2v2/models/cart_item.dart';
import 'package:saba2v2/providers/cart_provider.dart';
import 'package:saba2v2/services/restaurant_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  PublicRestaurant? restaurant;
  List<MenuSection> menuSections = [];
  bool isLoading = true;
  bool isMenuLoading = false;
  String? errorMessage;
  String? menuErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
  }

  Future<void> _loadRestaurantDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final restaurantData = await _restaurantService.getPublicRestaurantById(widget.restaurantId);
      
      setState(() {
        restaurant = restaurantData;
        isLoading = false;
      });

      // بعد تحميل بيانات المطعم بنجاح، نحمل القائمة
      _loadMenuSections();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMenuSections() async {
    try {
      print('🍽️ [RestaurantDetails] بدء تحميل أقسام القائمة للمطعم: ${widget.restaurantId}');
      
      setState(() {
        isMenuLoading = true;
        menuErrorMessage = null;
      });

      // أولاً، نحتاج للحصول على restaurant_detail.id من بيانات المطعم
      String restaurantDetailId = widget.restaurantId; // القيمة الافتراضية
      
      if (restaurant?.restaurantDetail?.id != null) {
        restaurantDetailId = restaurant!.restaurantDetail!.id.toString();
        print('🍽️ [RestaurantDetails] استخدام restaurant_detail.id: $restaurantDetailId بدلاً من user.id: ${widget.restaurantId}');
      } else {
        print('⚠️ [RestaurantDetails] لم يتم العثور على restaurant_detail.id، استخدام القيمة الافتراضية: ${widget.restaurantId}');
      }

      final sections = await _restaurantService.getRestaurantMenuSections(restaurantDetailId);
      
      print('🍽️ [RestaurantDetails] تم تحميل ${sections.length} أقسام من القائمة');
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        print('🍽️ [RestaurantDetails] القسم $i: ${section.title} - ${section.items.length} عنصر');
        for (int j = 0; j < section.items.length; j++) {
          final item = section.items[j];
          print('🍽️ [RestaurantDetails]   العنصر $j: ${item.name} - ${item.price} جنيه - صورة: ${item.imageUrl}');
        }
      }
      
      setState(() {
        menuSections = sections;
        isMenuLoading = false;
      });
    } catch (e) {
      print('❌ [RestaurantDetails] خطأ في تحميل أقسام القائمة: $e');
      setState(() {
        menuErrorMessage = e.toString();
        isMenuLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFC8700)))
            : errorMessage != null
                ? _buildErrorWidget()
                : restaurant != null
                    ? _buildRestaurantDetails()
                    : const Center(child: Text('لم يتم العثور على المطعم')),
        floatingActionButton: _buildFloatingCartButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل تفاصيل المطعم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadRestaurantDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC8700),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantDetails() {
    final detail = restaurant!.restaurantDetail;
    
    return CustomScrollView(
      slivers: [
        // App Bar مع صورة الغلاف المحسنة
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFFFC8700),
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // صورة الغلاف
                detail?.profileImage != null
                    ? CachedNetworkImage(
                        imageUrl: detail!.profileImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFC8700).withOpacity(0.3),
                                const Color(0xFFFC8700).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFC8700)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFC8700).withOpacity(0.3),
                                const Color(0xFFFC8700).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.restaurant, size: 64, color: Colors.white),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFC8700).withOpacity(0.3),
                              const Color(0xFFFC8700).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.restaurant, size: 64, color: Colors.white),
                      ),
                // تدرج لوني محسن
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                // معلومات المطعم في الأسفل
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail?.restaurantName ?? restaurant!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (detail?.cuisineTypes.isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            detail!.cuisineTypes.join(' • '),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // محتوى الصفحة
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة الحالة والتقييم
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    
                    // أزرار الإجراءات السريعة
                    _buildQuickActionsCard(),
                    const SizedBox(height: 20),
                    
                    // قائمة الطعام (عينة)
                    _buildMenuPreviewCard(),
                    const SizedBox(height: 20),
                    
                    // معلومات المطعم
                    _buildRestaurantInfoCard(),
                    const SizedBox(height: 20),
                    
                    // معلومات التواصل والموقع
                    _buildContactInfoCard(),
                    const SizedBox(height: 20),
                    
                    // أوقات العمل
                    if (detail?.workingHours.isNotEmpty == true)
                      _buildWorkingHoursCard(),
                    const SizedBox(height: 20),
                    
                    // الفروع
                    if (detail?.branches.isNotEmpty == true)
                      _buildBranchesCard(),
                    const SizedBox(height: 20),
                    
                    // خدمات المطعم
                    _buildServicesCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final detail = restaurant!.restaurantDetail;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // حالة المطعم
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: detail?.isAvailableForOrders == true 
                        ? Colors.green[50] 
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    detail?.isAvailableForOrders == true 
                        ? Icons.check_circle 
                        : Icons.cancel,
                    color: detail?.isAvailableForOrders == true 
                        ? Colors.green 
                        : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail?.isAvailableForOrders == true ? 'مفتوح' : 'مغلق',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: detail?.isAvailableForOrders == true 
                        ? Colors.green[700] 
                        : Colors.red[700],
                  ),
                ),
                Text(
                  'الآن',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // خط فاصل
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[200],
          ),
          
          // التقييم
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC8700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFC8700),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '4.5',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'التقييم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // خط فاصل
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[200],
          ),
          
          // وقت التوصيل
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '30-45',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'دقيقة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الاتصال
          Expanded(
            child: _buildActionButton(
              icon: Icons.phone,
              label: 'اتصال',
              color: Colors.green,
              onTap: () => _makePhoneCall(restaurant!.phone),
            ),
          ),
          const SizedBox(width: 12),
          
          // زر الاتجاهات
          Expanded(
            child: _buildActionButton(
              icon: Icons.directions,
              label: 'الاتجاهات',
              color: Colors.blue,
              onTap: () {
                // يمكن إضافة وظيفة فتح الخرائط هنا
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // زر المشاركة
          Expanded(
            child: _buildActionButton(
              icon: Icons.share,
              label: 'مشاركة',
              color: const Color(0xFFFC8700),
              onTap: () {
                // يمكن إضافة وظيفة المشاركة هنا
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'قائمة الطعام',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showFullMenu();
                  },
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: Color(0xFFFC8700),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // عرض حالة تحميل القائمة أو الأخطاء
          if (isMenuLoading)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFC8700)),
              ),
            )
          else if (menuErrorMessage != null)
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا يمكن تحميل القائمة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadMenuSections,
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: Color(0xFFFC8700)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (menuSections.isEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد قائمة طعام متاحة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هذا المطعم لم يضف قائمة طعام بعد',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // للاختبار: الانتقال إلى مطعم يحتوي على قائمة
                        context.go('/restaurant-details/1');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFC8700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'جرب مطعم آخر (للاختبار)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // عرض عينة من عناصر القائمة الحقيقية
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _getPreviewItems().length,
                itemBuilder: (context, index) {
                  final item = _getPreviewItems()[index];
                  return _buildRealMenuItemCard(item);
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(int index) {
    final items = [
      {'name': 'بيتزا مارجريتا', 'price': '200', 'image': 'assets/images/pizza.jpg'},
      {'name': 'برجر دجاج', 'price': '150', 'image': 'assets/images/burger.jpg'},
      {'name': 'دجاج مشوي', 'price': '180', 'image': 'assets/images/grill.jpg'},
      {'name': 'آيس كريم', 'price': '80', 'image': 'assets/images/ايس كريم.png'},
    ];
    
    final item = items[index];
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة الطبق
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // معلومات الطبق
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['price']} ج.م',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFC8700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC8700),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildRestaurantInfoCard() {
    final detail = restaurant!.restaurantDetail;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // لوجو المطعم
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: detail?.logoImage != null
                        ? CachedNetworkImage(
                            imageUrl: detail!.logoImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // معلومات المطعم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail?.restaurantName ?? restaurant!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (detail?.cuisineTypes.isNotEmpty == true)
                        Text(
                          detail!.cuisineTypes.join(' • '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant!.governorate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // حالة المطعم
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: detail?.isAvailableForOrders == true 
                        ? Colors.green[100] 
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: detail?.isAvailableForOrders == true 
                              ? Colors.green 
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        detail?.isAvailableForOrders == true ? 'مفتوح الآن' : 'مغلق الآن',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: detail?.isAvailableForOrders == true 
                              ? Colors.green[700] 
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (restaurant!.theBest)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC8700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: const Color(0xFFFC8700)),
                        const SizedBox(width: 4),
                        Text(
                          'الأفضل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFC8700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات التواصل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // رقم الهاتف
            _buildContactItem(
              icon: Icons.phone,
              title: 'رقم الهاتف',
              value: restaurant!.phone,
              onTap: () {
                // يمكن إضافة وظيفة الاتصال هنا
              },
            ),
            
            // البريد الإلكتروني
            _buildContactItem(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              value: restaurant!.email,
              onTap: () {
                // يمكن إضافة وظيفة إرسال بريد إلكتروني هنا
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFFFC8700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursCard() {
    final workingHours = restaurant!.restaurantDetail!.workingHours;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أوقات العمل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            ...workingHours.map((hour) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hour.day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${hour.from} - ${hour.to}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesCard() {
    final branches = restaurant!.restaurantDetail!.branches;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الفروع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            ...branches.map((branch) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          branch.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (branch.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          branch.phone!,
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
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    final detail = restaurant!.restaurantDetail!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الخدمات المتاحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // خدمة التوصيل
            _buildServiceItem(
              icon: Icons.delivery_dining,
              title: 'خدمة التوصيل',
              isAvailable: detail.deliveryAvailable,
              subtitle: detail.deliveryAvailable 
                  ? 'تكلفة التوصيل: ${detail.deliveryCostPerKm} ج.م/كم'
                  : null,
            ),
            
            // حجز الطاولات
            _buildServiceItem(
              icon: Icons.table_restaurant,
              title: 'حجز الطاولات',
              isAvailable: detail.tableReservationAvailable,
              subtitle: detail.tableReservationAvailable 
                  ? 'حد أقصى ${detail.maxPeoplePerReservation} أشخاص'
                  : null,
            ),
            
            // إيداع مطلوب
            if (detail.depositRequired)
              _buildServiceItem(
                icon: Icons.payment,
                title: 'إيداع مطلوب',
                isAvailable: true,
                subtitle: detail.depositAmount != null 
                    ? 'مبلغ الإيداع: ${detail.depositAmount} ج.م'
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required bool isAvailable,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? Colors.green[100] 
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: isAvailable 
                  ? Colors.green[700] 
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isAvailable 
                        ? Colors.black87 
                        : Colors.grey[600],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  // دالة للحصول على عينة من عناصر القائمة للمعاينة
  List<MenuItem> _getPreviewItems() {
    List<MenuItem> allItems = [];
    for (var section in menuSections) {
      allItems.addAll(section.items);
    }
    // عرض أول 5 عناصر كحد أقصى
    return allItems.take(5).toList();
  }

  // دالة بناء بطاقة عنصر القائمة الحقيقي
  Widget _buildRealMenuItemCard(MenuItem item) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemQuantity = cartProvider.getItemQuantity(item.id);
        
        return Container(
          width: 160,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الطبق
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 100,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFC8700),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                ),
              ),
              
              // معلومات الطبق
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price} ج.م',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFC8700),
                          ),
                        ),
                        // أزرار إدارة السلة
                        if (itemQuantity > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC8700),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // زر التقليل
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    onTap: () => cartProvider.removeItem(item.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                // عرض الكمية
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text(
                                    '$itemQuantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // زر الزيادة
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                    onTap: () => _addToCart(item, cartProvider),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // زر الإضافة الأولى
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => _addToCart(item, cartProvider),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFC8700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة عرض القائمة الكاملة
  void _showFullMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // عنوان القائمة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'قائمة الطعام الكاملة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // محتوى القائمة
              Expanded(
                child: isMenuLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFC8700)),
                      )
                    : menuErrorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'خطأ في تحميل القائمة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  menuErrorMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _loadMenuSections,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFC8700),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          )
                        : menuSections.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد قائمة طعام متاحة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(20),
                                itemCount: menuSections.length,
                                itemBuilder: (context, sectionIndex) {
                                  final section = menuSections[sectionIndex];
                                  return _buildFullMenuSection(section);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء قسم القائمة الكامل
  Widget _buildFullMenuSection(MenuSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFC8700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFC8700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: const Color(0xFFFC8700),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFC8700),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC8700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${section.items.length} عنصر',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // عناصر القسم
          if (section.items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Text(
                  'لا توجد عناصر في هذا القسم',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ...section.items.map((item) => _buildFullMenuItem(item)).toList(),
        ],
      ),
    );
  }

  // دالة بناء عنصر القائمة الكامل
  Widget _buildFullMenuItem(MenuItem item) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemQuantity = cartProvider.getItemQuantity(item.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // صورة الطبق
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFC8700),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // معلومات الطبق
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.price} ج.م',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFC8700),
                            ),
                          ),
                          
                          // أزرار إدارة السلة
                          _buildCartControls(item, cartProvider, itemQuantity),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة بناء أزرار التحكم في السلة
  Widget _buildCartControls(MenuItem item, CartProvider cartProvider, int quantity) {
    if (quantity == 0) {
      // زر الإضافة الأولى
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFC8700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _addToCart(item, cartProvider),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    } else {
      // أزرار التحكم في الكمية
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التقليل
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                onTap: () => cartProvider.removeItem(item.id),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove,
                    color: Color(0xFFFC8700),
                    size: 16,
                  ),
                ),
              ),
            ),
            // عرض الكمية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700),
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            // زر الزيادة
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                onTap: () => _addToCart(item, cartProvider),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.add,
                    color: Color(0xFFFC8700),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // دالة إضافة عنصر للسلة
  void _addToCart(MenuItem item, CartProvider cartProvider) {
    if (restaurant?.restaurantDetail?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: لا يمكن تحديد معرف المطعم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      cartProvider.addItem(item, restaurant!.restaurantDetail!.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة ${item.name} للسلة'),
          backgroundColor: const Color(0xFFFC8700),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(e.toString()),
           backgroundColor: Colors.red,
         ),
       );
     }
   }

   // دالة بناء مؤشر السلة العائم
   Widget _buildFloatingCartButton() {
     return Consumer<CartProvider>(
       builder: (context, cartProvider, child) {
         if (cartProvider.isEmpty) {
           return const SizedBox.shrink();
         }

         return Container(
           margin: const EdgeInsets.only(bottom: 20),
           child: FloatingActionButton.extended(
             onPressed: () => context.push('/cart'),
             backgroundColor: const Color(0xFFFC8700),
             foregroundColor: Colors.white,
             elevation: 8,
             icon: Stack(
               children: [
                 const Icon(Icons.shopping_cart, size: 24),
                 if (cartProvider.totalItems > 0)
                   Positioned(
                     right: -2,
                     top: -2,
                     child: Container(
                       padding: const EdgeInsets.all(2),
                       decoration: BoxDecoration(
                         color: Colors.red,
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Colors.white, width: 1),
                       ),
                       constraints: const BoxConstraints(
                         minWidth: 18,
                         minHeight: 18,
                       ),
                       child: Text(
                         '${cartProvider.totalItems}',
                         style: const TextStyle(
                           color: Colors.white,
                           fontSize: 10,
                           fontWeight: FontWeight.bold,
                         ),
                         textAlign: TextAlign.center,
                       ),
                     ),
                   ),
               ],
             ),
             label: Text(
               'السلة (${cartProvider.totalPrice.toStringAsFixed(0)} ج.م)',
               style: const TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 14,
               ),
             ),
           ),
         );
       },
     );
   }
 }
