import 'package:flutter/material.dart';

class DoneScreen extends StatelessWidget {
  final String groupName;
  final Map<String, dynamic> taskData;

  const DoneScreen({
    Key? key,
    required this.groupName,
    required this.taskData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     

    return Scaffold(
      body: Stack(
        children: [
          // Top Background Image
          Positioned(
            top: screenHeight * 0.02,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
               
            ),
          ),

          // Bottom Background Image
          Positioned(
            bottom: -30,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
               
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.03,
            left: screenWidth * 0.05,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: screenWidth * 0.08,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),

          // Centered Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Done Successfully!",
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
              
                  Image.asset(
                    "assets/done.png",
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
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