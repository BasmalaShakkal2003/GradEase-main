import 'package:flutter/material.dart';

class InsertLinkDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const InsertLinkDialog({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Link'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
            hintText: 'Paste link (e.g. GitHub, website)'),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        TextButton(onPressed: onSubmit, child: const Text('Submit')),
      ],
    );
  }
}
