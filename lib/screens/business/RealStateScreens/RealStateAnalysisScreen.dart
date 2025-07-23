import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class RealStateAnalysisScreen extends StatefulWidget {
  const RealStateAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<RealStateAnalysisScreen> createState() => _RealStateAnalysisScreenState();
}

class _RealStateAnalysisScreenState extends State<RealStateAnalysisScreen> {
  String selectedPeriod = 'شهرية';

  // بيانات تجريبية للرسم البياني
  final List<FlSpot> chartData = [
    FlSpot(0, 30),
    FlSpot(1, 20),
    FlSpot(2, 85),
    FlSpot(3, 45),
    FlSpot(4, 70),
    FlSpot(5, 35),
    FlSpot(6, 60),
    FlSpot(7, 80),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 90),
    FlSpot(11, 85),
  ];

  final List<String> months = [
    'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isTablet),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Column(
                  children: [
                    _buildPeriodSelector(isTablet),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildChartCard(isTablet),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildPropertyStatsCard(isTablet),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildTopPropertiesCard(isTablet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32.0 : 16.0,
          vertical: isTablet ? 20.0 : 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButtons(context, isTablet),
            _buildTitle(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String badge,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isTablet ? 48.0 : 44.0,
          height: isTablet ? 48.0 : 44.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(
                icon,
                size: isTablet ? 24.0 : 20.0,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 12.0 : 10.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.notifications_outlined,
          badge: "3",
          onTap: () => context.push("/NotificationsScreen"),
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        IconButton(
          onPressed: () {
            // إضافة وظيفة تصدير التقرير
            _exportReport(context);
          },
          icon: Icon(
            Icons.file_download_outlined,
            size: isTablet ? 28 : 24,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Text(
      'الإحصائيات',
      style: TextStyle(
        fontSize: isTablet ? 24 : 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('عامة', isTablet),
          _buildPeriodButton('شهرية', isTablet),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title, bool isTablet) {
    final isSelected = selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = title;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 12,
            horizontal: isTablet ? 24 : 16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: isTablet ? 300 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isTablet ? 12 : 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()].substring(0, 3),
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: isTablet ? 10 : 8,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.8),
                        Colors.purple.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.purple.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('إجمالي المبيعات', Colors.red, isTablet),
              _buildLegendItem('صافي الربح', Colors.blue, isTablet),
              _buildLegendItem('عدد العقارات', Colors.orange, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 12 : 10,
          height: isTablet ? 12 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyStatsCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجمالي العقارات',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: isTablet ? 200 : 150,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue,
                          value: 30,
                          title: '30%',
                          radius: isTablet ? 60 : 50,
                          titleStyle: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: 45,
                          title: '45%',
                          radius: isTablet ? 60 : 50,
                          titleStyle: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.grey,
                          value: 25,
                          title: '25%',
                          radius: isTablet ? 60 : 50,
                          titleStyle: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPieChartLegend('مباع', '615', Colors.blue, isTablet),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildPieChartLegend('قيد البيع', '539', Colors.red, isTablet),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildPieChartLegend('غير متاح', '815', Colors.grey, isTablet),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(String title, String value, Color color, bool isTablet) {
    return Row(
      children: [
        Container(
          width: isTablet ? 16 : 12,
          height: isTablet ? 16 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPropertiesCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأكثر مبيعًا',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: isTablet ? 16 : 12,
            mainAxisSpacing: isTablet ? 16 : 12,
            childAspectRatio: 1,
            children: [
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
              _buildPropertyCard('فيلا التجمع', '(199)', isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String name, String count, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 40 : 30,
            height: isTablet ? 40 : 30,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.home,
              color: Colors.orange,
              size: isTablet ? 20 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            count,
            style: TextStyle(
              fontSize: isTablet ? 10 : 8,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 1; // الإحصائيات

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/RealStateHomeScreen');
          break;
        case 1:
          context.go('/RealStateAnalysisScreen');
          break;
        case 2:
          context.go('/RealStateSettingsProvider');
          break;

      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 10,
              horizontal: isTablet ? 20 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navIcons.length, (idx) {
                final item = navIcons[idx];
                final selected = idx == currentIndex;
                Color mainColor =
                selected ? Colors.orange : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () => onItemTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          item["svg"]!,
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          colorFilter:
                          ColorFilter.mode(mainColor, BlendMode.srcIn),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          item["label"]!,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // وظائف إضافية لتحسين تجربة المستخدم
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإشعارات'),
        content: const Text('لا توجد إشعارات جديدة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير التقرير'),
        content: const Text('هل تريد تصدير التقرير كملف PDF؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير التقرير بنجاح')),
              );
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }
}