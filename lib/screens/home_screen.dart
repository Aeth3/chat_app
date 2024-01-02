import 'dart:io';

// import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/models/user_profile.dart';

import 'package:chat_app/providers/post_list_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/edit_profile_screen.dart';
import 'package:chat_app/screens/user_details.dart';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.user});

  final AsyncSnapshot<User?> user;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? enteredPostImage;
  final _postMessageController = TextEditingController();
  String imageUrl = '';
  bool isPostImage = false;
  late Reference storageRef;
  Timestamp timestamp = Timestamp.now();
  String stringTimestamp = '';
  bool isSubmitted = false;

  void submitPhoto() async {
    stringTimestamp = timestamp.toString();
    final navigator = Navigator.of(context);
    storageRef = FirebaseStorage.instance
        .ref('post-images')
        .child('${widget.user.data!.uid}-$stringTimestamp.jpg');
    setState(() {
      isSubmitted = true;
      isPostImage = false;
    });
    navigator.pop();
  }

  void _submitPost(UserProfile userProfile) async {
    final enteredMessage = _postMessageController.text;
    if (enteredMessage == '' && enteredPostImage == null) {
      return;
    }
    setState(() {
      isSubmitted = true;
    });
    FocusScope.of(context).unfocus();
    try {
      await storageRef.putFile(enteredPostImage!);
      imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').doc().set({
        'userId': widget.user.data!.uid,
        'post': enteredMessage,
        'postImage': imageUrl,
        'username': userProfile.username,
        'timestamp': timestamp,
        'userImage': userProfile.avatarPath
      });
      _postMessageController.clear();
      ref.read(postListNotifierProvider.notifier).addPost(
          widget.user.data!.uid,
          userProfile.username,
          enteredMessage,
          timestamp,
          imageUrl,
          userProfile.avatarPath!);
    } on FirebaseException {
      _showDialog();
    }

    setState(() {
      isSubmitted = false;
    });
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
          content: const Text('Something went wrong...')),
    );
  }

  

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    _loadUserProfile();
    super.initState();
    _loadPosts();
  }

  void _loadPosts() async {
    final postData = await FirebaseFirestore.instance.collection('posts').get();
    ref.read(postListNotifierProvider.notifier).clearPosts();
    for (final item in postData.docs) {
      String post = item['post'];
      String postImage = item['postImage'];
      Timestamp timestamp = item['timestamp'];
      String username = item['username'];
      String userImage = item['userImage'];
      ref.read(postListNotifierProvider.notifier).addPost(widget.user.data!.uid,
          username, post, timestamp, postImage, userImage);
    }
  }

  Future<void> _loadUserProfile() async {
    final data = await FirebaseFirestore.instance.collection('users').get();
    String username = '';
    String email = '';
    String imagePath = '';
    DateTime dob = DateTime.now();
    for (final item in data.docs) {
      String userId = item['user_id'];
      if (userId == widget.user.data!.uid) {
        username = item['username'];
        email = item['email'];
        imagePath = item['image_url'];
        Timestamp timeStamp = item['dob'];
        dob = timeStamp.toDate();
      }
      ref.read(userNotifierProvider.notifier).updateUser(
          UserProfile(username, email, dob, imagePath, widget.user.data!.uid));
    }
  }

  void _editProfile(UserProfile userProfile, List<Post> posts) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditProfileScreen(
        userProfile: userProfile,
        user: widget.user,
        posts: posts,
      ),
    ));
  }

  @override
  void dispose() {
    _postMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postListNotifierProvider);
    final user = ref.watch(userNotifierProvider);
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary),
        child: FloatingActionButton(
          onPressed: () {
            if (user.username.isEmpty ||
                user.username == '' ||
                user.avatarPath == '') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    content: const Text(
                        'Please add your username and image at the settings'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'))
                    ]),
              );
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ));
            }
          },
          child: const Icon(Icons.message_rounded),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
            child: CircleAvatar(
              backgroundImage: user.avatarPath != ''
                  ? NetworkImage(user.avatarPath!)
                  : const AssetImage('assets/images/user.png')
                      as ImageProvider<Object>?,
            ),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserDetails(user: user),
            )),
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
          ),
        ],
      )),
      appBar: AppBar(actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () {
                  _editProfile(user, posts);
                },
                child: const Row(
                  children: [
                    Icon(Icons.person_3_outlined),
                    Text('Edit Profile')
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Row(
                  children: [Icon(Icons.logout), Text('Logout')],
                ),
              )
            ];
          },
        )
      ]),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Card(
                  shadowColor: Theme.of(context).colorScheme.primary,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 5,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 40,
                                onPressed: () {
                                  setState(() {
                                    isPostImage = true;
                                  });
                                  Navigator.of(context)
                                      .push(ModalBottomSheetRoute(
                                          builder: (context) => Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    UserImagePicker(
                                                        onPickedImage:
                                                            (selectedImage) {
                                                          setState(() {
                                                            enteredPostImage =
                                                                selectedImage;
                                                          });
                                                        },
                                                        isPostImage:
                                                            isPostImage),
                                                    ElevatedButton(
                                                        onPressed: isSubmitted? null: submitPhoto,
                                                        child: const Text(
                                                            'Submit'))
                                                  ],
                                                ),
                                              ),
                                          isScrollControlled: false));
                                },
                                icon: const Icon(
                                  Icons.photo,
                                )),
                            Expanded(
                                child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                  hintText: "What's on your mind?"),
                              controller: _postMessageController,
                            )),
                            TextButton(
                                onPressed: () => _submitPost(user),
                                child: const Text('Post'))
                          ],
                        ),
                        if (isSubmitted) Image.file(enteredPostImage!)
                      ],
                    ),
                  )),
              Container(
                constraints: const BoxConstraints.expand(
                    height: 670, width: double.infinity),
                child: RefreshIndicator(
                  onRefresh: () async {
                    return _loadPosts();
                  },
                  child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        posts
                            .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shadowColor: Theme.of(context).colorScheme.primary,
                          elevation: 5,
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Stack(
                            children: [
                              Image.network(posts[index].image),
                              Container(
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                      Colors.black,
                                      Colors.transparent
                                    ])),
                                padding: const EdgeInsets.only(
                                    right: 8, left: 16, top: 16, bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)),
                                      child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              posts[index].userImage)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          posts[index].username,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          timeago.format(
                                              posts[index].timestamp.toDate(),
                                              locale: 'en'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(color: Colors.white60),
                                        )
                                      ],
                                    ),
                                    const Spacer(),
                                    PopupMenuButton(
                                      color: Colors.white,
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(child: Text('Edit Post')),
                                        PopupMenuItem(
                                            child: Text('Delete Post'))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                            Colors.black,
                                            Colors.transparent
                                          ])),
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        posts[index].post,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.white),
                                      )))
                            ],
                          ),
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
