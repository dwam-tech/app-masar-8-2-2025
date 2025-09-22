import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/laravel_service.dart';
import '../../models/offer_model.dart';
import '../../models/delivery_request_model.dart';

const String baseUrl = 'https://msar.app';

class SubmitOfferScreen extends StatefulWidget {
  final DeliveryRequestModel deliveryRequest;

  const SubmitOfferScreen({
    Key? key,
    required this.deliveryRequest,
  }) : super(key: key);

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    // تعيين السعر المطلوب كقيمة افتراضية
    _priceController.text = widget.deliveryRequest.requestedPrice.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        context.go('/login');
        return;
      }

      final url = Uri.parse('${baseUrl}/api/requests/${widget.deliveryRequest.id}/offer');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'offered_price': double.parse(_priceController.text),
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['status'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(data['message'] ?? 'حدث خطأ أثناء تقديم العرض');
      }
    } catch (e) {
      print('Error submitting offer: $e');
      _showErrorDialog('حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text(
          'تم تقديم العرض بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'تم تقديم عرضك بنجاح. سيتم إشعارك عند قبول العميل للعرض.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
                context.go('/driver-requests'); // التوجه لشاشة طلبات السائقين
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'موافق',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'خطأ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'موافق',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم عرض'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الطلب
              _buildRequestInfoCard(),
              const SizedBox(height: 20),
              
              // نموذج تقديم العرض
              _buildOfferForm(),
              const SizedBox(height: 30),
              
              // زر تقديم العرض
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب رقم #${widget.deliveryRequest.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTripTypeColor(widget.deliveryRequest.tripType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.deliveryRequest.tripType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('العميل', 'عميل مجهول'),
            _buildInfoRow('فئة السيارة', widget.deliveryRequest.carCategory),
            _buildInfoRow('طريقة الدفع', widget.deliveryRequest.paymentMethod),
            _buildInfoRow('السعر المطلوب', '${widget.deliveryRequest.requestedPrice.toStringAsFixed(0)} د.ع'),
            
            const SizedBox(height: 12),
            const Text(
              'الوجهات:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.deliveryRequest.toLocation,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.deliveryRequest.toLocation.length > 50)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${widget.deliveryRequest.toLocation.length - 50} حرف إضافي',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل العرض',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // مقارنة السعر
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مقارنة الأسعار',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'السعر المطلوب من العميل',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${widget.deliveryRequest.requestedPrice.toStringAsFixed(0)} جنيه',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'يمكنك اقتراح سعر مختلف',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // حقل السعر المحدث
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر المعروض (جنيه)',
                hintText: 'أدخل السعر الذي تريد عرضه',
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        double currentPrice = double.tryParse(_priceController.text) ?? 0;
                        if (currentPrice > 10) {
                          _priceController.text = (currentPrice - 10).toStringAsFixed(0);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        double currentPrice = double.tryParse(_priceController.text) ?? 0;
                        _priceController.text = (currentPrice + 10).toStringAsFixed(0);
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {}); // لتحديث مؤشر الفرق في السعر
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال السعر';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'يرجى إدخال سعر صحيح';
                }
                if (price > widget.deliveryRequest.requestedPrice * 2) {
                  return 'السعر مرتفع جداً مقارنة بالسعر المطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // مؤشر الفرق في السعر
            if (_priceController.text.isNotEmpty && double.tryParse(_priceController.text) != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPriceDifferenceColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getPriceDifferenceColor().withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPriceDifferenceIcon(),
                      color: _getPriceDifferenceColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getPriceDifferenceText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getPriceDifferenceColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // مقارنة السعر
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'السعر المطلوب من العميل: ${widget.deliveryRequest.requestedPrice.toStringAsFixed(0)} د.ع',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // حقل الملاحظات
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                hintText: 'أضف أي ملاحظات أو تفاصيل إضافية للعميل',
                prefixIcon: const Icon(Icons.note_add),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // نصائح للسائق المحدثة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.green, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'نصائح لتقديم عرض ناجح',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('💰', 'قدم سعراً منافساً ومعقولاً'),
                  _buildTipItem('📝', 'أضف ملاحظات توضح خبرتك أو خدمات إضافية'),
                  _buildTipItem('🤝', 'كن مهذباً ومهنياً في التعامل'),
                  _buildTipItem('⚡', 'الاستجابة السريعة تزيد من فرص القبول'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة لحساب الفرق في السعر
  Color _getPriceDifferenceColor() {
    final offeredPrice = double.tryParse(_priceController.text) ?? 0;
    final requestedPrice = widget.deliveryRequest.requestedPrice;
    
    if (offeredPrice == requestedPrice) {
      return Colors.green;
    } else if (offeredPrice < requestedPrice) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }
  
  IconData _getPriceDifferenceIcon() {
    final offeredPrice = double.tryParse(_priceController.text) ?? 0;
    final requestedPrice = widget.deliveryRequest.requestedPrice;
    
    if (offeredPrice == requestedPrice) {
      return Icons.check_circle;
    } else if (offeredPrice < requestedPrice) {
      return Icons.trending_down;
    } else {
      return Icons.trending_up;
    }
  }
  
  String _getPriceDifferenceText() {
    final offeredPrice = double.tryParse(_priceController.text) ?? 0;
    final requestedPrice = widget.deliveryRequest.requestedPrice;
    final difference = (offeredPrice - requestedPrice).abs();
    
    if (offeredPrice == requestedPrice) {
      return 'السعر مطابق للسعر المطلوب - ممتاز!';
    } else if (offeredPrice < requestedPrice) {
      return 'سعرك أقل بـ ${difference.toStringAsFixed(0)} جنيه - عرض جذاب للعميل';
    } else {
      return 'سعرك أعلى بـ ${difference.toStringAsFixed(0)} جنيه - تأكد من المبرر';
    }
  }
  
  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOffer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جاري تقديم العرض...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                'تقديم العرض',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Color _getTripTypeColor(String tripType) {
    switch (tripType) {
      case 'ذهاب فقط':
        return Colors.blue;
      case 'ذهاب وعودة':
        return Colors.green;
      case 'وجهات متعددة':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}