import 'package:flutter/material.dart';

class PaymentMethodSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodSelected;

  const PaymentMethodSection({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPaymentMethodCard(
              context: context,
              icon: Icons.money,
              label: 'كاش',
              method: 'Cash',
            ),
            const SizedBox(width: 16),
            _buildPaymentMethodCard(
              context: context,
              icon: Icons.credit_card,
              label: 'بطاقة ائتمانية',
              method: 'Credit Card',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String method,
  }) {
    final isSelected = selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPaymentMethodSelected(method),
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
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : const Color(0xFF333333),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}