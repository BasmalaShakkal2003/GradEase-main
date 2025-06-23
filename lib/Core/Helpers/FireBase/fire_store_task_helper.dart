import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final String description;
  final String requirements;
  final String technologies;
  final DateTime deadline;
  final String assigneeEmail;
  final String grade;
  final String category;
  final String? status;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.requirements,
    required this.technologies,
    required this.deadline,
    required this.assigneeEmail,
    required this.grade,
    required this.category,
    this.status,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'name': name,
      'description': description,
      'requirements': requirements,
      'technologies': technologies,
      'deadline': deadline.toIso8601String(),
      'assigneeEmail': assigneeEmail,
      'grade': grade,
      'category': category,
    };
    if (status != null) map['status'] = status!;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      technologies: map['technologies'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      assigneeEmail: map['assigneeEmail'] ?? '',
      grade: map['grade'] ?? '',
      category: map['category'] ?? '',
      status: map['status'],
    );
  }
}

class FireStoreTaskHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validate if user exists in users collection
  static Future<bool> userExists(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Add a task to a group
  static Future<void> addTask(String groupId, Task task) async {
    if (!await userExists(task.assigneeEmail)) {
      throw Exception('Assignee email does not exist in users collection');
    }
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  // Update a task
  static Future<void> updateTask(String groupId, Task task) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  // Delete a task
  static Future<void> deleteTask(String groupId, String taskId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Get all tasks for a group
  static Stream<List<Task>> getTasks(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  // Get a single task
  static Future<Task?> getTask(String groupId, String taskId) async {
    final doc = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .get();
    if (doc.exists) {
      return Task.fromMap(doc.data()!);
    }
    return null;
  }
}
