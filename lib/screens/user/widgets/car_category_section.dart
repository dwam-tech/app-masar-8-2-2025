import 'package:flutter/material.dart';

class CarCategorySection extends StatelessWidget {
  final String carCategory;
  final ValueChanged<String> onCarCategoryChanged;

  const CarCategorySection({
    Key? key,
    required this.carCategory,
    required this.onCarCategoryChanged,
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
            'فئة السيارة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          _buildCarCategoryRadioOption('اقتصادية'),
          _buildCarCategoryRadioOption('مميزة'),
        ],
      ),
    );
  }

  Widget _buildCarCategoryRadioOption(String category) {
    return GestureDetector(
      onTap: () => onCarCategoryChanged(category),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: carCategory == category
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
            Text(
              category,
              style: const TextStyle(
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
                  color: carCategory == category
                      ? const Color(0xFFFC8700)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: carCategory == category
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
    );
  }
}