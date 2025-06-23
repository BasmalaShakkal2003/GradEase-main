import 'package:firebase_auth/firebase_auth.dart';
import '../../Core/Helpers/FireBase/fire_store_notification_helper.dart';

/// Helper class for testing notification functionality
class NotificationTestHelper {
  /// Add a test notification to the current user
  static Future<void> addTestNotification({
    String message = "Test notification",
    String type = "general",
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreNotificationHelper.addNotification(
        userId: user.uid,
        message: message,
        senderId: "system",
        type: type,
        visible: true,
      );
    }
  }

  /// Add multiple test notifications
  static Future<void> addMultipleTestNotifications(int count) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (int i = 1; i <= count; i++) {
        await FirestoreNotificationHelper.addNotification(
          userId: user.uid,
          message: "Test notification #$i",
          senderId: "system",
          type: "test",
          visible: true,
        );
      }
    }
  }

  /// Clear all test notifications
  static Future<void> clearTestNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // This would require additional implementation in the helper
      // For now, users can manually dismiss notifications in the UI
    }
  }
}
