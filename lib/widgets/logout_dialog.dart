import 'package:flutter/material.dart';

typedef LogoutConfirmed = Future<void> Function();

class LogoutConfirmationDialog extends StatelessWidget {
  final LogoutConfirmed onConfirm;

  const LogoutConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await onConfirm();
          },
          child: Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}