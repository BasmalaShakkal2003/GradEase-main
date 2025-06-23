import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Core/Helpers/FireBase/fire_store_task_helper.dart';
import '../../../Core/Helpers/FireBase/fire_store_notification_helper.dart';
import '../widgets/calender.dart';

class TaskCategoryEditScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String category;
  final Task? task;
  final void Function()? onSaved;
  const TaskCategoryEditScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.category,
    this.task,
    this.onSaved,
  });

  @override
  State<TaskCategoryEditScreen> createState() => _TaskCategoryEditScreenState();
}

class _TaskCategoryEditScreenState extends State<TaskCategoryEditScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _technologiesController = TextEditingController();
  final TextEditingController _setGradController = TextEditingController();

  String _selectedDate = "DD/MM/YYYY";
  List<String> assigneeOptions = [];
  String? selectedAssignee;
  bool _showAssigneeDropdown = false;
  late double screenWidth;
  late double screenHeight;

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _technologiesController.dispose();
    _setGradController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAssigneeEmails();
    // If editing, populate fields
    if (widget.task != null) {
      _taskController.text = widget.task!.name;
      _descriptionController.text = widget.task!.description;
      _requirementsController.text = widget.task!.requirements;
      _technologiesController.text = widget.task!.technologies;
      _setGradController.text = widget.task!.grade;
      _selectedDate = DateFormat('dd/MM/yyyy').format(widget.task!.deadline);
      selectedAssignee = widget.task!.assigneeEmail;
    }
  }

  Future<void> _fetchAssigneeEmails() async {
    List<String> emails = [];
    try {
      // Get member UIDs from the group's members subcollection
      final membersSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('members')
          .get();
      final memberUIDs = membersSnap.docs.map((doc) => doc.id).toList();
      // Add groupId to the memberUIDs list (local only, for group leader)
      if (!memberUIDs.contains(widget.groupId)) {
        memberUIDs.add(widget.groupId);
      }
      // Fetch emails for each member UID
      for (String uid in memberUIDs) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final userData = userDoc.data();
        if (userData != null && userData['email'] != null) {
          emails.add(userData['email']);
        }
      }
      // If editing and the assignee is not in the group, add it to the dropdown
      if (widget.task != null &&
          widget.task!.assigneeEmail.isNotEmpty &&
          !emails.contains(widget.task!.assigneeEmail)) {
        emails.add(widget.task!.assigneeEmail);
      }
      setState(() {
        assigneeOptions = emails;
        if (assigneeOptions.isNotEmpty &&
            (selectedAssignee == null ||
                !assigneeOptions.contains(selectedAssignee))) {
          selectedAssignee = assigneeOptions.first;
        }
      });
    } catch (e) {
      setState(() {
        assigneeOptions = [];
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime currentDate = DateTime.now();
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: screenWidth * 0.8,
            child: MonthPicker(
              selectedDate: currentDate,
              firstDate: DateTime(currentDate.year - 1),
              lastDate: DateTime(currentDate.year + 1),
              onChanged: (date) => Navigator.pop(context, date),
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveTask() async {
    if (_taskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task name is required")),
      );
      return;
    }
    if (_descriptionController.text.isEmpty ||
        _requirementsController.text.isEmpty ||
        _technologiesController.text.isEmpty ||
        _setGradController.text.isEmpty ||
        selectedAssignee == null ||
        _selectedDate == "DD/MM/YYYY") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }
    try {
      final uuid = Uuid();
      final isEdit = widget.task != null;
      final task = Task(
        id: isEdit ? widget.task!.id : uuid.v4(),
        name: _taskController.text,
        description: _descriptionController.text,
        requirements: _requirementsController.text,
        technologies: _technologiesController.text,
        deadline: DateFormat('dd/MM/yyyy').parse(_selectedDate),
        assigneeEmail: selectedAssignee!,
        grade: _setGradController.text,
        category: widget.category,
      );
      if (isEdit) {
        await FireStoreTaskHelper.updateTask(widget.groupId, task);
      } else {
        await FireStoreTaskHelper.addTask(widget.groupId, task);
      }
      // Send notification to the assignee
      try {
        // Fetch the UID of the assignee based on their email
        String? assigneeUid;
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: selectedAssignee)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          assigneeUid = userQuery.docs.first.id;
          print("Assignee UID: $assigneeUid");
        }
        if (assigneeUid != null) {
          await FirestoreNotificationHelper.addNotification(
            userId: assigneeUid,
            message: isEdit
                ? 'Task "${task.name}" was updated in group ${widget.groupName}.'
                : 'You have been assigned a new task "${task.name}" in group ${widget.groupName}.',
            senderId: FirebaseAuth.instance.currentUser!.uid,
            type: 'task',
            taskId: task.id, // <-- Push the task_id to the notification
          );
        }
      } catch (e) {
        // Optionally log or ignore notification errors
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEdit
                  ? 'Task updated successfully'
                  : 'Task added successfully')),
        );
      }
      if (widget.onSaved != null) widget.onSaved!();
      // Wait a moment so the snackbar is visible before popping
      await Future.delayed(const Duration(milliseconds: 400));
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving task: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: screenWidth * 0.04,
          color: const Color(0xFF041C40),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
      TextEditingController controller, double widthRatio, double heightRatio) {
    return Container(
      width: screenWidth * widthRatio,
      height: screenHeight * heightRatio,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(screenWidth * 0.01),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.02),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(fontSize: screenWidth * 0.035),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Deadline:",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF041C40),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Icon(
                Icons.calendar_today,
                size: screenWidth * 0.05,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: screenWidth * 0.4,
          height: screenHeight * 0.04,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Center(
            child: Text(
              _selectedDate,
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneeDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _showAssigneeDropdown = !_showAssigneeDropdown),
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.04,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(screenWidth * 0.01),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    child: Text(
                      selectedAssignee ?? '',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: screenWidth * 0.05),
              ],
            ),
          ),
        ),
        if (_showAssigneeDropdown)
          Container(
            width: screenWidth * 0.5,
            height: screenHeight * 0.2,
            margin: EdgeInsets.only(top: screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              itemCount: assigneeOptions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) => ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  assigneeOptions[index],
                  style: TextStyle(fontSize: screenWidth * 0.035),
                ),
                onTap: () {
                  setState(() {
                    selectedAssignee = assigneeOptions[index];
                    _showAssigneeDropdown = false;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background Layers
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 1.2,
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
          // Back Arrow
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.05,
            left: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                size: screenWidth * 0.07,
                color: Colors.white,
              ),
            ),
          ),
          // Title
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.category,
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Scrollable Content
          Positioned(
            top: screenHeight * 0.22,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("Task:"),
                  _buildCustomTextField(_taskController, 0.8, 0.04),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFieldLabel("Description:"),
                  _buildCustomTextField(_descriptionController, 0.9, 0.1),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFieldLabel("Requirements:"),
                  _buildCustomTextField(_requirementsController, 0.9, 0.12),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFieldLabel("Technologies:"),
                  _buildCustomTextField(_technologiesController, 0.7, 0.06),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDeadlineSection(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFieldLabel("Assignees:"),
                  _buildAssigneeDropdown(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFieldLabel("Set Grade"),
                  _buildCustomTextField(_setGradController, 0.4, 0.04),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: Container(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(
                        color: const Color(0xFF011226),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.04),
                          ),
                        ),
                        child: Text(
                          widget.task == null ? "Create" : "Save Changes",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
