import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;
  
  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          child: const Text('Log Out', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}