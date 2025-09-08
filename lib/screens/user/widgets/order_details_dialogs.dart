import 'package:flutter/material.dart';
import 'package:saba2v2/models/my_orders_model.dart';
import 'package:intl/intl.dart';

void showOrderDetails(BuildContext context, MyOrderModel order) {
  // Check order type and show appropriate UI
  if (order.type == 'restaurant_order') {
    _showRestaurantOrderDetails(context, order);
  } else if (order.type == 'property_appointment') {
    _showPropertyAppointmentDetails(context, order);
  } else {
    _showGenericOrderDetails(context, order);
  }
}

String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'غير محدد';
  
  final date = _parseDate(dateString);
  if (date != null) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  } else {
    // If parsing fails, return the original string or a default message
    return dateString.isNotEmpty ? dateString : 'غير محدد';
  }
}

DateTime? _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  
  try {
    // Try different date formats
    if (dateString.contains('T')) {
      // ISO format: 2024-01-15T10:30:00Z or 2024-01-15T10:30:00
      return DateTime.parse(dateString);
    } else if (dateString.contains('-')) {
      // Format: 2024-01-15 10:30:00 or 2024-01-15
      return DateTime.parse(dateString);
    } else if (dateString.contains('/')) {
      // Format: 15/01/2024 or 01/15/2024
      final parts = dateString.split(' ');
      final datePart = parts[0];
      final timePart = parts.length > 1 ? parts[1] : '00:00:00';
      
      final dateComponents = datePart.split('/');
      if (dateComponents.length == 3) {
        // Assume dd/MM/yyyy format
        final day = int.parse(dateComponents[0]);
        final month = int.parse(dateComponents[1]);
        final year = int.parse(dateComponents[2]);
        
        final timeComponents = timePart.split(':');
        final hour = timeComponents.isNotEmpty ? int.parse(timeComponents[0]) : 0;
        final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;
        final second = timeComponents.length > 2 ? int.parse(timeComponents[2]) : 0;
        
        return DateTime(year, month, day, hour, minute, second);
      }
    }
    
    // Try parsing as is
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
}

