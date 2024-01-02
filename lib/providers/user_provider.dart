import 'package:chat_app/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<UserProfile> {
  UserNotifier() : super(UserProfile('', '', DateTime.now(), '',''));

  void updateUser(UserProfile updatedUser) {
    state = updatedUser;
  }
}

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, UserProfile>((ref) => UserNotifier());
