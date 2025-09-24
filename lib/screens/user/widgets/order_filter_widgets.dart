import 'package:flutter/material.dart';

class OrderFilterWidgets {
  static Widget buildFilterChips({
    required String? selectedStatus,
    required DateTimeRange? selectedDateRange,
    required Function(String?) onStatusChanged,
    required Function(DateTimeRange?) onDateRangeChanged,
    required VoidCallback onClearFilters,
  }) {
    final hasActiveFilters = selectedStatus != null || selectedDateRange != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter title
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'تصفية الطلبات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                  ),
                  label: const Text('مسح الفلاتر'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filter
                _buildStatusFilterChip(
                  selectedStatus: selectedStatus,
                  onStatusChanged: onStatusChanged,
                ),
                const SizedBox(width: 8),
                
                // Date range filter
                _buildDateRangeFilterChip(
                  selectedDateRange: selectedDateRange,
                  onDateRangeChanged: onDateRangeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusFilterChip({
    required String? selectedStatus,
    required Function(String?) onStatusChanged,
  }) {
    return PopupMenuButton<String?>(
      onSelected: onStatusChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selectedStatus != null 
              ? const Color(0xFFFC8700).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedStatus != null 
                ? const Color(0xFFFC8700)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_rounded,
              size: 18,
              color: selectedStatus != null 
                  ? const Color(0xFFFC8700)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              selectedStatus != null 
                  ? _getStatusDisplayName(selectedStatus)
                  : 'الحالة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selectedStatus != null 
                    ? const Color(0xFFFC8700)
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: selectedStatus != null 
                  ? const Color(0xFFFC8700)
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.all_inclusive_rounded, size: 18),
              SizedBox(width: 8),
              Text('جميع الحالات'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'pending',
          child: Row(
            children: [
              Icon(Icons.pending_rounded, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('قيد الانتظار'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'confirmed',
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('مؤكد'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'in_progress',
          child: Row(
            children: [
              Icon(Icons.hourglass_empty_rounded, size: 18, color: Colors.purple),
              SizedBox(width: 8),
              Text('قيد التنفيذ'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'completed',
          child: Row(
            children: [
              Icon(Icons.done_all_rounded, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('مكتمل'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'cancelled',
          child: Row(
            children: [
              Icon(Icons.cancel_rounded, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('ملغي'),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildDateRangeFilterChip({
    required DateTimeRange? selectedDateRange,
    required Function(DateTimeRange?) onDateRangeChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final context = NavigationService.navigatorKey.currentContext;
        if (context == null) return;
        
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: selectedDateRange,
          locale: const Locale('ar'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFFC8700),
                ),
              ),
              child: child!,
            );
          },
        );
        
        if (picked != null) {
          onDateRangeChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selectedDateRange != null 
              ? const Color(0xFFFC8700).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedDateRange != null 
                ? const Color(0xFFFC8700)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 18,
              color: selectedDateRange != null 
                  ? const Color(0xFFFC8700)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              selectedDateRange != null 
                  ? _formatDateRange(selectedDateRange)
                  : 'التاريخ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selectedDateRange != null 
                    ? const Color(0xFFFC8700)
                    : Colors.grey[700],
              ),
            ),
            if (selectedDateRange != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onDateRangeChanged(null),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC8700),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState({
    required String? selectedStatus,
    required DateTimeRange? selectedDateRange,
    required VoidCallback onClearFilters,
  }) {
    final hasActiveFilters = selectedStatus != null || selectedDateRange != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFC8700).withOpacity(0.1),
                            const Color(0xFFFFB347).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        hasActiveFilters 
                            ? Icons.filter_list_off_rounded
                            : Icons.receipt_long_rounded,
                        size: 80,
                        color: const Color(0xFFFC8700).withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Empty state text
            Text(
              hasActiveFilters 
                  ? 'لا توجد طلبات تطابق الفلاتر المحددة'
                  : 'لا توجد طلبات حتى الآن',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            Text(
              hasActiveFilters 
                  ? 'جرب تغيير الفلاتر أو مسحها لرؤية المزيد من النتائج'
                  : 'ستظهر طلباتك هنا بمجرد إنشائها',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Action button
            if (hasActiveFilters)
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('مسح جميع الفلاتر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8700),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      // Delivery journey (backend) statuses
      case 'pending_offers':
        return 'في انتظار العروض';
      case 'accepted':
      case 'accepted_waiting_driver':
        return 'مقبول - انتظار السائق';
      case 'driver_arrived':
        return 'وصل السائق';
      case 'trip_started':
        return 'بدأت الرحلة';
      case 'trip_completed':
        return 'انتهت الرحلة';
      case 'on_way_to_pickup':
        return 'في الطريق إلى الاستلام';
      case 'arrived_at_pickup':
        return 'تم الوصول للاستلام';
      case 'picked_up':
        return 'تم الاستلام';
      case 'on_way_to_delivery':
        return 'في الطريق إلى التسليم';
      case 'arrived_at_delivery':
        return 'تم الوصول للتسليم';
      case 'delivered':
        return 'تم التسليم';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  static String _formatDateRange(DateTimeRange dateRange) {
    final start = '${dateRange.start.day}/${dateRange.start.month}';
    final end = '${dateRange.end.day}/${dateRange.end.month}';
    return '$start - $end';
  }
}

// Navigation service for accessing context
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}