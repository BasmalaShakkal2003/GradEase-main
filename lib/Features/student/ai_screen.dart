import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import'ai_chat.dart';
//-----------------------AI Screen-----------------------------
class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  AIScreenState createState() => AIScreenState();
}

class AIScreenState extends State<AIScreen> {
  String? userName;
  bool isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    // Get current user ID from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc.data()?['name'] ?? '';
        isLoadingName = false;
      });
    } else {
      setState(() {
        isLoadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.asset(
                'assets/design1.png',
                fit: BoxFit.cover,
              ),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.asset(
                'assets/design2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/aibig.png', width: 180),
                  const SizedBox(height: 30),
                  isLoadingName
                      ? const Text(
                          "Hello, \nI'm ready to assist you today",
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          userName != null && userName!.isNotEmpty
                              ? "Hello ${userName![0].toUpperCase()}${userName!.substring(1)}, \nI'm ready to assist you today"
                              : "Hello, \nI'm ready to assist you today",
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AICHAT()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF041C40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ready",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}