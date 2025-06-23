import 'package:flutter/material.dart';


import '../../Core/Helpers/FireBase/fire_store_notes_helper.dart';
import 'add_note_screen.dart';
import 'note.dart';
import 'note_details_screen.dart';

//-------------------- Notes Screen -----------------------
class NotesScreen extends StatefulWidget {
  final String groupId;
  const NotesScreen({super.key, required this.groupId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final fetchedNotes =
        await FirestoreNoteHelper.fetchNotesForGroup(widget.groupId);
    setState(() {
      notes = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Notes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? const Center(child: Text("No notes yet"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return NotesCard(
                            meetingTitle: note.title,
                            date: note.date,
                            time: note.time,
                            day: note.day,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteDetailsScreen(note: note.toJson()),
                                ),
                              );
                            },
                          );
                        }),
              ),
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/bgd.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 165,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNoteScreen(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  final note =
                      Note.fromJson(result); // convert the returned map to Note
                  await FirestoreNoteHelper.addNoteToGroup(
                    groupId: widget.groupId,
                    note: note,
                    context: context,
                  );
                  await loadNotes();
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF072A3F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesCard extends StatelessWidget {
  final String meetingTitle;
  final String date;
  final String time;
  final String day;
  final VoidCallback onTap;

  const NotesCard({
    super.key,
    required this.meetingTitle,
    required this.date,
    required this.time,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract day number from date string (e.g., "May 12, 2025" -> "12")
    String dayNumber = '';
    try {
      final dateParts = date.split(' ');
      if (dateParts.length > 1) {
        dayNumber = dateParts[1].replaceAll(',', '');
      }
    } catch (_) {}
    // Use first 3 letters of day in uppercase
    final dayShort =
        day.length >= 3 ? day.substring(0, 3).toUpperCase() : day.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(56),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(56),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dayShort,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dayNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meetingTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
