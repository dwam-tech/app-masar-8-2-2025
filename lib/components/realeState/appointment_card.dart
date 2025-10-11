import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import 'package:saba2v2/models/appointment_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isApproving = false;

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
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.business),
                    ),
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

            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'تاريخ وتوقيت الموعد',
              value: intl.DateFormat('EEEE, d MMMM yyyy - hh:mm a', 'ar').format(
                widget.appointment.appointmentDatetime,
              ),
            ),
            const SizedBox(height: 12),

            if (widget.appointment.note != null && widget.appointment.note!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.notes_rounded,
                title: 'ملاحظات العميل',
                value: widget.appointment.note!,
                isNote: true,
              ),

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

            if (widget.appointment.status != 'provider_approved')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isApproving
                          ? null
                          : () async {
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
                          ? SizedBox(
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
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
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