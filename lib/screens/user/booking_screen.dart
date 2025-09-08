import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/flight_offer.dart';

class BookingScreen extends StatefulWidget {
  final FlightOffer offer;

  const BookingScreen({Key? key, required this.offer}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();

  // مفيش استخدام لحقل نصّي للجنسية، فشيلته من الـUI وخلّيت الاختيار Dropdown فقط
  final _nationalityController = TextEditingController(); // لو حابب تشيله تمامًا، احذفه ومعاه من dispose

  String? _selectedNationality;

  DateTime? _dateOfBirth;
  String _gender = 'male';
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'حجز الرحلة',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFlightSummary(),
              const SizedBox(height: 24),
              _buildPassengerInfoSection(),
              const SizedBox(height: 24),
              _buildContactInfoSection(),
              const SizedBox(height: 24),
              _buildTravelDocumentSection(),
              const SizedBox(height: 24),
              _buildPriceBreakdown(),
              const SizedBox(height: 24),
              _buildTermsAndConditions(),
              const SizedBox(height: 24),
              _buildBookingButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.orange.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flight_takeoff, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ملخص الرحلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.offer.from,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_back, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.offer.to,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.business, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.offer.airline} - ${widget.offer.flightNumber}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(widget.offer.departureTime),
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.offer.price.toStringAsFixed(0)} ${widget.offer.currency}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'معلومات المسافر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'الاسم الأول *',
            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'الاسم الأول مطلوب' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'اسم العائلة *',
            prefixIcon: Icon(Icons.family_restroom, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'اسم العائلة مطلوب' : null,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تاريخ الميلاد *', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDateOfBirth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dateOfBirth != null
                            ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                            : 'اختر التاريخ',
                        style: TextStyle(
                          color: _dateOfBirth != null ? Colors.black87 : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الجنس *', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.wc, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'male',
                  child: Row(children: [Icon(Icons.male, size: 18), SizedBox(width: 8), Text('ذكر')]),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child:
                      Row(children: [Icon(Icons.female, size: 18), SizedBox(width: 8), Text('أنثى')]),
                ),
              ],
              onChanged: (value) => setState(() => _gender = value ?? 'male'),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.contact_phone, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الاتصال',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني *',
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
              if (!value.contains('@')) return 'البريد الإلكتروني غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف *',
              prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'رقم الهاتف مطلوب' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDocumentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'وثائق السفر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passportController,
            decoration: InputDecoration(
              labelText: 'رقم جواز السفر *',
              prefixIcon: Icon(Icons.card_membership, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'رقم جواز السفر مطلوب' : null,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedNationality,
            decoration: InputDecoration(
              labelText: 'الجنسية *',
              prefixIcon: Icon(Icons.flag, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: const [
              DropdownMenuItem(value: 'مصري', child: Text('مصري')),
              DropdownMenuItem(value: 'سعودي', child: Text('سعودي')),
              DropdownMenuItem(value: 'إماراتي', child: Text('إماراتي')),
              DropdownMenuItem(value: 'كويتي', child: Text('كويتي')),
              DropdownMenuItem(value: 'قطري', child: Text('قطري')),
              DropdownMenuItem(value: 'بحريني', child: Text('بحريني')),
              DropdownMenuItem(value: 'عماني', child: Text('عماني')),
              DropdownMenuItem(value: 'أردني', child: Text('أردني')),
              DropdownMenuItem(value: 'لبناني', child: Text('لبناني')),
              DropdownMenuItem(value: 'سوري', child: Text('سوري')),
              DropdownMenuItem(value: 'عراقي', child: Text('عراقي')),
              DropdownMenuItem(value: 'فلسطيني', child: Text('فلسطيني')),
              DropdownMenuItem(value: 'مغربي', child: Text('مغربي')),
              DropdownMenuItem(value: 'تونسي', child: Text('تونسي')),
              DropdownMenuItem(value: 'جزائري', child: Text('جزائري')),
              DropdownMenuItem(value: 'ليبي', child: Text('ليبي')),
              DropdownMenuItem(value: 'سوداني', child: Text('سوداني')),
              DropdownMenuItem(value: 'يمني', child: Text('يمني')),
            ],
            onChanged: (value) => setState(() => _selectedNationality = value),
            validator: (value) => (value == null || value.isEmpty) ? 'الجنسية مطلوبة' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final double basePrice = widget.offer.price;
    final double taxes = basePrice * 0.14; // 14%
    final double total = basePrice + taxes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل السعر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.airplane_ticket, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'سعر التذكرة',
                      style: TextStyle(fontSize: 15, color: Color(0xFF2C3E50), fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                Text(
                  '${basePrice.toStringAsFixed(0)} ${widget.offer.currency}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'الضرائب والرسوم',
                      style: TextStyle(fontSize: 15, color: Color(0xFF2C3E50), fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                Text(
                  '${taxes.toStringAsFixed(0)} ${widget.offer.currency}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'المجموع الكلي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                Text(
                  '${total.toStringAsFixed(0)} ${widget.offer.currency}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gavel, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'الشروط والأحكام',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                  activeColor: Colors.orange,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                  child: const Text(
                    'أوافق على الشروط والأحكام وسياسة الخصوصية الخاصة بشركة الطيران وموقع مسار',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2C3E50),
                      fontFamily: 'Cairo',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    final bool enabled = _agreeToTerms && !_isLoading;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Colors.orange, Color(0xFFFF8C32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? _processBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.transparent : Colors.grey[300],
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جاري المعالجة...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'تأكيد الحجز',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ الميلاد'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: استبدل المحاكاة بنداء API الحقيقي
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Navigate to booking confirmation
    context.pushReplacement('/booking-confirmation', extra: {
      'offer': widget.offer,
      'passengerData': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'passport': _passportController.text,
        'nationality': _selectedNationality ?? '',
        'dateOfBirth': _dateOfBirth,
        'gender': _gender,
      },
    });
  }
}
