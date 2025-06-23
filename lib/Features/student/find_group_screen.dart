import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Core/Helpers/FireBase/fire_store_notification_helper.dart';

import 'home_screen.dart';
import 'edit_group_info_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'team_finder_screen.dart';

//-----------------Find Group Screen--------------------------
class CustomDividerWithShadow extends StatelessWidget {
  const CustomDividerWithShadow({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Divider(
        color: Colors.grey[200],
        thickness: 0.5,
      ),
    );
  }
}

class FindGroupScreen extends StatefulWidget {
  const FindGroupScreen({super.key});

  @override
  _FindGroupScreenState createState() => _FindGroupScreenState();
}

class _FindGroupScreenState extends State<FindGroupScreen> {
  List<Map<String, String>> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    try {
      final groupSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      List<Map<String, String>> fetchedGroups = [];

      for (var groupDoc in groupSnapshot.docs) {
        final groupData = groupDoc.data();
        final creatorId = groupDoc.id;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(creatorId)
            .get();
        final creatorName = userDoc.data()?['name'] ?? 'Unknown';

        fetchedGroups.add({
          'name': creatorName,
          'field': groupData['field'] ?? '',
          'description': groupData['description'] ?? '',
          'requirements': groupData['requirements'] ?? '',
        });
        print("Creator ID is " + creatorId.toString());
      }

      setState(() {
        groups = fetchedGroups;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching groups: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TeamFinderScreen()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set pure white background color
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(15.w),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GroupCard(
                            name: groups[index]['name']!,
                            field: groups[index]['field']!,
                            description: groups[index]['description']!,
                            requirements: groups[index]['requirements']!,
                          ),
                          if (index < groups.length - 1)
                            const CustomDividerWithShadow(),
                          SizedBox(height: 20.h),
                        ],
                      );
                    },
                  ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: 55.h,
        margin: EdgeInsets.symmetric(horizontal: 90.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(35.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.person_add, 0, isHighlighted: true),
            _navItem(context, Icons.home, 1),
            _navItem(context, Icons.check_box, 2),
            _navItem(context, Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 70.h,
            left: 2.w,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 135.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Find Group",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20.w,
            top: 70.h,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 23, color: Colors.white),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You must be logged in.')),
                  );
                  return;
                }
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                final userGroupId = userDoc.data()?['group_id'];
                if (userGroupId == null || userGroupId.toString().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'You are not in a group. Create a group first to edit its details.')),
                  );
                  return;
                }
                // Check if user is the leader of the group
                if (user.uid != userGroupId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Only the team leader can edit the team details.')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditGroupInfoScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, int index,
      {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: EdgeInsets.all(isHighlighted ? 8.w : 0),
        decoration: isHighlighted
            ? const BoxDecoration(
                color: Color(0xFF042C6E), shape: BoxShape.circle)
            : null,
        child: Icon(icon, size: 30.w, color: Colors.white),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final String name;
  final String field;
  final String description;
  final String requirements;

  const GroupCard({
    super.key,
    required this.name,
    required this.field,
    required this.description,
    required this.requirements,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/SUPERVISOR.png'),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16.sp),
                  ),
                  Text(
                    field,
                    style: TextStyle(color: Colors.black, fontSize: 14.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Description:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14.sp),
          ),
          Text(description, style: TextStyle(fontSize: 13.sp)),
          SizedBox(height: 5.h),
          Text(
            'Requirements:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14.sp),
          ),
          Text(requirements, style: TextStyle(fontSize: 13.sp)),
          SizedBox(height: 10.h),
          SizedBox(
            width: 130.w,
            height: 30.h,
            child: ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You must be logged in.')),
                  );
                  return;
                }
                // Check if user is already in a group
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                final userGroupId = userDoc.data()?['group_id'];
                if (userGroupId != null && userGroupId.toString().isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'You are already in a group. Leave your group first.')),
                  );
                  return;
                }
                // Find the group leader's UID by matching the group name/field/description/requirements
                final groupQuery = await FirebaseFirestore.instance
                    .collection('groups')
                    .where('field', isEqualTo: field)
                    .where('description', isEqualTo: description)
                    .where('requirements', isEqualTo: requirements)
                    .get();
                if (groupQuery.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group not found.')),
                  );
                  return;
                }
                final groupDoc = groupQuery.docs.first;
                final leaderUid = groupDoc.id;
                // Check if user is the leader
                if (user.uid == leaderUid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are the group leader.')),
                  );
                  return;
                }
                // Check if user is already a member
                final memberDoc = await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(leaderUid)
                    .collection('members')
                    .doc(user.uid)
                    .get();
                // Check if user is already in another group
                final userCurrentGroupId = userDoc.data()?['group_id'];
                if (userCurrentGroupId != null &&
                    userCurrentGroupId.toString().isNotEmpty &&
                    userCurrentGroupId != leaderUid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'You are already in another group. Please leave your current group first.')),
                  );
                  return;
                }

                if (memberDoc.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('You are already a member of this group.')),
                  );
                  return;
                }
                // Send notification to group leader with type 'groupRequest'
                await FirestoreNotificationHelper.addNotification(
                  userId: leaderUid,
                  message:
                      '${user.email ?? 'A user'} requested to join your group.',
                  senderId: user.uid,
                  type: 'groupRequest',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Request sent to group leader.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF011226),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                minimumSize: Size(10.w, 36.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Send Request', style: TextStyle(fontSize: 12.sp)),
                  SizedBox(width: 5.w),
                  const Icon(
                    Icons.person_add,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
