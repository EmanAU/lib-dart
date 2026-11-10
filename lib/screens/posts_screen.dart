import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';
import 'add_post_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    // Load posts once, right after the screen is drawn the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch: rebuild this screen whenever the provider changes
    final provider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const PostCountTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // read: just call a method, no rebuild needed
            onPressed: () => context.read<PostProvider>().fetchPosts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: buildBody(provider),
    );
  }

  Widget buildBody(PostProvider provider) {
    // 1) Loading
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Error
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.fetchPosts(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3) Data
    return ListView.builder(
      itemCount: provider.posts.length,
      itemBuilder: (context, index) {
        final post = provider.posts[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}

// select: this widget only rebuilds when the NUMBER of posts changes
class PostCountTitle extends StatelessWidget {
  const PostCountTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<PostProvider, int>(
      (provider) => provider.posts.length,
    );
    debugPrint('PostCountTitle rebuilt: $count');
    return Text('Posts ($count)');
  }
}
