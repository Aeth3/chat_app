import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageNotifier extends StateNotifier<List<Message>> {
  MessageNotifier() : super([]);

  void addMessage(String userId, String text, Timestamp time,
      String userImageUrl, String username) {
    final newMessage = Message(
        userId: userId,
        text: text,
        createdAt: time,
        userImageUrl: userImageUrl,
        username: username,
        );
    state = [newMessage, ...state];
  }

  void removeMessage(Message message) {
    state = state.where((element) => element != message).toList();
  }

  void updateMessage(Message message) {
    state = state.map((e) => e.userId == message.userId ? message : e).toList();
  }

  void addMessages(List<Message> messages) {
    state = [...messages];
  }
}

final messageNotifier = StateNotifierProvider<MessageNotifier, List<Message>>(
    (ref) => MessageNotifier());
