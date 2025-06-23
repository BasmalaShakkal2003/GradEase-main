import 'package:flutter/material.dart';
import'role_selection_screen.dart';

// ------------------------Splash screen 2------------------------------
class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child:
                      Image.asset('assets/LOGO.png', height: 200, width: 270),
                ),
              ),
              Container(
                height: 420,
                decoration: const BoxDecoration(
                  color: Color(0xFF011226),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF041C40),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      "GET STARTED",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Space Mono",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
