import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
Future<Map<String, dynamic>?> fetchCurrentUserInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("User not signed in.");
    return null;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return doc.data();
    } else {
      print("No document found for user: ${user.uid}");
      return null;
    }
  } catch (e) {
    print("Error fetching user info: $e");
    return null;
  }
}



Future<void> sendNotificationToUser(String token, String title, String body) async {
  final callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
  final result = await callable.call({
    'token': token,
    'title': title,
    'body': body,
  });
  print('Notification sent: ${result.data}');
}
