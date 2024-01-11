import 'dart:io';

import 'package:chat_app/models/post.dart';
import 'package:chat_app/models/user_profile.dart';

import 'package:chat_app/providers/post_list_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen(
      {super.key,
      required this.user,
      required this.userProfile,
      required this.posts});

  final List<Post> posts;
  final AsyncSnapshot<User?> user;
  final UserProfile userProfile;
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  File? _selectedFile;
  String imageUrl = '';
  DateTime? _selectedDate;
  String enteredUsername = '';
  bool isSubmitting = false;
  @override
  void initState() {
    _usernameController =
        TextEditingController(text: widget.userProfile.username);
    _selectedDate = widget.userProfile.dob;
    super.initState();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'))
          ],
          content: const Text('Avatar and Date of birth must NOT be null')),
    );
  }

  void _submitProfile() async {
    final navigator = Navigator.of(context);
    enteredUsername = _usernameController.text;
    List<Post> updatedPosts = [];
    final storageRef = FirebaseStorage.instance
        .ref('profile_images')
        .child('${widget.user.data!.uid}.jpg');
    if (_selectedFile == null || enteredUsername == '') {
      return _showDialog();
    }
    setState(() {
      isSubmitting = true;
    });
    try {
      await storageRef.putFile(_selectedFile!);
      imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.data!.uid)
          .set({
        'username': enteredUsername,
        'email': widget.user.data!.email ?? '',
        'dob': _selectedDate,
        'image_url': imageUrl,
        'user_id': widget.user.data!.uid
      });

      final firestore = FirebaseFirestore.instance;

      final CollectionReference chatCollection = firestore.collection('chats');

      final CollectionReference postCollection = firestore.collection('posts');

      //Updates chat data
      var chatsData = {'username': enteredUsername, 'userImage': imageUrl};

      var chatSnapshot = await chatCollection
          .where('userId', isEqualTo: widget.user.data!.uid)
          .get();

      for (final doc in chatSnapshot.docs) {
        await chatCollection.doc(doc.id).update(chatsData);
      }

      // Updates post data
      var postsData = {'username': enteredUsername};

      var postSnapshot = await postCollection
          .where('userId', isEqualTo: widget.user.data!.uid)
          .get();

      for (final doc in postSnapshot.docs) {
        await postCollection.doc(doc.id).update(postsData);
      }

      updatedPosts = widget.posts
          .map((post) => post.userId == widget.user.data!.uid
              ? Post(
                  userId: post.userId,
                  username: enteredUsername,
                  post: post.post,
                  timestamp: post.timestamp,
                  image: post.image,
                  userImage: imageUrl)
              : post)
          .toList();
      // WriteBatch batch = FirebaseFirestore.instance.batch();

      // QuerySnapshot postQuerySnapshot = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .where('userId', isEqualTo: widget.user.data!.uid)
      //     .get();

      // List<String> postDocIds =
      //     postQuerySnapshot.docs.map((doc) => doc.id).toList();

      // for (final postDocId in postDocIds) {
      //   await FirebaseFirestore.instance
      //       .collection('posts')
      //       .doc(postDocId)
      //       .update({'username': enteredUsername, 'postImage': imageUrl});
      // }

      // QuerySnapshot chatsQuerySnapshot = await FirebaseFirestore.instance
      //     .collection('chats')
      //     .where('userId', isEqualTo: widget.user.data!.uid)
      //     .get();

      // List<String> chatDocIds =
      //     chatsQuerySnapshot.docs.map((doc) => doc.id).toList();

      // for (final chatdocId in chatDocIds) {
      //   await FirebaseFirestore.instance
      //       .collection('chats')
      //       .doc(chatdocId)
      //       .update({'userImage': imageUrl, 'username': enteredUsername});
      // }
    } on FirebaseException {
      _showDialog();
    }

    ref.read(userNotifierProvider.notifier).updateUser(UserProfile(
        enteredUsername,
        widget.user.data?.email ?? '',
        _selectedDate!,
        imageUrl,
        widget.user.data!.uid));

    ref.read(postListNotifierProvider.notifier).addPosts(updatedPosts);
    navigator.pop();
    setState(() {
      isSubmitting = false;
    });
  }

  // void _updateProfile() async {
  //   final navigator = Navigator.of(context);
  //   enteredUsername = _usernameController.text;
  //   List<Message> messages = [];

  //   final storageRef = FirebaseStorage.instance
  //       .ref('profile_images')
  //       .child('${widget.user.data!.uid}.jpg');
  //   if (_selectedFile == null || _selectedDate == null) {
  //     return _showDialog();
  //   }

  //   try {
  //     await storageRef.putFile(_selectedFile!);
  //     imageUrl = await storageRef.getDownloadURL();

  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(widget.user.data!.uid)
  //         .update({
  //       'username': enteredUsername,
  //       'email': widget.user.data!.email ?? '',
  //       'dob': _selectedDate,
  //       'image_url': imageUrl,
  //       'user_id': widget.user.data!.uid
  //     });

  //     QuerySnapshot postQuerySnapshot = await FirebaseFirestore.instance
  //         .collection('chats')
  //         .where('userId', isEqualTo: widget.user.data!.uid)
  //         .get();

  //     List<String> postDocIds =
  //         postQuerySnapshot.docs.map((doc) => doc.id).toList();

  //     for (final postDocId in postDocIds) {
  //       await FirebaseFirestore.instance
  //           .collection('posts')
  //           .doc(postDocId)
  //           .update({'username': enteredUsername, 'postImage': imageUrl});
  //     }

  //     QuerySnapshot chatsQuerySnapshot = await FirebaseFirestore.instance
  //         .collection('chats')
  //         .where('userId', isEqualTo: widget.user.data!.uid)
  //         .get();

  //     List<String> chatDocIds =
  //         chatsQuerySnapshot.docs.map((doc) => doc.id).toList();
  //     print(chatDocIds);
  //     for (final chatdocId in chatDocIds) {
  //       await FirebaseFirestore.instance
  //           .collection('chats')
  //           .doc(chatdocId)
  //           .update({'userImage': imageUrl, 'username': enteredUsername});

  //       messages.add(Message(
  //           userId: '',
  //           text: '',
  //           createdAt: Timestamp.now(),
  //           userImageUrl: imageUrl,
  //           username: enteredUsername));
  //     }
  //   } on FirebaseException {
  //     _showDialog();
  //   }
  //   ref.read(messageNotifier.notifier).addMessages(messages);
  //   ref.read(userNotifierProvider.notifier).updateUser(UserProfile(
  //       enteredUsername,
  //       widget.user.data?.email ?? '',
  //       _selectedDate!,
  //       imageUrl,
  //       widget.user.data!.uid));
  //   navigator.pop();
  // }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDay = DateTime(1950, 1, 1);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: firstDay, lastDate: now);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              UserImagePicker(
                onPickedImage: (selectedImage) {
                  setState(() {
                    _selectedFile = selectedImage;
                  });
                },
                isPostImage: false,
              ),
              Form(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null ||
                                value.length < 6 ||
                                value.trim().isEmpty) {
                              return 'Please enter a valid username with 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            label: const Text('Username'),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'No Birthdate selected'
                                    : formatter.format(_selectedDate!),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            IconButton(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.calendar_month)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: isSubmitting ? null : _submitProfile,
                      child: const Text('Submit'))
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
