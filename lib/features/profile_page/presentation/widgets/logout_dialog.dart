import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Önce Firebase oturumunu kapat
      await FirebaseAuth.instance.signOut();

      // SharedPreferences'daki kullanıcı bilgilerini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Tüm verileri temizle

      if (context.mounted) {
        // Login sayfasına yönlendir
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapma hatası: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Çıkış Yapmak İstiyor musunuz?'),
      content: const Text(
          'Çıkış yaptıktan sonra tekrar giriş yapmanız gerekecektir.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () => _handleLogout(context),
          child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
