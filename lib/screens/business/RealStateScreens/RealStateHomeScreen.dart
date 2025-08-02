import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/appointment_model.dart';
import 'dart:io';

import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';

//==============================================================================
// START: Appointment Card Widget
//==============================================================================

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isApproving = false;
  // يمكنك إضافة حالة تحميل لزر التغيير هنا إذا أردت
  // bool _isChanging = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'provider_approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'provider_approved':
        return 'تم القبول';
      case 'pending':
        return 'في الانتظار';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Property and Customer info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.appointment.property.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                        width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.business)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'موعد لمعاينة: ${widget.appointment.property.type}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'بطلب من العميل: ${widget.appointment.customer.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Appointment Datetime
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'تاريخ وتوقيت الموعد',
              value: intl.DateFormat('EEEE, d MMMM yyyy - hh:mm a', 'ar').format(widget.appointment.appointmentDatetime),
            ),
            const SizedBox(height: 12),

            // Customer Note
            if (widget.appointment.note != null && widget.appointment.note!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.notes_rounded,
                title: 'ملاحظات العميل',
                value: widget.appointment.note!,
                isNote: true,
              ),

            // Admin Note
            if (widget.appointment.adminNote != null && widget.appointment.adminNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: _buildInfoRow(
                  icon: Icons.admin_panel_settings,
                  title: 'ملاحظات الإدارة',
                  value: widget.appointment.adminNote!,
                  isNote: true,
                  iconColor: Colors.blue[700],
                ),
              ),

            const SizedBox(height: 20),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.appointment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(widget.appointment.status),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(widget.appointment.status),
                style: TextStyle(
                  color: _getStatusColor(widget.appointment.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons - only show if appointment is not approved
            if (widget.appointment.status != 'provider_approved')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isApproving ? null : () async {
                        setState(() {
                          _isApproving = true;
                        });

                        final provider = Provider.of<AuthProvider>(context, listen: false);
                        final success = await provider.approveAppointment(appointmentId: widget.appointment.id);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم قبول الموعد بنجاح!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('فشل قبول الموعد، يرجى المحاولة مرة أخرى.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _isApproving = false;
                          });
                        }
                      },
                      icon: _isApproving
                          ? Container(
                              width: 20,
                              height: 20,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(_isApproving ? 'جاري القبول...' : 'قبول'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.green.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConversationsListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                      label: const Text('تغيير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Show approved message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تم قبول الموعد',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    bool isNote = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isNote)
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(151, 81, 0, 1)),
                )
              else
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold),
                ),
              SizedBox(height: isNote ? 4 : 2),
              if (isNote)
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                )
              else
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

