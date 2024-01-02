import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBubble extends StatefulWidget {
  const UserBubble({super.key});

  @override
  State<UserBubble> createState() => _UserbubbleState();
}

class _UserbubbleState extends State<UserBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).colorScheme.primary))),
      height: 80,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Something went wrong...');
            }

            final loadedUsers = snapshot.data!.docs;
            return loadedUsers.isNotEmpty
                ? ListView.builder(
                    itemCount: loadedUsers.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final user = loadedUsers[index].data();
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3)),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(user['image_url']),
                          ),
                        ),
                      );
                    },
                  )
                : const Text('No users available.');
          }),
    );
  }
}
