import 'package:flutter/material.dart';

import 'task_screen.dart';
import 'your_progress.dart';

// --------------------------Progress Screen-------------------------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'assets/bg.png',
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
            top: 110,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    "Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.bar_chart,
                        size: 30, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const YourProgress()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: Image.asset(
                'assets/design2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Center(
              child: Column(
                children: [
                  CustomButton(
                    color: const Color(0xFF011226),
                    text: "UI/UX",
                    textColor: Colors.white,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TaskScreen(title: "UI/UX"))),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    color: const Color(0xFF011226),
                    text: "Front End",
                    textColor: Colors.white,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TaskScreen(title: "Front-End"))),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    color: const Color(0xFF011226),
                    text: "Back End",
                    textColor: Colors.white,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TaskScreen(title: "Back-End"))),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    color: const Color(0xFF011226),
                    text: "Documentation",
                    textColor: Colors.white,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TaskScreen(title: "Documentation"))),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    color: const Color(0xFF011226),
                    text: "AI",
                    textColor: Colors.white,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TaskScreen(title: "AI"))),
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

// ignore: camel_case_types
class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.color,
    required this.text,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
