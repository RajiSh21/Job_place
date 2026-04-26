import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class WorkerCardSkeleton extends StatelessWidget {
  final bool horizontal;
  const WorkerCardSkeleton({super.key, this.horizontal = true});

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.divider,
          highlightColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, color: AppColors.divider, margin: const EdgeInsets.only(right: 30)),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 80, color: AppColors.divider),
                    const SizedBox(height: 6),
                    Container(height: 10, color: AppColors.divider),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, color: AppColors.divider, margin: const EdgeInsets.only(right: 60)),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 100, color: AppColors.divider),
                    const SizedBox(height: 6),
                    Container(height: 10, color: AppColors.divider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
