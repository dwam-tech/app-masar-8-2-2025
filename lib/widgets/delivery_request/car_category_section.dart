import 'package:flutter/material.dart';

class CarCategorySection extends StatelessWidget {
  final String selectedCarCategory;
  final Function(String) onCarCategorySelected;

  const CarCategorySection({
    Key? key,
    required this.selectedCarCategory,
    required this.onCarCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فئة السيارة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCarCategoryCard(
                context: context,
                icon: Icons.directions_car,
                label: 'سيارة عادية',
                category: 'Sedan',
              ),
              const SizedBox(width: 12),
              _buildCarCategoryCard(
                context: context,
                icon: Icons.local_shipping,
                label: 'شاحنة صغيرة',
                category: 'Van',
              ),
              const SizedBox(width: 12),
              _buildCarCategoryCard(
                context: context,
                icon: Icons.motorcycle,
                label: 'دراجة نارية',
                category: 'Motorcycle',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String category,
  }) {
    final isSelected = selectedCarCategory == category;
    return GestureDetector(
      onTap: () => onCarCategorySelected(category),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? Colors.white : const Color(0xFF333333),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}