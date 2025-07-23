import 'package:flutter/material.dart';

class ModernCityDropdown extends StatefulWidget {
  final String? selectedCity;
  final List<String> cities;
  final ValueChanged<String?> onChanged;

  const ModernCityDropdown({
    Key? key,
    required this.selectedCity,
    required this.cities,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ModernCityDropdown> createState() => _ModernCityDropdownState();
}

class _ModernCityDropdownState extends State<ModernCityDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            if (_isExpanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              border: Border.all(
                color: _isExpanded
                    ? Colors.blue.shade300
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المدينة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.selectedCity ?? 'اختر مدينة',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                // Dropdown List
                SizeTransition(
                  sizeFactor: _animation,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: widget.cities.map((city) {
                              final isSelected = city == widget.selectedCity;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      widget.onChanged(city);
                                      setState(() {
                                        _isExpanded = false;
                                      });
                                      _animationController.reverse();
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelected
                                            ? Colors.blue.shade50
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue.shade300
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade400,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          if (isSelected) const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              city,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? Colors.blue.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}