import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../../shared/widgets/glassmorphic_button.dart';
import '../providers/bookmark_provider.dart';
import '../../../data/models/bookmark_model.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookmarkListProvider.notifier).loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarkListProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Bookmarks'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Save current button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassmorphicButton(
                  onPressed: () => _saveBookmark(context, ref),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_add_rounded,
                          color: AppColors.textPrimary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Save Current Layout',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Bookmarks list
              Expanded(
                child: bookmarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_outline_rounded,
                                color: AppColors.textTertiary, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No bookmarks yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Save your clock layout for quick access',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = bookmarks[index];
                          return _BookmarkTile(
                            bookmark: bookmark,
                            onRestore: () => _confirmRestore(context, ref, bookmark),
                            onDelete: () => _confirmDelete(context, ref, bookmark),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    final cityNames = bookmark.timezoneIds.map((id) {
      final parts = id.split('/');
      return parts.last.replaceAll('_', ' ');
    }).toList();
    final preview = cityNames.length <= 3
        ? cityNames.join(', ')
        : '${cityNames.take(3).join(', ')}, +${cityNames.length - 3} more';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Restore '${bookmark.name}'?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will replace your current clock layout.'),
            const SizedBox(height: 12),
            Text(
              preview,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarkListProvider.notifier).restoreBookmark(bookmark);
              Navigator.pop(context); // dialog
              Navigator.pop(context); // bookmarks screen
            },
            child: Text('Restore', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${bookmark.name}'?"),
        content: const Text('This bookmark will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarkListProvider.notifier).deleteBookmark(bookmark.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _saveBookmark(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Bookmark'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g., Work setup, Meeting times',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(bookmarkListProvider.notifier).saveCurrentState(name);
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _BookmarkTile({
    required this.bookmark,
    required this.onRestore,
    required this.onDelete,
  });

  String _bookmarkCitiesPreview(BookmarkModel bm) {
    final cities = bm.timezoneIds.map((id) {
      final parts = id.split('/');
      return parts.last.replaceAll('_', ' ');
    }).toList();
    if (cities.length <= 3) return cities.join(', ');
    return '${cities.take(3).join(', ')}, +${cities.length - 3} more';
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: onRestore,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${bookmark.timezoneIds.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  _bookmarkCitiesPreview(bookmark),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  DateFormat.yMMMd().format(bookmark.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
