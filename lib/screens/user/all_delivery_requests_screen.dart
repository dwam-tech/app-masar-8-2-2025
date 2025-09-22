import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/service_request_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/services/laravel_service.dart';
import 'package:go_router/go_router.dart';
import 'offers_screen.dart';

class AllDeliveryRequestsScreen extends StatefulWidget {
  const AllDeliveryRequestsScreen({super.key});

  @override
  State<AllDeliveryRequestsScreen> createState() => _AllDeliveryRequestsScreenState();
}

class _AllDeliveryRequestsScreenState extends State<AllDeliveryRequestsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _navigateToLatestRequestOffers();
  }

  Future<void> _navigateToLatestRequestOffers() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // جلب آخر طلب للمستخدم
      final response = await LaravelService.get('/api/service-requests', token: token);
      if (response['status'] == true) {
        final List<dynamic> data = response['data']['data'];
        
        if (data.isNotEmpty) {
          // أخذ أول طلب (الأحدث)
          final latestRequest = data.first;
          final requestId = latestRequest['id'];
          
          // استخراج بيانات الطلب للتنقل
          String fromLocation = 'غير محدد';
          String toLocation = 'غير محدد';
          double requestedPrice = 0.0;
          int estimatedDuration = 0;
          
          // استخراج البيانات من request_data
          if (latestRequest['request_data'] != null) {
            final requestData = latestRequest['request_data'];
            fromLocation = requestData['from_location'] ?? 'غير محدد';
            toLocation = requestData['to_location'] ?? 'غير محدد';
            requestedPrice = double.tryParse(requestData['price']?.toString() ?? '0') ?? 0.0;
            estimatedDuration = requestData['estimated_duration'] ?? 0;
          }
          
          // التنقل إلى صفحة العروض
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OffersScreen(
                  deliveryRequestId: requestId,
                  fromLocation: fromLocation,
                  toLocation: toLocation,
                  requestedPrice: requestedPrice,
                  estimatedDurationMinutes: estimatedDuration,
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'لا توجد طلبات توصيل';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'فشل في جلب الطلبات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'العروض المقدمة',
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
            onPressed: () => context.pop(),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8700)),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل العروض...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _navigateToLatestRequestOffers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}