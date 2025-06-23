import 'package:flutter/material.dart';
import 'submitted_tasks.dart';

class ViewTasks extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ViewTasks({super.key, required this.groupId, required this.groupName});

  @override
  _ViewTasksState createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> {
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
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.2,
            ),
          ),

          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: screenHeight * 0.15),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.08),

                  // Back Arrow
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.05),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: screenWidth * 0.07),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Title
                  Text(
                    "View Tasks",
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Task List
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        _buildTaskCard(context, "Front-End"),
                        SizedBox(height: screenHeight * 0.03),
                        _buildTaskCard(context, "UI/UX"),
                        SizedBox(height: screenHeight * 0.03),
                        _buildTaskCard(context, "Back-End"),
                        SizedBox(height: screenHeight * 0.03),
                        _buildTaskCard(context, "AI"),
                        SizedBox(height: screenHeight * 0.03),
                        _buildTaskCard(context, "Documentation"),
                        SizedBox(height: screenHeight * 0.15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildTaskCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        // Navigate to UIUXScreen for all categories - showing tasks with submissions
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UIUXScreen(
              groupId: widget.groupId,
              groupName: widget.groupName,
              category: title,
            ),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.1,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
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
              child: Icon(Icons.arrow_forward_ios,
                  size: screenWidth * 0.04, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
