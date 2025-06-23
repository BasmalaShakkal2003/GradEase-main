import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  final String groupId;
  final String status;
  final String? notes;
  final String? grade;
  final String? totalGrade;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
    required this.groupId,
    required this.status,
    this.notes,
    this.grade,
    this.totalGrade,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'task_accepted':
        return Colors.green.shade600;
      case 'task_rejected':
        return Colors.red.shade600;
      case 'task':
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'task_accepted':
        return Icons.check_circle_outline;
      case 'task_rejected':
        return Icons.cancel_outlined;
      case 'task':
      default:
        return Icons.assignment_turned_in_outlined;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'task_accepted':
        return 'Accepted';
      case 'task_rejected':
        return 'Rejected';
      case 'task':
      default:
        return 'Assigned/Updated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.asset(
                'assets/bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Task Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: Image.asset(
                'assets/design2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .collection('tasks')
                  .doc(taskId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Task not found.'));
                }
                final data = snapshot.data!.data()!;
                return Center(
                  child: Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _statusColor(status).withOpacity(0.15),
                                child: Icon(_statusIcon(status),
                                    color: _statusColor(status), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _statusText(status),
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Color(0xFF041C40)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['deadline'] != null
                                      ? data['deadline']
                                          .toString()
                                          .substring(0, 10)
                                      : '',
                                  style: const TextStyle(
                                      fontSize: 15, color: Color(0xFF041C40)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.person,
                                  size: 18, color: Color(0xFF041C40)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['assigneeEmail'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 15, color: Color(0xFF041C40)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1.2),
                          _detailRow('Description', data['description'] ?? '',
                              Icons.description),
                          const SizedBox(height: 10),
                          _detailRow('Requirements', data['requirements'] ?? '',
                              Icons.list_alt),
                          const SizedBox(height: 10),
                          _detailRow('Technologies', data['technologies'] ?? '',
                              Icons.code),
                          const Divider(height: 32, thickness: 1.2),
                          Row(
                            children: [
                              const Icon(Icons.grade,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              Text('Total Grade: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(totalGrade ?? '-',
                                  style: const TextStyle(fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.star,
                                  color: Colors.green, size: 22),
                              const SizedBox(width: 8),
                              Text('Your Grade: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(grade ?? '-',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          if (notes != null && notes!.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.sticky_note_2,
                                      color: Colors.orange, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      notes!,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF041C40), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
