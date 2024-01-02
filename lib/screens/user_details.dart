import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.user});

  final UserProfile user;
  @override
  Widget build(BuildContext context) {
    double userDetailsMargin = 8;
    Color userCardColor = Theme.of(context).colorScheme.primary;
    TextStyle? userDetailsFont =
        Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Card(
          elevation: 5,
          child: Stack(
            children: [
              Container(
                height: 500,
              ),
              Container(
                height: 175,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Positioned(
                  child: Divider(
                color: Colors.black,
                thickness: 3,
                height: 350,
              )),
              Positioned(
                right: 120,
                bottom: 265,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.blue),
                      shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 60,
                    foregroundImage: NetworkImage(user.avatarPath!),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: Column(
                  children: [
                    Text('Username',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    Card(
                      color: userCardColor,
                      child: Container(
                          margin: EdgeInsets.all(userDetailsMargin),
                          child: Text(
                            user.username,
                            textAlign: TextAlign.center,
                            style: userDetailsFont,
                          )),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Card(
                              color: userCardColor,
                              child: Container(
                                margin: EdgeInsets.all(userDetailsMargin),
                                child: Text(
                                  user.email,
                                  textAlign: TextAlign.center,
                                  style: userDetailsFont,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Card(
                              color: userCardColor,
                              child: Container(
                                margin: EdgeInsets.all(userDetailsMargin),
                                child: Text(
                                  user.formattedDate,
                                  textAlign: TextAlign.center,
                                  style: userDetailsFont,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
