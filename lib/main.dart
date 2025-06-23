import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Features/SPV/main.dart';
import 'Features/SPV/screens/home_page.dart';
import 'Features/SPV/screens/profile_page.dart';
import 'Features/student/home_screen.dart';
import 'Features/student/splash_screen2.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen1(),
          routes: {
            '/groups': (context) => const MainScreen(initialIndex: 0),
            '/home': (context) => const HomePage(),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    ),
  );
}

//-------------------- splash screen 1---------------------------
class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});
  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    const String appVersion = '1'; // Local app version
    final versionDoc = await FirebaseFirestore.instance
        .collection('version')
        .doc(appVersion)
        .get();
    if (!versionDoc.exists) {
      // Out of date or version not found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VersionErrorScreen(
              message: 'App version is not supported. Please update.'),
        ),
      );
      return;
    }
    final data = versionDoc.data();
    final bool working = data?['working'] == true;
    final String message =
        (data?['message'] ?? 'App is not available.').toString();

    //TODO 
    if (!working) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VersionErrorScreen(message: message),
        ),
      );
      return;
    }
    // If up to date and working, continue with normal auth navigation
    _navigateBasedOnAuth();
  }

  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen2()),
      );
      return;
    }
    // User exists, check role
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = doc.data()?['role'];
    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (role == 'supervisor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // fallback: go to splash
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/LOGO.png', width: 270.w, height: 250.h),
            Image.asset('assets/LOGO2.png', width: 320.w, height: 150.h),
            const SizedBox(height: 30),
            LoadingAnimationWidget.discreteCircle(
              color: const Color(0xFF0F5C8C),
              secondRingColor: const Color(0xFF09316E),
              thirdRingColor: const Color.fromARGB(255, 33, 114, 165),
              size: 50.w,
            ),
          ],
        ),
      ),
    );
  }
}

class VersionErrorScreen extends StatelessWidget {
  final String message;
  const VersionErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 30),
              Text(
                'App Unavailable',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
