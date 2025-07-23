import 'package:flutter/material.dart';
import 'dart:io';

class ImagePickerRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String fieldIdentifier;
  final VoidCallback onTap;
  final String? imagePath;
  final VoidCallback? onRemove;

  const ImagePickerRow({
    super.key,
    required this.label,
    required this.icon,
    required this.fieldIdentifier,
    required this.onTap,
    this.imagePath,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFDEDCD9), width: 1),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 34,
                    height: 31,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEDAB0),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Image.asset(
                      'assets/icons/email-attachment-image.png',
                      height: 15.0,
                      width: 15.0,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 15, color: Colors.red);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                if (onRemove != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onRemove,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}