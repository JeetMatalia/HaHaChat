import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/chat_user.dart';
import '../../screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({Key? key, required this.user}) : super(key: key);

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: SizedBox(
        width: mq.size.width * .6,
        height: mq.size.height * .45,
        child: Stack(
          children: [
            // User profile picture
            Positioned(
              top: mq.size.height * .075,
              left: mq.size.width * .1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.size.height * .25),
                child: CachedNetworkImage(
                  width: mq.size.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
            ),

            // User name
            Positioned(
              left: mq.size.width * .2,
              top: mq.size.height * .02,
              width: mq.size.width * .55,
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Info button
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.pop(context);
                  // Move to view profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user),
                    ),
                  );
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(Icons.info_outline, color: Colors.blue, size: 30),
              ),
            ),

            // Close button
            Positioned(
              top: 6,
              left: 3,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.back, color: Colors.black, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
