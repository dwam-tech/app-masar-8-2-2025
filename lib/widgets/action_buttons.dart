import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onCancel;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final bool isLoading;
  final bool showCancelButton;
  final bool showContactButtons;

  const ActionButtons({
    Key? key,
    this.onRefresh,
    this.onCancel,
    this.onCall,
    this.onMessage,
    this.isLoading = false,
    this.showCancelButton = true,
    this.showContactButtons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showContactButtons) ...[
              _buildContactButtons(),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (onRefresh != null) ...[
                  Expanded(
                    child: _buildRefreshButton(),
                  ),
                  if (showCancelButton && onCancel != null) const SizedBox(width: 12),
                ],
                if (showCancelButton && onCancel != null)
                  Expanded(
                    child: _buildCancelButton(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        if (onCall != null)
          Expanded(
            child: _buildContactButton(
              icon: Icons.phone,
              label: 'اتصال',
              color: Colors.green,
              onPressed: onCall!,
            ),
          ),
        if (onCall != null && onMessage != null) const SizedBox(width: 12),
        if (onMessage != null)
          Expanded(
            child: _buildContactButton(
              icon: Icons.message,
              label: 'رسالة',
              color: Colors.blue,
              onPressed: onMessage!,
            ),
          ),
      ],
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onRefresh,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh, size: 18),
      label: Text(
        isLoading ? 'جاري التحديث...' : 'تحديث',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFC8700),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 2,
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onCancel,
      icon: const Icon(Icons.cancel_outlined, size: 18),
      label: const Text(
        'إلغاء الطلب',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red[600],
        side: BorderSide(color: Colors.red[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// Floating Action Button for Quick Actions
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? const Color(0xFFFC8700),
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon),
    );
  }
}

// Animated Action Button with Pulse Effect
class AnimatedActionButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isPrimary;

  const AnimatedActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: widget.isPrimary
                  ? ElevatedButton.icon(
                      onPressed: widget.isLoading ? null : widget.onPressed,
                      icon: widget.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : widget.icon != null
                              ? Icon(widget.icon, size: 18)
                              : const SizedBox.shrink(),
                      label: Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.backgroundColor ?? const Color(0xFFFC8700),
                        foregroundColor: widget.foregroundColor ?? Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: widget.isLoading ? null : widget.onPressed,
                      icon: widget.isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.foregroundColor ?? const Color(0xFFFC8700),
                                ),
                              ),
                            )
                          : widget.icon != null
                              ? Icon(widget.icon, size: 18)
                              : const SizedBox.shrink(),
                      label: Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.foregroundColor ?? const Color(0xFFFC8700),
                        side: BorderSide(
                          color: widget.backgroundColor ?? const Color(0xFFFC8700),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}