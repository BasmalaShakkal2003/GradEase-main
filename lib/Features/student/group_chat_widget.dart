
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;
  final String senderId;
  final bool showSenderName;
  final bool showTimestamp;
  final String timestamp;

  const GroupChat({
    super.key,
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.senderId,
    required this.showSenderName,
    required this.showTimestamp,
    required this.timestamp,
  });

  Future<String?> _getUserRole(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.data()?['role'];
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && showSenderName)
            FutureBuilder<String?>(
              future: _getUserRole(senderId),
              builder: (context, snapshot) {
                final role = snapshot.data;
                final displayName = role == 'supervisor' ? 'Dr. $senderName' : senderName;
                
                return Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF011226) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('h:mm a').format(DateTime.parse(timestamp)),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
