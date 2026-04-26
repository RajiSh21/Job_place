import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/category_grid.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = context.read<WorkerProvider>();
      if (widget.initialCategory != null) {
        wp.applyFilters(category: widget.initialCategory);
      }
      wp.searchWorkers(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<WorkerProvider>().searchWorkers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        onApply: () => context.read<WorkerProvider>().searchWorkers(refresh: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkerProvider>();
    final locale = context.watch<LocaleProvider>();
    final isNp = locale.isNepali;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNp ? 'कामदार खोज्नुहोस्' : 'Find Workers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: widget.initialCategory == null,
              decoration: InputDecoration(
                hintText: isNp ? 'सेवा खोज्नुहोस्...' : 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          wp.applyFilters(category: null);
                          wp.searchWorkers(refresh: true);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) {
                wp.applyFilters(category: v.isNotEmpty ? v : null);
                wp.searchWorkers(refresh: true);
              },
            ),
          ),
          // Active filters chips
          if (wp.filterCategory != null ||
              wp.filterDistrict != null ||
              wp.filterAvailableToday)
            _buildActiveFilters(wp),
          // Sort tabs
          _buildSortTabs(wp),
          Expanded(child: _buildResults(wp)),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(WorkerProvider wp) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          if (wp.filterCategory != null)
            _FilterChip(
              label: getCategoryLabel(wp.filterCategory!),
              onRemove: () {
                wp.applyFilters(category: null);
                wp.searchWorkers(refresh: true);
              },
            ),
          if (wp.filterDistrict != null)
            _FilterChip(
              label: wp.filterDistrict!,
              onRemove: () {
                wp.applyFilters(district: null);
                wp.searchWorkers(refresh: true);
              },
            ),
          if (wp.filterAvailableToday)
            _FilterChip(
              label: 'आज उपलब्ध',
              onRemove: () {
                wp.applyFilters(availableToday: false);
                wp.searchWorkers(refresh: true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSortTabs(WorkerProvider wp) {
    final sorts = [
      ('rating', 'शीर्ष रेटेड'),
      ('nearest', 'नजिकको'),
      ('price_asc', 'सस्तो'),
      ('most_booked', 'बढी बुक'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: sorts.map((s) {
          final selected = wp.sortBy == s.$1;
          return GestureDetector(
            onTap: () {
              wp.applyFilters(sort: s.$1);
              wp.searchWorkers(refresh: true);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(
                s.$2,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResults(WorkerProvider wp) {
    if (wp.workers.isEmpty && wp.loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (_, __) => const WorkerCardSkeleton(horizontal: false),
      );
    }
    if (wp.workers.isEmpty && !wp.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text('कामदार फेला परेन।', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                wp.clearFilters();
                wp.searchWorkers(refresh: true);
              },
              child: const Text('फिल्टर हटाउनुहोस्'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: wp.workers.length + (wp.hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= wp.workers.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return WorkerCard(worker: wp.workers[i], horizontal: false);
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final VoidCallback onApply;
  const _FilterSheet({required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  String? _district;
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _minRating = 0;
  bool _availableToday = false;

  @override
  void initState() {
    super.initState();
    final wp = context.read<WorkerProvider>();
    _category = wp.filterCategory;
    _district = wp.filterDistrict;
    _priceRange = RangeValues(wp.filterPriceMin ?? 0, wp.filterPriceMax ?? 5000);
    _minRating = wp.filterRatingMin ?? 0;
    _availableToday = wp.filterAvailableToday;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (_, sc) => SingleChildScrollView(
        controller: sc,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('फिल्टर र क्रम', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _district = null;
                      _priceRange = const RangeValues(0, 5000);
                      _minRating = 0;
                      _availableToday = false;
                    });
                  },
                  child: const Text('हटाउनुहोस्'),
                ),
              ],
            ),
            const Divider(),
            const Text('श्रेणी', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            CategoryGrid(
              selectedCategory: _category,
              onCategorySelected: (c) => setState(() => _category = _category == c ? null : c),
            ),
            const SizedBox(height: 16),
            const Text('मूल्य दायरा (रू)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              labels: RangeLabels('रू ${_priceRange.start.round()}', 'रू ${_priceRange.end.round()}'),
              onChanged: (v) => setState(() => _priceRange = v),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('रू ${_priceRange.start.round()}', style: const TextStyle(fontSize: 13)),
                Text('रू ${_priceRange.end.round()}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('आज उपलब्ध', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Switch(value: _availableToday, onChanged: (v) => setState(() => _availableToday = v)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<WorkerProvider>().applyFilters(
                  category: _category,
                  district: _district,
                  priceMin: _priceRange.start > 0 ? _priceRange.start : null,
                  priceMax: _priceRange.end < 5000 ? _priceRange.end : null,
                  ratingMin: _minRating > 0 ? _minRating : null,
                  availableToday: _availableToday,
                );
                Navigator.pop(context);
                widget.onApply();
              },
              child: const Text('फिल्टर लागू गर्नुहोस्'),
            ),
          ],
        ),
      ),
    );
  }
}
