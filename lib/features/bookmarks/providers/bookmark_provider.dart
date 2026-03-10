import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/bookmark_model.dart';
import '../../clock/providers/clock_list_provider.dart';
import '../../clock/providers/time_tick_provider.dart';

final bookmarkListProvider =
    StateNotifierProvider<BookmarkNotifier, List<BookmarkModel>>((ref) {
  return BookmarkNotifier(ref);
});

class BookmarkNotifier extends StateNotifier<List<BookmarkModel>> {
  final Ref _ref;
  bool _loaded = false;

  BookmarkNotifier(this._ref) : super([]);

  Future<void> loadBookmarks() async {
    if (_loaded) return;
    final prefs = _ref.read(preferencesRepositoryProvider);
    state = await prefs.loadBookmarks();
    _loaded = true;
  }

  Future<void> saveCurrentState(String name) async {
    final clocks = _ref.read(clockListProvider);
    if (clocks.isEmpty) return;

    final offsetMinutes = _ref.read(timePreviewOffsetMinutesProvider);

    final bookmark = BookmarkModel.create(
      name: name,
      timezoneIds: clocks.map((c) => c.timezoneId).toList(),
      masterTimezoneId: clocks.first.timezoneId,
      previewOffsetMinutes: offsetMinutes,
    );

    state = [...state, bookmark];
    await _persist();
  }

  void restoreBookmark(BookmarkModel bookmark) {
    _ref
        .read(clockListProvider.notifier)
        .restoreFromBookmark(bookmark.timezoneIds);
    // Restore time offset
    _ref.read(timePreviewOffsetMinutesProvider.notifier).state =
        bookmark.previewOffsetMinutes;
    // Set frozen base time if offset is non-zero
    if (bookmark.previewOffsetMinutes != 0) {
      _ref.read(previewBaseTimeProvider.notifier).state = DateTime.now();
    } else {
      _ref.read(previewBaseTimeProvider.notifier).state = null;
    }
  }

  Future<void> deleteBookmark(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _ref.read(preferencesRepositoryProvider);
    await prefs.saveBookmarks(state);
  }
}
