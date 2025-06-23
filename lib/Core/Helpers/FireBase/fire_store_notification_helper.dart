import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreNotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a notification for a user
  static Future<void> addNotification({
    required String userId,
    required String message,
    required String senderId,
    String type = '',
    bool visible = true,
    String? link, // <-- Add optional link
    String? taskId, // <-- Add optional taskId
  }) async {
    final data = {
      'message': message,
      'type': type,
      'senderId': senderId,
      'visible': visible,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (link != null && link.isNotEmpty) {
      data['link'] = link;
    }
    if (taskId != null && taskId.isNotEmpty) {
      data['task_id'] = taskId;
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notification')
        .add(data);
  }

  /// Get a stream of notifications for a user (ordered by timestamp desc)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notification')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Mark a notification as visible/invisible
  static Future<void> setNotificationVisibility({
    required String userId,
    required String notificationId,
    required bool visible,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notification')
        .doc(notificationId)
        .update({'visible': visible});
  }

  /// Delete a notification
  static Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notification')
        .doc(notificationId)
        .delete();
  }

  /// Get stream of notification count for badge display
  static Stream<int> getNotificationCountStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notification')
        .where('visible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