void _showRestaurantOrderDetails(BuildContext context, MyOrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Enhanced handle
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.6),
                    const Color(0xFF2E7D32).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            
            // Restaurant header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Colors.orange.withOpacity(0.08),
                    Colors.orange.withOpacity(0.02),
                    Colors.white,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.orange.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.15),
                          Colors.orange.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.details['restaurant']?['restaurant_name'] ?? 'طلب مطعم',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'رقم الطلب: ${order.orderNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
             
             // Restaurant order content
             Expanded(
               child: SingleChildScrollView(
                 controller: scrollController,
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const SizedBox(height: 16),
                     
                     // Order Summary Card
                     Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           begin: Alignment.topLeft,
                           end: Alignment.bottomRight,
                           colors: [
                             Colors.orange.withOpacity(0.05),
                             Colors.orange.withOpacity(0.02),
                             Colors.white,
                           ],
                         ),
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.orange.withOpacity(0.1)),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.orange.withOpacity(0.08),
                             blurRadius: 12,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         children: [
                           Row(
                             children: [
                               Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                               const SizedBox(width: 8),
                               Text(
                                 _formatDate(order.createdAt),
                                 style: TextStyle(
                                   fontSize: 14,
                                   color: Colors.grey[700],
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   gradient: const LinearGradient(
                                     colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                                   ),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const Icon(Icons.payments, color: Colors.white, size: 16),
                                     const SizedBox(width: 4),
                                     Text(
                                       '${order.totalPrice?.toStringAsFixed(0) ?? '0'} ج.م',
                                       style: const TextStyle(
                                         fontSize: 14,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           
                           // Order details
                           Row(
                             children: [
                               Expanded(
                                 child: _buildOrderSummaryItem(
                                   'المجموع الفرعي',
                                   '${order.details['subtotal'] ?? '0'} ج.م',
                                   Icons.receipt_long,
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: _buildOrderSummaryItem(
                                   'رسوم التوصيل',
                                   '${order.details['delivery_fee'] ?? '0'} ج.م',
                                   Icons.delivery_dining,
                                 ),
                               ),
                             ],
                           ),
                           if (order.details['note'] != null && order.details['note'].toString().isNotEmpty) ...[
                             const SizedBox(height: 12),
                             Container(
                               width: double.infinity,
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.blue.withOpacity(0.05),
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.blue.withOpacity(0.1)),
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.note_alt, color: Colors.blue[600], size: 18),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: Text(
                                       'ملاحظة: ${order.details['note']}',
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.blue[700],
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 24),
                     
                     // Items section
                     Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.orange.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.restaurant_menu,
                             color: Colors.orange,
                             size: 20,
                           ),
                         ),
                         const SizedBox(width: 12),
                         const Text(
                           'عناصر الطلب',
                           style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Color(0xFF2C3E50),
                           ),
                         ),
                       ],
                     ),
                     
                     const SizedBox(height: 16),
                     
                     // Items list
                     if (order.details['items'] != null)
                       ...List.generate(
                         (order.details['items'] as List).length,
                         (index) {
                           final item = (order.details['items'] as List)[index];
                           return _buildRestaurantItem(item, index);
                         },
                       ),
                     
                     const SizedBox(height: 24),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

Widget _buildOrderSummaryItem(String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRestaurantItem(Map<String, dynamic> item, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Item image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
            ),
            child: item['image'] != null && item['image'].toString().isNotEmpty
                ? Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.withOpacity(0.1),
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      );
                    },
                  )
                : Icon(
                    Icons.restaurant,
                    color: Colors.grey[400],
                    size: 30,
                  ),
          ),
        ),
        
        // Item details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'عنصر غير محدد',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.blue[600], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'الكمية: ${item['quantity'] ?? 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['total_price'] ?? item['unit_price'] ?? '0'} ج.م',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void _showPropertyAppointmentDetails(BuildContext context, MyOrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Enhanced handle
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.6),
                    Colors.blue.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            
            // Enhanced header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Colors.blue.withOpacity(0.08),
                    Colors.blue.withOpacity(0.02),
                    Colors.white,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.15),
                          Colors.blue.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_work,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'موعد معاينة عقار',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            
            // Property appointment content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Appointment Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.05),
                            Colors.blue.withOpacity(0.02),
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(order.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [order.statusColor, order.statusColor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.statusText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Property details
                          if (order.details['property_address'] != null) ...[
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.details['property_address'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Appointment details row
                          if (order.details?['appointment_datetime'] != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPropertyDetailItem(
                                    'موعد المعاينة',
                                    _formatDate(order.details['appointment_datetime']),
                                    Icons.calendar_today,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ] else if (order.details['appointment_date'] != null || order.details['appointment_time'] != null) ...[
                            Row(
                              children: [
                                if (order.details['appointment_date'] != null)
                                  Expanded(
                                    child: _buildPropertyDetailItem(
                                      'تاريخ الموعد',
                                      order.details['appointment_date'],
                                      Icons.calendar_today,
                                      Colors.green,
                                    ),
                                  ),
                                if (order.details['appointment_time'] != null) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildPropertyDetailItem(
                                      'وقت الموعد',
                                      order.details['appointment_time'],
                                      Icons.schedule,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'لم يتم تحديد موعد المعاينة بعد',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Property Information
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'معلومات العقار',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Property details grid
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (order.details['property_type'] != null)
                            _buildPropertyInfoRow('نوع العقار', order.details['property_type'], Icons.home),
                          if (order.details['property_area'] != null)
                            _buildPropertyInfoRow('المساحة', '${order.details['property_area']} م²', Icons.square_foot),
                          if (order.details['property_price'] != null)
                            _buildPropertyInfoRow('السعر', '${order.details['property_price']} ج.م', Icons.attach_money),
                          if (order.details['contact_phone'] != null)
                            _buildPropertyInfoRow('رقم التواصل', order.details['contact_phone'], Icons.phone),
                          if (order.details['notes'] != null && order.details['notes'].toString().isNotEmpty)
                            _buildPropertyInfoRow('ملاحظات', order.details['notes'], Icons.note_alt),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPropertyDetailItem(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildPropertyInfoRow(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.blue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showGenericOrderDetails(BuildContext context, MyOrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Enhanced handle
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.6),
                    const Color(0xFF2E7D32).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            
            // Enhanced header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.08),
                    const Color(0xFF2E7D32).withOpacity(0.02),
                    Colors.white,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32).withOpacity(0.15),
                          const Color(0xFF2E7D32).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF2E7D32),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل الطلب',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            
            // Enhanced content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildEnhancedDetailRow('نوع الطلب', order.orderTypeText, Icons.category),
                          _buildEnhancedDetailRow('الحالة', order.statusText, Icons.info, color: order.statusColor),
                          _buildEnhancedDetailRow('التاريخ', _formatDate(order.createdAt), Icons.access_time),
                          if (order.totalPrice != null)
                            _buildEnhancedDetailRow('المبلغ الإجمالي', '${order.totalPrice!.toStringAsFixed(0)} ج.م', Icons.payments, color: const Color(0xFF2E7D32)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Additional Details
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.list_alt,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'تفاصيل إضافية:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Additional details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: order.details.entries.map((entry) {
                          if (entry.value != null && entry.value.toString().isNotEmpty) {
                            return _buildEnhancedDetailRow(
                             _getFieldDisplayName(entry.key),
                             entry.value.toString(),
                             _getFieldIcon(entry.key),
                           );
                         }
                         return const SizedBox.shrink();
                       }).toList(),
                     ),
                   ),
                   
                   const SizedBox(height: 20),
                 ],
               ),
             ),
           ),
         ],
       ),
     ),
   ),
 );
}

