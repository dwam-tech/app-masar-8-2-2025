import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final String count;
  const NotificationBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 2,
      top: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        constraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        child: Center(
          child: Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
