import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Çıkış Yap'),
      content: const Text(
        'WinPoi uygulamasından çıkış yapmak istediğinize emin misiniz?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            'Vazgeç',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text(
            'Çıkış Yap',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
