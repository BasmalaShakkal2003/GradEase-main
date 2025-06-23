import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Core/Helpers/FireBase/fire_store_group_helper.dart';
import 'add_member_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'team_finder_screen.dart';


class YourGroup extends StatefulWidget {
  const YourGroup({super.key});

  @override
  _YourGroupState createState() => _YourGroupState();
}

class _YourGroupState extends State<YourGroup> {
  List<Map<String, dynamic>> members = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final fetchedMembers = await fetchGroupMembers();
    setState(() {
      members = fetchedMembers;
    });
  }

  void _onItemTapped(int index) {
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

  Future<void> _removeMember(String memberUid) async {
    await removeMemberFromGroup(memberUid, context);
    await _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isLeader = member['isLeader'] == true;
                final isCurrentUserLeader = members.any(
                    (m) => m['uid'] == currentUserId && m['isLeader'] == true);

                return YourGroupCard(
                  name: member['name'] ?? '',
                  id: member['id'] ?? '',
                  phone: member['phone'] ?? '',
                  email: member['email'] ?? '',
                  role: isLeader ? 'Leader' : 'Member',
                  showMenu: isCurrentUserLeader,
                  isCurrentUser: member['uid'] ==
                      currentUserId, // Check if this is the current user
                  onDelete: () => _removeMember(member['uid']),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset('assets/head2.png', fit: BoxFit.cover),
          Positioned(
            top: 70,
            left: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            top: 135,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Group Members",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 70,
            child: IconButton(
              icon: const Icon(Icons.person_add, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMemberScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isHighlighted = index == 1;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.all(isHighlighted ? 8 : 0),
        decoration: isHighlighted
            ? const BoxDecoration(
                color: Color(0xFF042C6E), shape: BoxShape.circle)
            : null,
        child: Icon(icon, size: 30, color: Colors.white),
      ),
    );
  }
}

class YourGroupCard extends StatelessWidget {
  final String name;
  final String id;
  final String phone;
  final String email;
  final String role;
  final bool showMenu;
  final VoidCallback onDelete;
  final bool
      isCurrentUser; // New flag to check if the current user is this member

  const YourGroupCard({
    Key? key,
    required this.name,
    required this.id,
    required this.phone,
    required this.email,
    required this.role,
    required this.showMenu,
    required this.onDelete,
    required this.isCurrentUser, // Pass this flag
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Name", name),
                      _buildLabel("ID", id),
                      _buildLabel("Phone", phone),
                      _buildLabel("Email", email),
                      _buildLabel("Role", role),
                    ],
                  ),
                ),
                if (showMenu ||
                    isCurrentUser) // Show menu if the user is the current member or the leader
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    color: const Color(0xFF041C40),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: SizedBox(
                          width: 50,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              isCurrentUser ? 'Leave Group' : 'Delete',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 16, color: Colors.black, fontFamily: "inter"),
          children: [
            TextSpan(
                text: "$title: ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
