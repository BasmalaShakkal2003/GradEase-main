import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Core/Helpers/FireBase/fire_store_group_helper.dart';
import 'done_successfully_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();

  String? userField; // will be loaded from Firestore

  @override
  void initState() {
    super.initState();
    _loadUserField();
  }

  Future<void> _loadUserField() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userField = userDoc.data()?['field'] ?? 'Unknown';
      });
    }
  }

  Future<void> _handleCreateGroup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentGroupId = userDoc.data()?['group_id'];
    if (currentGroupId != null && currentGroupId.toString().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You are already in a group. Leave your group before creating a new one.')),
      );
      return;
    }
    final description = _descriptionController.text.trim();
    final requirements = _requirementsController.text.trim();
    print("User field is " + userField.toString());
    print("Description is " + description);
    print("Requirements are " + requirements);
    print("User ID is " + FirebaseAuth.instance.currentUser!.uid);

    if (userField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User field not loaded. Try again.')),
      );
      return;
    }

    try {
      await createGroup(
        field: userField!,
        description: description,
        requirements: requirements,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoneSuccessfullyScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _textField("Description",
                        controller: _descriptionController),
                    const SizedBox(height: 30),
                    _textField("Requirements",
                        controller: _requirementsController),
                    const SizedBox(height: 50),
                    _createButton(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ],
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
          ),
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
                "Create Group",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, {TextEditingController? controller}) {
    return SizedBox(
      height: 50,
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

  Widget _createButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleCreateGroup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF011226),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 3,
        ),
        child: const Text(
          "Create",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
