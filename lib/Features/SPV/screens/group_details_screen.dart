import 'package:flutter/material.dart';
import 'package:grad_ease/Core/Helpers/FireBase/fire_store_group_helper.dart';
import 'package:grad_ease/Features/SPV/main.dart';
import 'chat_screen.dart';
import 'group_info.dart';
import 'view_tasks.dart';
import 'add_tasks.dart';
import 'notes.dart';
import 'add_meeting.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;
  final List<dynamic> members; // Accepts a list of member UIDs
  final String groupId; // Add groupId as a required parameter

  const GroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.members,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          // Top Background Image
          Positioned(
            top: screenHeight * 0.0001,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.2,
            ),
          ),

          // Back Button
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.03,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: screenWidth * 0.07,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              },
            ),
          ),

          // Group Name Title
          Positioned(
            top: screenHeight * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    groupName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Background Image
          Positioned(
            bottom: -screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.3,
            ),
          ),

          // Main Content
          Positioned(
            top: screenHeight * 0.2,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.15,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSection(
                    context,
                    "Group Information",
                    textColor: const Color(0xFF051F2F),
                    bgColor: Colors.white,
                    onTap: () => _onTap(context),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSection(
                    context,
                    "View Tasks",
                    textColor: Colors.white,
                    bgColor: const Color(0xFF093754),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTasks(
                                  groupId: groupId,
                                  groupName: groupName,
                                )),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSection(
                    context,
                    "Add Task",
                    textColor: Colors.white,
                    bgColor: const Color(0xFF051F2F),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTasks(groupName: groupName, groupId: groupId),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSection(
                    context,
                    "Notes",
                    textColor: Colors.white,
                    bgColor: const Color(0xFF093754),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Notes(groupName: groupName, groupId: groupId),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSection(
                    context,
                    "Add Meeting",
                    textColor: Colors.white,
                    bgColor: const Color(0xFF093754),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddMeeting(
                                groupName: groupName, groupId: groupId)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Chat Icon
          Positioned(
            bottom: screenHeight * 0.18,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(groupName: groupName, groupId: groupId)),
                );
              },
              child: Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                child: Image.asset(
                  "assets/icons/chat.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context) async {
    // Fetch member details using fetchGroupMembers
    final memberDetails = await fetchGroupMembersByUids(members);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupInfo(groupName: groupName, students: memberDetails),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title,
      {required Color textColor, required Color bgColor, VoidCallback? onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.7,
        height: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(width: 1, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000).withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: textColor),
        ),
      ),
    );
  }
}
