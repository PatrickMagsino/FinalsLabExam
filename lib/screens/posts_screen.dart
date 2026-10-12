import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// Screen 1 ('/'): fetches posts with http.get and lets the user create one with http.post.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // GET: posts come from JSONPlaceholder.
  static const String _url = 'https://jsonplaceholder.typicode.com/posts';

  // POST: new posts are sent to the Make.com webhook.
  static const String _webhookUrl =
      'https://hook.eu2.make.com/2uz9ftbj5x0cd48k4qopnja7hzmodubk';

  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPosts(); // async method called from initState()
  }

  /// GET request: shows the list on 200, an error message otherwise.
  Future<void> fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        setState(() {
          _posts = jsonDecode(response.body) as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load posts (status code: ${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not connect to the server.\n$e';
        _isLoading = false;
      });
    }
  }

  /// POST request: sends a new post to the webhook.
  /// Returns the result (success, status code, endpoint, message) to show on screen.
  Future<PostResult> createPost(String title, String body) async {
    // Give the new post the next free id so it never clashes with existing posts.
    final int newId = _posts.isEmpty
        ? 101
        : _posts.map((p) => p['id'] as int).reduce((a, b) => a > b ? a : b) + 1;

    final newPost = {
      'id': newId,
      'title': title,
      'body': body,
      'userId': 1,
    };

    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newPost),
      );

      // Make.com webhooks reply 200 ("Accepted"); a REST API replies 201 (Created).
      final success = response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        // Show the new post at the top of the list.
        setState(() => _posts.insert(0, newPost));
      }

      return PostResult(
        success: success,
        statusCode: response.statusCode,
        endpoint: _webhookUrl,
        message: success
            ? 'Post created successfully! (id: $newId)'
            : 'Failed to create post.',
      );
    } catch (e) {
      return PostResult(
        success: false,
        statusCode: null,
        endpoint: _webhookUrl,
        message: 'Failed to create post. Check your connection.\n$e',
      );
    }
  }

  /// Dialog with title and body fields; neither can be empty.
  void _showAddPostDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: AppColors.mint),
                    SizedBox(width: 10),
                    Text(
                      'Create New Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Title cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Body cannot be empty'
                          : null,
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                GradientButton(
                  label: isSending ? 'Sending...' : 'Submit',
                  icon: Icons.send_rounded,
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSending = true);

                          final result = await createPost(
                            titleController.text.trim(),
                            bodyController.text.trim(),
                          );

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          _showResultDialog(result);
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows the success/failure message, status code and endpoint of the POST on screen.
  void _showResultDialog(PostResult result) {
    final success = result.success;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: success ? AppGradients.accent : AppGradients.danger,
          ),
          child: Icon(
            success ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        title: Text(success ? 'Success' : 'Failed', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            _ResultInfoRow(
              label: 'STATUS CODE',
              value: result.statusCode?.toString() ?? 'No response',
              valueColor: success ? AppColors.leaf : AppColors.danger,
              large: true,
            ),
            const SizedBox(height: 10),
            _ResultInfoRow(
              label: 'ENDPOINT',
              value: 'POST  ${result.endpoint}',
              valueColor: AppColors.forest,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        actions: [
          GradientButton(
            label: 'OK',
            icon: Icons.thumb_up_alt_rounded,
            gradient: success ? AppGradients.primary : AppGradients.danger,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Posts',
        icon: Icons.eco_rounded,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              tooltip: 'Favorites',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.favorite_rounded),
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
            ),
          ),
        ],
      ),
      body: GradientBackground(child: _buildBody()),
      // Floating action button wrapped in a gradient.
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.leaf.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          tooltip: 'Add post',
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: const StadiumBorder(),
          onPressed: _showAddPostDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Post',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading posts...', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.danger,
                ),
                child: const Icon(Icons.cloud_off_rounded,
                    size: 42, color: Colors.white),
              ),
              const SizedBox(height: 22),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger, fontSize: 15),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: fetchPosts,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeroHeader();

        final post = _posts[index - 1];
        return _PostCard(
          id: post['id'],
          title: post['title'],
          body: post['body'],
          onTap: () {
            // Pass id, title and body as route arguments.
            Navigator.pushNamed(
              context,
              '/details',
              arguments: {
                'id': post['id'],
                'title': post['title'],
                'body': post['body'],
              },
            );
          },
        );
      },
    );
  }

  /// Gradient banner at the top of the list with post and favorite counts.
  Widget _buildHeroHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discover Posts',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Tap any post to read it and save your favorites.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              StatPill(
                  icon: Icons.article_rounded, text: '${_posts.length} Posts'),
              // Updates live when favorites are added or removed.
              ValueListenableBuilder(
                valueListenable: Hive.box('favoritesBox').listenable(),
                builder: (context, Box box, _) => StatPill(
                  icon: Icons.favorite_rounded,
                  text: '${box.length} Favorites',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One post in the list: white card with a gradient number badge.
class _PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _PostCard({
    required this.id,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.mint.withValues(alpha: 0.5),
          onTap: onTap,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '$id',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.leaf),
            ),
          ),
        ),
      ),
    );
  }
}

/// Result of the POST request, shown in the result dialog.
class PostResult {
  final bool success;
  final int? statusCode; // null when there was no response (e.g. no internet)
  final String endpoint;
  final String message;

  const PostResult({
    required this.success,
    required this.statusCode,
    required this.endpoint,
    required this.message,
  });
}

/// Labeled box in the result dialog (status code / endpoint).
class _ResultInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool large;

  const _ResultInfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: large ? 22 : 13,
              fontFamily: large ? null : 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}