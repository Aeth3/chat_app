import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.userImageUrl,
    required this.username,
  });

  final String userId;
  final String text;
  final Timestamp createdAt;
  final String userImageUrl;
  final String username;
}
