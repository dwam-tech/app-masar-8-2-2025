import 'package:flutter/material.dart';

class PaymentMethodSection extends StatelessWidget {
  final String paymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;

  const PaymentMethodSection({
    Key? key,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
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
            'طريقة الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: paymentMethod,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFFC8700),
                    size: 24,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: Color(0xFF333333),
                  ),
                  dropdownColor: Colors.white,
                  items: ['كاش', 'فيزا'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Cairo',
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onPaymentMethodChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}