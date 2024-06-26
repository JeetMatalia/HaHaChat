import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/widgets/appbar_widget.dart';
import 'package:chat_app/widgets/chat_input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? selectedOption = "";

  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  // Variable to store the last displayed date
  String? lastDisplayedDate;

  void _clearChat() async {
    // You might also want to clear the messages from Firestore here
    await APIs.deleteAllMessagesInConversation(widget.user);

    // Clear the chat messages from Firestore
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            //app bar
            appBar: AppBar(
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(CupertinoIcons.ellipsis_vertical),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Clear chat',
                      child: Text('Clear chat'),
                    ),
                  ],
                  onSelected: (String result) {
                    setState(() {
                      if (result == 'Clear chat') {
                        _clearChat();
                      }
                    });
                  },
                )

              ],
              automaticallyImplyLeading: false,
              flexibleSpace: AppBarWidget(user: widget.user),
            ),

            backgroundColor: const Color.fromARGB(255, 234, 248, 255),

            //body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                      //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ?? [];

                          if (_list.isNotEmpty) {
                            // Initialize lastDisplayedDate with the date of the first message
                            final firstMessageDate =
                            DateTime.fromMillisecondsSinceEpoch(int.parse(_list.first.sent));
                            lastDisplayedDate = DateFormat('yyyy-MM-dd').format(firstMessageDate);

                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.size.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final chat = _list[index];
                                final createdAt = MyDateUtil.getFormattedTime(
                                  context: context,
                                  time: chat.sent,
                                );
                                final createdDate = DateTime.fromMillisecondsSinceEpoch(int.parse(chat.sent));
                                String formattedDateTime = DateFormat('yyyy-MM-dd').format(createdDate);

                                // Determine if the current message is the last message of the day
                                final temp = DateTime.fromMillisecondsSinceEpoch(int.parse(chat.sent));
                                final tempdate = DateFormat('yyyy-MM-dd').format(temp);
                                bool isLastMessageOfDay = index == _list.length - 1 ||
                                    formattedDateTime != DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse(_list[index + 1].sent)));

                                if (isLastMessageOfDay) {
                                  // Show the header with the date
                                  return Column(
                                    children: [
                                      // Date header widget
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Text(
                                            DateFormat('dd MMM').format(createdDate),
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      // Message card
                                      MessageCard(message: chat),
                                    ],
                                  );
                                } else {
                                  // Only show the message card without the date header
                                  return MessageCard(message: chat);
                                }
                              },
                            );

                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),

                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                //chat input filed
                ChatInputWidget(
                  user: widget.user,
                ),

                //show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.size.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