//==============================================================================
// END: Appointment Card Widget
//==============================================================================



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
    // الكود الداخلي لـ PropertyCard يبقى كما هو تمامًا
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric( vertical: 8),
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
                      child:
                          const Icon(Icons.error, size: 50, color: Colors.grey),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                        borderRadius: BorderRadius.circular(4)),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                      _buildFeatureItem(
                          Icons.hotel, '${property.bedrooms} غرف'),
                      const SizedBox(width: 20),
                      _buildFeatureItem(Icons.bathtub_outlined,
                          '${property.bathrooms} حمامات'),
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
                          label: const Text(
                            'تعديل العقار',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: Colors.green[200]!, width: 2),
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
                          label: const Text(
                            'حذف العقار',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:
                                  BorderSide(color: Colors.red[200]!, width: 2),
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
    // الكود الداخلي لـ DeletePropertyDialog يبقى كما هو تمامًا
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
                    colorFilter:
                        ColorFilter.mode(Color(0xFFFF3B30)!, BlendMode.srcIn),
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
                       'نعم أريد الحذف',
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
                          side: BorderSide(color: Color(0xFFFF3B30), width: 2),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'لا أريد الحذف'
                        ,
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

void showDeletePropertyDialog(BuildContext context,
    {VoidCallback? onConfirm, VoidCallback? onCancel}) {
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

class _RealStateHomeScreenState extends State<RealStateHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // --- جلب بيانات العقارات والمواعيد عند بدء تشغيل الشاشة ---
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchMyProperties();
      authProvider.fetchAppointments();
      // بدء الريفريش اللحظي للمواعيد
      authProvider.startAppointmentsAutoRefresh();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    
    // إيقاف الريفريش اللحظي عند الخروج من الشاشة
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.stopAppointmentsAutoRefresh();
    
    super.dispose();
  }

  void _handleTabSelection() {
    // إذا تم التبديل إلى تبويب المواعيد (index 0)
    if (_tabController.index == 0) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // إجبار ريفريش فوري للمواعيد
      authProvider.forceRefreshAppointments();
    }
    setState(() {});
  }

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
    File? _selectedImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isReady = false;
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 600, maxHeight: 900),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.white, Colors.orange.shade50]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600
                        ]),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_location_alt,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                              child: Text('إضافة عقار جديد',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white))),
                          IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon:
                                  const Icon(Icons.close, color: Colors.white)),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Align(
                                alignment: Alignment.centerRight,
                                child: Text("صورة العقار",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_selectedImage!,
                                          fit: BoxFit.cover))
                                  : const Center(
                                      child: Icon(Icons.house_siding_rounded,
                                          color: Colors.grey, size: 50)),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange.shade800,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: Colors.orange.shade200))),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    setDialogState(() =>
                                        _selectedImage = File(image.path));
                                  }
                                },
                                icon: const Icon(
                                    Icons.add_photo_alternate_outlined),
                                label: const Text("اختيار صورة للعقار")),
                            const Divider(height: 30),
                            _buildEnhancedField(
                                icon: Icons.location_on,
                                label: "العنوان",
                                controller: addressController),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.attach_money,
                                label: "السعر",
                                controller: priceController,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.apartment,
                                label: "النوع",
                                controller: typeController),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.straighten,
                                label: "المساحة",
                                controller: areaController),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.bed,
                                label: "عدد الغرف",
                                controller: bedroomsController,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.bathtub,
                                label: "عدد الحمامات",
                                controller: bathroomsController,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.landscape,
                                label: "الإطلالة",
                                controller: viewController),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.credit_card,
                                label: "طريقة الدفع",
                                controller: paymentMethodController),
                            const SizedBox(height: 12),
                            _buildEnhancedField(
                                icon: Icons.notes,
                                label: "الوصف",
                                controller: descController,
                                maxLines: 3),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                    value: isReady,
                                    onChanged: (value) => setDialogState(
                                        () => isReady = value ?? false)),
                                const Text('جاهز'),
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
                            bottomRight: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('إلغاء'))),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('إضافة العقار'),
                              onPressed: () async {
                                if (_selectedImage == null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('يرجى اختيار صورة للعقار'),
                                          backgroundColor: Colors.red));
                                  return;
                                }
                                if (addressController.text.trim().isEmpty ||
                                    priceController.text.trim().isEmpty ||
                                    typeController.text.trim().isEmpty ||
                                    bedroomsController.text.trim().isEmpty ||
                                    bathroomsController.text.trim().isEmpty ||
                                    areaController.text.trim().isEmpty) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'يرجى ملء جميع الحقول الأساسية'),
                                          backgroundColor: Colors.red));
                                  return;
                                }
                                if (int.tryParse(
                                            priceController.text.trim()) ==
                                        null ||
                                    int.tryParse(
                                            bedroomsController.text.trim()) ==
                                        null ||
                                    int.tryParse(
                                            bathroomsController.text.trim()) ==
                                        null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('الرجاء إدخال أرقام صحيحة'),
                                          backgroundColor: Colors.red));
                                  return;
                                }

                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                final success = await authProvider.addProperty(
                                  address: addressController.text.trim(),
                                  type: typeController.text.trim(),
                                  price: int.parse(priceController.text.trim()),
                                  description: descController.text.trim(),
                                  imageFile: _selectedImage!,
                                  bedrooms:
                                      int.parse(bedroomsController.text.trim()),
                                  bathrooms: int.parse(
                                      bathroomsController.text.trim()),
                                  view: viewController.text.trim(),
                                  paymentMethod:
                                      paymentMethodController.text.trim(),
                                  area: areaController.text.trim(),
                                  isReady: isReady,
                                );

                                if (context.mounted) {
                                  if (success) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('تم حفظ العقار بنجاح!'),
                                            backgroundColor: Colors.green));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'فشل حفظ العقار، يرجى المحاولة'),
                                            backgroundColor: Colors.red));
                                  }
                                }
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
        });
      },
    );
  }


  void _editProperty(BuildContext context, Property propertyToEdit) {
    // ملء وحدات التحكم بالبيانات الحالية للعقار
    final addressController =
        TextEditingController(text: propertyToEdit.address);
    final priceController =
        TextEditingController(text: propertyToEdit.price.toString());
    final typeController = TextEditingController(text: propertyToEdit.type);
    final descController =
        TextEditingController(text: propertyToEdit.description);
    final bedroomsController =
        TextEditingController(text: propertyToEdit.bedrooms.toString());
    final bathroomsController =
        TextEditingController(text: propertyToEdit.bathrooms.toString());
    final viewController = TextEditingController(text: propertyToEdit.view);
    final paymentMethodController =
        TextEditingController(text: propertyToEdit.paymentMethod);
    final areaController = TextEditingController(text: propertyToEdit.area);

    File? _newSelectedImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isReady = propertyToEdit.isReady;
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.green.shade400,
                        Colors.green.shade600
                      ]),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_location_alt,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Text('تعديل العقار',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white))),
                        IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close, color: Colors.white)),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Align(
                              alignment: Alignment.centerRight,
                              child: Text("صورة العقار",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _newSelectedImage != null
                                  ? Image.file(_newSelectedImage!,
                                      fit: BoxFit.cover)
                                  : CachedNetworkImage(
                                      imageUrl: propertyToEdit.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (c, u, e) =>
                                          const Icon(Icons.error),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade800),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (image != null) {
                                  setDialogState(() =>
                                      _newSelectedImage = File(image.path));
                                }
                              },
                              icon: const Icon(Icons.sync),
                              label: const Text("تغيير الصورة")),
                          const Divider(height: 30),

                          _buildEnhancedField(
                              icon: Icons.location_on,
                              label: "العنوان",
                              controller: addressController),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.attach_money,
                              label: "السعر",
                              controller: priceController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.apartment,
                              label: "النوع",
                              controller: typeController),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.straighten,
                              label: "المساحة",
                              controller: areaController),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.bed,
                              label: "عدد الغرف",
                              controller: bedroomsController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.bathtub,
                              label: "عدد الحمامات",
                              controller: bathroomsController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.landscape,
                              label: "الإطلالة",
                              controller: viewController),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.credit_card,
                              label: "طريقة الدفع",
                              controller: paymentMethodController),
                          const SizedBox(height: 12),
                          _buildEnhancedField(
                              icon: Icons.notes,
                              label: "الوصف",
                              controller: descController,
                              maxLines: 3),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                  value: isReady,
                                  onChanged: (value) => setDialogState(
                                      () => isReady = value ?? false)),
                              const Text('جاهز'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('إلغاء'))),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('حفظ التعديلات'),
