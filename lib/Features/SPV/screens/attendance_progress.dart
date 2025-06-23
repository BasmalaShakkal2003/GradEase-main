import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceProgress extends StatelessWidget {
  final String groupId;
  final String groupName;

  const AttendanceProgress({
    Key? key,
    required this.groupId,
    this.groupName = '',
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
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
            ),
          ),

          // Bottom Background Image
          Positioned(
            bottom: -screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bgd.png",
              fit: BoxFit.cover,
            ),
          ),

          // Back Arrow Button
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.02,
            left: screenWidth * 0.03,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.white, size: screenWidth * 0.08),
              onPressed: () => Navigator.pop(context),
            ),
          ), // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: StreamBuilder<DocumentSnapshot>(
                stream: groupName.isEmpty
                    ? FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groupId)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  String title = "Attendance ";
                  if (groupName.isNotEmpty) {
                    title += " - $groupName";
                  } else if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null && data.containsKey('name')) {
                      title += " - ${data['name']}";
                    }
                  }
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),

          // Chart Container
          Positioned(
            top: screenHeight * 0.25,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenHeight * 0.25,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .snapshots(),
                builder: (context, groupSnapshot) {
                  if (groupSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
                    return const Center(child: Text('No group found.'));
                  }

                  final groupData =
                      groupSnapshot.data!.data() as Map<String, dynamic>;

                  // Stream all group members instead of using FutureBuilder
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('group_id', isEqualTo: groupId)
                        .snapshots(),
                    builder: (context, usersSnapshot) {
                      if (usersSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Create a list of members with their names
                      List<Map<String, dynamic>> allMembers = [];

                      // Add group leader if available
                      if (groupData.containsKey('leader_id')) {
                        allMembers.add({
                          'id': groupData['leader_id'],
                          'name': groupData['leader_name'] ?? 'Group Leader'
                        });
                      }

                      // Add all members from the group
                      if (usersSnapshot.hasData &&
                          usersSnapshot.data!.docs.isNotEmpty) {
                        for (var doc in usersSnapshot.data!.docs) {
                          var userData = doc.data() as Map<String, dynamic>;
                          String memberName = userData['name'] ??
                              userData['username'] ??
                              'Student';

                          // Skip if this is the leader (already added)
                          if (doc.id == groupData['leader_id']) {
                            continue;
                          }

                          allMembers.add({'id': doc.id, 'name': memberName});
                        }
                      }

                      if (allMembers.isEmpty) {
                        return const Center(
                            child: Text('No members found in this group.'));
                      }

                      // Now get the meeting data in real-time
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc(groupId)
                            .collection('notes')
                            .snapshots(),
                        builder: (context, notesSnapshot) {
                          if (notesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          // Get total number of meetings
                          int totalMeetings = 0;
                          if (notesSnapshot.hasData) {
                            totalMeetings = notesSnapshot.data!.docs.length;
                          }

                          if (totalMeetings == 0) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_busy,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No meetings recorded yet.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Attendance data will appear here after recording attendance for meetings.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Initialize attendance map with all members set to 0
                          final Map<String, _Attendance> attendanceMap = {};
                          for (var member in allMembers) {
                            attendanceMap[member['id']] =
                                _Attendance(member['name'], 0);
                          }

                          // Use StreamGroup to listen to all attendance collections
                          return StreamBuilder<List<QuerySnapshot>>(
                            stream: Stream.fromFuture(Future.wait(notesSnapshot
                                .data!.docs
                                .map((noteDoc) => noteDoc.reference
                                    .collection('attendance')
                                    .get()))),
                            builder: (context, attendanceSnapshots) {
                              if (attendanceSnapshots.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              // Reset all attendance counts to 0
                              for (var memberId in attendanceMap.keys) {
                                String memberName =
                                    attendanceMap[memberId]!.student;
                                attendanceMap[memberId] =
                                    _Attendance(memberName, 0);
                              }

                              // Process attendance data
                              if (attendanceSnapshots.hasData) {
                                for (var attendanceSnap
                                    in attendanceSnapshots.data!) {
                                  for (var att in attendanceSnap.docs) {
                                    var attData =
                                        att.data() as Map<String, dynamic>;
                                    String studentId =
                                        attData['studentId'] ?? '';
                                    String userId =
                                        attData['userId'] ?? studentId;

                                    // Check if this student is in our list of members
                                    for (var memberId in attendanceMap.keys) {
                                      if (memberId == userId ||
                                          memberId == studentId) {
                                        String memberName =
                                            attendanceMap[memberId]!.student;
                                        int currentSessions =
                                            attendanceMap[memberId]!.sessions;
                                        attendanceMap[memberId] = _Attendance(
                                            memberName, currentSessions + 1);
                                        break;
                                      }
                                    }
                                  }
                                }
                              }

                              final attendanceList =
                                  attendanceMap.values.toList();

                              // Create bar chart with all members
                              return BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: totalMeetings.toDouble() + 1,
                                  minY: 0,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: const Color(0xFF041C40)
                                          .withOpacity(0.8),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${attendanceList[groupIndex].student}\n${rod.toY.toInt()} / $totalMeetings meetings',
                                          const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1,
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      axisNameWidget: Text(
                                        'Meetings',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.black,
                                            ),
                                          );
                                        },
                                        reservedSize: screenWidth * 0.1,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index >= 0 &&
                                              index < attendanceList.length) {
                                            return Transform.rotate(
                                              angle: -1.2,
                                              child: Text(
                                                attendanceList[index].student,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.028,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        },
                                        reservedSize: screenWidth * 0.3,
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(),
                                    topTitles: const AxisTitles(),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      left: BorderSide(
                                          color: Colors.black, width: 1),
                                      bottom: BorderSide(
                                          color: Colors.black, width: 1),
                                    ),
                                  ),
                                  barGroups:
                                      attendanceList.mapIndexed((index, data) {
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: data.sessions.toDouble(),
                                          width: screenWidth * 0.15,
                                          color: const Color(0xFF001C30),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                            show: true,
                                            toY: totalMeetings.toDouble(),
                                            color: Colors.grey[200],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ), // Number of meetings label
          Positioned(
            top: screenHeight * 0.22,
            left: screenWidth * 0.01,
            child: Text(
              'Number of meetings attended',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black,
              ),
            ),
          ),

          // Legend for the chart
          Positioned(
            bottom: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: screenWidth * 0.04,
                      height: screenWidth * 0.04,
                      color: const Color(0xFF001C30),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Meetings Attended',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Container(
                      width: screenWidth * 0.04,
                      height: screenWidth * 0.04,
                      color: Colors.grey[200],
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Total Meetings',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Attendance {
  final String student;
  final int sessions;

  _Attendance(this.student, this.sessions);
}

extension MapIndexed<T> on List<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T item) f) sync* {
    for (var index = 0; index < length; index++) {
      yield f(index, this[index]);
    }
  }
}
