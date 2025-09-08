import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hotel_search_provider.dart';
import '../../utils/hotel_theme.dart';
import 'hotel_results_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _cityController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 2;
  int _rooms = 1;

  double? _maxPrice;
  int? _hotelRating;
  final _hotelNameController = TextEditingController();
  bool _showAdvancedFilters = false;

  String? _selectedCityCode;
  List<Map<String, String>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<HotelSearchProvider>();
    _filteredCities = provider.getAvailableCities();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HotelSearchProvider>().isLoading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HotelTheme.backgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HotelTheme.buildIconWithBackground(
                Icons.hotel,
                backgroundColor: HotelTheme.lightOrange,
                iconColor: HotelTheme.primaryOrange,
              ),
              const SizedBox(width: 12),
              Text(
                'البحث عن فنادق',
                style: HotelTheme.headingMedium,
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: HotelTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildCitySelection(),
                const SizedBox(height: 24),
                _buildDatesSection(),
                const SizedBox(height: 20),
                _buildGuestsRoomsSection(),
                const SizedBox(height: 20),
                _buildAdvancedFiltersSection(),
                const SizedBox(height: 32),
                _buildSearchButton(isLoading),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: HotelTheme.elevatedCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: HotelTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ابحث عن فندقك المثالي', style: HotelTheme.headingMedium),
                const SizedBox(height: 4),
                Text(
                  'اكتشف أفضل الفنادق بأسعار مناسبة',
                  style: HotelTheme.bodyMedium.copyWith(
                    color: HotelTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: HotelTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HotelTheme.buildIconWithBackground(
                Icons.location_city,
                backgroundColor: HotelTheme.lightOrange,
                iconColor: HotelTheme.primaryOrange,
              ),
              const SizedBox(width: 12),
              Text('الوجهة', style: HotelTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: HotelTheme.inputBoxDecoration,
            child: TextField(
              controller: _cityController,
              textAlign: TextAlign.right,
              onChanged: _onCitySearchChanged,
              style: HotelTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "اختر المدينة أو الوجهة",
                hintStyle: HotelTheme.bodyMedium.copyWith(
                  color: HotelTheme.textSecondary,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.location_city,
                      color: HotelTheme.primaryOrange, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (_filteredCities.isNotEmpty && _cityController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: HotelTheme.cardDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _filteredCities.length > 5 ? 5 : _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    title: Text(city['name']!, style: HotelTheme.bodyMedium,
                        textAlign: TextAlign.right),
                    subtitle: Text(city['code']!, style: HotelTheme.bodySmall,
                        textAlign: TextAlign.right),
                    trailing: Icon(Icons.location_on,
                        color: HotelTheme.primaryOrange, size: 20),
                    onTap: () {
                      _cityController.text = city['name']!;
                      _selectedCityCode = city['code']!;
                      setState(() {
                        _filteredCities = [];
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: HotelTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HotelTheme.buildIconWithBackground(
                Icons.calendar_today,
                backgroundColor: HotelTheme.lightOrange,
                iconColor: HotelTheme.primaryOrange,
              ),
              const SizedBox(width: 12),
              Text('تواريخ الإقامة', style: HotelTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildDateField(
                label: 'تسجيل الدخول',
                date: _checkInDate,
                onTap: _selectCheckInDate,
                icon: Icons.login,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تسجيل الخروج',
                date: _checkOutDate,
                onTap: _selectCheckOutDate,
                icon: Icons.logout,
              ),
            ],
          ),

          if (_checkInDate != null && _checkOutDate != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: HotelTheme.lightGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nights_stay,
                      color: HotelTheme.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${context.read<HotelSearchProvider>().calculateNights(_checkInDate!, _checkOutDate!)} ليلة',
                    style: HotelTheme.bodyMedium.copyWith(
                      color: HotelTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestsRoomsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الضيوف والغرف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildCounterRow(Icons.person, '$_adults بالغ', _adults, (val) {
            setState(() => _adults = val);
          }, min: 1, max: 10),
          const SizedBox(height: 12),
          _buildCounterRow(Icons.hotel, '$_rooms غرفة', _rooms, (val) {
            setState(() => _rooms = val);
          }, min: 1, max: 5),
        ],
      ),
    );
  }

  Widget _buildCounterRow(
      IconData icon, String label, int value, Function(int) onChange,
      {required int min, required int max}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, textAlign: TextAlign.right)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.grey),
                onPressed: value > min ? () => onChange(value - 1) : null,
              ),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                onPressed: value < max ? () => onChange(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          InkWell(
            onTap: () => setState(() {
              _showAdvancedFilters = !_showAdvancedFilters;
            }),
            child: Row(
              children: [
                Icon(Icons.tune, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('فلاتر متقدمة (اختيارية)',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16)),
                ),
                Icon(
                  _showAdvancedFilters
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            _buildAdvancedFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: HotelTheme.inputBoxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: HotelTheme.primaryOrange, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: HotelTheme.bodySmall.copyWith(
                      color: HotelTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? "${date.day}/${date.month}/${date.year}"
                  : "اختر التاريخ",
              style: HotelTheme.bodyMedium.copyWith(
                color: date != null
                    ? HotelTheme.textPrimary
                    : HotelTheme.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: HotelTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: HotelTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text("البحث عن فنادق",
                      style: HotelTheme.bodyLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("السعر الأقصى", style: HotelTheme.bodyMedium),
        const SizedBox(height: 12),
        Container(
          decoration: HotelTheme.inputBoxDecoration,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: (value) {
              _maxPrice = double.tryParse(value);
            },
            decoration: InputDecoration(
              hintText: "أدخل السعر الأقصى (ج.م)",
              prefixIcon: Icon(Icons.attach_money,
                  color: HotelTheme.primaryOrange, size: 20),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text("تقييم الفندق", style: HotelTheme.bodyMedium),
        const SizedBox(height: 12),
        Container(
          decoration: HotelTheme.inputBoxDecoration,
          child: DropdownButtonFormField<int?>(
            value: _hotelRating,
            decoration: InputDecoration(
              hintText: 'اختر تقييم الفندق',
              prefixIcon: Icon(Icons.star,
                  color: HotelTheme.primaryOrange, size: 20),
              border: InputBorder.none,
            ),
            items: [
              DropdownMenuItem(value: null, child: Text('أي تقييم')),
              DropdownMenuItem(value: 5, child: Text('5 نجوم')),
              DropdownMenuItem(value: 4, child: Text('4 نجوم فأكثر')),
              DropdownMenuItem(value: 3, child: Text('3 نجوم فأكثر')),
            ],
            onChanged: (value) {
              setState(() => _hotelRating = value);
            },
          ),
        ),
        const SizedBox(height: 20),
        Text("اسم الفندق", style: HotelTheme.bodyMedium),
        const SizedBox(height: 12),
        Container(
          decoration: HotelTheme.inputBoxDecoration,
          child: TextField(
            controller: _hotelNameController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: "ابحث باسم الفندق (اختياري)",
              prefixIcon: Icon(Icons.search,
                  color: HotelTheme.primaryOrange, size: 20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  void _onCitySearchChanged(String query) {
    final provider = context.read<HotelSearchProvider>();
    setState(() {
      _filteredCities = provider.searchCities(query);
    });
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final firstDate =
        _checkInDate?.add(Duration(days: 1)) ?? DateTime.now().add(Duration(days: 2));
    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  Future<void> _performSearch() async {
    if (_selectedCityCode == null || _selectedCityCode!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("يرجى اختيار المدينة")));
      return;
    }
    final provider = context.read<HotelSearchProvider>();
    final dateValidation =
        provider.validateDates(_checkInDate, _checkOutDate);
    if (dateValidation != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dateValidation)));
      return;
    }
    await provider.searchHotels(
      cityCode: _selectedCityCode!,
      checkInDate:
          "${_checkInDate!.year}-${_checkInDate!.month.toString().padLeft(2, '0')}-${_checkInDate!.day.toString().padLeft(2, '0')}",
      checkOutDate:
          "${_checkOutDate!.year}-${_checkOutDate!.month.toString().padLeft(2, '0')}-${_checkOutDate!.day.toString().padLeft(2, '0')}",
      adults: _adults,
      roomQuantity: _rooms,
      maxPrice: _maxPrice,
      hotelRating: _hotelRating,
      hotelName:
          _hotelNameController.text.isNotEmpty ? _hotelNameController.text : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelResultsScreen(),
      ),
    );
  }
}
