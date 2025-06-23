import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../Core/Helpers/FireBase/fire_store_task_helper.dart';
import 'task_category_edit_screen.dart';

class TaskCategoryScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String category;
  const TaskCategoryScreen(
      {super.key,
      required this.groupName,
      required this.groupId,
      required this.category});

  @override
  _TaskCategoryScreenState createState() => _TaskCategoryScreenState();
}

class _TaskCategoryScreenState extends State<TaskCategoryScreen> {
  late double screenWidth;
  late double screenHeight;
  List<Task> _tasks = [];
  bool _loading = true;
  StreamSubscription? _taskSubscription;

  @override
  void initState() {
    super.initState();
    _listenToTasks();
  }

  void _listenToTasks() {
    _taskSubscription?.cancel();
    _taskSubscription =
        FireStoreTaskHelper.getTasks(widget.groupId).listen((tasks) {
      if (!mounted) return;
      setState(() {
        _tasks = tasks.where((t) => t.category == widget.category).toList();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showTaskEditScreen({Task? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCategoryEditScreen(
          groupName: widget.groupName,
          groupId: widget.groupId,
          category: widget.category,
          task: task,
          onSaved: _listenToTasks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              height: screenHeight * 0.41,
              decoration: BoxDecoration(
                color: const Color(0xFF041C40),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenWidth * 0.4),
                  bottomRight: Radius.circular(screenWidth * 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            top: -screenHeight * 0.15,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFF011226),
                borderRadius: BorderRadius.circular(screenWidth * 0.3),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          size: screenWidth * 0.06,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showTaskEditScreen(),
                        child: Icon(
                          Icons.add,
                          size: screenWidth * 0.06,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    widget.category,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator())
                      : _tasks.isEmpty
                          ? Center(
                              child: Text(
                                'No ${widget.category} tasks created yet',
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.03,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Task: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: task.name),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Description:\n',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: task.description),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Requirements:\n',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: task.requirements),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Technologies: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: task.technologies),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Deadline: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: DateFormat(
                                                          'MMM d, yyyy')
                                                      .format(task.deadline)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.038),
                                            children: [
                                              TextSpan(
                                                  text: 'Assigned to: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: task.assigneeEmail),
                                            ],
                                          ),
                                        ),
                                        if (task.grade.isNotEmpty) ...[
                                          SizedBox(height: 6),
                                          RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      screenWidth * 0.038),
                                              children: [
                                                TextSpan(
                                                    text: 'Grade: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(text: task.grade),
                                              ],
                                            ),
                                          ),
                                        ],
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Color(0xFF011226)),
                                            onPressed: () =>
                                                _showTaskEditScreen(task: task),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
