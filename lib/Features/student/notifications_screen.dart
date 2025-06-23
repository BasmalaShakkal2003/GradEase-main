import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Helpers/FireBase/fire_store_notification_helper.dart';
import 'task_details_screen.dart';

//--------------------Notification screen-----------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in.')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 20,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Positioned(
                top: 110,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirestoreNotificationHelper.getNotificationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notifications.'));
                }
                final notifications = snapshot.data!.docs
                    .where((doc) => doc['visible'] == true)
                    .toList();
                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notifDoc = notifications[index];
                    final notif = notifDoc.data();
                    final notifId = notifDoc.id;
                    final notifType = notif['type'] ?? '';
                    final senderId = notif['senderId'];
                    return Dismissible(
                      key: Key(notifId),
                      direction: (notifType == 'task' ||
                              notifType == 'task_accepted' ||
                              notifType == 'task_rejected' ||
                              notifType == 'meeting')
                          ? DismissDirection.startToEnd
                          : DismissDirection.horizontal,
                      background: (notifType == 'task' ||
                              notifType == 'task_accepted' ||
                              notifType == 'task_rejected' ||
                              notifType == 'meeting')
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 32),
                            )
                          : notifType == 'groupRequest'
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 24),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 32),
                                )
                              : Container(),
                      secondaryBackground: notifType == 'groupRequest'
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.cancel,
                                  color: Colors.white, size: 32),
                            )
                          : Container(),
                      confirmDismiss: (direction) async {
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        if (notifType == 'task' ||
                            notifType == 'task_accepted' ||
                            notifType == 'task_rejected' ||
                            notifType == 'meeting') {
                          await FirestoreNotificationHelper.deleteNotification(
                            userId: user.uid,
                            notificationId: notifId,
                          );
                          messenger?.showSnackBar(
                            const SnackBar(
                                content: Text('Notification dismissed.')),
                          );
                          return true;
                        } else if (notifType == 'groupRequest') {
                          if (direction == DismissDirection.startToEnd) {
                            if (senderId == null) {
                              messenger?.showSnackBar(
                                const SnackBar(
                                    content: Text('Sender ID not found.')),
                              );
                              return false;
                            }
                            final memberDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(senderId)
                                .get();
                            if (!memberDoc.exists) {
                              messenger?.showSnackBar(
                                const SnackBar(
                                    content: Text('User not found.')),
                              );
                              return false;
                            }
                            final memberData = memberDoc.data()!;
                            final memberGroupId = memberData['group_id'];
                            if (memberGroupId != null &&
                                memberGroupId.toString().isNotEmpty) {
                              messenger?.showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'User is already in another group. Ask them to leave their group first.')),
                              );
                              return false;
                            }
                            final groupId = user.uid;
                            await FirebaseFirestore.instance
                                .collection('groups')
                                .doc(groupId)
                                .collection('members')
                                .doc(senderId)
                                .set(
                                    {'joinedAt': FieldValue.serverTimestamp()});
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(senderId)
                                .update({'group_id': groupId});
                            messenger?.showSnackBar(
                              const SnackBar(
                                  content: Text('Member added to group.')),
                            );
                            await FirestoreNotificationHelper
                                .deleteNotification(
                              userId: user.uid,
                              notificationId: notifId,
                            );
                            return true;
                          } else {
                            await FirestoreNotificationHelper
                                .deleteNotification(
                              userId: user.uid,
                              notificationId: notifId,
                            );
                            messenger?.showSnackBar(
                              const SnackBar(
                                  content: Text('Request rejected.')),
                            );
                            return true;
                          }
                        } else {
                          messenger?.showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'This notification cannot be dismissed.')),
                          );
                          return false;
                        }
                      },
                      child: NotificationCard(
                        message: notif['message'] ?? '',
                        type: notifType,
                        senderId: senderId,
                        taskId: notif['task_id'],
                        groupId: notif['group_id'] ?? user.uid,
                        notes: notif['notes'],
                        grade: notif['grade'],
                        totalGrade: notif['total_grade'],
                        onTap: (notifType == 'task' ||
                                    notifType == 'task_accepted' ||
                                    notifType == 'task_rejected') &&
                                notif['task_id'] != null
                            ? () async {
                                // Fetch group_id from user document
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                final groupId =
                                    userDoc.data()?['group_id'] ?? user.uid;
                                // Fetch total grade from task document
                                String? totalGrade;
                                if (groupId != null &&
                                    notif['task_id'] != null) {
                                  final taskDoc = await FirebaseFirestore
                                      .instance
                                      .collection('groups')
                                      .doc(groupId)
                                      .collection('tasks')
                                      .doc(notif['task_id'])
                                      .get();
                                  totalGrade =
                                      taskDoc.data()?['grade']?.toString();
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsScreen(
                                      taskId: notif['task_id'],
                                      groupId: groupId,
                                      status: notifType,
                                      notes: notif['notes'],
                                      grade: notif['grade'],
                                      totalGrade: totalGrade,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/bgd.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// Notification card widget
class NotificationCard extends StatelessWidget {
  final String message;
  final String type;
  final String? senderId;
  final String? taskId;
  final String? groupId;
  final String? notes;
  final String? grade;
  final String? totalGrade;
  final VoidCallback? onTap;
  const NotificationCard({
    Key? key,
    required this.message,
    required this.type,
    this.senderId,
    this.taskId,
    this.groupId,
    this.notes,
    this.grade,
    this.totalGrade,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: type == 'groupRequest'
            ? const Icon(Icons.group_add_rounded, color: Colors.orangeAccent)
            : const Icon(Icons.notifications, color: Colors.blueAccent),
        title: Text(message, style: const TextStyle(fontSize: 16)),
        subtitle: type.isNotEmpty
            ? Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: type == 'groupRequest'
                          ? Colors.orangeAccent.withOpacity(0.15)
                          : Colors.blueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type == 'groupRequest' ? 'Group Request' : type,
                      style: TextStyle(
                        color: type == 'groupRequest'
                            ? Colors.orangeAccent
                            : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
