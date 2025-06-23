import 'package:flutter/material.dart';

//-------------------------Note Details--------------------------
class NoteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // Support both 'note' and 'notes' fields for backward compatibility
    final List<dynamic> notesList = note['notes'] is List
        ? List<String>.from(note['notes'])
        : (note['note'] != null ? note['note'].toString().split('\n') : []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/head2.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 70,
                left: 2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note['date'] ?? 'No date',
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  note['time'] ?? 'No time',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Meeting Number: ',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: note['title'] ?? 'No meeting number',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Meeting Type: ',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: note['type'] ?? 'No meeting type',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Notes:',
              style: TextStyle(
                fontSize: 19,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (notesList.isEmpty)
              const Text(
                'No notes added',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              )
            else
              ...notesList
                  .map((notePoint) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4, right: 8),
                              child: Text("•", style: TextStyle(fontSize: 16)),
                            ),
                            Expanded(
                              child: Text(
                                notePoint.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
