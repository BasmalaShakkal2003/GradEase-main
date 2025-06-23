import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../../Core/Helpers/FireBase/fire_store_notification_helper.dart' show FirestoreNotificationHelper;
import 'team_finder_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'home_screen.dart';

class SupervisorScreen extends StatelessWidget {
  final List<Map<String, String>> supervisors = [
    {
      'name': 'Dr./Mechanical_a',
      'field': 'Business Technology',
    },
  ];

  SupervisorScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isGroupLeader() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(user.uid)
        .get();
    return doc.exists && doc.id == user.uid;
  }

  Future<String> _getCurrentUsername() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['username'] ?? '';
  }

  void _showOptionsDialog(BuildContext context, String supervisorId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Save the parent context for snackbar use
    final parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  TextEditingController _linkController =
                      TextEditingController();

                  await showDialog(
                    context: dialogContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Insert Proposal Link'),
                      content: TextField(
                        controller: _linkController,
                        decoration:
                            const InputDecoration(hintText: 'https://...'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final proposalLink = _linkController.text.trim();
                            final uri = Uri.tryParse(proposalLink);
                            if (proposalLink.isEmpty ||
                                uri == null ||
                                !uri.hasAbsolutePath ||
                                !(proposalLink.startsWith('http://') ||
                                    proposalLink.startsWith('https://'))) {
                              Navigator.pop(context);
                              Future.delayed(Duration.zero, () {
                                ScaffoldMessenger.of(parentContext)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please enter a valid link (must start with http/https).')),
                                );
                              });
                              return;
                            }
                            await FirebaseFirestore.instance
                                .collection('groups')
                                .doc(user.uid)
                                .collection('proposals')
                                .doc(user.uid)
                                .set({
                              'proposalLink': proposalLink,
                              'groupLeaderId': user.uid,
                              'timestamp': Timestamp.now(),
                              'method': 'link',
                              'date': DateTime.now().toIso8601String(),
                            });

                            // Fetch username and send notification
                            final username = await _getCurrentUsername();
                            await FirestoreNotificationHelper.addNotification(
                              userId: supervisorId,
                              message:
                                  '$username is asking for you to join him as supervisor',
                              senderId: user.uid,
                              type: 'supervisor_request',
                              link: proposalLink,
                            );

                            Navigator.pop(context);
                            Future.delayed(Duration.zero, () {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Link submitted successfully.')),
                              );
                            });
                          },
                          child: const Text('Send'),
                        )
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041C40),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Insert link'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  FilePickerResult? result;
                  try {
                    result =
                        await FilePicker.platform.pickFiles(withData: true);
                  } catch (e) {
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text('File picker error: $e')),
                      );
                    });
                    return;
                  }
                  if (result != null) {
                    final file = result.files.single;
                    final fileBytes = file.bytes;
                    final fileName = file.name;
                    if (fileBytes != null) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('groups')
                            .doc(user.uid)
                            .collection('proposals')
                            .doc(user.uid)
                            .set({
                          'proposalFile': fileName,
                          'proposalFilePath': file.path,
                          'groupLeaderId': user.uid,
                          'timestamp': Timestamp.now(),
                          'method': 'upload',
                          'date': DateTime.now().toIso8601String(),
                        });

                        // Fetch username and send notification
                        final username = await _getCurrentUsername();
                        await FirestoreNotificationHelper.addNotification(
                          userId: supervisorId,
                          message:
                              '$username is asking for you to join him as supervisor',
                          senderId: user.uid,
                          type: 'supervisor_request',
                          link: file.path ?? '',
                        );

                        Future.delayed(Duration.zero, () {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                                content: Text('File info saved successfully.')),
                          );
                        });
                        print('File info saved: $fileName, path: ${file.path}');
                      } catch (e) {
                        print('Save error: \\${e.toString()}');
                        Future.delayed(Duration.zero, () {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                                content: Text('Save error: \\${e.toString()}')),
                          );
                        });
                      }
                    } else {
                      Future.delayed(Duration.zero, () {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                              content: Text('Could not read file bytes.')),
                        );
                      });
                    }
                  } else {
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('No file selected.')),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041C40),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Upload'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    final file = result.files.single;
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(user.uid)
                        .collection('proposals')
                        .doc(user.uid)
                        .set({
                      'proposalDriveFileName': file.name,
                      'proposalDrivePath': file.path,
                      'groupLeaderId': user.uid,
                      'timestamp': Timestamp.now(),
                      'method': 'drive',
                      'date': DateTime.now().toIso8601String(),
                    });

                    // Fetch username and send notification
                    final username = await _getCurrentUsername();
                    await FirestoreNotificationHelper.addNotification(
                      userId: supervisorId,
                      message:
                          '$username is asking for you to join him as supervisor',
                      senderId: user.uid,
                      type: 'supervisor_request',
                      link: file.path ?? '',
                    );

                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'File picked from Google Drive or device. For a shareable link, use Insert Link option.')),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041C40),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Add from Drive'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TeamFinderScreen()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  Widget _navItem(BuildContext context, IconData icon, int index,
      {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: EdgeInsets.all(isHighlighted ? 8 : 0),
        decoration: isHighlighted
            ? const BoxDecoration(
                color: Color(0xFF042C6E), shape: BoxShape.circle)
            : null,
        child: Icon(icon, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset('assets/head2.png', fit: BoxFit.cover),
          Positioned(
            top: 70,
            left: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            top: 135,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "SUPERVISOR",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> supervisor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: supervisor['profileImage'] != null &&
                  supervisor['profileImage'].toString().isNotEmpty
              ? NetworkImage(supervisor['profileImage']) as ImageProvider
              : const AssetImage('assets/SUPERVISOR.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${supervisor['username'] ?? supervisor['name'] ?? 'Unknown'}\n${supervisor['field'] ?? ''}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'supervisor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No supervisors found.'));
                }
                final supervisors = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: supervisors.length,
                  itemBuilder: (context, index) {
                    final supervisorDoc = supervisors[index];
                    final supervisor = supervisorDoc.data();
                    final supervisorId = supervisorDoc.id;
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          child: SizedBox(
                            height: 130,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: _buildProfileSection(supervisor),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 16,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (await isGroupLeader()) {
                                        _showOptionsDialog(
                                            context, supervisorId);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Only group leaders can send proposals.")),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF011226),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      minimumSize: const Size(150, 5),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Send proposal'),
                                        SizedBox(width: 8),
                                        Icon(Icons.send,
                                            size: 18, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.person_add, 0, isHighlighted: true),
            _navItem(context, Icons.home, 1),
            _navItem(context, Icons.check_box, 2),
            _navItem(context, Icons.person, 3),
          ],
        ),
      ),
    );
  }
}
