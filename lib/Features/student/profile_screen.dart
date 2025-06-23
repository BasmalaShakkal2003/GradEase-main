import 'package:flutter/material.dart';

import 'package:grad_ease/Core/Helpers/FireBase/fire_store_profile_helper.dart' show fetchCurrentUserInfo;
import '../../Core/Helpers/FireBase/fire_auth_helper.dart';
import 'role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final data = await fetchCurrentUserInfo();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: userData == null
                  ? const Center(child: CircularProgressIndicator())
                  : userData!.isEmpty
                      ? const Center(child: Text('No user data found.'))
                      : Column(
                          children: [
                            _textField("Full Name",
                                value: userData?['name'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("Username",
                                value: userData?['username'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("ID", value: userData?['id'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("Email",
                                value: userData?['email'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("Major",
                                value: userData?['field'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("Phone",
                                value: userData?['phone'] ?? ''),
                            const SizedBox(height: 15),
                            _textField("Address",
                                value: userData?['address'] ?? ''),
                            const SizedBox(height: 40),
                            _logoutButton(context),
                            const SizedBox(height: 20),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
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
                "Profile",
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

  Widget _textField(String label, {String value = ''}) {
    return SizedBox(
      height: 50,
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(27),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          FireBaseHelper fireBaseHelper = FireBaseHelper();
          fireBaseHelper.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF014771),
        ),
        child: const Text(
          "Logout",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF014771),
            fontFamily: "Source Sans Pro",
          ),
        ),
      ),
    );
  }
}
