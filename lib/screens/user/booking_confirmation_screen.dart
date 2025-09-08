import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../models/flight_offer.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingConfirmationScreen({Key? key, required this.bookingData}) : super(key: key);

  FlightOffer get offer => bookingData['offer'] as FlightOffer;
  Map<String, dynamic> get passengerData => bookingData['passengerData'] as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(), // Remove back button
        title: Text(
          'تأكيد الحجز',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            SizedBox(height: 24),
            _buildBookingReference(context),
            SizedBox(height: 24),
            _buildFlightDetails(),
            SizedBox(height: 24),
            _buildPassengerDetails(),
            SizedBox(height: 24),
            _buildImportantNotes(),
            SizedBox(height: 24),
            _buildActionButtons(context),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: EdgeInsets.all(24),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'تم تأكيد حجزك بنجاح!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'سيتم إرسال تفاصيل الحجز إلى بريدك الإلكتروني',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingReference(BuildContext context) {
    String bookingRef = 'MSR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'رقم الحجز',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bookingRef,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: bookingRef));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ رقم الحجز'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'احتفظ برقم الحجز للمراجعة أو التعديل',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetails() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'تفاصيل الرحلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          
          // Flight route
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${offer.departureTime.hour.toString().padLeft(2, '0')}:${offer.departureTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      offer.from,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      offer.fromCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    color: Colors.orange,
                    size: 20,
                  ),
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.orange,
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  Text(
                    offer.duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.orange,
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  Icon(
                    Icons.flight_land,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${offer.arrivalTime.hour.toString().padLeft(2, '0')}:${offer.arrivalTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      offer.to,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      offer.toCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          
          // Flight info
          _buildDetailRow('شركة الطيران', '${offer.airline} - ${offer.flightNumber}'),
          _buildDetailRow('تاريخ الرحلة', DateFormat('dd/MM/yyyy').format(offer.departureTime)),
          _buildDetailRow('درجة السفر', offer.cabin),
          _buildDetailRow('نوع الطائرة', offer.aircraft),
        ],
      ),
    );
  }

  Widget _buildPassengerDetails() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'بيانات المسافر',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow('الاسم', '${passengerData['firstName']} ${passengerData['lastName']}'),
          _buildDetailRow('البريد الإلكتروني', passengerData['email']),
          _buildDetailRow('رقم الهاتف', passengerData['phone']),
          _buildDetailRow('رقم جواز السفر', passengerData['passport']),
          _buildDetailRow('الجنسية', passengerData['nationality']),
          _buildDetailRow('تاريخ الميلاد', DateFormat('dd/MM/yyyy').format(passengerData['dateOfBirth'])),
          _buildDetailRow('الجنس', passengerData['gender'] == 'male' ? 'ذكر' : 'أنثى'),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'ملاحظات مهمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildNoteItem('يرجى الوصول إلى المطار قبل 3 ساعات من موعد الإقلاع للرحلات الدولية'),
          _buildNoteItem('تأكد من صحة بيانات جواز السفر وصلاحيته'),
          _buildNoteItem('راجع متطلبات الفيزا للدولة المقصودة'),
          _buildNoteItem('احتفظ برقم الحجز لإجراءات تسجيل الوصول'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, left: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Download ticket functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سيتم إرسال التذكرة إلى بريدك الإلكتروني'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, size: 20),
                SizedBox(width: 8),
                Text(
                  'تحميل التذكرة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              context.go('/UserHomeScreen');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'العودة للرئيسية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}