onPressed: () async {
  if (addressController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة'), backgroundColor: Colors.red),
    );
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  final updatedProperty = Property(
    id: propertyToEdit.id,
    address: addressController.text.trim(),
    type: typeController.text.trim(),
    price: int.parse(priceController.text.trim()),
    description: descController.text.trim(),
    imageUrl: propertyToEdit.imageUrl,
    bedrooms: int.parse(bedroomsController.text.trim()),
    bathrooms: int.parse(bathroomsController.text.trim()),
    view: viewController.text.trim(),
    paymentMethod: paymentMethodController.text.trim(),
    area: areaController.text.trim(),
    isReady: isReady,
    // تمت إزالة الحقول التي ليست في الموديل
    // submittedBy: '', // أضف قيمة افتراضية إذا كانت مطلوبة
    // submittedPrice: '', // أضف قيمة افتراضية إذا كانت مطلوبة
    );
  
  final success = await authProvider.updateProperty(
    updatedProperty: updatedProperty,
    newImageFile: _newSelectedImage,
  );
  
  if (context.mounted) {
    if (success) {
      Navigator.of(ctx).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات بنجاح!'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل حفظ التعديلات'), backgroundColor: Colors.red));
    }
  }
},
                          
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _deleteProperty(BuildContext context, Property property) async {
    showDeletePropertyDialog(
      context,
      onConfirm: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.deleteProperty(property.id);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم حذف العقار بنجاح!'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('فشل حذف العقار'), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, _isTablet(context)),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildCustomTab(
                        icon: Icons.calendar_today,
                        text: 'مواعيدي',
                        isSelected: _tabController.index == 0,
                        onTap: () => setState(() => _tabController.animateTo(0))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCustomTab(
                        icon: Icons.home_work_outlined,
                        text: 'عقاراتي',
                        isSelected: _tabController.index == 1,
                        onTap: () => setState(() => _tabController.animateTo(1))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- START: "مواعيدي" Tab ---
                  Consumer<AuthProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoadingAppointments) {
                        return const Center(child: CircularProgressIndicator(color: Colors.orange));
                      }

                      if (provider.appointmentsError != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('حدث خطأ: ${provider.appointmentsError}', textAlign: TextAlign.center),
                          ),
                        );
                      }

                      if (provider.appointments.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا توجد مواعيد مقترحة حاليًا.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // إجبار الريفريش الفوري
                          await provider.forceRefreshAppointments();
                          // ثم جلب البيانات الكاملة
                          await provider.fetchAppointments();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: provider.appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = provider.appointments[index];
                            return AppointmentCard(
        // استخدم ValueKey مع id الموعد لتعطيه هوية فريدة
        key: ValueKey(appointment.id), 
        appointment: appointment,
      );
                          },
                        ),
                      );
                    },
                  ),
                  // --- END: "مواعيدي" Tab ---

                  // --- START: "عقاراتي" Tab ---
                  Stack(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isLoading &&
                              authProvider.properties.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (authProvider.properties.isEmpty) {
                            return const Center(
                                child: Text('لم تقم بإضافة أي عقارات بعد'));
                          }
                          return RefreshIndicator(
                            onRefresh: () => authProvider.fetchMyProperties(),
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 80 + paddingBottom,
                                  left: 16,
                                  right: 16),
                              itemCount: authProvider.properties.length,
                              itemBuilder: (context, index) {
                                final property = authProvider.properties[index];
                                return PropertyCard(
                                  property: property,
                                  onEdit: () => _editProperty(context, property),
                                  onDelete: () =>
                                      _deleteProperty(context, property),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: ElevatedButton(
                          onPressed: () => _addProperty(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('إضافة عقار',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  // --- END: "عقاراتي" Tab ---
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(context, _isTablet(context)),
    );
  }

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Widget _buildEnhancedField(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      TextInputType? keyboardType,
      int? maxLines,
      Color? iconColor,
      double? fontSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade700)),
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
                  borderRadius: BorderRadius.circular(6)),
              child: Icon(icon,
                  color: iconColor ?? Colors.orange.shade500, size: 18),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.orange.shade400, width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: isTablet ? 20.0 : 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildActionButton(
                    icon: Icons.message_outlined,
                    badge: "",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConversationsListScreen(),
                        ),
                      );
                    },
                    isTablet: isTablet),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                _buildActionButton(
                    icon: Icons.notifications_outlined,
                    badge: "3",
                    onTap: () => context.push("/NotificationsScreen"),
                    isTablet: isTablet),
              ],
            ),
            Text("الرئيسية",
                style: TextStyle(
                    fontSize: isTablet ? 24.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String badge,
      required VoidCallback onTap,
      required bool isTablet}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isTablet ? 48.0 : 44.0,
          height: isTablet ? 48.0 : 44.0,
          decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(icon,
                  size: isTablet ? 24.0 : 20.0, color: const Color(0xFF6B7280)),
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
                  color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(badge,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12.0 : 10.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomTab(
      {required IconData icon,
      required String text,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0;
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
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 10, horizontal: isTablet ? 20 : 8),
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
                        vertical: isTablet ? 12 : 10),
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
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
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