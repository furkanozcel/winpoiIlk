import 'package:flutter/material.dart';
import 'package:winpoi/core/services/firestore_service.dart';
import 'package:winpoi/core/services/notification_service.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';

class CompetitionManagementPage extends StatefulWidget {
  const CompetitionManagementPage({super.key});

  @override
  State<CompetitionManagementPage> createState() =>
      _CompetitionManagementPageState();
}

class _CompetitionManagementPageState extends State<CompetitionManagementPage> {
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _imageController = TextEditingController();
  final _durationController = TextEditingController();

  Future<void> _addCompetition() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Saat cinsinden süreyi al
        final durationInHours = double.parse(_durationController.text);
        // Şu anki zamana süreyi ekle
        final endTime =
            DateTime.now().add(Duration(hours: durationInHours.toInt()));

        final competition = Competition(
          id: '', // Firestore otomatik oluşturacak
          title: _titleController.text,
          description: _descriptionController.text,
          entryFee: double.parse(_entryFeeController.text),
          endTime: endTime,
          image: _imageController.text,
        );

        await _firestoreService.addCompetition(competition);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yarışma başarıyla eklendi'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Bildirim gönder
    final notificationService = NotificationService();
    await notificationService.sendNotificationToAllUsers(
      title: "Yeni Yarışma!",
      message: "${_titleController.text} yarışması başladı!",
      type: "competition",
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _entryFeeController.clear();
    _imageController.clear();
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yarışma Yönetimi'),
        backgroundColor: const Color(0xFFFF6600),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Yarışma Başlığı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),

              // Katılım Puanı
              TextFormField(
                controller: _entryFeeController,
                decoration: InputDecoration(
                  labelText: 'Katılım Puanı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Bu alan gerekli';
                  if (double.tryParse(value!) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Görsel URL
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: 'Görsel URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.image),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),

              // Süre (Saat)
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Yarışma Süresi (Saat)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.timer),
                  suffixText: 'saat',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Bu alan gerekli';
                  if (double.tryParse(value!) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Süre 0\'dan büyük olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Yarışma Ekle Butonu
              ElevatedButton(
                onPressed: _addCompetition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6600),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Yarışma Ekle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _entryFeeController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
