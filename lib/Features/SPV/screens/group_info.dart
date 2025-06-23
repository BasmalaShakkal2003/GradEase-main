import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final List<Map<String, dynamic>> students;

  const GroupInfo({super.key, required this.groupName, required this.students});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Stack for header and background
            SizedBox(
              height: screenHeight * 0.25,
              child: Stack(
                children: [
                  // Background Layers
                  Positioned(
                    top: -screenHeight * 0.2,
                    left: -screenWidth * 0.1,
                    right: -screenWidth * 0.1,
                    child: Container(
                      height: screenHeight * 0.42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF041C40),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenWidth * 0.4),
                          bottomRight: Radius.circular(screenWidth * 0.4),
                        ),
                      ),
                    ),
                  ),
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
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: screenWidth * 0.07,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // "Group Information" Text
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.15),
                      child: Text(
                        "Group Information",
                        style: TextStyle(
                          fontFamily: 'Source Sans Pro',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Student List
            Flexible(
              child: widget.students.isEmpty
                  ? Center(child: Text("No students found."))
                  : SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        children: widget.students.map((student) {
                          return Container(
                            width: screenWidth * 0.9,
                            // Remove fixed height to allow content to fit
                            margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0x40000000).withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoText(
                                    "Name: ${student["name"] ?? ''}"),
                                _buildInfoText("ID: ${student["id"] ?? ''}"),
                                _buildInfoText(
                                    "Phone: ${student["phone"] ?? ''}"),
                                _buildInfoText(
                                    "Email: ${student["email"] ?? ''}"),
                                _buildInfoText(
                                    "Role: ${student["role"] ?? ''}"),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: screenWidth * 0.04,
        height: 1.0,
        letterSpacing: 0,
      ),
    );
  }
}
