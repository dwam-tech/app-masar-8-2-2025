import 'package:flutter/material.dart';

class NoteSection extends StatelessWidget {
  final TextEditingController notesController;

  const NoteSection({Key? key, required this.notesController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات إضافية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اترك ملاحظاتك هنا للسائق...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}