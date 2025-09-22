import 'package:flutter/material.dart';

class FareSection extends StatelessWidget {
  final double totalPrice;
  final bool isPriceLoading;

  const FareSection({
    super.key,
    required this.totalPrice,
    required this.isPriceLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Trip Fare:', style: Theme.of(context).textTheme.titleLarge),
          if (isPriceLoading)
            const CircularProgressIndicator()
          else
            Text(
              totalPrice > 0 ? '${totalPrice.toStringAsFixed(2)} EGP' : 'N/A',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
        ],
      ),
    );
  }
}