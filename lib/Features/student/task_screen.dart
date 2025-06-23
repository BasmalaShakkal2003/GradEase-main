import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../Core/Helpers/FireBase/fire_store_task_helper.dart';
import 'widgets/task_card.dart';
import 'widgets/task_screen_header.dart';
import 'widgets/task_submission_options_dialog.dart';

class TaskScreen extends StatefulWidget {
  final String title; // This is the category
  const TaskScreen({Key? key, required this.title}) : super(key: key);
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late double screenWidth;
  late double screenHeight;
  String? currentUserEmail;
  String? groupId;

  @override
  void initState() {
    super.initState();
    _initUserAndGroup();
  }

  Future<void> _initUserAndGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    currentUserEmail = user.email;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      groupId = userDoc.data()?['group_id'];
    });
  }

  void _showOptionsDialog(BuildContext context, String taskId) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return TaskSubmissionOptionsDialog(
          groupId: groupId,
          taskId: taskId,
          scaffoldMessengerKey: _scaffoldMessengerKey,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TaskScreenHeader(title: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background Layers
            Positioned(
              top: -screenHeight * 0.2,
              left: -screenWidth * 0.1,
              right: -screenWidth * 0.1,
              child: Container(
                height: screenHeight * 0.41,
                decoration: BoxDecoration(
                  color: const Color(0xFF041C40),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.4),
                    bottomRight: Radius.circular(screenWidth * 0.4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -screenHeight * 0.15,
              left: -screenWidth * 0.1,
              right: -screenWidth * 0.1,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  color: const Color(0xFF011226),
                  borderRadius: BorderRadius.circular(screenWidth * 0.3),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  SizedBox(height: screenHeight * 0.02),
                  if (groupId == null)
                    const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                  else
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (groupId == null) {
                            print(
                                'ERROR: groupId became null unexpectedly within the StreamBuilder logic.');
                            return const Center(
                              child: Text(
                                  'Error: Group ID is missing unexpectedly.',
                                  style: TextStyle(color: Colors.red)),
                            );
                          }
                          return StreamBuilder<List<Task>>(
                            stream: FireStoreTaskHelper.getTasks(groupId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text('No tasks available',
                                      style: TextStyle(color: Colors.black)),
                                );
                              }
                              // Filter by category and exclude tasks with status 'done' (status may be missing/null)
                              final filteredTasks =
                                  snapshot.data!.where((task) {
                                final categoryMatch =
                                    task.category.toLowerCase() ==
                                        widget.title.toLowerCase();
                                // Check status property from Task model
                                final status = task.status;
                                if (status == null) return categoryMatch;
                                return categoryMatch &&
                                    status.toString().toLowerCase() != 'done';
                              }).toList();
                              if (filteredTasks.isEmpty) {
                                return const Center(
                                  child: Text('No tasks available',
                                      style: TextStyle(color: Colors.black)),
                                );
                              }
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04),
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return TaskCard(
                                    task: task.name,
                                    description: task.description,
                                    requirements: task.requirements,
                                    technologies: task.technologies,
                                    deadline: DateFormat('yyyy-MM-dd')
                                        .format(task.deadline),
                                    assigneeEmail: task.assigneeEmail,
                                    currentUserEmail: currentUserEmail,
                                    grade: task.grade,
                                    onUploadAllowed: () =>
                                        _showOptionsDialog(context, task.id),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
