import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ai_screen.dart';
import 'conversation_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'team_finder_screen.dart';
import 'your_group.dart';
import '../../Core/Helpers/FireBase/fire_store_notification_helper.dart';

// ---------------------------Home screen-------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  bool _showGuideOptions = false; // Add this variable to track visibility

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    // Get current user ID from FirebaseAuth
    final user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc.data()?['name'] ?? '';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TeamFinderScreen()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              SizedBox(height: 15.h),
              _buildCalendarButton(),
              SizedBox(height: 50.h),
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 380.w,
                      height: 70.h,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const YourGroup()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF011226),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Row(
                                children: [
                                  const Icon(Icons.groups_3_sharp,
                                      color: Colors.white, size: 30),
                                  SizedBox(width: 10.w),
                                  const Text(
                                    "Group Members",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontFamily: "Inter"),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: 280.w,
                      height: 55.h,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showGuideOptions = !_showGuideOptions;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF011226),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Row(
                                children: [
                                  const Icon(Icons.library_books_sharp,
                                      color: Colors.white, size: 25),
                                  SizedBox(width: 10.w),
                                  const Text(
                                    "Your Guide",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontFamily: "Inter"),
                                  ),
                                  const Spacer(),
                                  AnimatedRotation(
                                    turns: _showGuideOptions ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    SizedBox(
                        height: 10
                            .h), // Animated container for GitHub and Documentation buttons
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showGuideOptions ? 120.h : 0,
                      curve: Curves.easeInOut,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              opacity: _showGuideOptions ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                onPressed: () => _launchUrl(
                                  'https://github.com/',
                                  'Could not launch GitHub',
                                ),
                                icon: Image.asset('assets/github.png',
                                    width: 120.w, height: 40.h),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _showGuideOptions ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                onPressed: () => _launchUrl(
                                  'https://docs.flutter.dev/',
                                  'Could not launch Documentation',
                                ),
                                icon: Image.asset('assets/documentation.png',
                                    width: 170.w, height: 40.h),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // AI and chat buttons
          Positioned(
            bottom: 20.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AIScreen()));
              },
              child: ClipOval(
                  child:
                      Image.asset('assets/ai.png', width: 80.w, height: 70.h)),
            ),
          ),
          Positioned(
            bottom: 90.h,
            right: 30.w,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConversationScreen()));
              },
              child: ClipOval(
                  child: Image.asset('assets/chat.png',
                      width: 45.w, height: 65.h)),
            ),
          ),
          // Notification icon with badge
          Positioned(
            top: 60.h,
            right: 18.w,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()));
              },
              child: StreamBuilder<int>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? FirestoreNotificationHelper.getNotificationCountStream(
                        FirebaseAuth.instance.currentUser!.uid)
                    : Stream.value(0),
                builder: (context, snapshot) {
                  final notificationCount = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      // Base notification icon
                      Image.asset(
                        'assets/notification.png',
                        width: 40.w,
                        height: 40.h,
                      ),
                      // Badge for notification count
                      if (notificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20.w,
                              minHeight: 20.h,
                            ),
                            child: Text(
                              notificationCount > 99 ? '99+' : '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Subtle pulsing animation for new notifications
                      if (notificationCount > 0)
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 130.h,
            left: 35.w,
            child: Text(
              userName != null && userName!.isNotEmpty
                  ? "Hi ${userName![0].toUpperCase()}${userName!.substring(1)}"
                  : "Hi",
              style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: "Inter"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 55.h,
        margin: EdgeInsets.symmetric(horizontal: 90.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(31.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.person_add, 0),
            _navItem(Icons.home, 1),
            _navItem(Icons.check_box, 2),
            _navItem(Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isHighlighted = index == 1;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.all(isHighlighted ? 8.w : 0),
        decoration: isHighlighted
            ? const BoxDecoration(
                color: Color(0xFF042C6E),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(icon, size: 30.w, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        'assets/head.png',
        fit: BoxFit.cover,
      ),
    );
  }

  // Calendar button
  Widget _buildCalendarButton() {
    String currentDate = DateFormat('E, d MMM').format(DateTime.now());
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF011226),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              SizedBox(width: 15.w),
              Text(currentDate,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String urlString, String errorMessage) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }
}
