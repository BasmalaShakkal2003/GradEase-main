import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'group_details_screen.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final groupIds = userDoc.data()?['group_id'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> groupsList = [];
    for (var groupId in groupIds) {
      if (groupId == null || groupId.toString().isEmpty) continue;
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();
      if (groupDoc.exists) {
        final groupData = groupDoc.data() ?? {};
        // Fetch members UIDs from the 'members' subcollection
        final membersSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('members')
            .get();
        final memberUids = membersSnapshot.docs.map((doc) => doc.id).toList();

        // Ensure the group leader (groupId) is included in the members list (local only)
        List<String> allMembers = List<String>.from(memberUids);
        if (!allMembers.contains(groupId)) {
          allMembers.insert(0, groupId);
        }

        groupsList.add({
          'id': groupDoc.id,
          'name': groupData['name'] ?? groupDoc.id,
          'members': allMembers,
          'membersCount': allMembers.length,
        });
      }
    }
    return groupsList;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Base Layer
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF041C40),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenWidth * 0.4),
                  bottomRight: Radius.circular(screenWidth * 0.4),
                ),
              ),
            ),
          ),

          // Overlay Layer
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
            top: screenHeight * 0.099,
            left: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: screenWidth * 0.07,
                color: Colors.white,
              ),
            ),
          ),

          // "Groups" Text
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.14),
              child: Text(
                "Groups",
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Group List
          Positioned.fill(
            top: screenHeight * 0.25,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No groups found.'));
                }
                final groups = snapshot.data!;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: groups.map((group) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailsScreen(
                                groupId: group["id"],
                                groupName: group["name"],
                                members: group["members"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.11,
                          margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                            border: Border.all(
                              color: const Color.fromARGB(255, 15, 15, 15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Group Name
                              Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  group["name"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Group Icon & Number of Members
                              Positioned(
                                bottom: screenHeight * 0.0005,
                                right: screenWidth * 0.02,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.group,
                                      size: screenWidth * 0.05,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      "${group["membersCount"]} members",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
