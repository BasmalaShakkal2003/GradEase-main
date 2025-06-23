import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'task_submission_button.dart';
import 'insert_link_dialog.dart';

class TaskSubmissionOptionsDialog extends StatelessWidget {
  final String? groupId;
  final String taskId;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const TaskSubmissionOptionsDialog({
    super.key,
    required this.groupId,
    required this.taskId,
    required this.scaffoldMessengerKey,
  });

  Future<void> _handleUpload(BuildContext context) async {
    Navigator.pop(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    bool fileSelected = false;
    bool readError = false;
    bool saveSuccessful = false;
    String errorMessage = '';
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        fileSelected = true;
        final file = result.files.single;
        final fileBytes = file.bytes;
        final fileName = file.name;
        if (fileBytes == null) {
          readError = true;
        } else {
          try {
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .collection('tasks')
                .doc(taskId)
                .collection('submissions')
                .doc(user.uid)
                .set({
              'submissionFile': fileName,
              'submissionFilePath': file.path,
              'submittedBy': user.email,
              'timestamp': Timestamp.now(),
              'method': 'upload',
              'date': DateTime.now().toIso8601String(),
            });
            saveSuccessful = true;
            final groupDoc = await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .get();
            final supervisorId = groupDoc.data()?['supervisor_id'];
            if (supervisorId != null && supervisorId.toString().isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(supervisorId)
                  .collection('notification')
                  .add({
                'message': '${user.email ?? 'A student'} has submitted a task.',
                'type': 'task_submission',
                'senderId': user.uid,
                'link': file.path ?? '',
                'task_id': taskId,
                'timestamp': FieldValue.serverTimestamp(),
                'visible': true,
              });
            }
          } catch (e) {
            errorMessage = 'Error saving file: ${e.toString()}';
          }
        }
      }
      Future.microtask(() {
        if (!fileSelected) {
          scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(content: Text('No file selected.')));
        } else if (readError) {
          scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(content: Text('Could not read file bytes.')));
        } else if (saveSuccessful) {
          scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(content: Text('File uploaded successfully.')));
        } else if (errorMessage.isNotEmpty) {
          scaffoldMessengerKey.currentState
              ?.showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      });
    } catch (e) {
      Future.microtask(() {
        scaffoldMessengerKey.currentState
            ?.showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      });
    }
  }

  Future<void> _handleDrive(BuildContext context) async {
    Navigator.pop(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    bool fileSelected = false;
    bool saveSuccessful = false;
    String errorMessage = '';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        fileSelected = true;
        final file = result.files.single;
        try {
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .collection('tasks')
              .doc(taskId)
              .collection('submissions')
              .doc(user.uid)
              .set({
            'submissionFile': file.name,
            'submissionFilePath': file.path,
            'submittedBy': user.email,
            'timestamp': Timestamp.now(),
            'method': 'drive',
            'date': DateTime.now().toIso8601String(),
          });
          saveSuccessful = true;
          final groupDoc = await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .get();
          final supervisorId = groupDoc.data()?['supervisor_id'];
          if (supervisorId != null && supervisorId.toString().isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(supervisorId)
                .collection('notification')
                .add({
              'message':
                  '${user.email ?? 'A student'} has submitted a task via Drive.',
              'type': 'task_submission',
              'senderId': user.uid,
              'link': file.path ?? '',
              'task_id': taskId,
              'timestamp': FieldValue.serverTimestamp(),
              'visible': true,
            });
          }
        } catch (e) {
          errorMessage = 'Error saving file: ${e.toString()}';
        }
      }
      Future.microtask(() {
        if (!fileSelected) {
          // Do nothing if no file selected
        } else if (saveSuccessful) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
                content: Text(
                    'File picked from Google Drive or device. For a shareable link, use Insert Link option.')),
          );
        } else if (errorMessage.isNotEmpty) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      });
    } catch (e) {
      Future.microtask(() {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      });
    }
  }

  Future<void> _handleInsertLink(BuildContext context) async {
    Navigator.pop(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    TextEditingController linkController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return InsertLinkDialog(
          controller: linkController,
          onCancel: () => Navigator.pop(context),
          onSubmit: () async {
            final link = linkController.text.trim();
            final uri = Uri.tryParse(link);
            Navigator.pop(context);
            if (link.isEmpty ||
                uri == null ||
                !(uri.isAbsolute &&
                    (link.startsWith('http://') ||
                        link.startsWith('https://')))) {
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                    content: Text(
                        'Please enter a valid link (must start with http/https).')),
              );
              return;
            }
            try {
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .collection('tasks')
                  .doc(taskId)
                  .collection('submissions')
                  .doc(user.uid)
                  .set({
                'submissionFile': link,
                'submissionFilePath': link,
                'submittedBy': user.email,
                'timestamp': Timestamp.now(),
                'method': 'link',
                'date': DateTime.now().toIso8601String(),
              });
              final groupDoc = await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .get();
              final supervisorId = groupDoc.data()?['supervisor_id'];
              if (supervisorId != null && supervisorId.toString().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(supervisorId)
                    .collection('notification')
                    .add({
                  'message':
                      '${user.email ?? 'A student'} has submitted a task via link.',
                  'type': 'task_submission',
                  'senderId': user.uid,
                  'link': link,
                  'task_id': taskId,
                  'timestamp': FieldValue.serverTimestamp(),
                  'visible': true,
                });
              }
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('Link submitted successfully.')),
              );
            } catch (e) {
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text('Error submitting link: $e')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose an Option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskSubmissionButton(
            label: 'Upload',
            onPressed: () => _handleUpload(context),
          ),
          const SizedBox(height: 10),
          TaskSubmissionButton(
            label: 'Add From Drive',
            onPressed: () => _handleDrive(context),
          ),
          const SizedBox(height: 10),
          TaskSubmissionButton(
            label: 'Insert link',
            onPressed: () => _handleInsertLink(context),
          ),
        ],
      ),
    );
  }
}
