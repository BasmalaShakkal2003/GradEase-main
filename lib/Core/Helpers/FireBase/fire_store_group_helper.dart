import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Features/student/done_successfully_screen.dart';

Future<void> createGroup({
  required String field,
  required String description,
  required String requirements,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('No authenticated user found.');
  }

  final groupData = {
    'field': field,
    'description': description,
    'requirements': requirements,
  };

  try {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(user.uid)
        .set(groupData);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'group_id': user.uid,
    });

    print('Group created with UID as document ID.');
  } catch (e) {
    print('Failed to create group: $e');
    rethrow;
  }
}

Future<void> addMemberToGroup({
  required BuildContext context,
  required String groupId,
  required String memberId,
}) async {
  final firestore = FirebaseFirestore.instance;
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (FirebaseAuth.instance.currentUser!.uid.toString() != groupId) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
          content: Text("You Must be the Group Leader to add members.")),
    );
    return;
  }
  try {
    // Step 1: Check if a user with the given ID exists
    final userQuery = await firestore
        .collection('users')
        .where('id', isEqualTo: memberId)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("No user found with that ID.")),
      );
      return;
    }

    final userDoc = userQuery.docs.first;
    final userUid = userDoc.id;
    final userData = userDoc.data();

    // Step 2: Check if the user is already part of another group
    final existingGroupId = userData['group_id'];
    if (existingGroupId != null && existingGroupId.toString().isNotEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("This user has already joined a group.")),
      );
      return;
    }

    // Step 3: Add the user to this group’s members subcollection
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userUid)
        .set({
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Step 4: Update user's group_id field to reflect group membership
    await firestore.collection('users').doc(userUid).update({
      'group_id': groupId,
    });

    // Step 5: Navigate and notify success
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoneSuccessfullyScreen(),
      ),
    );

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text("User successfully added to the group.")),
    );
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("An error occurred: ${e.toString()}")),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchGroupMembersByUids(
    List<dynamic> memberUids) async {
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> members = [];
  for (final uid in memberUids) {
    final userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      data['uid'] = userDoc.id;
      // Mark as leader if group_id == uid
      if (data['group_id'] == uid) {
        data['role'] = 'Leader';
        data['isLeader'] = true;
      } else {
        data['role'] = 'Member';
        data['isLeader'] = false;
      }
      members.add(data);
    }
  }
  return members;
}

Future<List<Map<String, dynamic>>> fetchGroupMembers() async {
  final firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) return [];

  final userDoc =
      await firestore.collection('users').doc(currentUser.uid).get();
  final groupId = userDoc.data()?['group_id'];

  if (groupId == null || groupId.toString().isEmpty) return [];

  List<Map<String, dynamic>> members = [];

  try {
    // ✅ Step 1: Add the group leader (whose UID == groupId)
    final leaderDoc = await firestore.collection('users').doc(groupId).get();
    if (leaderDoc.exists) {
      final leaderData = leaderDoc.data()!;
      leaderData['uid'] = leaderDoc.id;
      leaderData['role'] = 'Leader'; // Mark as leader
      leaderData['isLeader'] = true;
      members.add(leaderData);
    }

    // ✅ Step 2: Get other members (exclude leader from this query)
    final memberDocs = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();

    for (var memberDoc in memberDocs.docs) {
      if (memberDoc.id == groupId)
        continue; // skip leader if accidentally included

      final userData =
          await firestore.collection('users').doc(memberDoc.id).get();
      if (userData.exists) {
        final data = userData.data()!;
        data['uid'] = userData.id;
        data['role'] = 'Member'; // Mark as member
        data['isLeader'] = false;
        members.add(data);
      }
    }

    print("Members: $members");
    return members;
  } catch (e) {
    print('Error fetching group members: $e');
    return [];
  }
}

Future<void> removeMemberFromGroup(
    String memberUid, BuildContext context) async {
  final firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    // Fetch the current user's group ID
    final userDoc =
        await firestore.collection('users').doc(currentUser.uid).get();
    final groupId = userDoc.data()?['group_id'];

    if (groupId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("You are not part of any group.")),
      );
      return;
    }

    // Check if the current user is the leader of the group
    if (currentUser.uid == groupId) {
      // Fetch all members of the group
      final memberDocs = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get();

      if (memberUid == currentUser.uid) {
        // If the leader is trying to delete themselves
        if (memberDocs.docs.isNotEmpty) {
          // If there are still members in the group, show a SnackBar
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                  "You cannot delete yourself as the leader while there are members in the group. Please remove all members first."),
            ),
          );
          return;
        } else {
          // If no members are left, delete the group
          await firestore.collection('groups').doc(groupId).delete();
          await firestore.collection('users').doc(currentUser.uid).update({
            'group_id': null,
          });

          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text("Group deleted successfully.")),
          );
          return;
        }
      }
    }

    // If the user is not the leader or is removing a normal member
    final memberDoc = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(memberUid)
        .get();

    if (!memberDoc.exists) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Member not found in the group.")),
      );
      return;
    }

    // Remove the member from the group's members subcollection
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(memberUid)
        .delete();

    // Update the member's group_id field to null
    await firestore
        .collection('users')
        .doc(memberUid)
        .update({'group_id': null});

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text("Member removed successfully.")),
    );
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("An error occurred: ${e.toString()}")),
    );
  }
}
