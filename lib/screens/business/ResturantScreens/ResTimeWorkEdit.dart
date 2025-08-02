// lib/screens/res_time_work_edit.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/restaurant_profile_provider.dart'; // Ensure path is correct

class ResTimeWorkEdit extends StatefulWidget {
  const ResTimeWorkEdit({super.key});
  @override
  State<ResTimeWorkEdit> createState() => _ResTimeWorkEditState();
}

class _ResTimeWorkEditState extends State<ResTimeWorkEdit> {
  final List<String> _weekDays = [ 'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة' ];
  
  // State variables - will be initialized with real data
  late List<bool> _activeDays;
  late List<TimeOfDay> _startTimes;
  late List<TimeOfDay> _endTimes;
  bool _isDataInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize data only once when the provider has it
    if (!_isDataInitialized) {
      _initializeDataFromProvider();
    }
  }
  
  /// Parses the working hours from the provider and populates the UI state
  void _initializeDataFromProvider() {
    final provider = context.watch<RestaurantProfileProvider>();
    final workingHours = provider.restaurantData?['restaurant_detail']?['working_hours'] as List?;

    // Default values if no data exists
    _activeDays = List.generate(7, (i) => i != 6); // Friday off by default
    _startTimes = List.generate(7, (_) => const TimeOfDay(hour: 9, minute: 0));
    _endTimes = List.generate(7, (_) => const TimeOfDay(hour: 23, minute: 0));

    if (workingHours != null && workingHours.isNotEmpty) {
       _activeDays = List.generate(7, (_) => false); // Reset all to inactive initially

      for (var schedule in workingHours) {
        final day = schedule['day'] as String?;
        final from = schedule['from'] as String?;
        final to = schedule['to'] as String?;
        
        final dayIndex = _weekDays.indexOf(day ?? '');
        
        if (dayIndex != -1 && from != null && to != null) {
          _activeDays[dayIndex] = true;
          _startTimes[dayIndex] = TimeOfDay(hour: int.parse(from.split(':')[0]), minute: int.parse(from.split(':')[1]));
          _endTimes[dayIndex] = TimeOfDay(hour: int.parse(to.split(':')[0]), minute: int.parse(to.split(':')[1]));
        }
      }
    }
    _isDataInitialized = true;
  }
  
  // --- UI Logic Methods ---
  Future<void> _selectStartTime(int dayIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTimes[dayIndex],
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startTimes[dayIndex] = picked;
        _adjustEndTime(dayIndex, picked);
      });
    }
  }

  Future<void> _selectEndTime(int dayIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTimes[dayIndex],
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );

    if (picked != null && _validateTime(dayIndex, picked)) {
      setState(() => _endTimes[dayIndex] = picked);
    }
  }

  void _adjustEndTime(int dayIndex, TimeOfDay startTime) {
    if (_timeToDouble(startTime) >= _timeToDouble(_endTimes[dayIndex])) {
      int newHour = startTime.hour + 2;
      if (newHour >= 24) {
        _endTimes[dayIndex] = const TimeOfDay(hour: 23, minute: 59);
      } else {
        _endTimes[dayIndex] = TimeOfDay(hour: newHour, minute: startTime.minute);
      }
    }
  }

  bool _validateTime(int dayIndex, TimeOfDay endTime) {
    if (_timeToDouble(endTime) <= _timeToDouble(_startTimes[dayIndex])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن يكون وقت النهاية بعد وقت البداية')),
      );
      return false;
    }
    return true;
  }

  double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
  
  String _formatTime(TimeOfDay time) {
    final dt = DateTime(2023, 1, 1, time.hour, time.minute);
    return DateFormat.jm('en_US').format(dt); // Using 'en_US' for AM/PM format
  }

  void _copyTimesToActiveDays(int fromDayIndex) {
    setState(() {
      for (int i = 0; i < _activeDays.length; i++) {
        if (_activeDays[i] && i != fromDayIndex) {
          _startTimes[i] = _startTimes[fromDayIndex];
          _endTimes[i] = _endTimes[fromDayIndex];
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الأوقات إلى جميع الأيام المفعلة')),
    );
  }

  /// **The new, real _submitData function**
  Future<void> _submitData() async {
    final provider = context.read<RestaurantProfileProvider>();
    if (provider.restaurantData == null) return;
    
    // 1. Convert UI state back to the API JSON format
    List<Map<String, String>> updatedWorkingHours = [];
    for (int i = 0; i < _weekDays.length; i++) {
      if (_activeDays[i]) {
        updatedWorkingHours.add({
          'day': _weekDays[i],
          'from': '${_startTimes[i].hour.toString().padLeft(2, '0')}:${_startTimes[i].minute.toString().padLeft(2, '0')}',
          'to': '${_endTimes[i].hour.toString().padLeft(2, '0')}:${_endTimes[i].minute.toString().padLeft(2, '0')}',
        });
      }
    }
    
    // 2. Create the payload map for the API
    final Map<String, dynamic> dataToSave = {
      'working_hours': updatedWorkingHours
    };
    
    // 3. Call the provider's new update method
    final success = await provider.updateRestaurantProfile(dataToSave);
    
    // 4. Show feedback
    if (mounted) {
      if(success) {
        ScaffoldMessenger.of(context).showSnackBar(_snack('تم حفظ مواعيد العمل بنجاح', Colors.green));
        context.pop(); // Go back on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(_snack(provider.error ?? 'فشل حفظ البيانات', Colors.red));
      }
    }
  }

  SnackBar _snack(String text, Color color) {
    return SnackBar(
      content: Text(text),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  double _screenPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 32.0;
    if (screenWidth > 400) return 20.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    // We get the provider here to know the loading state
    final provider = context.watch<RestaurantProfileProvider>();
    final pad = _screenPadding(context);
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      appBar: AppBar(
        title: const Text('مواعيد العمل', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange), 
          onPressed: () => context.pop()
        ),
      ),
      body: !_isDataInitialized // Show loader until data is parsed from provider
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : Padding(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(18),
                      separatorBuilder: (_, __) => Divider(height: 32, color: Colors.grey[200]),
                      itemCount: _weekDays.length,
                      itemBuilder: (context, index) => _buildDayRow(index, sw),
                    ),
                  ),
                  _buildSubmitButton(sw, provider.isLoading), // Pass loading state to the button
                ],
              ),
            ),
        ),
    );
  }

  // --- BUILD WIDGETS ---
  Widget _buildDayRow(int index, double sw) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
               color: Colors.grey.withValues(alpha: 0.1),
               spreadRadius: 1,
               blurRadius: 3,
               offset: const Offset(0, 2),
             ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCopyButton(index),
                const Spacer(),
                _buildDayName(index),
                const Spacer(),
                _buildActiveToggle(index),
              ],
            ),
            if (_activeDays[index]) ...[
              const Divider(height: 16),
              _buildTimeControls(index, sw),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton(int index) {
    return IconButton(
      icon: const Icon(Icons.copy_all_outlined, color: Colors.grey, size: 20),
      onPressed: _activeDays[index] ? () => _copyTimesToActiveDays(index) : null,
      tooltip: 'نسخ هذه الأوقات إلى باقي الأيام',
    );
  }

  Widget _buildDayName(int index) {
    return Text(
      _weekDays[index],
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActiveToggle(int index) {
    return Switch(
      value: _activeDays[index],
      onChanged: (value) => setState(() => _activeDays[index] = value),
      activeColor: Colors.orange,
    );
  }

  Widget _buildTimeControls(int index, double sw) {
    return Row(
      children: [
        _buildTimeField(
          label: 'إلى', 
          time: _endTimes[index], 
          onTap: () => _selectEndTime(index), 
          hasBorder: true, 
          sw: sw
        ),
        _buildTimeField(
          label: 'من', 
          time: _startTimes[index], 
          onTap: () => _selectStartTime(index),
          sw: sw
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    bool hasBorder = false,
    required double sw,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: hasBorder
              ? BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300)))
              : null,
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(_formatTime(time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double sw, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading 
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                )
              : const Text(
                  'حفظ', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                ),
        ),
      ),
    );
  }
}