import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/my_bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final OrderService _orderService = OrderService();
  bool _isPlacingOrder = false;
  String? _addressUrl; // رابط Google Maps للعنوان المحدد

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  Future<void> _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.isEmpty) {
      _showErrorDialog('السلة فارغة');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorDialog('يرجى إدخال عنوان التوصيل بالتفصيل');
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final orderData = cartProvider.toOrderJson(
        deliveryAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      print('🛒 [CartScreen] إرسال الطلب: $orderData');

      final response = await _orderService.createOrder(
        restaurantId: orderData['restaurant_id'],
        items: List<Map<String, dynamic>>.from(orderData['items']),
        deliveryAddress: orderData['delivery_address'],
        notes: orderData['notes'],
      );

      // مسح السلة بعد نجاح الطلب
      cartProvider.clearCart();

      // إظهار رسالة نجاح
      if (mounted) {
        _showSuccessDialog(response['message'] ?? 'تم إرسال الطلب بنجاح');
      }
    } catch (e) {
      print('❌ [CartScreen] خطأ في إرسال الطلب: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // فتح خريطة Google Maps لاختيار الموقع
  Future<void> _selectLocationOnMap() async {
    try {
      // الحصول على الموقع الحالي
      Position? currentPosition;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          currentPosition = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        print('خطأ في الحصول على الموقع: $e');
      }

      // إعداد الموقع الافتراضي (القاهرة)
      final LatLng initialPosition = currentPosition != null 
          ? LatLng(currentPosition.latitude, currentPosition.longitude)
          : const LatLng(30.0444, 31.2357); // القاهرة

      final result = await showDialog<LatLng>(
        context: context,
        builder: (context) => _MapSelectionDialog(initialPosition: initialPosition),
      );

      if (result != null) {
        // تحويل الإحداثيات إلى عنوان
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            result.latitude, 
            result.longitude
          );
          
          String address = '';
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          } else {
            address = 'الموقع المحدد على الخريطة';
          }

          // إنشاء رابط Google Maps
          final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';

          _addressController.text = address;
          _addressUrl = googleMapsUrl;
        } catch (e) {
          print('خطأ في تحويل الإحداثيات: $e');
          // في حالة فشل تحويل الإحداثيات، استخدم الإحداثيات مباشرة
          final String googleMapsUrl = 'https://www.google.com/maps?q=${result.latitude},${result.longitude}';
          final String address = 'الموقع المحدد: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
          
          _addressController.text = address;
          _addressUrl = googleMapsUrl;
        }
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء فتح الخريطة: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم بنجاح'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/UserHomeScreen');
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'سلة التسوق',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFC8700),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFC8700), Color(0xFFFF9500)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/UserHomeScreen'),
          ),
        ),
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCartItems(cartProvider),
                        const SizedBox(height: 20),
                        _buildOrderSummary(cartProvider),
                        const SizedBox(height: 20),
                        _buildDeliveryForm(),
                      ],
                    ),
                  ),
                ),
                _buildPlaceOrderButton(cartProvider),
              ],
            );
          },
        ),
        bottomNavigationBar: const MyBottomNavBar(
          currentIndex: 2, // Cart index
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'أضف بعض العناصر من المطاعم',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.push('/user-restaurants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8700),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('تصفح المطاعم'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: const Color(0xFFFC8700),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'عناصر الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC8700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cartProvider.items.length} عنصر',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFC8700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return _buildCartItemCard(item, cartProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(dynamic item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // الصف الأول: الصورة والتفاصيل
            Row(
              children: [
                // صورة العنصر
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fastfood,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                ),
                const SizedBox(width: 12),
                // تفاصيل العنصر
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toStringAsFixed(0)} جنيه للقطعة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // الصف الثاني: أزرار التحكم والسعر الإجمالي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // أزرار التحكم في الكمية
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => cartProvider.removeItem(item.menuItemId),
                        icon: const Icon(Icons.remove),
                        color: const Color(0xFFFC8700),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => cartProvider.updateItemQuantity(
                          item.menuItemId,
                          item.quantity + 1,
                        ),
                        icon: const Icon(Icons.add),
                        color: const Color(0xFFFC8700),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                // السعر الإجمالي للعنصر
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC8700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.totalPrice.toStringAsFixed(0)} جنيه',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFC8700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    const deliveryFee = 15.0; // رسوم توصيل ثابتة
    final subtotal = cartProvider.totalPrice;
    final total = subtotal + deliveryFee;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: const Color(0xFFFC8700),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSummaryRow('المجموع الفرعي', '${subtotal.toStringAsFixed(0)} جنيه'),
            const SizedBox(height: 8),
            _buildSummaryRow('رسوم التوصيل', '${deliveryFee.toStringAsFixed(0)} جنيه'),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildSummaryRow(
                'الإجمالي',
                '${total.toStringAsFixed(0)} جنيه',
                isTotal: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFFFC8700) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.delivery_dining,
                  color: const Color(0xFFFC8700),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تفاصيل التوصيل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عنوان التوصيل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectLocationOnMap(),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'اضغط لاختيار عنوان التوصيل من الخريطة',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFC8700)),
                        suffixIcon: const Icon(Icons.map, color: Color(0xFFFC8700)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFC8700)),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أي ملاحظات خاصة للطلب',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFC8700), width: 2),
                ),
                prefixIcon: Icon(
                  Icons.note,
                  color: const Color(0xFFFC8700),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider) {
    const deliveryFee = 15.0;
    final total = cartProvider.totalPrice + deliveryFee;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFC8700), Color(0xFFFF9500)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFC8700).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isPlacingOrder
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'جاري إرسال الطلب...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إرسال الطلب (${cartProvider.totalItems} عنصر)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${total.toStringAsFixed(0)} ج',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Dialog لاختيار الموقع من الخريطة
class _MapSelectionDialog extends StatefulWidget {
  final LatLng initialPosition;

