import 'package:chat_app/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListNotifier extends StateNotifier<List<UserProfile>> {
  UserListNotifier() : super([]);
}

final userListNotifier =
    StateNotifierProvider<UserListNotifier, List<UserProfile>>(
        (ref) => UserListNotifier());
