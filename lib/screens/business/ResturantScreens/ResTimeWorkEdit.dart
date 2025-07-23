import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ResTimeWorkEdit extends StatefulWidget {
  const ResTimeWorkEdit({super.key});

  @override
  State<ResTimeWorkEdit> createState() => _ResTimeWorkEditState();
}

class _ResTimeWorkEditState extends State<ResTimeWorkEdit> {
  final List<String> _weekDays = [
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'
  ];
  final List<bool> _activeDays = [true, true, true, true, true, true, false];
  final List<TimeOfDay> _startTimes =
  List.generate(7, (index) => const TimeOfDay(hour: 9, minute: 0));
  final List<TimeOfDay> _endTimes =
  List.generate(7, (index) => const TimeOfDay(hour: 23, minute: 0));

  double _screenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1024) return w * 0.25;
    if (w > 600) return w * 0.13;
    return 10;
  }

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

  void _adjustEndTime(int dayIndex, TimeOfDay startTime) {
    if (_timeToDouble(startTime) >= _timeToDouble(_endTimes[dayIndex])) {
      int newHour = startTime.hour + 2;
      if (newHour >= 24) {
        newHour = 23;
        _endTimes[dayIndex] = const TimeOfDay(hour: 23, minute: 59);
      } else {
        _endTimes[dayIndex] = TimeOfDay(hour: newHour, minute: startTime.minute);
      }
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

  bool _validateTime(int dayIndex, TimeOfDay endTime) {
    if (_timeToDouble(endTime) <= _timeToDouble(_startTimes[dayIndex])) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snack('يجب أن يكون وقت النهاية بعد وقت البداية', Colors.red),
      );
      return false;
    }
    return true;
  }

  double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

  String _formatTime(TimeOfDay time) {
    final dt = DateTime(2023, 1, 1, time.hour, time.minute);
    return DateFormat.jm().format(dt);
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
      _snack('تم نسخ الأوقات إلى جميع الأيام المفعلة', Colors.green),
    );
  }

  void _submitData() {
    // هنا تقدر تعمل حفظ للبيانات
    ScaffoldMessenger.of(context).showSnackBar(
      _snack('تم حفظ مواعيد العمل بنجاح', Colors.orange),
    );
    context.go('/RestaurantEditProfile');
  }

  SnackBar _snack(String text, Color color) => SnackBar(
    content: Text(text, style: const TextStyle(fontSize: 15)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(18),
    duration: const Duration(seconds: 2),
  );

  @override
  Widget build(BuildContext context) {
    final pad = _screenPadding(context);
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => context.go("/RestaurantEditProfile"),
          tooltip: 'رجوع',
        ),
        title: const Text(
          'مواعيد العمل',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(right: pad, left: pad, top: 14, bottom: 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  separatorBuilder: (_, __) => Divider(height: 32, color: Colors.grey[100]),
                  itemCount: _weekDays.length,
                  itemBuilder: (context, index) => _buildDayRow(index, sw),
                ),
              ),
              _buildSubmitButton(sw),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(int index, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (index != 6)
              Tooltip(
                message: 'نسخ هذا الوقت لباقي الأيام',
                child: IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey, size: 22),
                  onPressed: _activeDays[index] ? () => _copyTimesToActiveDays(index) : null,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                ),
              ),
            const Spacer(),
            Text(
              _weekDays[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _activeDays[index] = !_activeDays[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _activeDays[index] ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: _activeDays[index] ? Colors.orange : Colors.grey),
                ),
                child: _activeDays[index]
                    ? const Icon(Icons.check, color: Colors.white, size: 17)
                    : null,
              ),
            ),
          ],
        ),
        if (_activeDays[index]) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildTimeField(
                  label: 'إلى',
                  time: _endTimes[index],
                  onTap: () => _selectEndTime(index),
                  hasBorder: true,
                  sw: sw,
                ),
                _buildTimeField(
                  label: 'من',
                  time: _startTimes[index],
                  onTap: () => _selectStartTime(index),
                  sw: sw,
                ),
              ],
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: sw > 500 ? 18 : 12),
          decoration: hasBorder
              ? BoxDecoration(
              border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 1.2)))
              : null,
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                _formatTime(time),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double sw) {
    return Container(
      padding: EdgeInsets.only(bottom: 22, right: 8, left: 8, top: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(vertical: sw > 500 ? 18 : 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'حفظ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
