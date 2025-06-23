import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/Helpers/FireBase/fire_store_task_helper.dart';

class UIUXScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String category;

  // This screen now works with all categories, not just UI/UX
  // But we're keeping the class name for backward compatibility
  const UIUXScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.category,
  }) : super(key: key);

  @override
  _UIUXScreenState createState() => _UIUXScreenState();
}

class _UIUXScreenState extends State<UIUXScreen> {
  late double screenWidth;
  late double screenHeight;
  List<Task> _tasksWithSubmissions = [];
  Map<String, Map<String, dynamic>> _submissionDetails = {};
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchTasksWithSubmissions();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here if needed
  }

  Future<void> _fetchTasksWithSubmissions() async {
    // Get stream of tasks for the given category
    FireStoreTaskHelper.getTasks(widget.groupId).listen((tasks) async {
      // Filter tasks by category
      final categoryTasks =
          tasks.where((t) => t.category == widget.category).toList();

      // Check each task for submissions
      List<Task> tasksWithSubmissions = [];
      Map<String, Map<String, dynamic>> submissionDetails = {};

      for (final task in categoryTasks) {
        final submissionsSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('tasks')
            .doc(task.id)
            .collection('submissions')
            .orderBy('timestamp', descending: true)
            .get();

        if (submissionsSnapshot.docs.isNotEmpty) {
          tasksWithSubmissions.add(task);

          // Get the most recent submission
          final submission = submissionsSnapshot.docs.first.data();
          final submissionId = submissionsSnapshot.docs.first.id;

          // Get detailed information from the submission
          submissionDetails[task.id] = {
            'submissionId': submissionId,
            'submittedBy': submission['submittedBy'] ?? 'Unknown',
            'submissionDate': submission['date'] != null
                ? DateFormat('MMM d, yyyy')
                    .format(DateTime.parse(submission['date']))
                : 'Unknown date',
            'grade': submission['grade'] ?? 'Not graded yet',
            'notes': submission['notes'] ?? '',
            'method': submission['method'] ?? 'unknown',
            'submissionLink': submission['submissionFilePath'] ?? ''
          };
        }
      }

      if (mounted) {
        setState(() {
          _tasksWithSubmissions = tasksWithSubmissions;
          _submissionDetails = submissionDetails;
          _loading = false;
        });
      }
    });
  }

  Future<void> _viewSubmission(BuildContext context, Task task) async {
    try {
      // Check if we already have the submission details cached
      if (_submissionDetails.containsKey(task.id)) {
        final details = _submissionDetails[task.id]!;
        final submissionId = details['submissionId'];
        final submittedBy = details['submittedBy'];
        final submissionDate = details['submissionDate'];
        final submissionMethod = details['method'] ?? 'unknown';
        final submissionLink = details['submissionLink'] ?? '';
        final submissionGrade = details['grade'];
        final submissionNotes = details['notes'] ?? '';

        // Show the dialog with the cached details
        _showSubmissionDetailsDialog(
            context,
            task,
            submissionId,
            submittedBy,
            submissionDate,
            submissionMethod,
            submissionLink,
            submissionGrade,
            submissionNotes);
        return;
      }

      // If not cached, fetch submission details
      final submissionSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('tasks')
          .doc(task.id)
          .collection('submissions')
          .orderBy('timestamp', descending: true)
          .get();

      if (submissionSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No submission found')),
        );
        return;
      }

      // Get the most recent submission
      final submissionDoc = submissionSnapshot.docs.first;
      final submission = submissionDoc.data();
      final submissionId = submissionDoc.id;
      final submissionMethod = submission['method'] ?? 'unknown';
      final submissionLink = submission['submissionFilePath'] ?? '';
      final submittedBy = submission['submittedBy'] ?? 'Unknown';
      final submissionDate = submission['date'] != null
          ? DateFormat('MMM d, yyyy').format(DateTime.parse(submission['date']))
          : 'Unknown date';

      // Get the submission grade if it exists (might be null)
      final submissionGrade = submission['grade'] ?? 'Not graded yet';
      final submissionNotes = submission['notes'] ?? '';

      // Show the dialog with the fetched details
      _showSubmissionDetailsDialog(
          context,
          task,
          submissionId,
          submittedBy,
          submissionDate,
          submissionMethod,
          submissionLink,
          submissionGrade,
          submissionNotes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing submission: $e')),
      );
    }
  }

  // Helper method to show submission details dialog
  void _showSubmissionDetailsDialog(
      BuildContext context,
      Task task,
      String submissionId,
      String submittedBy,
      String submissionDate,
      String submissionMethod,
      String submissionLink,
      String submissionGrade,
      String submissionNotes) {
    final TextEditingController gradeController = TextEditingController(
        text: submissionGrade != 'Not graded yet' ? submissionGrade : '');
    final TextEditingController notesController =
        TextEditingController(text: submissionNotes);
    bool isLink = submissionMethod == 'link';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Task: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: task.name),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Submitted by: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: submittedBy),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Submission date: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: submissionDate),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Submission method: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: submissionMethod),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (submissionLink.isNotEmpty)
                InkWell(
                  onTap: () async {
                    if (isLink) {
                      final uri = Uri.tryParse(submissionLink);
                      if (uri != null) {
                        // Open the link
                        await launchUrl(uri);
                      }
                    } else {
                      // Simulate download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading File...')),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(isLink ? Icons.link : Icons.download,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isLink
                              ? 'Open Submission Link'
                              : 'Download Submission File',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: 'Update Submission Grade',
                  border: OutlineInputBorder(),
                  hintText: 'Enter grade for this submission',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add notes for this submission',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Task original grade: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: task.grade.isEmpty ? 'Not graded' : task.grade,
                      style: TextStyle(
                        color: task.grade.isEmpty
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF011226),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newGrade = gradeController.text.trim();
              final newNotes = notesController.text.trim();
              if (newGrade.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grade is required.')),
                );
                return;
              }
              final int? gradeValue = int.tryParse(newGrade);
              final int? maxGrade = int.tryParse(task.grade);
              if (gradeValue != null &&
                  maxGrade != null &&
                  gradeValue > maxGrade) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Submission grade cannot exceed the original task grade ($maxGrade).')),
                );
                return;
              }
              // Update grade and notes in Firestore
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('tasks')
                  .doc(task.id)
                  .collection('submissions')
                  .doc(submissionId)
                  .update({
                'grade': newGrade,
                'notes': newNotes,
                'status': 'done',
              });
              // Send notification to the student who submitted
              //          final assigneeId = assigneeQuery.docs.first.id;
              final assigneeQuery = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: task.assigneeEmail)
                  .limit(1)
                  .get();
              if (assigneeQuery.docs.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(assigneeQuery.docs.first.id)
                    .collection('notification')
                    .add({
                  'message':
                      'Your submission for "${task.name}" has been graded.',
                  'type': 'task_accepted',
                  'senderId': FirebaseAuth.instance.currentUser!.uid,
                  'task_id': task.id,
                  'timestamp': FieldValue.serverTimestamp(),
                  'visible': true,
                  'grade': newGrade,
                  'notes': newNotes,
                  'group_id': widget.groupId,
                });

                Navigator.pop(context);
                // Optionally, you can refresh the list
                _fetchTasksWithSubmissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submission grade updated.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Background Image
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.2,
            ),
          ),

          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: screenHeight * 0.15),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.08),

                  // Back Arrow
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.05),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: screenWidth * 0.07),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Title
                  Text(
                    "${widget.category} ",
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Task List
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _tasksWithSubmissions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: screenHeight * 0.2),
                                      child: Text(
                                        'No ${widget.category} tasks with submissions found',
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            color: Colors.black54),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _tasksWithSubmissions.length,
                                    itemBuilder: (context, index) {
                                      final task = _tasksWithSubmissions[index];
                                      return _buildTaskCard(context, task);
                                    },
                                  ),
                        SizedBox(height: screenHeight * 0.15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Background Image
          Positioned(
            bottom: -screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.3,
            ),
          ),

          // Custom Navigation Bar
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(width: 1, color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title and Grade Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF011226),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: task.grade.isEmpty
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.grade.isEmpty
                        ? 'Not Graded'
                        : 'Task Grade: ${task.grade}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w500,
                      color: task.grade.isEmpty
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),

            // Task Details
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Assigned to: ${task.assigneeEmail}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.008),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text(
                  'Deadline: ${DateFormat('MMM d, yyyy').format(task.deadline)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            // Submission Details Section
            if (_submissionDetails.containsKey(task.id)) ...[
              SizedBox(height: screenHeight * 0.015),
              Divider(color: Colors.grey.withOpacity(0.3)),
              SizedBox(height: screenHeight * 0.01),

              Text(
                'Submission Details',
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF011226),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Submitted by: ${_submissionDetails[task.id]!['submittedBy']}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.008),

              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    'Date: ${_submissionDetails[task.id]!['submissionDate']}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.008),

              // Submission Grade Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _submissionDetails[task.id]!['grade'] == 'Not graded yet'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _submissionDetails[task.id]!['grade'] ==
                            'Not graded yet'
                        ? Colors.orange.shade300
                        : Colors.blue.shade300,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Submission Grade: ${_submissionDetails[task.id]!['grade']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: _submissionDetails[task.id]!['grade'] ==
                            'Not graded yet'
                        ? Colors.orange.shade800
                        : Colors.blue.shade800,
                  ),
                ),
              ),
            ],

            // View Button
            SizedBox(height: screenHeight * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _viewSubmission(context, task),
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('View Submission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011226),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
