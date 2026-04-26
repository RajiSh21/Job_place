import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_status_chip.dart';
import '../../config/app_theme.dart';
import '../../utils/date_helpers.dart';
import '../../utils/constants.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मेरा बुकिङहरू'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'सबै'),
            Tab(text: 'सक्रिय'),
            Tab(text: 'सम्पन्न'),
            Tab(text: 'रद्द'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _BookingList(status: null),
          _BookingList(status: 'accepted'),
          _BookingList(status: 'completed'),
          _BookingList(status: 'cancelled'),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final String? status;
  const _BookingList({this.status});

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final bookings = status == null
        ? bp.bookings
        : bp.bookings.where((b) => b.status == status).toList();

    if (bp.loading && bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('कुनै बुकिङ छैन।', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        getCategoryLabel(b.serviceType),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    BookingStatusChip(status: b.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(b.workerName ?? 'Unknown Worker',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${DateHelpers.formatDate(b.scheduledDate)} • ${DateHelpers.formatTime(b.scheduledTime)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (b.amount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'रू ${b.amount!.toStringAsFixed(0)} — ${b.paymentMethod}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (b.isActive || b.isPending)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/chat/${b.id}', extra: {'workerName': b.workerName}),
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('च्याट', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                        ),
                      ),
                    if (b.isActive || b.isPending) const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/chat/${b.id}'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)),
                        child: const Text('हेर्नुहोस्', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
