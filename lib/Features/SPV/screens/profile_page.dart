import 'package:flutter/material.dart';
import '../../../Core/Helpers/FireBase/fire_store_profile_helper.dart';
import '../../student/role_selection_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Layer 1
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 1.2,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFF041C40),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenWidth * 0.4),
                  bottomRight: Radius.circular(screenWidth * 0.4),
                ),
              ),
            ),
          ),
          // Background Layer 2
          Positioned(
            top: -screenHeight * 0.15,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 1.2,
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFF011226),
                borderRadius: BorderRadius.circular(screenWidth * 0.3),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: screenHeight * 0.099,
            left: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              child: Icon(
                Icons.arrow_back,
                size: screenWidth * 0.07,
                color: Colors.white,
              ),
            ),
          ),
          // Profile Image & Title
          Positioned(
            top: screenHeight * 0.12,
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/profile.png',
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Profile",
                  style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Profile Data
          Positioned.fill(
            top: screenHeight * 0.26,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  if (userData == null)
                    const Center(child: CircularProgressIndicator())
                  else if (userData!.isEmpty)
                    const Center(child: Text('No user data found.'))
                  else ...[
                    buildProfileField(
                        "Full Name", userData?['name'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField(
                        "Username", userData?['username'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField("ID", userData?['id'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField(
                        "Email", userData?['email'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField(
                        "Major", userData?['field'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField(
                        "Phone", userData?['phone'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    buildProfileField(
                        "Address", userData?['address'] ?? '', screenWidth),
                    SizedBox(height: screenHeight * 0.03),
                    // Notifications Section

                    // Logout Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.07,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 129, 129, 129)
                                  .withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF014771),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.09),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileField(String label, String value, double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.07),
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Source Sans Pro',
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF014771),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
