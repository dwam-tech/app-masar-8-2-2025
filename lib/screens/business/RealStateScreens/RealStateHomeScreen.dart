import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class Property {
  String id;
  String address;
  String type;
  int price;
  String description;
  String imageUrl;
  int bedrooms;
  int bathrooms;
  String view;
  String paymentMethod;
  String area;
  String submittedBy;
  String submittedPrice;
  bool isReady;

  Property({
    required this.id,
    required this.address,
    required this.type,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.view,
    required this.paymentMethod,
    required this.area,
    required this.submittedBy,
    required this.submittedPrice,
    this.isReady = false,
  });
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: property.imageUrl,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 170,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      if (property.isReady)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 243, 230, 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 2,
                              color: Color(0xFFFFEDD9),
                            ),
                          ),
                          child: const Text(
                            'جاهز',
                            style: TextStyle(
                              color: Color(0xFF713D00),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 243, 230, 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 2,
                            color: Color(0xFFFFEDD9),
                          ),
                        ),
                        child: Text(
                          property.type,
                          style: TextStyle(
                            color: Color(0xFF713D00),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color.fromRGBO(252, 135, 0, 1),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            intl.NumberFormat('#,###').format(property.price),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(151, 81, 0, 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ج.م',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 243, 230, 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 2,
                            color: Color(0xFFFFEDD9),
                          ),
                        ),
                        child: Text(
                          property.type,
                          style: TextStyle(
                            color: Color(0xFF713D00),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.address,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFeatureItem(Icons.hotel, '${property.bedrooms} غرف'),
                      const SizedBox(width: 20),
                      _buildFeatureItem(Icons.bathtub_outlined, '${property.bathrooms} حمامات'),
                      const SizedBox(width: 20),
                      _buildFeatureItem(Icons.straighten, property.area),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مقدم : ${intl.NumberFormat('#,###').format(int.parse(property.submittedPrice))} ج.م',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              property.submittedBy,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: SvgPicture.asset(
                            'assets/icons/PencileForEdit.svg',
                            width: 18,
                            height: 18,
                            color: Colors.green[700],
                          ),
                          label: const Text('تعديل العقار',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.green[200]!, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: SvgPicture.asset(
                            'assets/icons/DeleteIcon.svg',
                            width: 18,
                            height: 18,
                            color: Colors.red[700],
                          ),
                          label: const Text('حذف العقار',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.red[200]!, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class DeletePropertyDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DeletePropertyDialog({
    Key? key,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFC8700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/DeleteIcon.svg",
                    width: 43,
                    height: 43,
                    colorFilter: ColorFilter.mode(Color(0xFFFF3B30)!, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'هل أنت متأكد من حذف هذا العقار بالفعل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onConfirm != null) onConfirm!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'لا أريد الحذف',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onCancel != null) onCancel!();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xFFFF3B30),width: 2),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'نعم أريد الحذف',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showDeletePropertyDialog(
    BuildContext context, {
      VoidCallback? onConfirm,
      VoidCallback? onCancel,
    }) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return DeletePropertyDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
      );
    },
  );
}

class RealStateHomeScreen extends StatefulWidget {
  const RealStateHomeScreen({super.key});

  @override
  State<RealStateHomeScreen> createState() => _RealStateHomeScreenState();
}

class _RealStateHomeScreenState extends State<RealStateHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _notesController = TextEditingController();

  final List<Property> _properties = [
    Property(
      id: '1',
      address: 'التجمع الخامس - القاهرة',
      type: 'فيلا',
      price: 4300000,
      description: 'فيلا حديثة بتشطيبات سوبر لوكس وحمام سباحة وحديقة خاصة.',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
      bedrooms: 5,
      bathrooms: 4,
      view: 'حديقة',
      paymentMethod: 'كاش',
      area: '300م²',
      submittedBy: 'شركة العقارات المصرية',
      submittedPrice: '430000',
      isReady: true,
    ),
    Property(
      id: '2',
      address: 'مدينة نصر - القاهرة',
      type: 'شقة',
      price: 1750000,
      description: 'شقة واسعة بالدور الخامس مع مصعد وتشطيب فاخر.',
      imageUrl: 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=600&q=80',
      bedrooms: 3,
      bathrooms: 2,
      view: 'شارع رئيسي',
      paymentMethod: 'تقسيط',
      area: '150م²',
      submittedBy: 'وكالة الماسة',
      submittedPrice: '175000',
      isReady: false,
    ),
    Property(
      id: '3',
      address: 'الشيخ زايد - 6 أكتوبر',
      type: 'مكتب إداري',
      price: 950000,
      description: 'مكتب إداري مفروش بالكامل في مول حديث.',
      imageUrl: 'https://images.unsplash.com/photo-1460518451285-97b6aa326961?auto=format&fit=crop&w=600&q=80',
      bedrooms: 0,
      bathrooms: 1,
      view: 'نيل',
      paymentMethod: 'رهن عقاري',
      area: '80م²',
      submittedBy: 'شركة الريادة',
      submittedPrice: '95000',
      isReady: true,
    ),
  ];

  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

 // استبدل هذه الدالة بالكامل في كودك

void _addProperty(BuildContext context) {
    final addressController = TextEditingController();
    final priceController = TextEditingController();
    final typeController = TextEditingController();
    final descController = TextEditingController();
    final bedroomsController = TextEditingController();
    final bathroomsController = TextEditingController();
    final viewController = TextEditingController();
    final paymentMethodController = TextEditingController();
    final areaController = TextEditingController();
    // --- تم التعطيل: الحقل غير مطلوب في الـ API ---
     final submittedByController = TextEditingController();
     final submittedPriceController = TextEditingController();
    final isReadyController = TextEditingController();

    // --- إضافة جديدة: متغير لحفظ الصورة المختارة ---
    File? _selectedImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isReady = false;
        // نستخدم StatefulBuilder للسماح بتحديث الصورة فور اختيارها
        return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              // ... نفس كود الـ Dialog الأصلي ...
              child: Container(
                // ... نفس كود الـ Container الأصلي ...
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // ... نفس كود الـ Header الأصلي ...
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // --- بداية قسم إضافة الصورة (مع الحفاظ على التصميم الأصلي) ---
                            // 1. عنوان نصي للقسم الجديد
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "صورة العقار",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // 2. حاوية عرض الصورة أو الأيقونة
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                    )
                                  : const Center(
                                      child: Icon(Icons.house_siding_rounded, color: Colors.grey, size: 50),
                                    ),
                            ),
                            const SizedBox(height: 12),

                            // 3. زر اختيار الصورة
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange.shade800,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.orange.shade200)
                                    )
                                ),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setDialogState(() { // <-- تحديث الصورة
                                      _selectedImage = File(image.path);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add_photo_alternate_outlined),
                                label: const Text("اختيار صورة للعقار")
                            ),
                            const Divider(height: 30),
                            // --- نهاية قسم الصورة ---


                            // --- العودة إلى الهيكل الأصلي بالكامل ---
                            _buildEnhancedField(
                              icon: Icons.location_on,
                              label: "العنوان",
                              controller: addressController,
                            ),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                              icon: Icons.attach_money,
                              label: "السعر",
                              controller: priceController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                              icon: Icons.apartment,
                              label: "النوع",
                              controller: typeController,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildEnhancedField(
                              icon: Icons.straighten,
                              label: "المساحة",
                              controller: areaController,
                            ),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                              icon: Icons.bed,
                              label: "عدد الغرف",
                              controller: bedroomsController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                             _buildEnhancedField(
                              icon: Icons.bathtub,
                              label: "عدد الحمامات",
                              controller: bathroomsController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                             _buildEnhancedField(
                              icon: Icons.landscape,
                              label: "الإطلالة",
                              controller: viewController,
                            ),
                             const SizedBox(height: 12),
                            _buildEnhancedField(
                              icon: Icons.credit_card,
                              label: "طريقة الدفع",
                              controller: paymentMethodController,
                            ),
                             const SizedBox(height: 12),
                             _buildEnhancedField(
                              icon: Icons.notes,
                              label: "الوصف",
                              controller: descController,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  
                                  value: isReady,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      isReady = value ?? false;
                                    });
                                  },
                                ),
                                const Text('جاهز'),
                              ],
                            ),

                            // --- تم التعطيل: الحقول غير مطلوبة في الـ API ---
                            /*
                            const Divider(height: 30),
                             _buildEnhancedField(
                              icon: Icons.business,
                              label: "مقدم بواسطة",
                              controller: submittedByController,
                            ),
                            const SizedBox(height: 12),
                             _buildEnhancedField(
                              icon: Icons.attach_money,
                              label: "سعر المقدم",
                              controller: submittedPriceController,
                              keyboardType: TextInputType.number,
                            ),
                            */
                          ],
                        ),
                      ),
                    ),
                      Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.save, size: 18),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    shadowColor: Colors.orange.withOpacity(0.3),
                                  ),
                                  label: const Text(
                                    'إضافة العقار',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onPressed: () {
                                    // تحقق أن الحقول المطلوبة ليست فاضية
                                    if (addressController.text.trim().isEmpty ||
                                        priceController.text.trim().isEmpty ||
                                        typeController.text.trim().isEmpty ||
                                        bedroomsController.text
                                            .trim()
                                            .isEmpty ||
                                        bathroomsController.text
                                            .trim()
                                            .isEmpty ||
                                        areaController.text.trim().isEmpty ||
                                        submittedByController.text
                                            .trim()
                                            .isEmpty ||
                                        submittedPriceController.text
                                            .trim()
                                            .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'يرجى ملء جميع الحقول المطلوبة'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // تحقق أن الأرقام مكتوبة بشكل صحيح
                                    if (int.tryParse(
                                                priceController.text.trim()) ==
                                            null ||
                                        int.tryParse(bedroomsController.text
                                                .trim()) ==
                                            null ||
                                        int.tryParse(bathroomsController.text
                                                .trim()) ==
                                            null ||
                                        int.tryParse(submittedPriceController
                                                .text
                                                .trim()) ==
                                            null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'الرجاء إدخال أرقام صحيحة في الحقول الرقمية'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _properties.add(Property(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        address: addressController.text.trim(),
                                        type: typeController.text.trim(),
                                        price: int.parse(
                                            priceController.text.trim()),
                                        description: descController.text.trim(),
                                        imageUrl:
                                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
                                        bedrooms: int.parse(
                                            bedroomsController.text.trim()),
                                        bathrooms: int.parse(
                                            bathroomsController.text.trim()),
                                        view: viewController.text.trim(),
                                        paymentMethod:
                                            paymentMethodController.text.trim(),
                                        area: areaController.text.trim(),
                                        submittedBy:
                                            submittedByController.text.trim(),
                                        submittedPrice: submittedPriceController
                                            .text
                                            .trim(),
                                        isReady: isReady,
                                      ));
                                    });
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text('تم إضافة العقار بنجاح'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade500,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ]),
          )
    ));});
      },
    );
  }
 
  void _editProperty(BuildContext context, Property property) async {
    final addressController = TextEditingController(text: property.address);
    final priceController = TextEditingController(text: property.price.toString());
    final typeController = TextEditingController(text: property.type);
    final descController = TextEditingController(text: property.description);
    final bedroomsController = TextEditingController(text: property.bedrooms.toString());
    final bathroomsController = TextEditingController(text: property.bathrooms.toString());
    final viewController = TextEditingController(text: property.view);
    final paymentMethodController = TextEditingController(text: property.paymentMethod);
    final areaController = TextEditingController(text: property.area);
    final submittedByController = TextEditingController(text: property.submittedBy);
    final submittedPriceController = TextEditingController(text: property.submittedPrice);
    bool isReady = property.isReady;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.orange.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_location_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'تعديل بيانات العقار',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: property.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: property.imageUrl,
                              width: 200,
                              height: 120,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 200,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            )
                                : Container(
                              width: 200,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildSectionCard(
                            title: "المعلومات الأساسية",
                            icon: Icons.info_outline,
                            children: [
                              _buildEnhancedField(
                                icon: Icons.location_on,
                                label: "العنوان",
                                controller: addressController,
                                iconColor: Colors.red.shade400,
                                fontSize: 14,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.attach_money,
                                      label: "السعر",
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      iconColor: Colors.green.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.apartment,
                                      label: "النوع",
                                      controller: typeController,
                                      iconColor: Colors.blue.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildEnhancedField(
                                icon: Icons.straighten,
                                label: "المساحة",
                                controller: areaController,
                                iconColor: Colors.teal.shade400,
                                fontSize: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: "التفاصيل",
                            icon: Icons.details,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.bed,
                                      label: "عدد الغرف",
                                      controller: bedroomsController,
                                      keyboardType: TextInputType.number,
                                      iconColor: Colors.purple.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.bathtub,
                                      label: "عدد الحمامات",
                                      controller: bathroomsController,
                                      keyboardType: TextInputType.number,
                                      iconColor: Colors.cyan.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.landscape,
                                      label: "الإطلالة",
                                      controller: viewController,
                                      iconColor: Colors.teal.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildEnhancedField(
                                      icon: Icons.credit_card,
                                      label: "طريقة الدفع",
                                      controller: paymentMethodController,
                                      iconColor: Colors.indigo.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildEnhancedField(
                                icon: Icons.notes,
                                label: "الوصف",
                                controller: descController,
                                maxLines: 3,
                                iconColor: Colors.amber.shade600,
                                fontSize: 14,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isReady,
                                    onChanged: (value) {
                                      setState(() {
                                        isReady = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'جاهز',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: "معلومات المقدم",
                            icon: Icons.person_outline,
                            children: [
                              _buildEnhancedField(
                                icon: Icons.business,
                                label: "مقدم بواسطة",
                                controller: submittedByController,
                                iconColor: Colors.orange.shade400,
                                fontSize: 14,
                              ),
                              const SizedBox(height: 12),
                              _buildEnhancedField(
                                icon: Icons.attach_money,
                                label: "سعر المقدم",
                                controller: submittedPriceController,
                                keyboardType: TextInputType.number,
                                iconColor: Colors.green.shade400,
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.orange.withOpacity(0.3),
                            ),
                            label: const Text(
                              'حفظ التعديلات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                property.address = addressController.text.trim();
                                property.price = int.tryParse(priceController.text.trim()) ?? property.price;
                                property.type = typeController.text.trim();
                                property.description = descController.text.trim();
                                property.bedrooms = int.tryParse(bedroomsController.text.trim()) ?? property.bedrooms;
                                property.bathrooms = int.tryParse(bathroomsController.text.trim()) ?? property.bathrooms;
                                property.view = viewController.text.trim();
                                property.paymentMethod = paymentMethodController.text.trim();
                                property.area = areaController.text.trim();
                                property.submittedBy = submittedByController.text.trim();
                                property.submittedPrice = submittedPriceController.text.trim();
                                property.isReady = isReady;
                              });
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('تم حفظ التعديلات بنجاح'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade500,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteProperty(BuildContext context, Property property) async {
    showDeletePropertyDialog(
      context,
      onConfirm: () {
        setState(() {
          _properties.removeWhere((p) => p.id == property.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العقار بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onCancel: () {
        print('تم إلغاء عملية الحذف');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isTablet),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCustomTab(
                    icon: Icons.calendar_today,
                    text: 'مواعيدي',
                    isSelected: _tabController.index == 0,
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {}); // تحديث الحالة لتغيير الألوان
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildCustomTab(
                    icon: Icons.home,
                    text: 'عقاراتي',
                    isSelected: _tabController.index == 1,
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {}); // تحديث الحالة لتغيير الألوان
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'am' : 'pm'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        intl.DateFormat('dd/MM/yyyy').format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 4,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              hintText: 'ملاحظات',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'تغيير مع الإدارة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'قبول موعد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      _properties.isEmpty
                          ? const Center(child: Text('لا توجد عقارات متاحة', style: TextStyle(fontSize: 16)))
                          : ListView.builder(
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: 80 + paddingBottom,
                          left: 16,
                          right: 16,
                        ),
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return GestureDetector(
                            child: PropertyCard(
                              property: property,
                              onEdit: () => _editProperty(context, property),
                              onDelete: () => _deleteProperty(context, property),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[100],
                          child: SafeArea(
                            child: ElevatedButton(
                              onPressed: () => _addProperty(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إضافة عقار',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768.0; // نفس الـ _tabletBreakpoint
          return _buildBottomNavigationBar(context, isTablet);
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.orange.shade500,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEnhancedField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLines,
    Color? iconColor,
    double? fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: TextStyle(fontSize: fontSize ?? 14),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.orange.shade500,
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
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
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.message_outlined,
                  badge: "5",
                  onTap: () {},
                  isTablet: isTablet,
                ),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                _buildActionButton(
                  icon: Icons.notifications_outlined,
                  badge: "3",
                  onTap: () => context.push("/NotificationsScreen"),
                  isTablet: isTablet,
                ),
              ],
            ),
            Text(
              "الرئيسية",
              style: TextStyle(
                fontSize: isTablet ? 24.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
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

  Widget _buildCustomTab({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0; // القائمة

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
}