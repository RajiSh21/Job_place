import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/worker.dart';
import '../config/app_theme.dart';
import '../utils/constants.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final bool horizontal;

  const WorkerCard({super.key, required this.worker, this.horizontal = true});

  @override
  Widget build(BuildContext context) {
    if (horizontal) return _buildHorizontalCard(context);
    return _buildVerticalCard(context);
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/worker/${worker.id}'),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildPhoto(double.infinity, 110),
                ),
                if (worker.isFeatured)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.featured,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('⭐ Featured', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          worker.name ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (worker.isVerified)
                        const Icon(Icons.verified, color: AppColors.verified, size: 16),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    getCategoryLabel(worker.primarySkill),
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 14),
                      Text(
                        ' ${worker.ratingAvg.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        worker.displayPrice,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (worker.distance != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 12),
                        Text(
                          ' ${worker.displayDistance}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/worker/${worker.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildPhoto(64, 64),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worker.name ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (worker.isVerified)
                          const Icon(Icons.verified, color: AppColors.verified, size: 16),
                        if (worker.isFeatured) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.featured,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('⭐', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 4,
                      children: worker.skills
                          .take(2)
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  getCategoryLabel(s),
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accent, size: 14),
                        Text(
                          ' ${worker.ratingAvg.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          ' (${worker.totalJobs})',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (worker.distance != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on, color: AppColors.textSecondary, size: 12),
                          Text(
                            worker.displayDistance,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          worker.displayPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.push('/worker/${worker.id}'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(72, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(double width, double height) {
    if (worker.profilePhoto != null) {
      return CachedNetworkImage(
        imageUrl: worker.profilePhoto!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: AppColors.divider,
          child: const Icon(Icons.person, color: AppColors.textHint, size: 32),
        ),
        errorWidget: (_, __, ___) => _placeholder(width, height),
      );
    }
    return _placeholder(width, height);
  }

  Widget _placeholder(double width, double height) => Container(
        width: width,
        height: height,
        color: AppColors.background,
        child: const Icon(Icons.person, color: AppColors.textHint, size: 32),
      );
}
