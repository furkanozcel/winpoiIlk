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
  final _prizeController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _addCompetition() async {
    if (_formKey.currentState!.validate()) {
      try {
        final competition = Competition(
          id: '', // Firestore otomatik oluşturacak
          title: _titleController.text,
          description: _descriptionController.text,
          prize: _prizeController.text,
          dateTime: _selectedDate,
          entryFee: double.parse(_entryFeeController.text),
          imageUrl: _imageUrlController.text,
          status: 'upcoming',
        );

        await _firestoreService.addCompetition(competition);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yarışma başarıyla eklendi')),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }

    final notificationService = NotificationService();
    notificationService.sendNotificationToAllUsers(
        title: "Yarışma Vakti!!!",
        message: "Yeni yarışma listeye eklenmiştir.",
        type: "competition");
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _prizeController.clear();
    _entryFeeController.clear();
    _imageUrlController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yarışma Yönetimi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Yarışma Başlığı'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prizeController,
                decoration: const InputDecoration(labelText: 'Ödül'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _entryFeeController,
                decoration: const InputDecoration(labelText: 'Katılım Ücreti'),
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
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Görsel URL'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addCompetition,
                child: const Text('Yarışma Ekle'),
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
    _prizeController.dispose();
    _entryFeeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
