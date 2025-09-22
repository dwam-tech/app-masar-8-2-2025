import 'package:flutter/material.dart';

class DeliveryTimeSection extends StatelessWidget {
  final String deliveryTime;
  final ValueChanged<String> onDeliveryTimeChanged;

  const DeliveryTimeSection({
    Key? key,
    required this.deliveryTime,
    required this.onDeliveryTimeChanged,
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
            'وقت التوصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => onDeliveryTimeChanged('توصيل الآن'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: deliveryTime == 'توصيل الآن'
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFC8700),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'توصيل الآن',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: deliveryTime == 'توصيل الآن'
                            ? const Color(0xFFFC8700)
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: deliveryTime == 'توصيل الآن'
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFC8700),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onDeliveryTimeChanged('تحديد الوقت'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: deliveryTime == 'تحديد الوقت'
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFC8700),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تحديد الوقت',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: deliveryTime == 'تحديد الوقت'
                            ? const Color(0xFFFC8700)
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: deliveryTime == 'تحديد الوقت'
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFC8700),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}