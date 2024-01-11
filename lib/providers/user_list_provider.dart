import 'package:chat_app/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListNotifier extends StateNotifier<List<UserProfile>> {
  UserListNotifier() : super([]);

  void addUsers(List<UserProfile> users){
    state = [...users];
  }
}

final userListNotifierProvider =
    StateNotifierProvider<UserListNotifier, List<UserProfile>>(
        (ref) => UserListNotifier());
