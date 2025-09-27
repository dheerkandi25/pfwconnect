import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/models.dart';

class SocialTab extends StatelessWidget {
  const SocialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (BuildContext context, AppState state, _) {
          if (state.posts.isEmpty) {
            return const Center(
              child: Text('Share something with your classmates!'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.posts.length,
              itemBuilder: (BuildContext context, int index) {
                final StudentPost post = state.posts[index];
                return _PostCard(post: post);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context),
        icon: const Icon(Icons.create),
        label: const Text('New post'),
      ),
    );
  }

  Future<void> _showCreatePostSheet(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController bodyController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Share an update',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyController,
                  decoration:
                      const InputDecoration(labelText: "What's happening?"),
                  minLines: 3,
                  maxLines: 5,
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) {
                        return;
                      }
                      context.read<AppState>().addPost(
                            StudentPost(
                              id: generateId(),
                              author: authorController.text.trim(),
                              body: bodyController.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final StudentPost post;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.author,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      formatDateTime(post.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () => state.reactToPost(post.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.body),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  avatar: const Icon(Icons.thumb_up, size: 16),
                  label: Text('${post.reactions} cheers'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add_comment_outlined, size: 16),
                  label: const Text('Comment'),
                  onPressed: () => _promptComment(context, state),
                ),
              ],
            ),
            if (post.comments.isNotEmpty) ...<Widget>[
              const Divider(height: 32),
              Text('Comments', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final String comment in post.comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.chat_bubble_outline, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(comment)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _promptComment(BuildContext context, AppState state) async {
    final TextEditingController controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your comment',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }
                state.commentOnPost(post.id, controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
