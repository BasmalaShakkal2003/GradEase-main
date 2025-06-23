import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'group_chat_widget.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  GroupChatScreenState createState() => GroupChatScreenState();
}

class GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final senderName = userDoc['name'];

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': uid,
      'senderName': senderName,
      'timestamp': Timestamp.now(),
      'type': 'group_chat', // Ensure type is set for student group chat
    });
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 70,
            left: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 95,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/gradchat.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Grad Chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Type a message'),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  return data == null ||
                      !data.containsKey('type') ||
                      data['type'] != 'dr_chat';
                }).toList();
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final current = messages[index];
                    final prev = index > 0 ? messages[index - 1] : null;

                    final currentTime =
                        (current['timestamp'] as Timestamp).toDate();

                    final bool showSenderName =
                        prev == null || prev['senderId'] != current['senderId'];

                    final bool showTimestamp = index == messages.length - 1 ||
                        index + 1 >= messages.length ||
                        messages[index + 1]['senderId'] !=
                            current['senderId'] ||
                        ((messages[index + 1]['timestamp'] as Timestamp)
                                .toDate()
                                .minute !=
                            currentTime.minute);

                    return GroupChat(
                      text: current['text'],
                      isMe: current['senderId'] ==
                          FirebaseAuth.instance.currentUser!.uid,
                      senderName: current['senderName'],
                      senderId: current['senderId'],
                      showSenderName: showSenderName,
                      showTimestamp: showTimestamp,
                      timestamp: currentTime.toString(),
                    );
                  },
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }
}