  const _MapSelectionDialog({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<_MapSelectionDialog> createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<_MapSelectionDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Location> _searchResults = [];
  String? _selectedLocationName;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _markers.add(
      Marker(
        markerId: const MarkerId('initial'),
        position: widget.initialPosition,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _selectedPosition = newPosition;
            _selectedLocationName = null;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // البحث عن المواقع
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      print('خطأ في البحث: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لم يتم العثور على نتائج للبحث',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // اختيار موقع من نتائج البحث
  void _selectSearchResult(Location location, String query) {
    final LatLng position = LatLng(location.latitude, location.longitude);
    
    setState(() {
      _selectedPosition = position;
      _selectedLocationName = query;
      _searchResults.clear();
      _searchController.clear();
      
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _selectedPosition = newPosition;
              _selectedLocationName = null;
            });
          },
        ),
      );
    });

    // تحريك الكاميرا للموقع الجديد
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              // الطبقة الخلفية - Column الأصلي بدون نتائج البحث
              Column(
                children: [
                  // رأس الحوار
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFC8700),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: Colors.white),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'اختر عنوان التوصيل من الخريطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  
                  // شريط البحث
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن عنوان أو منطقة...',
                              hintStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.grey,
                              ),
                              prefixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFC8700),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.search,
                                      color: Color(0xFFFC8700),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFC8700),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                            ),
                            onSubmitted: (_) => _searchLocation(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSearching ? null : _searchLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFC8700),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'بحث',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // الخريطة
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.initialPosition,
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onTap: (LatLng position) {
                        setState(() {
                            _selectedPosition = position;
                            _selectedLocationName = null; // مسح اسم الموقع عند النقر على الخريطة
                            _markers.clear();
                            _markers.add(
                              Marker(
                                markerId: const MarkerId('selected'),
                                position: position,
                                draggable: true,
                                onDragEnd: (LatLng newPosition) {
                                  setState(() {
                                    _selectedPosition = newPosition;
                                    _selectedLocationName = null;
                                  });
                                },
                              ),
                            );
                          });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                  ),
                  
                  // معلومات الموقع المحدد
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFFC8700),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'الموقع المحدد:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // إظهار اسم الموقع إذا تم اختياره من البحث
                        if (_selectedLocationName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC8700).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFC8700).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFFFC8700),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedLocationName!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFC8700),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // الإحداثيات
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Color(0xFFFC8700),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'الإحداثيات:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _selectedPosition != null
                                        ? '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}'
                                        : 'غير محدد',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'إلغاء',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _selectedPosition != null
                                          ? () => Navigator.of(context).pop(_selectedPosition)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFC8700),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'تأكيد الاختيار',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
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
                  ),
                ],
              ),
              
              // طبقة نتائج البحث (تظهر فوق الخريطة)
              if (_searchResults.isNotEmpty)
                Positioned(
                  top: 140, // بعد رأس الحوار وشريط البحث
                  left: 16,
                  right: 16,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFFFC8700),
                            size: 20,
                          ),
                          title: Text(
                            _searchController.text,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            _selectSearchResult(location, _searchController.text);
                          },
                        );
                      },
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