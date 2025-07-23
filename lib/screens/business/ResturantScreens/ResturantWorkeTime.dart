import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantInformation.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantLawData.dart';

class RestaurantWorkHours {
  final Map<String, Map<String, TimeOfDay>> schedule;
  final List<String> activeDays;

  RestaurantWorkHours({
    required this.schedule,
    required this.activeDays,
  });

  Map<String, dynamic> toJson() => {
        'schedule': schedule.map((key, value) => MapEntry(
              key,
              {
                'start': _timeToString(value['start']!),
                'end': _timeToString(value['end']!),
              },
            )),
        'active_days': activeDays,
      };

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ResturantWorkTime extends StatefulWidget {
  final RestaurantLegalData legalData;
  final RestaurantAccountInfo accountInfo;

  const ResturantWorkTime({
    super.key,
    required this.legalData,
    required this.accountInfo,
  });

  @override
  State<ResturantWorkTime> createState() => _ResturantWorkTimeState();
}

class _ResturantWorkTimeState extends State<ResturantWorkTime> {
  final List<String> _weekDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  final List<bool> _activeDays = [true, true, true, true, true, true, false];
  final List<TimeOfDay> _startTimes = List.generate(7, (index) => const TimeOfDay(hour: 9, minute: 0)   );
  final List<TimeOfDay> _endTimes = List.generate(7, (index) => const TimeOfDay(hour: 23, minute: 0) );

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
        const SnackBar(content: Text('يجب أن يكون وقت النهاية بعد وقت البداية')),
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
      const SnackBar(content: Text('تم نسخ الأوقات إلى جميع الأيام المفعلة')),
    );
  }

  void _submitData() {
    context.go('/restaurant-home');
    final workHours = _prepareWorkHours();

    final completeData = {
      'legal_data': widget.legalData.toJson(),
      'account_info': widget.accountInfo.toJson(),
      'work_hours': workHours.toJson(),
    };

    debugPrint('Complete Registration Data: $completeData');
    context.go('/restaurant-home');
  }
  void _submitDataForTest() {
    context.go('/restaurant-home');

  }

  RestaurantWorkHours _prepareWorkHours() {
    final schedule = <String, Map<String, TimeOfDay>>{};
    final activeDays = <String>[];

    for (int i = 0; i < _weekDays.length; i++) {
      if (_activeDays[i]) {
        schedule[_weekDays[i]] = {
          'start': _startTimes[i],
          'end': _endTimes[i],
        };
        activeDays.add(_weekDays[i]);
      }
    }

    return RestaurantWorkHours(
      schedule: schedule,
      activeDays: activeDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيد العمل'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _weekDays.length,
              itemBuilder: (context, index) => _buildDayRow(index),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDayRow(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index != 6) _buildCopyButton(index),
            _buildDayName(index),
            _buildActiveToggle(index),
          ],
        ),
        const SizedBox(height: 8),
        if (_activeDays[index]) _buildTimeControls(index),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCopyButton(int index) {
    return IconButton(
      icon: const Icon(Icons.copy, color: Colors.grey),
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
    return InkWell(
      onTap: () => setState(() => _activeDays[index] = !_activeDays[index]),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _activeDays[index] ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _activeDays[index] ? Colors.orange : Colors.grey),
        ),
        child: _activeDays[index] 
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _buildTimeControls(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTimeField(
            label: 'إلى',
            time: _endTimes[index],
            onTap: () => _selectEndTime(index),
            hasBorder: true,
          ),
          _buildTimeField(
            label: 'من',
            time: _startTimes[index],
            onTap: () => _selectStartTime(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: hasBorder
              ? BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300)))
              : null,
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(_formatTime(time), style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitDataForTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'حفظ ومتابعة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}