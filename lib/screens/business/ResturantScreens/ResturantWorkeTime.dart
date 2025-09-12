// مسار الملف: lib/screens/ResturantScreens/ResturantWorkTime.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
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
  bool _isLoading = false;
  final List<String> _weekDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  final List<bool> _activeDays = [true, true, true, true, true, true, false];
  final List<TimeOfDay> _startTimes = List.generate(7, (index) => const TimeOfDay(hour: 9, minute: 0));
  final List<TimeOfDay> _endTimes = List.generate(7, (index) => const TimeOfDay(hour: 23, minute: 0));

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
        const SnackBar(
          content: Text('يجب أن يكون وقت النهاية بعد وقت البداية'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }
    return true;
  }

  double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

  String _formatTime(TimeOfDay time) {
    final dt = DateTime(2023, 1, 1, time.hour, time.minute);
    // Use 'ar' locale for Arabic formatting like "٩:٠٠ ص"
    return DateFormat.jm('ar').format(dt);
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

  RestaurantWorkHours _prepareWorkHours() {
    final schedule = <String, Map<String, TimeOfDay>>{};
    final activeDays = <String>[];
    for (int i = 0; i < _weekDays.length; i++) {
      if (_activeDays[i]) {
        schedule[_weekDays[i]] = {'start': _startTimes[i], 'end': _endTimes[i]};
        activeDays.add(_weekDays[i]);
      }
    }
    return RestaurantWorkHours(schedule: schedule, activeDays: activeDays);
  }

  Future<void> _submitData() async {
    if (_isLoading) return;
    
    // التحقق من وجود يوم واحد على الأقل مفعل
    if (!_activeDays.any((isActive) => isActive)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تفعيل يوم واحد على الأقل من أيام العمل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workHours = _prepareWorkHours();
      
      final result = await authProvider.registerRestaurant(
        legalData: widget.legalData.toJson(),
        accountInfo: widget.accountInfo.toJson(),
        workHours: workHours.toJson(),
      );

      if (!mounted) return;
      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل المطعم بنجاح! يرجى التحقق من بريدك الإلكتروني.'), backgroundColor: Colors.green),
        );
        if (mounted) {
          context.go('/otp-verification', extra: widget.accountInfo.email);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'فشل التسجيل')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ فادح: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: Stack(
        children: [
          Column(
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
        ],
      ),
    );
  }

  Widget _buildDayRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
              _buildTimeControls(index),
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

  Widget _buildTimeControls(int index) {
    return Row(
      children: [
        _buildTimeField(label: 'إلى', time: _endTimes[index], onTap: () => _selectEndTime(index), hasBorder: true),
        _buildTimeField(label: 'من', time: _startTimes[index], onTap: () => _selectStartTime(index)),
      ],
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

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('إنشاء الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}