Widget _buildEnhancedDetailRow(String label, String value, IconData icon, {Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF2E7D32)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? const Color(0xFF333333),
              fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}

IconData _getFieldIcon(String fieldName) {
  switch (fieldName) {
    case 'travel_date':
      return Icons.flight_takeoff;
    case 'nationality':
      return Icons.flag;
    case 'people_count':
      return Icons.people;
    case 'coming_from':
      return Icons.location_on;
    case 'passport_image':
      return Icons.description;
    case 'other_document_image':
      return Icons.attach_file;
    case 'notes':
      return Icons.note;
    case 'restaurant_name':
      return Icons.restaurant;
    case 'subtotal':
      return Icons.calculate;
    case 'delivery_fee':
      return Icons.delivery_dining;
    case 'vat':
      return Icons.receipt;
    case 'property_address':
      return Icons.home;
    case 'appointment_datetime':
      return Icons.event;
    default:
      return Icons.info;
  }
}

String _getFieldDisplayName(String fieldName) {
  switch (fieldName) {
    case 'travel_date':
      return 'تاريخ السفر';
    case 'nationality':
      return 'الجنسية';
    case 'people_count':
      return 'عدد الأشخاص';
    case 'coming_from':
      return 'قادم من';
    case 'passport_image':
      return 'صورة الجواز';
    case 'other_document_image':
      return 'وثيقة أخرى';
    case 'notes':
      return 'ملاحظات';
    case 'restaurant_name':
      return 'اسم المطعم';
    case 'subtotal':
      return 'المجموع الفرعي';
    case 'delivery_fee':
      return 'رسوم التوصيل';
    case 'vat':
      return 'الضريبة';
    case 'property_address':
      return 'عنوان العقار';
    case 'appointment_datetime':
      return 'موعد المعاينة';
    default:
      return fieldName;
  }
}