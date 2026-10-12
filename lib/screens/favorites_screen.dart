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
      appBar: const GradientAppBar(
        title: 'Favorites',
        icon: Icons.favorite_rounded,
        showBackButton: true, // uses Navigator.pop()
      ),
      body: GradientBackground(
        // Rebuilds automatically whenever the box changes.
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box b, _) {
            // Read: all saved posts from the box.
            final favorites = b.values.toList();

            if (favorites.isEmpty) return const _EmptyFavorites();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              itemCount: favorites.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildSummaryHeader(context, b.length);

                final post = Map<String, dynamic>.from(favorites[index - 1]);
                final int id = post['id'];

                return Dismissible(
                  key: ValueKey(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 26),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_rounded, color: Colors.white),
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
      ),
    );
  }

  /// Gradient banner with the number of saved posts.
  Widget _buildSummaryHeader(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Collection',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Add notes or swipe left to remove.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Update: edit the personal note and put() it back under the same key.
  void _editNote(BuildContext context, Box box, Map<String, dynamic> post) {
    final controller = TextEditingController(text: post['note'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: const Row(
            children: [
              Icon(Icons.sticky_note_2_rounded, color: AppColors.mint),
              SizedBox(width: 10),
              Text(
                'Personal Note',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(
            controller: controller,
            maxLength: 100,
            maxLines: 3,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Write a short note...'),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          GradientButton(
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
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forest.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.spa_rounded,
                  size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open a post and tap "Save to Favorites"\nto build your collection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// One saved post: gradient badge, title, note box, and edit/delete actions.
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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$id',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: hasNote ? AppGradients.soft : null,
                    color: hasNote ? null : AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: hasNote ? AppColors.leaf : AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasNote ? note : 'No note yet',
                          style: TextStyle(
                            color: hasNote ? AppColors.forest : AppColors.muted,
                            fontStyle:
                                hasNote ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Column(
            children: [
              _CircleAction(
                tooltip: 'Edit note',
                icon: Icons.edit_rounded,
                color: AppColors.leaf,
                background: AppColors.mint.withValues(alpha: 0.45),
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _CircleAction(
                tooltip: 'Delete',
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                background: AppColors.dangerSoft.withValues(alpha: 0.6),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small round icon button with a tinted background.
class _CircleAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}