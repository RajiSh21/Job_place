import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class RatingSummaryWidget extends StatelessWidget {
  final double overall;
  final double punctuality;
  final double quality;
  final double behavior;
  final int totalReviews;

  const RatingSummaryWidget({
    super.key,
    required this.overall,
    required this.punctuality,
    required this.quality,
    required this.behavior,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  overall.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < overall.floor() ? Icons.star
                        : (i < overall ? Icons.star_half : Icons.star_border),
                    color: AppColors.accent,
                    size: 16,
                  )),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalReviews समीक्षा',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _RatingRow(label: 'समयपालन', value: punctuality),
                  const SizedBox(height: 6),
                  _RatingRow(label: 'गुणस्तर', value: quality),
                  const SizedBox(height: 6),
                  _RatingRow(label: 'व्यवहार', value: behavior),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final double value;
  const _RatingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
