import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../config/app_theme.dart';
import '../../utils/date_helpers.dart';

class BookingStep3Screen extends StatelessWidget {
  const BookingStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final booking = bp.currentBooking;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Step progress - all done
              Row(children: List.generate(3, (_) => Expanded(
                child: Row(children: [
                  Expanded(child: Container(height: 4, color: AppColors.primary)),
                  if (_ < 2) const SizedBox(width: 4),
                ]),
              ))),
              const SizedBox(height: 40),

              // Success animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 20),
              const Text(
                'बुकिङ पुष्टि भयो! 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'कामदारलाई सूचना पठाइएको छ।\nउनले स्वीकार गरेपछि तपाईंलाई जानकारी दिइनेछ।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
              ),

              const SizedBox(height: 32),
              if (booking != null) ...[
                _InfoCard(
                  children: [
                    _InfoRow(label: 'बुकिङ ID', value: booking.id.substring(0, 8).toUpperCase()),
                    _InfoRow(label: 'कामदार', value: booking.workerName ?? '—'),
                    if (booking.workerPhone != null)
                      _InfoRow(label: 'सम्पर्क', value: booking.workerPhone!),
                    _InfoRow(
                      label: 'मिति',
                      value: '${DateHelpers.formatDate(booking.scheduledDate)} • ${DateHelpers.formatTime(booking.scheduledTime)}',
                    ),
                    _InfoRow(label: 'भुक्तानी', value: booking.paymentMethod == 'cash' ? 'काम पूरा भएपछि नगद' : booking.paymentMethod),
                  ],
                ),
              ],

              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/chat/${booking?.id}', extra: {'workerName': booking?.workerName}),
                icon: const Icon(Icons.chat),
                label: const Text('कामदारसँग च्याट गर्नुहोस्'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/bookings'),
                child: const Text('बुकिङहरू हेर्नुहोस्'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('होममा जानुहोस्'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
