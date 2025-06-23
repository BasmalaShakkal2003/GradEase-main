import 'package:flutter/material.dart';

class DriveLinkDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const DriveLinkDialog({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Drive Link'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Paste Google Drive link'),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        TextButton(onPressed: onSubmit, child: const Text('Submit')),
      ],
    );
  }
}
