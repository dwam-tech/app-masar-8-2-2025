import 'package:flutter/material.dart';

class EstimatedDurationSection extends StatelessWidget {
  final int? estimatedDurationMinutes;

  const EstimatedDurationSection({
    Key? key,
    this.estimatedDurationMinutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFC8700), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مدة الرحلة المتوقعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFC8700),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (estimatedDurationMinutes != null && estimatedDurationMinutes! > 0)
                        ? 'الرحلة تستغرق حوالي $estimatedDurationMinutes دقيقة'
                        : 'الرحلة تستغرق حوالي 20 دقيقة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontFamily: 'Cairo',
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
}