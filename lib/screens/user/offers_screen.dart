import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/offers_provider.dart';
import 'package:saba2v2/models/offer_model.dart';
import 'package:saba2v2/models/delivery_request_model.dart';
import 'package:saba2v2/services/notification_service.dart';
import 'package:saba2v2/services/error_handling_service.dart';
import 'package:saba2v2/widgets/offer_card.dart';
import 'package:saba2v2/widgets/status_indicator.dart';
import 'package:saba2v2/widgets/action_buttons.dart';
import 'package:saba2v2/widgets/loading_states.dart';
import 'dart:async';

class OffersScreen extends StatefulWidget {
  final int deliveryRequestId;
  final String fromLocation;
  final String toLocation;
  final double requestedPrice;
  final int estimatedDurationMinutes;

  const OffersScreen({
    Key? key,
    required this.deliveryRequestId,
    required this.fromLocation,
    required this.toLocation,
    required this.requestedPrice,
    required this.estimatedDurationMinutes,
  }) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late OffersProvider _offersProvider;
  Timer? _refreshTimer;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _offersProvider = Provider.of<OffersProvider>(context, listen: false);
    _initializeAnimations();
    _loadData();
    _startAutoRefresh();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_offersProvider.isLoading) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // التحقق من الاتصال بالإنترنت قبل التحميل
    final hasConnection = await _errorHandler.hasInternetConnection();
    if (!hasConnection && mounted) {
      _errorHandler.showError(context, Exception('لا يوجد اتصال بالإنترنت'));
      return;
    }
    
    await _offersProvider.loadDeliveryRequestWithOffers(widget.deliveryRequestId.toString());
    if (_offersProvider.deliveryRequest != null) {
      _animationController.forward();
    }
  }

  Future<void> _refreshData() async {
    if (_offersProvider.isRefreshing) return;

    // التحقق من الاتصال بالإنترنت قبل التحديث
    final hasConnection = await _errorHandler.hasInternetConnection();
    if (!hasConnection && mounted) {
      _errorHandler.showError(context, Exception('لا يوجد اتصال بالإنترنت'));
      return;
    }

    await _offersProvider.refreshOffers(widget.deliveryRequestId.toString());
    
    if (_offersProvider.offers.isNotEmpty) {
      NotificationService.showSuccess(
        context,
        'تم تحديث العروض بنجاح',
      );
    }
    
    if (_offersProvider.errorMessage != null) {
      NotificationService.showError(
        context,
        'فشل في تحديث البيانات: ${_offersProvider.errorMessage}',
      );
    }
  }

  Future<void> _acceptOffer(OfferModel offer) async {
    try {
      // التحقق من صحة معرف العرض
      if (offer.id <= 0) {
        _errorHandler.showError(context, ArgumentError('معرف العرض غير صحيح'));
        return;
      }
      
      // التحقق من الاتصال بالإنترنت
      final hasConnection = await _errorHandler.hasInternetConnection();
      if (!hasConnection && mounted) {
        _errorHandler.showError(context, Exception('لا يوجد اتصال بالإنترنت'));
        return;
      }
      
      // عرض حوار التأكيد الجديد
      final confirmed = await NotificationService.showAcceptOfferConfirmation(
        context: context,
        driverName: offer.driverName,
        price: offer.price.toString(),
        estimatedTime: offer.estimatedTime?.toString() ?? 'غير محدد',
      );

      if (!confirmed) return;

      NotificationService.showLoadingDialog(
        context,
        message: 'جاري قبول العرض...',
      );

      final success = await _offersProvider.acceptOffer(
        widget.deliveryRequestId.toString(),
        offer.id.toString(),
      );

      Navigator.of(context).pop(); // إغلاق dialog التحميل

      if (success) {
        NotificationService.showSuccess(
          context,
          'تم قبول العرض بنجاح - سيتم التواصل معك قريباً من قبل مقدم الخدمة',
        );
        
      } else {
        final errorMessage = _offersProvider.errorMessage ?? 'فشل في قبول العرض';
        _errorHandler.showError(context, Exception(errorMessage), showDialog: true);
      }
    } catch (e) {
      if (mounted) {
        _errorHandler.showError(context, e, showDialog: true);
      }
    }
  }

  Future<void> _cancelRequest() async {
    try {
      // التحقق من وجود طلب للإلغاء
      if (_offersProvider.deliveryRequest == null) {
        _errorHandler.showError(context, Exception('لا يوجد طلب توصيل لإلغائه'));
        return;
      }
      
      // التحقق من حالة الطلب
      final currentStatus = _offersProvider.deliveryRequest?.status;
      if (currentStatus == 'cancelled') {
        _errorHandler.showError(context, Exception('الطلب ملغى مسبقاً'));
        return;
      }
      
      if (currentStatus == 'completed') {
        _errorHandler.showError(context, Exception('لا يمكن إلغاء طلب مكتمل'));
        return;
      }
      
      // عرض حوار التأكيد الجديد
      final confirmed = await NotificationService.showCancelRequestConfirmation(
        context: context,
      );

      if (!confirmed) return;
      
      // التحقق من الاتصال بالإنترنت
      final hasConnection = await _errorHandler.hasInternetConnection();
      if (!hasConnection && mounted) {
        _errorHandler.showError(context, Exception('لا يوجد اتصال بالإنترنت'));
        return;
      }
      
      final reason = await _showInputDialog(
        context,
        title: 'إلغاء الطلب',
        hint: 'اكتب سبب الإلغاء...',
      );
      
      if (reason == null || reason.isEmpty) return;

      NotificationService.showLoadingDialog(
        context,
        message: 'جاري إلغاء الطلب...',
      );

      final success = await _offersProvider.cancelDeliveryRequest(
        widget.deliveryRequestId.toString(),
        reason,
      );

      Navigator.of(context).pop(); // إغلاق dialog التحميل

      if (success) {
        NotificationService.showSuccess(
          context,
          'تم إلغاء الطلب بنجاح',
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        final errorMessage = _offersProvider.errorMessage ?? 'فشل في إلغاء الطلب';
        _errorHandler.showError(context, Exception(errorMessage), showDialog: true);
      }
    } catch (e) {
      if (mounted) {
        _errorHandler.showError(context, e, showDialog: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OffersProvider>(
      builder: (context, offersProvider, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text(
                'العروض المتاحة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              backgroundColor: const Color(0xFFFC8700),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (!offersProvider.isLoading)
                  IconButton(
                    icon: AnimatedBuilder(
                      animation: offersProvider.isRefreshing ? _pulseAnimation : _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: offersProvider.isRefreshing ? _pulseAnimation.value : 1.0,
                          child: Icon(
                            Icons.refresh,
                            color: offersProvider.isRefreshing ? Colors.amber : Colors.white,
                          ),
                        );
                      },
                    ),
                    onPressed: offersProvider.isRefreshing ? null : _refreshData,
                    tooltip: 'تحديث العروض',
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _cancelRequest();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('إلغاء الطلب'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: _buildBody(offersProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(OffersProvider offersProvider) {
    if (offersProvider.isLoading && offersProvider.deliveryRequest == null) {
      return LoadingStates.offerCardShimmer();
    }

    if (offersProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                offersProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (offersProvider.deliveryRequest == null) {
      return const Center(
        child: Text(
          'لم يتم العثور على الطلب.',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: Colors.grey,
          ),
        ),
      );
    }

    // التحقق من حالة الطلب
    if (offersProvider.deliveryRequest!.status != 'pending_offers') {
      return _buildRequestAcceptedView(offersProvider);
    }

    return Column(
      children: [
        // بطاقة تفاصيل الطلب مع رسوم متحركة
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Text(
                        'تفاصيل الطلب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on, 'من', widget.fromLocation),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.flag, 'إلى', widget.toLocation),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.attach_money, 'السعر المطلوب', '${widget.requestedPrice.toStringAsFixed(0)} جنيه'),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.access_time, 'الوقت المقدر', '${widget.estimatedDurationMinutes} دقيقة'),
                ],
              ),
            ),
          ),
        ),
        
        // عداد العروض مع رسوم متحركة
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFC8700), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer,
                    color: const Color(0xFFFC8700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'عدد العروض المتاحة: ${offersProvider.offers.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFC8700),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // قائمة العروض
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFFFC8700),
            child: offersProvider.offers.isEmpty
                ? _buildNoOffersView()
                : Column(
                    children: [
                      if (offersProvider.isLoading)
                        Column(
                          children: [
                            LoadingStates.offerCardShimmer(),
                            const SizedBox(height: 16),
                            LoadingStates.pulseLoading(
                              isLoading: true,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: offersProvider.offers.length,
                          itemBuilder: (context, index) {
                            final offer = offersProvider.offers[index];
                            return _buildOfferCard(offer, index, offersProvider);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFC8700),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoOffersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد عروض متاحة حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جاري البحث عن سائقين متاحين...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'سيتم تحديث العروض تلقائياً',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer, int index, OffersProvider offersProvider) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 50),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: OfferCard(
              offer: offer,
              onAccept: () => _acceptOffer(offer),
              isLoading: offersProvider.isLoading,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestAcceptedView(OffersProvider offersProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success Icon and Message
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green[200]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'تم قبول طلبك بنجاح!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Status Indicator
          StatusIndicator(
            status: offersProvider.deliveryRequest!.status,
            statusTranslated: offersProvider.deliveryRequest!.statusTranslated,
            showAnimation: true,
          ),
          const SizedBox(height: 24),
          
          // Driver Information Card
          if (offersProvider.deliveryRequest!.driver != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات السائق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFFC8700).withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: const Color(0xFFFC8700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offersProvider.deliveryRequest!.driver!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (offersProvider.deliveryRequest!.driver!.phone != null)
                                Text(
                                  offersProvider.deliveryRequest!.driver!.phone!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              if (offersProvider.deliveryRequest!.driver!.rating != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${offersProvider.deliveryRequest!.driver!.rating}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          
          // Action Buttons
          ActionButtons(
            onRefresh: _refreshData,
            isLoading: offersProvider.isRefreshing,
            showCancelButton: false,
            showContactButtons: offersProvider.deliveryRequest!.driver?.phone != null,
            onCall: offersProvider.deliveryRequest!.driver?.phone != null
                ? () => _callDriver(offersProvider.deliveryRequest!.driver!.phone!)
                : null,
          ),
        ],
      ),
    );
  }
  
  void _callDriver(String phoneNumber) {
    // Implementation for calling driver
    // You can use url_launcher package to make phone calls
  }

  // Helper Methods for Dialogs and Notifications
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String content,
    String confirmText,
    String cancelText,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              content: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC8700),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(
    String title,
    String content, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showCancelDialog() async {
    final TextEditingController reasonController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'إلغاء الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
              fontFamily: 'Cairo',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'يرجى تحديد سبب الإلغاء:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب سبب الإلغاء هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFC8700)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop(reason);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showInputDialog(BuildContext context, {required String title, required String hint}) async {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى كتابة سبب الإلغاء';
              }
              if (value.trim().length < 5) {
                return 'يجب أن يكون السبب أكثر من 5 أحرف';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}