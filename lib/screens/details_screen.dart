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
      appBar: const GradientAppBar(
        title: 'Post Details',
        showBackButton: true, // uses Navigator.pop()
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient hero card with the post number and title.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forest.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatPill(icon: Icons.tag_rounded, text: 'POST $id'),
                    const SizedBox(height: 16),
                    Text(title,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Body text card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTENT',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppGradients.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(body, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Rebuilds when the box changes so the button reflects saved state.
              ValueListenableBuilder(
                valueListenable: box.listenable(keys: [id]),
                builder: (context, Box b, _) {
                  final alreadySaved = b.containsKey(id);
                  return GradientButton(
                    expand: true,
                    gradient:
                        alreadySaved ? AppGradients.soft : AppGradients.primary,
                    foregroundColor:
                        alreadySaved ? AppColors.forest : Colors.white,
                    icon: alreadySaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: alreadySaved
                        ? 'Saved to Favorites'
                        : 'Save to Favorites',
                    onPressed: () {
                      if (alreadySaved) {
                        _showMessage(context,
                            'This post is already in your favorites.');
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
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}