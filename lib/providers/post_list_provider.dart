import 'package:chat_app/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostListNotifier extends StateNotifier<List<Post>> {
  PostListNotifier() : super([]);

  void addPost(String userId, String username, String post, Timestamp timestamp,
      String image, String userImage) {
    final newPost = Post(
        userId: userId,
        username: username,
        post: post,
        timestamp: timestamp,
        image: image,
        userImage: userImage);

    state = [newPost, ...state];
  }

  void updatePost(Post updatedPost) {
    state = state
        .map((existingPost) => existingPost.userId == updatedPost.userId
            ? updatedPost
            : existingPost)
        .toList();
  }

  void addPosts(List<Post> posts) {
    state = [...posts];
  }

  void clearPosts() {
    state = []; // Assuming that the state is a List<Post>
  }
}

final postListNotifierProvider =
    StateNotifierProvider<PostListNotifier, List<Post>>(
        (ref) => PostListNotifier());
