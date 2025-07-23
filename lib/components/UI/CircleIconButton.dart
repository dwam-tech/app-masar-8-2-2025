import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Widget? badge;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 28,
              ),
            ),
          ),
        ),
        if (badge != null) badge!,
      ],
    );
  }
}
