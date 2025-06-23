import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Core/Helpers/FireBase/fire_store_chat_helper.dart';
import '../../student/group_chat_widget.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const ChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    await FirestoreChatHelper.sendGroupMessage(
      groupId: widget.groupId,
      text: text,
      senderType: 'dr_chat',
    );
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
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/SUPERVISOR.png'),
                  ),
                  SizedBox(width: 10),
                  const Text(
                    'SuperVisor Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .get(),
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
            return const Center(child: Text('Group not found.'));
          }
          final groupData = groupSnapshot.data!.data() as Map<String, dynamic>?;
          if (groupData == null) {
            return const Center(child: Text('Group not found.'));
          }
          final supervisorId = groupData['supervisor_id'];
          final userId = FirebaseAuth.instance.currentUser?.uid;

          // Use FutureBuilder to fetch member UIDs from subcollection
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('members')
                .get(),
            builder: (context, membersSnapshot) {
              if (membersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!membersSnapshot.hasData) {
                return const Center(child: Text('Unable to load members.'));
              }
              final memberUids =
                  membersSnapshot.data!.docs.map((doc) => doc.id).toList();

              // Allow access for supervisor, members, and group leader (groupId == userId)
              if (userId != supervisorId &&
                  !memberUids.contains(userId) &&
                  userId != widget.groupId) {
                return const Center(
                    child: Text('You do not have access to this chat.'));
              }
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirestoreChatHelper.getGroupMessagesStream(
                          widget.groupId,
                          type: 'dr_chat'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: Text('No messages.'));
                        }
                        final messages = snapshot.data!.docs;
                        if (messages.isEmpty) {
                          return const Center(child: Text('No messages.'));
                        }
                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final current = messages[index];
                            final prev = index > 0 ? messages[index - 1] : null;

                            final currentTime =
                                (current['timestamp'] as Timestamp).toDate();

                            final bool showSenderName = prev == null ||
                                prev['senderId'] != current['senderId'];

                            final bool showTimestamp = index ==
                                    messages.length - 1 ||
                                index + 1 >= messages.length ||
                                messages[index + 1]['senderId'] !=
                                    current['senderId'] ||
                                ((messages[index + 1]['timestamp'] as Timestamp)
                                        .toDate()
                                        .minute !=
                                    currentTime.minute);

                            return GroupChat(
                              text: current['text'] ?? '',
                              isMe: current['senderId'] ==
                                  FirebaseAuth.instance.currentUser!.uid,
                              senderName: current['senderName'] ?? '',
                              senderId: current['senderId'] ?? '',
                              showSenderName: showSenderName,
                              showTimestamp: showTimestamp,
                              timestamp: currentTime.toIso8601String(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildTextComposer(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
