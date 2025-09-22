import 'package:flutter/material.dart';

class RouteDetailsSection extends StatelessWidget {
  final bool isCalculatingRoute;
  final double? totalDistanceKm;
  final int? estimatedDurationMinutes;
  final double? estimatedPrice;

  const RouteDetailsSection({
    Key? key,
    required this.isCalculatingRoute,
    this.totalDistanceKm,
    this.estimatedDurationMinutes,
    this.estimatedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'تفاصيل المسار المقترح',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          if (isCalculatingRoute)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFC8700)))
          else ...[
            _buildRouteDetailRow(
              icon: Icons.social_distance,
              label: 'المسافة الإجمالية',
              value: totalDistanceKm != null ? '${totalDistanceKm!.toStringAsFixed(2)} كم' : 'غير متاحة',
            ),
            const SizedBox(height: 8),
            _buildRouteDetailRow(
              icon: Icons.timer,
              label: 'الوقت المتوقع للرحلة',
              value: estimatedDurationMinutes != null ? '$estimatedDurationMinutes دقيقة' : 'غير متاحة',
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildRouteDetailRow(
              icon: Icons.price_change,
              label: 'السعر المقترح',
              value: estimatedPrice != null ? '${estimatedPrice!.toStringAsFixed(2)} جنيه' : 'غير متاح',
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFC8700), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF333333),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}