import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../student/note.dart';
import 'attendance.dart';

class MeetingOne extends StatelessWidget {
  final Note note;

  const MeetingOne({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String formattedDate = '';
    try {
      DateTime parsedDate = DateTime.parse(note.date);
      formattedDate = DateFormat('d/M/yyyy').format(parsedDate);
    } catch (e) {
      formattedDate = note.date;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Base Layer
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.08,
            right: -screenWidth * 0.08,
            child: Container(
              width: screenWidth * 1.3,
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

          // Overlay Layer
          Positioned(
            top: -screenHeight * 0.16,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 1.3,
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

          // Attendance Button
          Positioned(
            top: screenHeight * 0.099,
            right: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(
                    note: note,
                    groupName: note
                        .title, // This should be the group name, but you may want to pass the actual group name if available
                    groupId: note.groupId, // Now Note has groupId
                  ),
                ),
              ),
              child: Image.asset(
                "assets/attend.png",
                width: screenWidth * 0.07,
              ),
            ),
          ),

          // Title
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Meeting ${note.title}',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Note Details
          Positioned(
            top: screenHeight * 0.25,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailText('Date: $formattedDate', context),
                SizedBox(height: screenHeight * 0.015),
                _buildDetailText('Meeting: ${note.title}', context),
                SizedBox(height: screenHeight * 0.015),
                _buildDetailText('Meeting Type: ${note.meetingType}', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailText(String text, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
