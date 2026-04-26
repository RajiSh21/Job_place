import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/offline_banner.dart';
import '../../config/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedDistrict;
  Position? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final wp = context.read<WorkerProvider>();
    await _fetchLocation();
    await Future.wait([
      wp.loadNearbyWorkers(
        lat: _position?.latitude,
        lng: _position?.longitude,
        district: _selectedDistrict,
      ),
      wp.loadTopRated(district: _selectedDistrict),
    ]);
  }

  Future<void> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _position = pos);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wp = context.watch<WorkerProvider>();
    final connectivity = context.watch<ConnectivityProvider>();
    final locale = context.watch<LocaleProvider>();
    final isNp = locale.isNepali;

    return Scaffold(
      body: Column(
        children: [
          if (!connectivity.isOnline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, auth, isNp),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(context, isNp),
                          const SizedBox(height: 20),
                          Text(
                            isNp ? 'सेवाहरू' : 'Services',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          CategoryGrid(nepali: isNp),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            isNp ? 'नजिकका कामदारहरू' : 'Nearby Workers',
                            onSeeAll: () => context.push('/search'),
                          ),
                          const SizedBox(height: 12),
                          _buildNearbyWorkers(wp),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            isNp ? 'शीर्ष रेटेड कामदारहरू' : 'Top Rated Workers',
                            onSeeAll: () => context.push('/search'),
                          ),
                          const SizedBox(height: 12),
                          _buildTopRated(wp, isNp),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AuthProvider auth, bool isNp) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isNp ? 'नमस्ते, ${auth.currentUser?.name?.split(' ').first ?? 'साथी'}! 🙏'
                           : 'Hello, ${auth.currentUser?.name?.split(' ').first ?? 'Friend'}! 🙏',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showDistrictPicker,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _selectedDistrict ?? (isNp ? 'स्थान छान्नुहोस्' : 'Select Location'),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/settings'),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.settings, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isNp) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: AppColors.textHint),
            const SizedBox(width: 12),
            Text(
              isNp ? 'कस्तो सेवा चाहिन्छ?' : 'What service do you need?',
              style: const TextStyle(color: AppColors.textHint, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('सबै हेर्नुहोस्')),
      ],
    );
  }

  Widget _buildNearbyWorkers(WorkerProvider wp) {
    if (wp.nearbyWorkers.isEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (_, __) => const WorkerCardSkeleton(),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wp.nearbyWorkers.length,
        itemBuilder: (_, i) => WorkerCard(worker: wp.nearbyWorkers[i]),
      ),
    );
  }

  Widget _buildTopRated(WorkerProvider wp, bool isNp) {
    if (wp.topRatedWorkers.isEmpty) {
      return Column(
        children: List.generate(3, (_) => const WorkerCardSkeleton(horizontal: false)),
      );
    }
    return Column(
      children: wp.topRatedWorkers
          .take(5)
          .map((w) => WorkerCard(worker: w, horizontal: false))
          .toList(),
    );
  }

  void _showDistrictPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DistrictPicker(
        selected: _selectedDistrict,
        onSelected: (d) {
          setState(() => _selectedDistrict = d);
          _loadData();
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        switch (i) {
          case 1: context.push('/search'); break;
          case 2: context.push('/bookings'); break;
          case 3: context.push('/settings'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'होम'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'खोज'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'बुकिङ'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'प्रोफाइल'),
      ],
    );
  }
}

class _DistrictPicker extends StatefulWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _DistrictPicker({this.selected, required this.onSelected});

  @override
  State<_DistrictPicker> createState() => _DistrictPickerState();
}

class _DistrictPickerState extends State<_DistrictPicker> {
  final List<String> _districts = const [
    'Kathmandu', 'Lalitpur', 'Bhaktapur', 'Kaski', 'Chitwan',
    'Morang', 'Sunsari', 'Rupandehi', 'Kailali', 'Banke',
    'Jhapa', 'Bara', 'Parsa', 'Sarlahi', 'Makwanpur',
  ];
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _districts.where((d) => d.toLowerCase().contains(_search.toLowerCase())).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, sc) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('जिल्ला छान्नुहोस्', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(hintText: 'खोज्नुहोस्...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('सबै जिल्लाहरू'),
              leading: const Icon(Icons.location_off),
              selected: widget.selected == null,
              onTap: () { Navigator.pop(context); widget.onSelected(null); },
            ),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: filtered.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(filtered[i]),
                  leading: const Icon(Icons.location_on),
                  selected: widget.selected == filtered[i],
                  selectedColor: AppColors.primary,
                  onTap: () { Navigator.pop(context); widget.onSelected(filtered[i]); },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
