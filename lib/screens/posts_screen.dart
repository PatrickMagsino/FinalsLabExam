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
              title: const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: AppColors.outline),
                  SizedBox(width: 10),
                  Text('New Post'),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: AppTheme.font(size: 16),
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Title cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bodyController,
                      maxLines: 4,
                      style: AppTheme.font(size: 16),
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
              actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ChunkyButton(
                  compact: true,
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
        icon: CircleIcon(
          size: 76,
          icon: success ? Icons.check_rounded : Icons.close_rounded,
          color: success ? AppColors.cream : AppColors.danger,
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
              valueColor: success ? AppColors.depth : AppColors.dangerDepth,
              large: true,
            ),
            const SizedBox(height: 10),
            _ResultInfoRow(
              label: 'ENDPOINT',
              value: 'POST  ${result.endpoint}',
              valueColor: AppColors.outline,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        actions: [
          ChunkyButton(
            compact: true,
            label: 'OK',
            icon: Icons.check_rounded,
            color: success ? AppColors.primary : AppColors.danger,
            depthColor: success ? AppColors.depth : AppColors.dangerDepth,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PastelAppBar(
        title: 'Posts',
        actions: [
          AppBarAction(
            icon: Icons.favorite_rounded,
            tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      body: _buildBody(),
      // Floating action button in the chunky style.
      floatingActionButton: Container(
        decoration: chunkyDecoration(
          color: AppColors.primary,
          radius: 30,
          depth: 6,
        ),
        child: FloatingActionButton.extended(
          tooltip: 'Add post',
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.outline,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: const StadiumBorder(),
          onPressed: _showAddPostDialog,
          icon: const Icon(Icons.add_rounded, size: 26),
          label: Text(
            'New Post',
            style: AppTheme.font(size: 18, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 4),
            const SizedBox(height: 16),
            Text('Loading posts...', style: AppTheme.font(color: AppColors.muted)),
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
              const CircleIcon(
                icon: Icons.cloud_off_rounded,
                color: AppColors.danger,
              ),
              const SizedBox(height: 22),
              Text(
                'Something went wrong',
                style: AppTheme.font(size: 21, weight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTheme.font(size: 15, color: AppColors.dangerText),
              ),
              const SizedBox(height: 24),
              ChunkyButton(
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader();

        final post = _posts[index - 1];
        return _PostRow(
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

  /// Green panel at the top with the post and favorite counts.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: PastelPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover Posts',
              style: AppTheme.font(size: 26, weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a post to read it and save your favorites.',
              style: AppTheme.font(size: 15, weight: FontWeight.w400),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatTile(
                    icon: Icons.article_rounded,
                    text: '${_posts.length} posts'),
                // Updates live when favorites are added or removed.
                ValueListenableBuilder(
                  valueListenable: Hive.box('favoritesBox').listenable(),
                  builder: (context, Box box, _) => StatTile(
                    icon: Icons.favorite_rounded,
                    text: '${box.length} favorites',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One post row: chunky light-green tile containing a ListTile.
class _PostRow extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _PostRow({
    required this.id,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable3D(
        onTap: onTap,
        color: AppColors.tile,
        radius: 18,
        depth: 5,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          leading: IdBadge(id: id),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.font(size: 16, weight: FontWeight.w600),
          ),
          subtitle: Text(
            body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.font(
                size: 14, weight: FontWeight.w400, color: AppColors.muted),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 30, color: AppColors.outline),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.font(
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: large
                ? AppTheme.font(
                    size: 24, weight: FontWeight.w700, color: valueColor)
                : TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
          ),
        ],
      ),
    );
  }
}