import 'package:flutter/material.dart';
import '../widgets/responsive_calendar.dart';
import '../widgets/responsive_notifications_list.dart';
import '../profile_data.dart';
import '../../../Core/Helpers/FireBase/fire_store_profile_helper.dart';

Future<String> getUserNameFromFirestore() async {
  final userInfo = await fetchCurrentUserInfo();
  if (userInfo != null && userInfo['name'] != null) {
    return userInfo['name'] as String;
  }
  return "Unknown";
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background layers
          Positioned(
            top: -screenSize.height * 0.2,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.42,
              decoration: BoxDecoration(
                color: const Color(0xFF041C40),
                borderRadius: BorderRadius.circular(screenSize.width * 0.2),
              ),
            ),
          ),
          Positioned(
            top: -screenSize.height * 0.15,
            left: -screenSize.width * 0.05,
            right: -screenSize.width * 0.05,
            child: Container(
              height: screenSize.height * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFF011226),
                borderRadius: BorderRadius.circular(screenSize.width * 0.3),
              ),
            ),
          ),
          // Profile Picture
          Positioned(
            top: screenSize.height * 0.06,
            right: screenSize.width * 0.05,
            child: CircleAvatar(
              radius: screenSize.width * 0.07,
              backgroundImage: AssetImage(
                profileData["Profile Image"] ?? 'assets/profile.png',
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                      vertical: screenSize.height * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Dr/ ",
                              style: TextStyle(
                                fontSize: screenSize.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Flexible(
                              child: FutureBuilder<String>(
                                future:
                                    getUserNameFromFirestore(), // Define this function to fetch the name
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      "Loading...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      "Unknown",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      snapshot.data ?? "Unknown",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Calendar Box
                  ResponsiveCalendar(screenSize: screenSize),
                  SizedBox(height: screenSize.height * 0.05),
                  // Notifications Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: screenSize.height * 0.1,
                      decoration: BoxDecoration(
                        color: const Color(0xFF011226),
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.04),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: screenSize.width * 0.05),
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.width * 0.05,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(right: screenSize.width * 0.05),
                            child: SizedBox(
                              width: 41.1,
                              height: 35.4,
                              child: Image.asset(
                                'assets/notification.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Notification List
                  ResponsiveNotificationsList(screenSize: screenSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
