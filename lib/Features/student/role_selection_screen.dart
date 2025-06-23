import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../SPV/screens/doctor_login_screen.dart';
import 'student_login_screen.dart';

// --------------------Role selection screen---------------------------
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 30.h),
          Image.asset('assets/LOGO.png', width: 230.w, height: 350.h),
          const Spacer(),
          Container(
            height: 460.h,
            decoration: const BoxDecoration(
              color: Color(0xFF011226),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _roleCard(
                      context: context,
                      imagePath: 'assets/STUDENT.png',
                      label: 'Student',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentLoginScreen()),
                        );
                      },
                    ),
                    _roleCard(
                      context: context,
                      imagePath: 'assets/SUPERVISOR.png',
                      label: 'SuperVisor', // Localized string
                      onTap: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        // const SnackBar(
                        //   content: Text(
                        //       'You are in the demo mode. Please wait to get the full version.'),
                        // ),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SupervisorLoginScreen()),
                        );
                        // );
                        // Uncomment below to enable navigation when full version is ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const SupervisorLoginScreen()),
                        // );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Create role cards
  Widget _roleCard({
    required BuildContext context,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: const Color(0xFF041C40),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 100.w,
                height: 100.h,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Spectral",
            ),
          ),
        ],
      ),
    );
  }
}
