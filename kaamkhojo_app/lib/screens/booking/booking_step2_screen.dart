import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/worker_provider.dart';
import '../../config/app_theme.dart';
import '../../utils/date_helpers.dart';
import '../../utils/constants.dart';

class BookingStep2Screen extends StatefulWidget {
  const BookingStep2Screen({super.key});

  @override
  State<BookingStep2Screen> createState() => _BookingStep2ScreenState();
}

class _BookingStep2ScreenState extends State<BookingStep2Screen> {
  String _paymentMethod = 'cash';

  Future<void> _confirm() async {
    final bp = context.read<BookingProvider>();
    bp.updateDraftStep2(paymentMethod: _paymentMethod);
    final booking = await bp.submitBooking();
    if (!mounted) return;
    if (booking != null) {
      context.go('/booking/step3');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bp.error ?? 'बुकिङ गर्न सकिएन।'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final wp = context.watch<WorkerProvider>();
    final worker = wp.selectedWorker;

    return Scaffold(
      appBar: AppBar(title: const Text('पुष्टि र भुक्तानी (२/३)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Row(children: [
              Expanded(child: Container(height: 4, color: AppColors.primary)),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 4, color: AppColors.primary)),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 4, color: AppColors.divider)),
            ]),
            const SizedBox(height: 24),

            // Booking summary
            const Text('बुकिङ सारांश', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildSummaryCard(bp, worker),

            const SizedBox(height: 24),
            const Text('भुक्तानी विधि', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _PaymentOption(
              icon: Icons.payments_outlined,
              title: 'काम पूरा भएपछि नगद',
              subtitle: 'कामदारलाई नगद भुक्तानी गर्नुहोस्',
              value: 'cash',
              selected: _paymentMethod == 'cash',
              onTap: () => setState(() => _paymentMethod = 'cash'),
              enabled: true,
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              icon: Icons.account_balance_wallet_outlined,
              title: 'eSewa',
              subtitle: 'चाँडै आउँदैछ',
              value: 'esewa',
              selected: _paymentMethod == 'esewa',
              onTap: null,
              enabled: false,
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              icon: Icons.wallet,
              title: 'Khalti',
              subtitle: 'चाँडै आउँदैछ',
              value: 'khalti',
              selected: _paymentMethod == 'khalti',
              onTap: null,
              enabled: false,
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: bp.loading ? null : _confirm,
              child: bp.loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('बुकिङ पुष्टि गर्नुहोस्'),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'बुकिङ गरेपछि कामदारलाई सूचना जानेछ।',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BookingProvider bp, worker) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              label: 'सेवा',
              value: getCategoryLabel(bp.draftServiceType ?? 'other'),
            ),
            _SummaryRow(label: 'कामदार', value: bp.draftWorkerName ?? '—'),
            _SummaryRow(
              label: 'मिति',
              value: bp.draftDate != null ? DateHelpers.formatDate(bp.draftDate!) : '—',
            ),
            _SummaryRow(
              label: 'समय',
              value: bp.draftTime != null ? DateHelpers.formatTime(bp.draftTime!) : '—',
            ),
            _SummaryRow(label: 'ठेगाना', value: bp.draftAddress ?? '—'),
            if (worker?.hourlyRate != null || worker?.fixedRate != null)
              _SummaryRow(
                label: 'अनुमानित मूल्य',
                value: worker?.displayPrice ?? '—',
                highlight: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.secondary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? (selected ? AppColors.primary.withAlpha(13) : Colors.white) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('चाँडै', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              )
            else
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}
