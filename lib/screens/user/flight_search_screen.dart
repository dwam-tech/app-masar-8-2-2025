import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/flight_search_provider.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  DateTime? _departDate;
  int _adults = 1;
  String _travelClass = "الدرجة الاقتصادية";
  bool _isRoundTrip = false;
  
  // متغيرات لحفظ كود المطار المختار
  String? _selectedFromCode;
  String? _selectedToCode;
  
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

  // دالة لإنشاء حقل بحث المطارات الذكي
  Widget _buildAirportSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String code, String name) onAirportSelected,
    required bool showDropdown,
    required Function(bool) onDropdownChanged,
    required FocusNode focusNode,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
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
          // القائمة المنسدلة للمطارات
          if (showDropdown && controller.text.isNotEmpty && _getFilteredAirports(controller.text).isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _getFilteredAirports(controller.text).length,
                itemBuilder: (context, index) {
                  final airport = _getFilteredAirports(controller.text)[index];
                  return InkWell(
                    onTap: () {
                      controller.text = airport['name']!;
                      onAirportSelected(airport['code']!, airport['name']!);
                      // إخفاء القائمة والتركيز
                      onDropdownChanged(false);
                      focusNode.unfocus();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
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
        ],
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

  @override
  void dispose() {
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _hideAllDropdowns() {
    setState(() {
      _showFromDropdown = false;
      _showToDropdown = false;
    });
    _fromFocusNode.unfocus();
    _toFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FlightSearchProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'اختيار رحلتك',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: _hideAllDropdowns,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Type Selection
              Container(
                padding: EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: _isRoundTrip,
                            onChanged: (value) {
                              setState(() => _isRoundTrip = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text(
                            'ذهاب فقط',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _isRoundTrip,
                            onChanged: (value) {
                              setState(() => _isRoundTrip = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text(
                            'ذهاب وعودة',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // From and To Fields
              Container(
                padding: EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    // From Field - حقل البحث الذكي للمغادرة
                    _buildAirportSearchField(
                      controller: _fromCtrl,
                      hint: "المغادرة من (اكتب اسم المدينة)",
                      icon: Icons.flight_takeoff,
                      showDropdown: _showFromDropdown,
                      focusNode: _fromFocusNode,
                      onDropdownChanged: (show) {
                        setState(() {
                          _showFromDropdown = show;
                          if (show) _showToDropdown = false; // إخفاء القائمة الأخرى
                        });
                      },
                      onAirportSelected: (code, name) {
                        _selectedFromCode = code;
                      },
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Swap Button
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.swap_vert, color: Colors.white, size: 20),
                          onPressed: () {
                            // تبديل النصوص
                            final tempText = _fromCtrl.text;
                            _fromCtrl.text = _toCtrl.text;
                            _toCtrl.text = tempText;
                            
                            // تبديل الأكواد
                            final tempCode = _selectedFromCode;
                            _selectedFromCode = _selectedToCode;
                            _selectedToCode = tempCode;
                            
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // To Field - حقل البحث الذكي للوصول
                    _buildAirportSearchField(
                      controller: _toCtrl,
                      hint: "الوصول إلى (اكتب اسم المدينة)",
                      icon: Icons.flight_land,
                      showDropdown: _showToDropdown,
                      focusNode: _toFocusNode,
                      onDropdownChanged: (show) {
                        setState(() {
                          _showToDropdown = show;
                          if (show) _showFromDropdown = false; // إخفاء القائمة الأخرى
                        });
                      },
                      onAirportSelected: (code, name) {
                        _selectedToCode = code;
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Date Selection
              Container(
                padding: EdgeInsets.all(16),
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
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _departDate = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _departDate != null
                                ? "${_departDate!.day}/${_departDate!.month}/${_departDate!.year}"
                                : "15/1/2025",
                            style: TextStyle(
                              fontSize: 16,
                              color: _departDate != null ? Colors.black : Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Passengers and Class
              Container(
                padding: EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    // Adults Count
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.orange, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$_adults بالغ',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: _adults > 1 ? () => setState(() => _adults--) : null,
                              ),
                              Text('$_adults', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Colors.orange),
                                onPressed: _adults < 9 ? () => setState(() => _adults++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Travel Class
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.airline_seat_recline_normal, color: Colors.orange, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _travelClass,
                                isExpanded: true,
                                items: [
                                  "الدرجة الاقتصادية",
                                  "درجة رجال الأعمال", 
                                  "الدرجة الأولى"
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.right,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() => _travelClass = newValue!);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Search Button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // التحقق من اختيار المطارات
                          if (_selectedFromCode == null || _selectedToCode == null || _departDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("يرجى اختيار مطار المغادرة والوصول وتاريخ السفر"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          if (_selectedFromCode == _selectedToCode) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("لا يمكن أن يكون مطار المغادرة والوصول نفس المطار"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          try {
                            // استخدام أكواد المطارات في البحث
                            await context.read<FlightSearchProvider>().searchFlights(
                                  origin: _selectedFromCode!,
                                  destination: _selectedToCode!,
                                  departureDate: "${_departDate!.year}-${_departDate!.month.toString().padLeft(2, '0')}-${_departDate!.day.toString().padLeft(2, '0')}",
                                  adults: _adults,
                                  travelClass: _travelClass,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlightResultsScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("حدث خطأ أثناء البحث: ${e.toString()}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "بحث",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
