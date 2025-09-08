import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/flight_search_provider.dart';
import '../../models/flight_offer.dart';
import '../../services/amadeus_flight_service.dart';

class FlightResultsScreen extends StatefulWidget {
  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _sortBy = 'السعر';
  bool _showFilters = false;
  
  // متغيرات لإدارة حالة القوائم المنسدلة
  bool _showFromDropdown = false;
  bool _showToDropdown = false;
  
  // FocusNodes لإدارة التركيز
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  // قائمة المطارات والمدن الشائعة
  final List<Map<String, String>> _airports = [
    {'name': 'القاهرة، مصر', 'code': 'CAI'},
    {'name': 'دبي، الإمارات', 'code': 'DXB'},
    {'name': 'الرياض، السعودية', 'code': 'RUH'},
    {'name': 'جدة، السعودية', 'code': 'JED'},
    {'name': 'الدوحة، قطر', 'code': 'DOH'},
    {'name': 'الكويت، الكويت', 'code': 'KWI'},
    {'name': 'بيروت، لبنان', 'code': 'BEY'},
    {'name': 'عمان، الأردن', 'code': 'AMM'},
    {'name': 'بغداد، العراق', 'code': 'BGW'},
    {'name': 'دمشق، سوريا', 'code': 'DAM'},
    {'name': 'طرابلس، ليبيا', 'code': 'TIP'},
    {'name': 'تونس، تونس', 'code': 'TUN'},
    {'name': 'الجزائر، الجزائر', 'code': 'ALG'},
    {'name': 'الرباط، المغرب', 'code': 'RBA'},
    {'name': 'الدار البيضاء، المغرب', 'code': 'CMN'},
    {'name': 'لندن، بريطانيا', 'code': 'LHR'},
    {'name': 'باريس، فرنسا', 'code': 'CDG'},
    {'name': 'روما، إيطاليا', 'code': 'FCO'},
    {'name': 'برلين، ألمانيا', 'code': 'BER'},
    {'name': 'مدريد، إسبانيا', 'code': 'MAD'},
    {'name': 'أمستردام، هولندا', 'code': 'AMS'},
    {'name': 'اسطنبول، تركيا', 'code': 'IST'},
    {'name': 'نيويورك، أمريكا', 'code': 'JFK'},
    {'name': 'لوس أنجلوس، أمريكا', 'code': 'LAX'},
    {'name': 'طوكيو، اليابان', 'code': 'NRT'},
    {'name': 'سيدني، أستراليا', 'code': 'SYD'},
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة القيم من البحث السابق
    final provider = context.read<FlightSearchProvider>();
    _fromController.text = provider.lastSearchOrigin ?? '';
    _toController.text = provider.lastSearchDestination ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightSearchProvider>();
    final results = provider.results;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.flight_takeoff, color: Colors.orange, size: 18),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                provider.lastSearchOrigin ?? 'من',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.flight_land, color: Colors.orange, size: 18),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                provider.lastSearchDestination ?? 'إلى',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: Colors.black),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          if (_showFilters) _buildFilterSection(),
          
          // Sort Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'ترتيب حسب:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: SizedBox(),
                  items: ['السعر', 'الوقت', 'المدة'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _sortBy = newValue!);
                    _sortResults();
                  },
                ),
                Spacer(),
                Text(
                  '${results.length} نتيجة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: Colors.grey[300]),
          
          // Results List
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.orange))
                : provider.error != null
                    ? _buildErrorWidget(provider.error!)
                    
                    : results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flight_takeoff, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('لا يوجد نتائج', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: results.length,
                            itemBuilder: (ctx, idx) {
                              final offer = results[idx];
                              return _buildFlightCard(offer);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAirportSearchField(
                      controller: _fromController,
                      hint: 'من',
                      icon: Icons.flight_takeoff,
                      showDropdown: _showFromDropdown,
                      onDropdownChanged: (show) {
                        setState(() {
                          _showFromDropdown = show;
                          if (show) _showToDropdown = false;
                        });
                      },
                      focusNode: _fromFocusNode,
                      isFrom: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                      onPressed: () {
                        final temp = _fromController.text;
                        _fromController.text = _toController.text;
                        _toController.text = temp;
                        _hideAllDropdowns();
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildAirportSearchField(
                      controller: _toController,
                      hint: 'إلى',
                      icon: Icons.flight_land,
                      showDropdown: _showToDropdown,
                      onDropdownChanged: (show) {
                        setState(() {
                          _showToDropdown = show;
                          if (show) _showFromDropdown = false;
                        });
                      },
                      focusNode: _toFocusNode,
                      isFrom: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _performNewSearch(),
                  child: Text(
                    'بحث جديد',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // القوائم المنسدلة العائمة
        if (_showFromDropdown && _fromController.text.isNotEmpty && _getFilteredAirports(_fromController.text).isNotEmpty)
          _buildFloatingDropdown(
            controller: _fromController,
            focusNode: _fromFocusNode,
            isFrom: true,
            onItemSelected: (airport) {
              _fromController.text = airport['name']!;
              setState(() => _showFromDropdown = false);
              _fromFocusNode.unfocus();
            },
          ),
        if (_showToDropdown && _toController.text.isNotEmpty && _getFilteredAirports(_toController.text).isNotEmpty)
          _buildFloatingDropdown(
            controller: _toController,
            focusNode: _toFocusNode,
            isFrom: false,
            onItemSelected: (airport) {
              _toController.text = airport['name']!;
              setState(() => _showToDropdown = false);
              _toFocusNode.unfocus();
            },
          ),
      ],
    );
  }

  // دالة لإنشاء حقل بحث المطارات الذكي
  Widget _buildAirportSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool showDropdown,
    required Function(bool) onDropdownChanged,
    required FocusNode focusNode,
    required bool isFrom,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.right,
        onChanged: (value) {
          onDropdownChanged(value.isNotEmpty);
        },
        onTap: () {
          if (controller.text.isNotEmpty) {
            onDropdownChanged(true);
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // دالة لإنشاء القائمة المنسدلة العائمة
  Widget _buildFloatingDropdown({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFrom,
    required Function(Map<String, String>) onItemSelected,
  }) {
    return Positioned(
      top: 68, // ارتفاع حقل النص + padding
      left: isFrom ? 16 : null,
      right: isFrom ? null : 16,
      width: (MediaQuery.of(context).size.width - 32 - 12 - 40 - 12) / 2, // عرض نصف الشاشة تقريباً
      child: Material(
        elevation: 16, // زيادة الـ elevation لضمان الظهور فوق العناصر الأخرى
        borderRadius: BorderRadius.circular(8),
        shadowColor: Colors.black.withOpacity(0.3),
        child: Container(
          constraints: BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _getFilteredAirports(controller.text).length,
              itemBuilder: (context, index) {
                final airport = _getFilteredAirports(controller.text)[index];
                return InkWell(
                  onTap: () => onItemSelected(airport),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: index < _getFilteredAirports(controller.text).length - 1
                            ? BorderSide(color: Colors.grey[200]!, width: 0.5)
                            : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          airport['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 2),
                        Text(
                          airport['code']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتصفية المطارات حسب النص المدخل
  List<Map<String, String>> _getFilteredAirports(String query) {
    if (query.isEmpty) return [];
    return _airports.where((airport) {
      return airport['name']!.toLowerCase().contains(query.toLowerCase()) ||
             airport['code']!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _hideAllDropdowns() {
    setState(() {
      _showFromDropdown = false;
      _showToDropdown = false;
    });
    _fromFocusNode.unfocus();
    _toFocusNode.unfocus();
  }

  Widget _buildFlightCard(FlightOffer offer) {
    return GestureDetector(
      onTap: () {
        context.push('/flight-details', extra: offer);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
            // Header with airline and price
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flight, color: Colors.blue[700], size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.airline,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'مباشر',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${offer.price.toStringAsFixed(0)} جم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'شامل الضرائب',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Flight details
            Row(
              children: [
                // Departure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${offer.departureTime.hour.toString().padLeft(2, '0')}:${offer.departureTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        offer.from,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Duration and flight path
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        offer.duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.orange,
                            ),
                          ),
                          Icon(Icons.flight, color: Colors.orange, size: 16),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.orange,
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مباشر',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrival
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${offer.arrivalTime.hour.toString().padLeft(2, '0')}:${offer.arrivalTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        offer.to,
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
            
            SizedBox(height: 12),
            
            // Additional info and action button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${offer.availableSeats} مقعد متاح',
                        style: TextStyle(
                          fontSize: 12,
                          color: offer.availableSeats < 10 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        offer.refundable ? 'قابل للاسترداد' : 'غير قابل للاسترداد',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _performNewSearch() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    final provider = context.read<FlightSearchProvider>();
    await provider.searchFlights(
      origin: _fromController.text,
      destination: _toController.text,
      departureDate: DateTime.now().add(Duration(days: 1)).toString().split(' ')[0],
      adults: 1,
      travelClass: 'الدرجة الاقتصادية',
    );
    
    setState(() => _showFilters = false);
  }

  Widget _buildErrorWidget(String error) {
    IconData errorIcon;
    String errorTitle;
    String errorSubtitle;
    List<String> suggestions = [];
    
    // تحديد نوع الخطأ وتقديم الإرشادات المناسبة
     if (error.contains('رمز المطار')) {
       errorIcon = Icons.location_off;
       errorTitle = 'رمز المطار غير صحيح';
       errorSubtitle = 'يرجى التأكد من رموز المطارات المدخلة';
       suggestions = [
         'تأكد من استخدام رموز المطارات الصحيحة (مثل: CAI للقاهرة)',
         'جرب البحث باستخدام أسماء المدن بدلاً من رموز المطارات',
         'تحقق من الإملاء الصحيح لأسماء المدن',
       ];
     } else if (error.contains('التاريخ')) {
       errorIcon = Icons.date_range;
       errorTitle = 'تاريخ غير صحيح';
       errorSubtitle = 'يرجى اختيار تاريخ صحيح في المستقبل';
       suggestions = [
         'تأكد من أن تاريخ السفر في المستقبل',
         'تحقق من صحة التاريخ المدخل',
         'جرب تواريخ أخرى قريبة من التاريخ المطلوب',
       ];
     } else if (error.contains('لا توجد رحلات')) {
       errorIcon = Icons.flight_takeoff;
       errorTitle = 'لا توجد رحلات متاحة';
       errorSubtitle = 'لم نجد رحلات للمسار والتاريخ المحددين';
       suggestions = [
         'جرب تواريخ أخرى قريبة من التاريخ المطلوب',
         'ابحث عن مطارات أخرى قريبة من وجهتك',
         'تحقق من توفر رحلات في أيام أخرى من الأسبوع',
       ];
     } else if (error.contains('مشكلة في الاتصال') || 
                error.contains('تم قطع الاتصال') ||
                error.contains('الاتصال')) {
       errorIcon = Icons.wifi_off;
       errorTitle = 'مشكلة في الاتصال';
       errorSubtitle = 'تعذر الاتصال بخدمة الرحلات';
       suggestions = [
         'تحقق من اتصال الإنترنت',
         'أعد المحاولة بعد قليل',
         'تأكد من استقرار الشبكة',
         'جرب إغلاق التطبيق وإعادة فتحه',
       ];
     } else if (error.contains('انتهت مهلة') || error.contains('timeout')) {
       errorIcon = Icons.timer_off;
       errorTitle = 'انتهت مهلة الاتصال';
       errorSubtitle = 'استغرق الطلب وقتاً أطول من المتوقع';
       suggestions = [
         'تحقق من سرعة الإنترنت',
         'أعد المحاولة بعد قليل',
         'جرب في وقت آخر عندما تكون الشبكة أقل ازدحاماً',
       ];
     } else if (error.contains('تجاوز الحد')) {
       errorIcon = Icons.timer;
       errorTitle = 'كثرة الطلبات';
       errorSubtitle = 'تم تجاوز الحد المسموح من الطلبات';
       suggestions = [
         'انتظر دقيقة واحدة قبل المحاولة مرة أخرى',
         'تجنب البحث المتكرر في فترة قصيرة',
       ];
     } else {
      errorIcon = Icons.error_outline;
      errorTitle = 'حدث خطأ';
      errorSubtitle = 'حدث خطأ غير متوقع';
      suggestions = [
        'أعد المحاولة بعد قليل',
        'تحقق من البيانات المدخلة',
        'تواصل مع الدعم الفني إذا استمرت المشكلة',
      ];
    }
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              errorTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              errorSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'اقتراحات للحل:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...suggestions.map((suggestion) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: Colors.orange[700], fontSize: 16)),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final provider = context.read<FlightSearchProvider>();
                if (provider.lastSearchOrigin != null && 
                    provider.lastSearchDestination != null) {
                  provider.searchFlights(
                    origin: provider.lastSearchOrigin!,
                    destination: provider.lastSearchDestination!,
                    departureDate: provider.lastSearchDepartureDate ?? 
                        DateTime.now().add(Duration(days: 1)).toString().split(' ')[0],
                    returnDate: provider.lastSearchReturnDate,
                    adults: provider.lastSearchAdults ?? 1,
                    travelClass: provider.lastSearchTravelClass ?? 'الدرجة الاقتصادية',
                  );
                }
              },
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortResults() {
    final provider = context.read<FlightSearchProvider>();
    provider.sortResults(_sortBy);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }
}
