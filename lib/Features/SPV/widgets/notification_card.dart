import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final String notifId;
  final String? link;
  final bool isSupervisorRequest;
  final bool isTaskSubmission;
  final String? groupId;
  final Size screenSize;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onView;

  const NotificationCard({
    super.key,
    required this.notif,
    required this.notifId,
    required this.link,
    required this.isSupervisorRequest,
    required this.isTaskSubmission,
    required this.groupId,
    required this.screenSize,
    required this.onAccept,
    required this.onReject,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(bottom: screenSize.height * 0.008),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.03,
              vertical: isSupervisorRequest || isTaskSubmission
                  ? screenSize.height * 0.018
                  : screenSize.height * 0.012),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif['message'] ?? '',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isSupervisorRequest || isTaskSubmission)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011F40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        minimumSize: Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011F40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        minimumSize: Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (link != null && link!.isNotEmpty)
                      ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF011F40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 4),
                          minimumSize: Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (link != null && link!.isNotEmpty)
                      Container(
                        width: screenSize.width * 0.3,
                        height: screenSize.height * 0.032,
                        decoration: BoxDecoration(
                          color: const Color(0xFF041C40),
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.06),
                        ),
                        child: ElevatedButton(
                          onPressed: onView,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  screenSize.width * 0.06),
                            ),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "View",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.03,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
