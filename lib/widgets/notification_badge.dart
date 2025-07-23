import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final String count;
  final Color backgroundColor;
  
  const NotificationBadge({
    super.key,
    required this.count,
    this.backgroundColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}