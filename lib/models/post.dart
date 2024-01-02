

import 'package:chat_app/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  const Post({
    required this.userId,
    required this.username,
    required this.post,
    required this.timestamp,
    required this.image,
    required this.userImage
  });
  
  final String userId;
  final String username;
  final String post;
  final Timestamp timestamp;
  final String image;
  final String userImage;

  String get formattedDate{
  return formatter.format(timestamp.toDate());
}
}
