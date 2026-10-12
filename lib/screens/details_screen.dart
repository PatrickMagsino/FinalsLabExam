import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// Screen 2 ('/details'): shows one post and saves it to Hive (Create).
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments sent with Navigator.pushNamed.
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int id = args['id'];
    final String title = args['title'];
    final String body = args['body'];

    final box = Hive.box('favoritesBox');

    return Scaffold(
      appBar: const PastelAppBar(
        title: 'Post Details',
        showBackButton: true, // uses Navigator.pop()
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PastelPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatTile(icon: Icons.tag_rounded, text: 'Post $id'),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: AppTheme.font(
                        size: 23, weight: FontWeight.w700, height: 1.25),
                  ),
                  const SizedBox(height: 16),
                  // Cream content box, like the selected tile in the template.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline, width: 2.5),
                    ),
                    child: Text(
                      body,
                      style: AppTheme.font(
                          size: 16, weight: FontWeight.w400, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Rebuilds when the box changes so the button reflects saved state.
            ValueListenableBuilder(
              valueListenable: box.listenable(keys: [id]),
              builder: (context, Box b, _) {
                final alreadySaved = b.containsKey(id);
                return ChunkyButton(
                  expand: true,
                  color: alreadySaved ? AppColors.cream : AppColors.primary,
                  icon: alreadySaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label:
                      alreadySaved ? 'Saved to Favorites' : 'Save to Favorites',
                  onPressed: () {
                    if (alreadySaved) {
                      _showMessage(
                          context, 'This post is already in your favorites.');
                      return;
                    }
                    // Create: post id is the key, so it can't be saved twice.
                    b.put(id, {
                      'id': id,
                      'title': title,
                      'body': body,
                      'note': '',
                    });
                    _showMessage(context, 'Post saved to favorites!');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}