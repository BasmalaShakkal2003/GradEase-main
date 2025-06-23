import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ----------------------------------Add Note---------------------------------
class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _meetingNumberController =
      TextEditingController();
  final TextEditingController _meetingTypeController = TextEditingController();
  final TextEditingController _notePointController = TextEditingController();
  String _selectedDate = DateFormat('MMM d, yyyy').format(DateTime.now());
  late String _selectedTime;
  final List<String> _notesPoints = [];

  @override
  void initState() {
    super.initState();
    _selectedTime = DateFormat('hh:mm a').format(DateTime.now());
  }

  Future<void> _showEditOptions(BuildContext context) async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF011226),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(69),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDialogOption('Edit Date', 'date'),
              const SizedBox(height: 12),
              _buildDialogOption('Edit Time', 'time'),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF0F5C8C),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (option == 'date') {
      // ignore: use_build_context_synchronously
      await _selectDate(context);
    } else if (option == 'time') {
      // ignore: use_build_context_synchronously
      await _selectTime(context);
    }
  }

  Widget _buildDialogOption(String text, String value) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF011226),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => Navigator.pop(context, value),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF0F5C8C),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0F5C8C),
              onPrimary: Colors.white,
              surface: Color(0xFF011226),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0F5C8C),
              onPrimary: Colors.white,
              surface: Color(0xFF011226),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF011226),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(69),
              ),
              dialHandColor: const Color(0xFF0F5C8C),
              hourMinuteColor: const Color(0xFF0F5C8C),
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: const Color(0xFF0F5C8C),
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context);
      });
    }
  }

  void _addNotePoint() {
    final text = _notePointController.text.trim();
    if (text.isNotEmpty && text != '.') {
      setState(() {
        _notesPoints.add(text);
        _notePointController.clear();
      });
    }
  }

  void _removeNotePoint(int index) {
    setState(() {
      _notesPoints.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _textField("Meeting Number",
                      controller: _meetingNumberController),
                  const SizedBox(height: 20),
                  _textField("Meeting Type",
                      controller: _meetingTypeController),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Notes:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._notesPoints
                          .map((point) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(top: 4, right: 8),
                                      child: Text("•",
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => _removeNotePoint(
                                          _notesPoints.indexOf(point)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4, right: 8),
                            child: Text("•", style: TextStyle(fontSize: 16)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _notePointController,
                              decoration: const InputDecoration(
                                hintText: "Add a point...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintStyle: TextStyle(fontSize: 16),
                              ),
                              style: const TextStyle(fontSize: 16),
                              maxLines: null,
                              onSubmitted: (_) => _addNotePoint(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add,
                                size: 20, color: Color(0xFF011226)),
                            onPressed: _addNotePoint,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 250),
                      _DoneButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditOptions(context),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Stack(
          children: [
            Image.asset(
              'assets/head2.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Positioned(
              top: 70,
              left: 2,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Text(
                    _selectedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, {required TextEditingController controller}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _DoneButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            if (_meetingNumberController.text.isNotEmpty) {
              try {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();
                  final authorName = userDoc.data()?['name'] ?? 'Unknown';

                  final newNote = {
                    'day': DateFormat('EEEE').format(DateTime.now()),
                    'date': _selectedDate,
                    'title': _meetingNumberController.text,
                    'author': authorName,
                    'time': _selectedTime,
                    'type': _meetingTypeController.text,
                    'notes': _notesPoints
                        .where((e) => e.trim().isNotEmpty && e != '.')
                        .toList(),
                  };

                  Navigator.pop(context, newNote);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter meeting number')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF011226),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
            elevation: 3,
          ),
          child: const Text(
            "Done",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<String?> _getCurrentUserGroupId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    return userDoc.data()?['group_id'];
  }
}
