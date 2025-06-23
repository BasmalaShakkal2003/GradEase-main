import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../student/note.dart';
import 'done.dart';

class AttendanceScreen extends StatefulWidget {
  final Note note;
  final String groupName;
  final String groupId; // Add groupId

  const AttendanceScreen({
    Key? key,
    required this.note,
    required this.groupName,
    required this.groupId, // Add groupId
  }) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _addAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      setState(() {
        _errorMessage = 'Student ID cannot be empty.';
        _isLoading = false;
      });
      return;
    }
    try {
      // First find the user with this ID to verify they exist and belong to this group
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: studentId)
          .get();

      if (usersQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Student ID not found in the system.';
          _isLoading = false;
        });
        return;
      }

      final userDoc = usersQuery.docs.first;
      final userData = userDoc.data();
      final userGroupId = userData['group_id'];
      final userName = userData['username'] ?? 'Unknown';
      final userUid = userDoc.id;

      // Check if user belongs to the same group as the note
      if (userGroupId != widget.groupId) {
        setState(() {
          _errorMessage = 'This student does not belong to this group.';
          _isLoading = false;
        });
        return;
      }

      // Use groupId directly
      final groupId = widget.groupId;
      // Find the note by title and date
      final notesQuery = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('notes')
          .where('title', isEqualTo: widget.note.title)
          .where('date', isEqualTo: widget.note.date)
          .get();

      if (notesQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Meeting note not found.';
          _isLoading = false;
        });
        return;
      }

      final noteDoc = notesQuery.docs.first;
      // Add attendance record with more user details
      await noteDoc.reference.collection('attendance').doc(studentId).set({
        'studentId': studentId,
        'userId': userUid,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _successMessage = 'Attendance added for $userName!';
        _isLoading = false;
        _studentIdController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Base Layer
          Positioned(
            top: -screenHeight * 0.17,
            left: -screenWidth * 0.08,
            right: -screenWidth * 0.08,
            child: Container(
              width: screenWidth * 1.3,
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
            top: screenHeight * 0.1,
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

          // Title
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Attendance",
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Insert Student's ID Text
          Positioned(
            top: screenHeight * 0.3,
            left: screenWidth * 0.05,
            child: Text(
              'Insert Student’s ID',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF041C40),
              ),
            ),
          ),

          // Student ID TextField
          Positioned(
            top: screenHeight * 0.34,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: TextField(
                controller: _studentIdController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  hintText: 'Enter Student ID',
                ),
              ),
            ),
          ),

          // Add Button
          Positioned(
            bottom: screenHeight * 0.12,
            left: screenWidth * 0.25,
            right: screenWidth * 0.25,
            child: Column(
              children: [
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                if (_successMessage != null)
                  Text(_successMessage!, style: TextStyle(color: Colors.green)),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF041C40),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.07),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
