import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String task;
  final String description;
  final String requirements;
  final String technologies;
  final String deadline;
  final String assigneeEmail;
  final String? currentUserEmail;
  final VoidCallback? onUploadAllowed;
  final String? grade;

  const TaskCard({
    required this.task,
    required this.description,
    required this.requirements,
    required this.technologies,
    required this.deadline,
    required this.assigneeEmail,
    required this.currentUserEmail,
    this.grade,
    this.onUploadAllowed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAssignee =
        (assigneeEmail).toLowerCase() == (currentUserEmail ?? '').toLowerCase();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Task:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task),
              const SizedBox(height: 5),
              const Text('Description:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
              const SizedBox(height: 5),
              const Text('Requirements:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(requirements),
              const SizedBox(height: 5),
              const Text('Technologies:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(technologies),
              const SizedBox(height: 5),
              const Text('Deadline:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(deadline),
              const SizedBox(height: 5),
              const Text('Assigned to:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(assigneeEmail),
              const SizedBox(height: 5),
              const Text('Grade:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(grade ?? 'N/A'),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (isAssignee) {
                      if (onUploadAllowed != null) onUploadAllowed!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Only the assigned user can upload for this task.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011226),
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Upload'),
                      SizedBox(width: 8),
                      Icon(Icons.send, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
