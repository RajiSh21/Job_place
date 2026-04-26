import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/worker_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/rating_summary_widget.dart';
import '../../widgets/image_gallery.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String workerId;
  const WorkerProfileScreen({super.key, required this.workerId});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = false;
  int _reviewTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadWorkerProfile(widget.workerId);
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final result = await _reviewService.getWorkerReviews(widget.workerId);
      setState(() {
        _reviews = result['reviews'] as List<ReviewModel>;
        _reviewTotal = result['total'] as int;
      });
    } catch (_) {}
    setState(() => _loadingReviews = false);
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkerProvider>();
    final auth = context.watch<AuthProvider>();
    final worker = wp.selectedWorker;

    if (wp.loadingProfile || worker == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(worker),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(worker),
                      const SizedBox(height: 16),
                      _buildSkillChips(worker),
                      const SizedBox(height: 16),
                      _buildPriceAvailability(worker),
                      if (worker.bio != null && worker.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildBio(worker.bio!),
                      ],
                      if (worker.workPhotos.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('कामको ग्यालरी', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ImageGallery(imageUrls: worker.workPhotos),
                      ],
                      const SizedBox(height: 20),
                      const Text('समीक्षाहरू', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      RatingSummaryWidget(
                        overall: worker.ratingAvg,
                        punctuality: worker.ratingPunctuality,
                        quality: worker.ratingQuality,
                        behavior: worker.ratingBehavior,
                        totalReviews: _reviewTotal,
                      ),
                      const SizedBox(height: 12),
                      ..._buildReviews(),
                      const SizedBox(height: 100), // space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky Book Now button
          if (auth.currentUser?.role != 'worker')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<BookingProvider>().setDraftWorker(
                      worker.id,
                      worker.name ?? 'Unknown',
                      worker.primarySkill,
                    );
                    context.push('/booking/step1', extra: {
                      'workerId': worker.id,
                      'workerName': worker.name,
                      'serviceType': worker.primarySkill,
                    });
                  },
                  icon: const Icon(Icons.book_online),
                  label: Text(
                    'अहिले बुक गर्नुहोस् — ${worker.displayPrice}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(worker) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            worker.profilePhoto != null
                ? CachedNetworkImage(
                    imageUrl: worker.profilePhoto!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppColors.primary.withAlpha(51),
                    child: const Icon(Icons.person, size: 80, color: AppColors.textHint),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(153)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(worker) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    worker.name ?? 'Unknown',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  if (worker.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: AppColors.verified, size: 20),
                  ],
                  if (worker.isFeatured) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.featured,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('⭐ Featured', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (worker.locationDistrict != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    Text(
                      ' ${worker.locationDistrict}${worker.locationCity != null ? ', ${worker.locationCity}' : ''}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (worker.memberSince != null)
                Text(
                  'सदस्य: ${DateHelpers.formatMemberSince(worker.memberSince!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.accent, size: 20),
                Text(
                  ' ${worker.ratingAvg.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text('${worker.totalJobs} काम', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChips(worker) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: worker.skills.map<Widget>((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(77)),
        ),
        child: Text(getCategoryLabel(s), style: const TextStyle(fontSize: 13, color: AppColors.primary)),
      )).toList(),
    );
  }

  Widget _buildPriceAvailability(worker) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.payments,
            title: 'मूल्य',
            value: worker.displayPrice,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.schedule,
            title: 'समय',
            value: worker.availabilityStartTime != null
                ? '${worker.availabilityStartTime} – ${worker.availabilityEndTime}'
                : 'लचिलो',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBio(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('परिचय', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(bio, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary)),
      ],
    );
  }

  List<Widget> _buildReviews() {
    if (_loadingReviews) {
      return [const Center(child: CircularProgressIndicator())];
    }
    if (_reviews.isEmpty) {
      return [
        const Text('अहिलेसम्म कुनै समीक्षा छैन।',
            style: TextStyle(color: AppColors.textSecondary)),
      ];
    }
    return _reviews.take(5).map((r) => _ReviewTile(review: r)).toList();
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: review.reviewerPhoto != null
                ? CachedNetworkImageProvider(review.reviewerPhoto!) : null,
            child: review.reviewerPhoto == null
                ? const Icon(Icons.person, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.reviewerName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: AppColors.accent, size: 14,
                      )),
                    ),
                  ],
                ),
                if (review.serviceType != null)
                  Text(getCategoryLabel(review.serviceType!),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(review.comment!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
                const SizedBox(height: 4),
                Text(
                  DateHelpers.formatDate(review.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
