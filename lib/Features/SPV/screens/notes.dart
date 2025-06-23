import 'package:flutter/material.dart';

import '../../../Core/Helpers/FireBase/fire_store_notes_helper.dart';
import '../../student/note.dart';
import 'attendance_progress.dart';
import 'group_details_screen.dart';
import 'meeting_one.dart';

class Notes extends StatefulWidget {
  final String groupId; // The Firestore document ID for the group
  final String groupName;
  const Notes({Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes(widget.groupId); // Always use the groupId passed as parameter
  }

  Future<void> _loadNotes(String groupId) async {
    final fetchedNotes = await FirestoreNoteHelper.fetchNotesForGroup(groupId);
    setState(() {
      _notes = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Top Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          // Progress Icon
          Positioned(
            top: screenHeight * 0.13,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceProgress(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                    ),
                  ),
                );
              },
              child: Image.asset(
                "assets/progress.png",
                width: screenWidth * 0.1,
              ),
            ),
          ),

          // Bottom Background Image
          Positioned(
            bottom: -screenHeight * 0.06,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.3,
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.01,
            left: screenWidth * 0.04,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  size: screenWidth * 0.08, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
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

          // Title
          Positioned(
            top: screenHeight * 0.13,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Notes",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Content Area
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.15,
            bottom: screenHeight * 0.1,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: _notes.isEmpty
                ? const Center(child: Text("No notes yet"))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(_notes[index], context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingOne(note: note),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.15,
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(screenWidth * 0.15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        note.day,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        note.date,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.07),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Meeting: ${note.title}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          note.author,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF50555C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.015,
              right: screenWidth * 0.05,
              child: Text(
                note.time,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
