import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_ease/Features/student/note.dart';

class FirestoreNoteHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a note to the group if the current user is the leader (UID == group['group_id'])
  /// or the supervisor (UID == group['supervisor_id']).
  static Future<void> addNoteToGroup({
    required String groupId,
    required Note note,
    required BuildContext context,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        _showSnackbar(context, "User not logged in.");
        return;
      }

      // Get group document
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        _showSnackbar(context, "Group not found.");
        return;
      }

      final groupData = groupDoc.data();

      final supervisorId = groupData?['supervisor_id']; // Supervisor UID

      // Only allow if current user is the leader or supervisor
      if (currentUserId != supervisorId && currentUserId != groupId) {
        _showSnackbar(
            context, "Only the team leader or supervisor can add notes.");
        return;
      }

      // Add the note to the "notes" subcollection under the group
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('notes')
          .add(note.toJson()..['groupId'] = groupId); // Ensure groupId is saved

      _showSnackbar(context, "Note added successfully.");
    } catch (e) {
      debugPrint("Error adding note: $e");
      _showSnackbar(context, "Failed to add note.");
    }
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<List<Note>> fetchNotesForGroup(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('notes')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      return [];
    }
  }
}
