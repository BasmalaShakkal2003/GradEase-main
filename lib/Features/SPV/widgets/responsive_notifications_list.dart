import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification_card.dart';
import 'grade_dialog.dart';
import 'reject_dialog.dart';

class ResponsiveNotificationsList extends StatelessWidget {
  final Size screenSize;
  const ResponsiveNotificationsList({super.key, required this.screenSize});

  Future<void> _openLink(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No link available.')),
      );
      return;
    }
    try {
      final uri = Uri.parse(url);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = await launchUrl(uri);
      }
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open the link:\n$url\n'
              'The link is valid, but launchUrl() still failed. '
              'Please check your device settings or try copying the link manually.',
            ),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard.')),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link:\n$url\nError: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in.'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notification')
            .orderBy('timestamp', descending: true)
            .snapshots(),
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

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notifDoc = notifications[index];
              final notif = notifDoc.data();
              final notifId = notifDoc.id;
              final notifType = notif['type'] ?? '';
              final link = notif['link'] as String?;
              final isSupervisorRequest = notifType == 'supervisor_request';
              final isTaskSubmission = notifType == 'task_submission';
              final groupId = notif['senderId'];

              return NotificationCard(
                notif: notif,
                notifId: notifId,
                link: link,
                isSupervisorRequest: isSupervisorRequest,
                isTaskSubmission: isTaskSubmission,
                groupId: groupId,
                screenSize: screenSize,
                onAccept: () async {
                  if (isSupervisorRequest) {
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    final userDoc = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId);
                    if (groupId != null && groupId.toString().isNotEmpty) {
                      await userDoc.update({
                        'group_id': FieldValue.arrayUnion([groupId])
                      });
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(groupId)
                          .update({'supervisor_id': userId});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Group ID is missing or invalid.')),
                      );
                    }
                    await userDoc
                        .collection('notification')
                        .doc(notifId)
                        .delete();
                  } else if (isTaskSubmission) {
                    final senderId = notif['senderId'];
                    final taskId = notif['task_id'];
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(senderId)
                        .get();
                    final groupId = userDoc.data()?['group_id'];
                    int? maxGrade;
                    if (groupId != null &&
                        groupId.toString().isNotEmpty &&
                        taskId != null) {
                      final taskDoc = await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(groupId)
                          .collection('tasks')
                          .doc(taskId)
                          .get();
                      if (taskDoc.exists && taskDoc.data()?['grade'] != null) {
                        maxGrade =
                            int.tryParse(taskDoc.data()!['grade'].toString());
                      }
                    }
                    final gradeController = TextEditingController();
                    final notesController = TextEditingController();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => GradeDialog(
                        maxGrade: maxGrade,
                        gradeController: gradeController,
                        notesController: notesController,
                        onCancel: () => Navigator.pop(context),
                        onSubmit: () async {
                          final grade = gradeController.text.trim();
                          final notes = notesController.text.trim();
                          if (grade.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Grade is required.')),
                            );
                            return;
                          }
                          final gradeValue = int.tryParse(grade);
                          if (maxGrade != null &&
                              gradeValue != null &&
                              gradeValue > maxGrade) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Grade cannot exceed $maxGrade.')),
                            );
                            return;
                          }
                          if (groupId == null || groupId.toString().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Group ID not found.')),
                            );
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .collection('tasks')
                              .doc(taskId)
                              .collection('submissions')
                              .doc(senderId)
                              .set({
                            'grade': grade,
                            'notes': notes,
                            'status': 'done',
                          }, SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .collection('tasks')
                              .doc(taskId)
                              .update({'status': 'done'});
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(senderId)
                              .collection('notification')
                              .add({
                            'message':
                                'Your task has been accepted and graded by the supervisor.',
                            'type': 'task_accepted',
                            'senderId': FirebaseAuth.instance.currentUser!.uid,
                            'task_id': taskId,
                            'timestamp': FieldValue.serverTimestamp(),
                            'visible': true,
                            'grade': grade,
                            'notes': notes,
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notification')
                              .doc(notifId)
                              .delete();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Task graded and marked as done.')),
                          );
                        },
                      ),
                    );
                  }
                },
                onReject: () async {
                  if (isSupervisorRequest) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('notification')
                        .doc(notifId)
                        .delete();
                  } else if (isTaskSubmission) {
                    final senderId = notif['senderId'];
                    final taskId = notif['task_id'];
                    final rejectNotesController = TextEditingController();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => RejectDialog(
                        notesController: rejectNotesController,
                        onCancel: () => Navigator.pop(context),
                        onReject: () async {
                          final rejectNotes = rejectNotesController.text.trim();
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(senderId)
                              .collection('notification')
                              .add({
                            'message':
                                'Your task has been rejected by the supervisor.' +
                                    (rejectNotes.isNotEmpty
                                        ? '\nNotes: $rejectNotes'
                                        : ''),
                            'type': 'task_rejected',
                            'senderId': FirebaseAuth.instance.currentUser!.uid,
                            'task_id': taskId,
                            'timestamp': FieldValue.serverTimestamp(),
                            'visible': true,
                            'notes': rejectNotes,
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notification')
                              .doc(notifId)
                              .delete();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Task rejected and student notified.')),
                          );
                        },
                      ),
                    );
                  }
                },
                onView: link != null && link.isNotEmpty
                    ? () => _openLink(context, link)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
