import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/models/car_model.dart';
import 'package:saba2v2/screens/business/CarsScreens/add_car_dialog.dart';
import 'package:saba2v2/screens/business/CarsScreens/car_card_widget.dart';
import 'package:saba2v2/services/car_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCarRental extends StatefulWidget {
  const AddCarRental({super.key});

  @override
  State<AddCarRental> createState() => _AddCarRentalState();
}

class _AddCarRentalState extends State<AddCarRental> {
  late int _carRentalId;
  final String _ownerType = "office";
  final int _currentIndex = 1; // القائمة النشطة حاليًا

  late CarApiService _apiService;
  Future<List<Car>>? _carsFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final carRentalId = prefs.getInt('car_rental_id') ?? 0;

    setState(() {
      _carRentalId = carRentalId;
      _apiService = CarApiService(token: token);
      _carsFuture = _apiService.fetchMyCars(_carRentalId);
    });
  }

  void _loadCars() {
    setState(() {
      _carsFuture = _apiService.fetchMyCars(_carRentalId);
    });
  }

  void _onCarAddedSuccessfully() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("تمت إضافة السيارة بنجاح!"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
    _loadCars();
  }

  void _openAddCarDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) => AddCarDialog(
        carRentalId: _carRentalId,
        ownerType: _ownerType,
        apiService: _apiService,
        onCarAdded: _onCarAddedSuccessfully,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          "سياراتي",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryColor),
            tooltip: "تحديث القائمة",
            onPressed: _loadCars,
          ),
        ],
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final cars = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadCars(),
            color: theme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return CarCard(
                  car: cars[index],
                  onTap: () {
                    context.push('/car-details', extra: cars[index]);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCarDialog,
        backgroundColor: Color(0xFFFC8700),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "إضافة سيارة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_transfer_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "لم تقم بإضافة أي سيارات بعد",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "انقر على زر الإضافة لبدء إضافة سياراتك",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            "حدث خطأ في جلب البيانات",
            style: TextStyle(fontSize: 18, color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ------------- BOTTOM NAV -------------
  // ------------- BOTTOM NAV -------------
  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 1; // القائمة

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/delivery-homescreen');
          break;
        case 1:
          context.go('/AddCarRental');
          break;
        case 2:
          context.go('/CarRentalAnalysisScreen');
          break;
        case 3:
          context.go('/CarRentalSettingsProvider');
          break;

      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Menu_provider.svg", "label": "اضافه عربيه"},
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
              vertical: isTablet ? 16 : 5,
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
                      vertical: isTablet ? 12 : 5,
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
}