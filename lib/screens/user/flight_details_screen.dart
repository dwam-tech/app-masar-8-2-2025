import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/flight_offer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FlightOffer offer;

  const FlightDetailsScreen({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      title: Text(
        'تفاصيل الرحلة',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.black87, size: 20),
            onPressed: () {
              // Share functionality
            },
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlightSummaryCard(),
          SizedBox(height: 16),
          _buildFlightDetailsCard(),
          SizedBox(height: 16),
          _buildAircraftInfoCard(),
          SizedBox(height: 16),
          _buildAmenitiesCard(),
          SizedBox(height: 16),
          _buildFareInfoCard(),
          SizedBox(height: 24),
          _buildBookingButton(context),
          SizedBox(height: 16),
        ],
      ),
    ),
        );
  }

  Widget _buildFlightSummaryCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Airline and flight number
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B35).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.airline,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'رحلة ${offer.flightNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B35).withOpacity(0.1), Color(0xFFFF8E53).withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFF6B35).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${offer.price.toStringAsFixed(0)} ${offer.currency}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6B35),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'للشخص الواحد',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Flight route
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${offer.departureTime.hour.toString().padLeft(2, '0')}:${offer.departureTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: 4),
                      Text(
                        offer.from,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        offer.fromCode,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flight_takeoff,
                          color: Color(0xFFFF6B35),
                          size: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFFF6B35).withOpacity(0.3)),
                        ),
                        child: Text(
                          offer.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flight_land,
                          color: Color(0xFFFF6B35),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${offer.arrivalTime.hour.toString().padLeft(2, '0')}:${offer.arrivalTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 4),
                      Text(
                        offer.to,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        offer.toCode,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetailsCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'تفاصيل الرحلة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailRow('تاريخ المغادرة', DateFormat('dd/MM/yyyy').format(offer.departureTime)),
          _buildDetailRow('وقت المغادرة', '${offer.departureTime.hour.toString().padLeft(2, '0')}:${offer.departureTime.minute.toString().padLeft(2, '0')}'),
          _buildDetailRow('وقت الوصول', '${offer.arrivalTime.hour.toString().padLeft(2, '0')}:${offer.arrivalTime.minute.toString().padLeft(2, '0')}'),
          _buildDetailRow('مدة الرحلة', offer.duration),
          _buildDetailRow('درجة السفر', offer.cabin),
          _buildDetailRow('المقاعد المتاحة', '${offer.availableSeats} مقعد'),
        ],
      ),
    );
  }

  Widget _buildAircraftInfoCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.airplanemode_active,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'معلومات الطائرة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flight,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع الطائرة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        offer.aircraft,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'الخدمات المتاحة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: offer.amenities.map((amenity) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6).withOpacity(0.1), Color(0xFF7C3AED).withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Color(0xFF8B5CF6).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8B5CF6).withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF8B5CF6),
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    amenity,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFareInfoCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'معلومات التذكرة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailRow('نوع التذكرة', offer.fareType),
          _buildDetailRow('قابلية الاسترداد', offer.refundable ? 'قابل للاسترداد' : 'غير قابل للاسترداد'),
          _buildDetailRow('السعر الأساسي', '${offer.price.toStringAsFixed(0)} ${offer.currency}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/booking', extra: offer);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'احجز الآن - ${offer.price.toStringAsFixed(0)} ${offer.currency}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.flight_takeoff,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}