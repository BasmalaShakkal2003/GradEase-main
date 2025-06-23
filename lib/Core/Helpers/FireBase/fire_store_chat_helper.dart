import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreChatHelper {
  static Future<void> sendGroupMessage({
    required String groupId,
    required String text,
    required String senderType, // 'dr_chat' or 'group_chat'
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final senderName = userDoc['name'] ?? 'Unknown';

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': uid,
      'senderName': senderName,
      'timestamp': Timestamp.now(),
      'type': senderType,
    });
  }

  static Stream<QuerySnapshot> getGroupMessagesStream(String groupId,
      {String? type}) {
    var ref = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false);
    if (type != null) {
      return ref.where('type', isEqualTo: type).snapshots();
    }
    return ref.snapshots();
  }
}
