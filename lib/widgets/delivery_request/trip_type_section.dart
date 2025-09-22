import 'package:flutter/material.dart';

enum TripType {
  oneWay,
  roundTrip,
}

class TripTypeSection extends StatelessWidget {
  final TripType selectedTripType;
  final Function(TripType) onTripTypeSelected;

  const TripTypeSection({
    Key? key,
    required this.selectedTripType,
    required this.onTripTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTripTypeChip(
          context: context,
          label: 'ذهاب فقط',
          type: TripType.oneWay,
        ),
        _buildTripTypeChip(
          context: context,
          label: 'ذهاب وعودة',
          type: TripType.roundTrip,
        ),
      ],
    );
  }

  Widget _buildTripTypeChip({
    required BuildContext context,
    required String label,
    required TripType type,
  }) {
    final isSelected = selectedTripType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onTripTypeSelected(type);
        }
      },
      backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontFamily: 'Cairo',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
        ),
      ),
    );
  }
}