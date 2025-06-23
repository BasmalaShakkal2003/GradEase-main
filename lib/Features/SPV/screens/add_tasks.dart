import 'package:flutter/material.dart';

import 'group_details_screen.dart';
import 'task_category_screen.dart';

class AddTasks extends StatefulWidget {
  final String groupName;
  final String groupId;
  const AddTasks({super.key, required this.groupName, required this.groupId});

  @override
  _AddTasksState createState() => _AddTasksState();
}

class _AddTasksState extends State<AddTasks> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Background Image
          Positioned(
            top: screenHeight * 0.02,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.2,
            ),
          ),

          // Content Section
          Column(
            children: [
              SizedBox(height: screenHeight * 0.1),

              // Back Arrow
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          //TODO: Change to GroupsPage
                          builder: (context) => GroupDetailsScreen(
                            groupName: widget.groupName,
                            members: [],
                            groupId: widget.groupId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // Title
              Text(
                "Add Tasks",
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Task Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTaskCard(context, "Front-End", true),
                      SizedBox(height: screenHeight * 0.03),
                      _buildTaskCard(context, "UI/UX", true),
                      SizedBox(height: screenHeight * 0.03),
                      _buildTaskCard(context, "Back-End", true),
                      SizedBox(height: screenHeight * 0.03),
                      _buildTaskCard(context, "AI", true),
                      SizedBox(height: screenHeight * 0.03),
                      _buildTaskCard(context, "Documentation", true),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Background Image
          Positioned(
            bottom: -screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, String title, bool isClickable) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskCategoryScreen(
                groupName: widget.groupName,
                category: title,
                groupId: widget.groupId),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.1,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(width: 1, color: Colors.black),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: screenWidth * 0.04,
              child: Icon(
                Icons.arrow_forward_ios,
                size: screenWidth * 0.04,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
