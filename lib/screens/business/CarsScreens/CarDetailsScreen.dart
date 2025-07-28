// lib/screens/business/CarsScreens/car_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // استيراد خدمات النظام
import 'package:saba2v2/models/car_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:saba2v2/services/car_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late Car _currentCar;

  @override
  void initState() {
    super.initState();
    _currentCar = widget.car;
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await context.push<Car>('/CarDataEdit', extra: _currentCar);
    if (result != null) {
      setState(() {
        _currentCar = result;
      });
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذه السيارة؟ لا يمكن التراجع عن هذا الإجراء."),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text("حذف الآن", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? '';
                final carService = CarApiService(token: token);
                final isDeleted = await carService.deleteCar(_currentCar.id);

                if (isDeleted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم حذف السيارة بنجاح'),
                        backgroundColor: Colors.green),
                  );
                  Navigator.of(context).pop(true);
                } else {
                  throw Exception('فشل الحذف من السيرفر.');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('خطأ أثناء الحذف: $e'),
                        backgroundColor: theme.colorScheme.error),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String tag) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            panEnabled: false,
            boundaryMargin: const EdgeInsets.all(0),
            minScale: 0.5,
            maxScale: 4,
            child: Hero(
              tag: tag,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white, size: 60),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carTitle = '${_currentCar.carType} ${_currentCar.carModel}';

    final List<Map<String, String?>> imageList = [
      {'url': _currentCar.carImageFront, 'label': 'صورة أمامية'},
      {'url': _currentCar.carImageBack, 'label': 'صورة خلفية'},
      {'url': _currentCar.carLicenseFront, 'label': 'رخصة السيارة (وجه)'},
      {'url': _currentCar.carLicenseBack, 'label': 'رخصة السيارة (خلف)'},
      {'url': _currentCar.licenseFrontImage, 'label': 'رخصة السائق (وجه)'},
      {'url': _currentCar.licenseBackImage, 'label': 'رخصة السائق (خلف)'},
    ];

    // --- (التحسين الأول) ---
    // تم إضافة AnnotatedRegion للتحكم في شريط الحالة
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, // أيقونات بيضاء
        statusBarBrightness: Brightness.dark, // للـ iOS
        statusBarColor: Colors.black, // خلفية شفافة لتندمج مع شريط التطبيق
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 65,
                  expandedHeight: 250.0,
                  backgroundColor: Color(0xFFFC8700),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'car_image_${_currentCar.id}',
                      // --- (التحسين الثاني) ---
                      // تمت إضافة GestureDetector هنا
                      child: GestureDetector(
                        onTap: () {
                          if (_currentCar.carImageFront.isNotEmpty) {
                            _showFullScreenImage(context, _currentCar.carImageFront, 'car_image_${_currentCar.id}');
                          }
                        },
                        child: Image.network(
                          _currentCar.carImageFront.isNotEmpty ? _currentCar.carImageFront : 'https://via.placeholder.com/400x300?text=No+Image',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey, child: const Icon(Icons.directions_car, size: 100, color: Colors.white54)),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Container(

                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: IconButton(
                        tooltip: 'تعديل',
                        icon: const Icon(Icons.edit_note_outlined),
                        onPressed: () => _navigateToEdit(context),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: IconButton(
                        tooltip: 'حذف',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // زيادة الحشو السفلي
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInfoCard(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader("معرض الصور والمستندات", theme),
                      _buildImageGallery(context, imageList),
                      const SizedBox(height: 24),
                      _buildSectionHeader("المواصفات", theme),
                      _buildSpecificationGrid(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${_currentCar.carType} ${_currentCar.carModel}',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  intl.NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0).format(_currentCar.price),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('/ يوم', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<Map<String, String?>> imageList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: imageList.length,
      itemBuilder: (context, index) {
        final image = imageList[index];
        final url = image['url'] ?? '';
        final label = image['label']!;
        final heroTag = 'gallery_image_${_currentCar.id}_$index';

        return GestureDetector(
          onTap: () {
            if (url.isNotEmpty) _showFullScreenImage(context, url, heroTag);
          },
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    left: 8,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [Shadow(blurRadius: 1, color: Colors.black)]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecificationGrid(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> specs = [
      {'icon': Icons.confirmation_number_outlined, 'label': 'رقم اللوحة', 'value': _currentCar.carPlateNumber},
      {'icon': Icons.palette_outlined, 'label': 'اللون', 'value': _currentCar.carColor ?? "غير محدد"},
      {'icon': Icons.calendar_today_outlined, 'label': 'تاريخ الإضافة', 'value': _currentCar.createdAt != null ? intl.DateFormat('yyyy-MM-dd').format(_currentCar.createdAt!) : '---'},
      {'icon': Icons.person_outline, 'label': 'نوع المالك', 'value': _currentCar.ownerType == "office" ? "مكتب" : "شخصي"},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: specs.length,
        itemBuilder: (context, index) {
          final spec = specs[index];
          return Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(spec['icon'], color: theme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spec['label'], style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text(spec['value'], style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}