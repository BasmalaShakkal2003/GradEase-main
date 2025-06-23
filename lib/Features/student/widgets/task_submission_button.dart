import 'package:flutter/material.dart';

class TaskSubmissionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const TaskSubmissionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF041C40),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 45),
      ),
      child: Text(label),
    );
  }
}
