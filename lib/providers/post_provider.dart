import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();

  List<Post> posts = [];
  bool isLoading = false;
  String? errorMessage;

  // Called by the list screen (GET)
  Future<void> fetchPosts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // UI shows the loader

    try {
      posts = await _service.getPosts();
    } catch (e) {
      errorMessage = 'Something went wrong.\n$e';
    } finally {
      isLoading = false;
      notifyListeners(); // UI shows the list or the error
    }
  }

  // Called by the add screen (POST). Returns true if it worked.
  Future<bool> addPost(String title, String body) async {
    try {
      final newPost = await _service.createPost(
        Post(userId: 1, title: title, body: body),
      );
      posts.insert(0, newPost); // add at the top of the list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Add post failed: $e');
      return false;
    }
  }
}
