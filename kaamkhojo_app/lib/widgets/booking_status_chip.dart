import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class BookingStatusChip extends StatelessWidget {
  final String status;
  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.$1.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.$1.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.$2, size: 12, color: info.$1),
          const SizedBox(width: 4),
          Text(
            info.$3,
            style: TextStyle(fontSize: 12, color: info.$1, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _statusInfo(String s) => switch (s) {
        'pending' => (AppColors.statusPending, Icons.hourglass_empty, 'पर्खिरहेको'),
        'accepted' => (AppColors.statusAccepted, Icons.check_circle_outline, 'स्वीकृत'),
        'in_progress' => (AppColors.statusInProgress, Icons.work, 'भइरहेको'),
        'completed' => (AppColors.statusCompleted, Icons.task_alt, 'सम्पन्न'),
        'cancelled' => (AppColors.statusCancelled, Icons.cancel_outlined, 'रद्द'),
        'declined' => (AppColors.statusDeclined, Icons.block, 'अस्वीकृत'),
        _ => (AppColors.textSecondary, Icons.help_outline, s),
      };
}
