import 'package:flutter/material.dart';

class FareSection extends StatelessWidget {
  final TextEditingController fareController;
  final double? estimatedPrice;

  const FareSection({
    Key? key,
    required this.fareController,
    this.estimatedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFC8700), width: 1),
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
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                color: Color(0xFFFC8700),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'أجرة التوصيلة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (estimatedPrice != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFC8700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFC8700).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFFFC8700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'السعر المقترح بناءً على المسافة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFC8700),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '${estimatedPrice!.toStringAsFixed(0)} جنيه',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFC8700),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fareController.text = estimatedPrice!.toStringAsFixed(0);
                    },
                    child: const Text(
                      'استخدام',
                      style: TextStyle(
                        color: Color(0xFFFC8700),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextFormField(
            controller: fareController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'أجرة التوصيلة (جنيه)',
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
              hintText: estimatedPrice != null
                  ? 'السعر المقترح: ${estimatedPrice!.toStringAsFixed(0)} جنيه'
                  : 'أدخل أجرة التوصيلة',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey[400],
              ),
              prefixIcon: const Icon(
                Icons.money,
                color: Color(0xFFFC8700),
              ),
              suffixText: 'جنيه',
              suffixStyle: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFC8700)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال أجرة التوصيلة';
              }
              final fare = double.tryParse(value);
              if (fare == null || fare <= 0) {
                return 'يرجى إدخال أجرة صحيحة';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يمكنك تعديل السعر المقترح حسب احتياجاتك. السعر النهائي قابل للتفاوض مع السائق.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
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