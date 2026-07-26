import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SuccessAnimationDialog extends StatefulWidget {
  final String title;
  final String message;

  const SuccessAnimationDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static Future<void> show(BuildContext context, {required String title, required String message}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SuccessAnimationDialog(title: title, message: message),
    );
  }

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto dismiss dialog after 1.8 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.incomeGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: ScaleTransition(
                  scale: _checkAnimation,
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.incomeGreen,
                      size: 54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.incomeGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Mantap!',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
