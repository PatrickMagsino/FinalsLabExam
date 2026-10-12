import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// Screen 3 ('/favorites'): Read, Update (note) and Delete saved posts.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('favoritesBox');

    return Scaffold(
      appBar: const PastelAppBar(
        title: 'Favorites',
        showBackButton: true, // uses Navigator.pop()
      ),
      // Rebuilds automatically whenever the box changes.
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box b, _) {
          // Read: all saved posts from the box.
          final favorites = b.values.toList();

          if (favorites.isEmpty) return const _EmptyFavorites();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: favorites.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader(b.length);

              final post = Map<String, dynamic>.from(favorites[index - 1]);
              final int id = post['id'];

              return Dismissible(
                key: ValueKey(id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: chunkyDecoration(
                    color: AppColors.danger,
                    depth: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Delete',
                        style: AppTheme.font(
                            weight: FontWeight.w600,
                            color: AppColors.dangerText),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.delete_rounded,
                          color: AppColors.dangerText),
                    ],
                  ),
                ),
                onDismissed: (_) => _deletePost(context, b, id),
                child: _FavoriteCard(
                  id: id,
                  title: post['title'],
                  note: post['note'] ?? '',
                  onEdit: () => _editNote(context, b, post),
                  onDelete: () => _deletePost(context, b, id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Green panel with the number of saved posts.
  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: PastelPanel(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Collection',
                    style: AppTheme.font(size: 26, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a note or swipe left to remove.',
                    style: AppTheme.font(size: 15, weight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline, width: 3),
              ),
              child: Text(
                '$count',
                style: AppTheme.font(size: 26, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update: edit the personal note and put() it back under the same key.
  void _editNote(BuildContext context, Box box, Map<String, dynamic> post) {
    final controller = TextEditingController(text: post['note'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sticky_note_2_rounded, color: AppColors.outline),
            SizedBox(width: 10),
            Text('Personal Note'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLength: 100,
          maxLines: 3,
          autofocus: true,
          style: AppTheme.font(size: 16),
          decoration: const InputDecoration(hintText: 'Write a short note...'),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ChunkyButton(
            compact: true,
            label: 'Save',
            icon: Icons.check_rounded,
            onPressed: () {
              final updated = Map<String, dynamic>.from(post);
              updated['note'] = controller.text.trim();
              box.put(post['id'], updated);
              Navigator.pop(ctx);
              _showMessage(context, 'Note saved.');
            },
          ),
        ],
      ),
    );
  }

  /// Delete: remove the post from the box by its key.
  void _deletePost(BuildContext context, Box box, int id) {
    box.delete(id);
    _showMessage(context, 'Removed from favorites.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Shown when the box has no saved posts.
class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleIcon(icon: Icons.spa_rounded, size: 104),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: AppTheme.font(size: 22, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a post and tap "Save to Favorites"\nto build your collection.',
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  size: 15, weight: FontWeight.w400, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// One saved post: id badge, title, cream note box, edit/delete buttons.
class _FavoriteCard extends StatelessWidget {
  final int id;
  final String title;
  final String note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FavoriteCard({
    required this.id,
    required this.title,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasNote = note.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: chunkyDecoration(color: AppColors.tile, depth: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IdBadge(id: id),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.font(size: 16, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: hasNote ? AppColors.cream : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined,
                            size: 17, color: AppColors.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasNote ? note : 'No note yet',
                            style: AppTheme.font(
                              size: 14,
                              weight: FontWeight.w400,
                              color: hasNote
                                  ? AppColors.outline
                                  : AppColors.muted,
                            ).copyWith(
                              fontStyle: hasNote
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                ChunkyButton(
                  compact: true,
                  icon: Icons.edit_rounded,
                  tooltip: 'Edit note',
                  onPressed: onEdit,
                ),
                const SizedBox(height: 6),
                ChunkyButton(
                  compact: true,
                  icon: Icons.close_rounded,
                  tooltip: 'Delete',
                  color: AppColors.danger,
                  depthColor: AppColors.dangerDepth,
                  textColor: AppColors.dangerText,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}