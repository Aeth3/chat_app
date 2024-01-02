// import 'package:chat_app/models/message.dart';
// import 'package:chat_app/providers/message_provider.dart';

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage extends ConsumerStatefulWidget {
  const ChatMessage({super.key});

  @override
  ConsumerState<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends ConsumerState<ChatMessage> {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;

  // @override
  // void initState() {
  //   _loadMessage();
  //   super.initState();
  // }

  // void _loadMessage() async {
  //   final data = await FirebaseFirestore.instance.collection('chats').get();

  //   //Built-in function by firebaseFirestore .orderBy() that sorts data entries accordingly.
  //   // final data = await FirebaseFirestore.instance.collection('chats').orderBy('createdAt',descending: true);
  //   String userId;
  //   String text;
  //   Timestamp time;
  //   String userImageUrl;
  //   String username;
  //   List<Message> messages = [];
  //   for (final item in data.docs) {
  //     userId = item['userId'];
  //     text = item['text'];
  //     time = item['createdAt'];
  //     userImageUrl = item['userImage'];
  //     username = item['username'];

  //     messages.add(Message(
  //         userId: userId,
  //         text: text,
  //         createdAt: time,
  //         userImageUrl: userImageUrl,
  //         username: username));
  //     ref.read(messageNotifier.notifier).addMessages(messages);
  //   }
  //   messages.sort(
  //     (a, b) => b.createdAt.compareTo(a.createdAt),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1]
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final message = ref.watch(messageNotifier);
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: ListView.builder(
  //             reverse: true,
  //             itemCount: message.length,
  //             itemBuilder: (context, index) {
  //               final chatMessage = message[index];
  //               final nextChatMessage =
  //                   index + 1 < message.length ? message[index + 1] : null;

  //               final currentMessageUserId = chatMessage.userId;
  //               final nextMessageUserId = nextChatMessage?.userId;
  //               final nextUserIsSame =
  //                   nextMessageUserId == currentMessageUserId;

  //               if (nextUserIsSame) {
  //                 return MessageBubble.next(
  //                     message: chatMessage.text,
  //                     isMe: authenticatedUser.uid == currentMessageUserId);
  //               } else {
  //                 return MessageBubble.first(
  //                     userImage: chatMessage.userImageUrl,
  //                     username: chatMessage.username,
  //                     message: chatMessage.text,
  //                     isMe: authenticatedUser.uid == currentMessageUserId);
  //               }
  //             }),
  //       ),
  //     ],
  //   );
  // }
}
