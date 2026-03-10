import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/search_service.dart';
import '../../clock/providers/clock_list_provider.dart';
import '../../clock/providers/time_tick_provider.dart';

class TimezoneSearchScreen extends ConsumerStatefulWidget {
  const TimezoneSearchScreen({super.key});

  @override
  ConsumerState<TimezoneSearchScreen> createState() =>
      _TimezoneSearchScreenState();
}

class _TimezoneSearchScreenState extends ConsumerState<TimezoneSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<TimezoneSearchResult> _results = [];

  @override
  void initState() {
    super.initState();
    // Show popular timezones initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchService = ref.read(searchServiceProvider);
      setState(() {
        _results = searchService.search('');
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      final searchService = ref.read(searchServiceProvider);
      setState(() {
        _results = searchService.search(query);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final existingIds =
        ref.watch(clockListProvider).map((c) => c.timezoneId).toSet();
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: AppColors.accent, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Add Timezone',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search city, country, timezone, or time...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textTertiary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Results count
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_results.length} result${_results.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

          // Results list
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: AppColors.textTertiary, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No timezones found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final isAdded = existingIds.contains(result.timezoneId);

                      return _SearchResultTile(
                        result: result,
                        isAdded: isAdded,
                        onTap: isAdded
                            ? null
                            : () {
                                final addResult = ref
                                    .read(clockListProvider.notifier)
                                    .addClock(result.timezoneId);
                                switch (addResult) {
                                  case AddClockResult.added:
                                    Navigator.pop(context);
                                    break;
                                  case AddClockResult.duplicate:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${result.city} is already in your list'),
                                        backgroundColor: AppColors.backgroundMid,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    break;
                                  case AddClockResult.maxReached:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Maximum ${AppConstants.maxTotalClocks} clocks reached'),
                                        backgroundColor: AppColors.backgroundMid,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    break;
                                }
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TimezoneSearchResult result;
  final bool isAdded;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.result,
    required this.isAdded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: Center(
          child: Text(
            result.region.isNotEmpty ? result.region.substring(0, 2).toUpperCase() : '??',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
      title: Text(
        result.city,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        '${result.region} ${result.utcOffsetString}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: isAdded
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Added',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            )
          : Icon(Icons.add_circle_outline_rounded,
              color: AppColors.accent, size: 22),
    );
  }
}
