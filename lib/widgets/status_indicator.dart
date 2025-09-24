import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final String statusTranslated;
  final bool showAnimation;

  const StatusIndicator({
    Key? key,
    required this.status,
    required this.statusTranslated,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusConfig.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusConfig.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAnimation && (status == 'pending' || status == 'pending_offers'))
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusConfig.iconColor),
              ),
            )
          else
            Icon(
              statusConfig.icon,
              size: 16,
              color: statusConfig.iconColor,
            ),
          const SizedBox(width: 6),
          Text(
            statusTranslated,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusConfig.textColor,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_offers':
        return StatusConfig(
          icon: Icons.hourglass_empty,
          backgroundColor: Colors.orange[50]!,
          borderColor: Colors.orange[300]!,
          iconColor: Colors.orange[600]!,
          textColor: Colors.orange[800]!,
          shadowColor: Colors.orange[200]!.withOpacity(0.3),
        );
      
      case 'accepted':
      case 'accepted_waiting_driver':
        return StatusConfig(
          icon: Icons.check_circle,
          backgroundColor: Colors.green[50]!,
          borderColor: Colors.green[300]!,
          iconColor: Colors.green[600]!,
          textColor: Colors.green[800]!,
          shadowColor: Colors.green[200]!.withOpacity(0.3),
        );
      
      case 'on_way_to_pickup':
      case 'arrived_at_pickup':
      case 'picked_up':
      case 'on_way_to_delivery':
      case 'arrived_at_delivery':
        return StatusConfig(
          icon: Icons.local_shipping,
          backgroundColor: Colors.blue[50]!,
          borderColor: Colors.blue[300]!,
          iconColor: Colors.blue[600]!,
          textColor: Colors.blue[800]!,
          shadowColor: Colors.blue[200]!.withOpacity(0.3),
        );
      
      case 'delivered':
      case 'completed':
      case 'trip_completed':
        return StatusConfig(
          icon: Icons.done_all,
          backgroundColor: Colors.teal[50]!,
          borderColor: Colors.teal[300]!,
          iconColor: Colors.teal[600]!,
          textColor: Colors.teal[800]!,
          shadowColor: Colors.teal[200]!.withOpacity(0.3),
        );
      
      case 'cancelled':
      case 'rejected':
        return StatusConfig(
          icon: Icons.cancel,
          backgroundColor: Colors.red[50]!,
          borderColor: Colors.red[300]!,
          iconColor: Colors.red[600]!,
          textColor: Colors.red[800]!,
          shadowColor: Colors.red[200]!.withOpacity(0.3),
        );
      
      default:
        return StatusConfig(
          icon: Icons.help_outline,
          backgroundColor: Colors.grey[50]!,
          borderColor: Colors.grey[300]!,
          iconColor: Colors.grey[600]!,
          textColor: Colors.grey[800]!,
          shadowColor: Colors.grey[200]!.withOpacity(0.3),
        );
    }
  }
}

class StatusConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color shadowColor;

  StatusConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.shadowColor,
  });
}

// Enhanced Status Indicator with Timeline
class StatusTimeline extends StatelessWidget {
  final List<TimelineStep> steps;
  final String currentStatus;

  const StatusTimeline({
    Key? key,
    required this.steps,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تتبع حالة الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            final isActive = _isStepActive(step.status, currentStatus);
            final isCompleted = _isStepCompleted(step.status, currentStatus);
            
            return _buildTimelineItem(
              step: step,
              isActive: isActive,
              isCompleted: isCompleted,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required TimelineStep step,
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green[600]
                    : isActive
                        ? const Color(0xFFFC8700)
                        : Colors.grey[300],
                border: Border.all(
                  color: isCompleted
                      ? Colors.green[600]!
                      : isActive
                          ? const Color(0xFFFC8700)
                          : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check
                    : isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                size: 12,
                color: isCompleted || isActive ? Colors.white : Colors.grey[600],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green[300] : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted || isActive
                        ? Colors.grey[800]
                        : Colors.grey[500],
                    fontFamily: 'Cairo',
                  ),
                ),
                if (step.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      step.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                if (step.timestamp != null && (isCompleted || isActive))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      step.timestamp!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isStepActive(String stepStatus, String currentStatus) {
    return stepStatus == currentStatus;
  }

  bool _isStepCompleted(String stepStatus, String currentStatus) {
    final statusOrder = [
      'pending',
      'pending_offers',
      'accepted',
      'accepted_waiting_driver',
      'driver_arrived',
      'on_way_to_pickup',
      'arrived_at_pickup',
      'picked_up',
      'trip_started',
      'on_way_to_delivery',
      'arrived_at_delivery',
      'delivered',
      'trip_completed',
      'cancelled',
      'rejected',
    ];
    
    final stepIndex = statusOrder.indexOf(stepStatus);
    final currentIndex = statusOrder.indexOf(currentStatus);
    
    return stepIndex != -1 && currentIndex != -1 && stepIndex < currentIndex;
  }
}

class TimelineStep {
  final String status;
  final String title;
  final String? description;
  final String? timestamp;

  TimelineStep({
    required this.status,
    required this.title,
    this.description,
    this.timestamp,
  });
}