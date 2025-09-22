import 'package:flutter/material.dart';

class DeliveryTimeSection extends StatelessWidget {
  final String selectedDeliveryTime;
  final Function(String) onDeliveryTimeSelected;

  const DeliveryTimeSection({
    Key? key,
    required this.selectedDeliveryTime,
    required this.onDeliveryTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وقت التوصيل',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDeliveryTimeCard(
              context: context,
              label: 'الآن',
              time: 'Now',
            ),
            const SizedBox(width: 16),
            _buildDeliveryTimeCard(
              context: context,
              label: 'لاحقًا',
              time: 'Later',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeCard({
    required BuildContext context,
    required String label,
    required String time,
  }) {
    final isSelected = selectedDeliveryTime == time;
    return Expanded(
      child: GestureDetector(
        onTap: () => onDeliveryTimeSelected(time),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFC8700) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFC8700) : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}