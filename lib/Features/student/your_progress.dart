import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartData {
  final String category;
  final int value;
  final Color color;
  ChartData(this.category, this.value, this.color);
}

class TaskProgress {
  final String name;
  final int totalGrade;
  final int achievedGrade;
  final bool isCompleted;
  TaskProgress({
    required this.name,
    required this.totalGrade,
    required this.achievedGrade,
    required this.isCompleted,
  });
}

class CategoryProgress {
  final String category;
  final List<TaskProgress> tasks;
  final int totalAchieved;
  final int totalGrade;
  CategoryProgress({
    required this.category,
    required this.tasks,
    required this.totalAchieved,
    required this.totalGrade,
  });
}

class YourProgress extends StatefulWidget {
  const YourProgress({super.key});
  @override
  State<YourProgress> createState() => _YourProgressState();
}

class _YourProgressState extends State<YourProgress> {
  String? groupId;
  @override
  void initState() {
    super.initState();
    _fetchGroupId();
  }

  Future<void> _fetchGroupId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      groupId = userDoc.data()?['group_id'];
    });
  }

  Stream<List<CategoryProgress>> _categoryProgressStream() async* {
    if (groupId == null) yield [];
    final tasksSnap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .get();
    Map<String, List<TaskProgress>> categoryMap = {};
    for (final doc in tasksSnap.docs) {
      final data = doc.data();
      final String name = data['name'] ?? doc.id;
      final int totalGrade =
          int.tryParse(data['grade']?.toString() ?? '0') ?? 0;
      final String? status = data['status'];
      final String category = data['category'] ?? 'Uncategorized';
      final submissionsSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(doc.id)
          .collection('submissions')
          .get();
      int achievedGrade = 0;
      for (final sub in submissionsSnap.docs) {
        achievedGrade +=
            int.tryParse(sub.data()['grade']?.toString() ?? '0') ?? 0;
      }
      final isCompleted = status == 'done';
      final taskProgress = TaskProgress(
        name: name,
        totalGrade: totalGrade,
        achievedGrade: achievedGrade,
        isCompleted: isCompleted,
      );
      categoryMap.putIfAbsent(category, () => []).add(taskProgress);
    }
    List<CategoryProgress> result = [];
    categoryMap.forEach((cat, tasks) {
      final totalAchieved =
          tasks.fold(0, (int sum, t) => sum + t.achievedGrade);
      final totalGrade = tasks.fold(0, (int sum, t) => sum + t.totalGrade);
      result.add(CategoryProgress(
        category: cat,
        tasks: tasks,
        totalAchieved: totalAchieved,
        totalGrade: totalGrade,
      ));
    });
    yield result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: groupId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<CategoryProgress>>(
              stream: _categoryProgressStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = snapshot.data!;
                if (categories.isEmpty) {
                  return const Center(child: Text('No tasks available'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(
                      top: 0, left: 0, right: 0, bottom: 30),
                  separatorBuilder: (context, idx) => const Divider(
                      height: 40, thickness: 1, color: Colors.grey),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return _buildHeader(context);
                    }
                    final cat = categories[idx - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.category,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Source Serif 4",
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...cat.tasks.map((t) => Text(
                                      '${t.name} : ${t.achievedGrade}/${t.totalGrade}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[700],
                                        fontFamily: "Source Serif 4",
                                      ),
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  'Total: ${cat.totalAchieved} / ${cat.totalGrade}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Source Serif 4",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          _buildCategoryPieChart(cat),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildCategoryPieChart(CategoryProgress cat) {
    final List<ChartData> data = [
      ChartData('Achieved', cat.totalAchieved, const Color(0xFF011226)),
      ChartData(
          'Remaining',
          (cat.totalGrade - cat.totalAchieved).clamp(0, cat.totalGrade),
          const Color.fromARGB(255, 194, 192, 192)),
    ];
    return SizedBox(
      width: 120,
      height: 140,
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: PieChart(
              PieChartData(
                sections: data
                    .map((item) => PieChartSectionData(
                          value: item.value.toDouble(),
                          title: '',
                          color: item.color,
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildLegendItem(const Color(0xFF011226), 'Achieved'),
              const SizedBox(height: 4),
              _buildLegendItem(
                  const Color.fromARGB(255, 194, 192, 192), 'Remaining'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
          ),
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
                "Your Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
