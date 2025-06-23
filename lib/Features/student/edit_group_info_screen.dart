import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Core/Helpers/FireBase/fire_store_profile_helper.dart';

class EditGroupInfoScreen extends StatefulWidget {
  const EditGroupInfoScreen({super.key});

  @override
  State<EditGroupInfoScreen> createState() => _EditGroupInfoScreenState();
}

class _EditGroupInfoScreenState extends State<EditGroupInfoScreen> {
  String? userName;
  String? description;
  String? requirements;
  String? field;
  bool isLoading = true;

  final _descController = TextEditingController();
  final _reqController = TextEditingController();
  final _fieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final userInfo = await fetchCurrentUserInfo();
    if (userInfo == null) {
      setState(() => isLoading = false);
      return;
    }
    userName = userInfo['name'] ?? '';
    final groupId = userInfo['group_id'];
    if (groupId == null || groupId.toString().isEmpty) {
      setState(() => isLoading = false);
      return;
    }
    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    if (groupDoc.exists) {
      final groupData = groupDoc.data()!;
      description = groupData['description'] ?? '';
      requirements = groupData['requirements'] ?? '';
      _fieldController.text = field ?? '';
      _descController.text = description ?? '';
      _reqController.text = requirements ?? '';
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _descController.dispose();
    _reqController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 30),
                        _textField("Description",
                            controller: _descController, hint: description),
                        const SizedBox(height: 20),
                        _textField("Requirements",
                            controller: _reqController, hint: requirements),
                        const SizedBox(height: 40),
                        _SaveButton(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
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
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/SUPERVISOR.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }

  Widget _textField(String label,
      {required TextEditingController controller, String? hint}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          // hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),
    );
  }

  Widget _SaveButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                setState(() => isLoading = true);
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                try {
                  // Fetch current group data
                  final groupDoc = await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(user.uid)
                      .get();
                  final groupData = groupDoc.data() ?? {};
                  final updatedDescription =
                      _descController.text.trim().isNotEmpty
                          ? _descController.text.trim()
                          : groupData['description'] ?? '';
                  final updatedRequirements =
                      _reqController.text.trim().isNotEmpty
                          ? _reqController.text.trim()
                          : groupData['requirements'] ?? '';
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(user.uid)
                      .update({
                    'description': updatedDescription,
                    'requirements': updatedRequirements,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Group info updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update group: $e')),
                  );
                }
                setState(() => isLoading = false);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF011226),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 3,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
