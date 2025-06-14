import 'package:flutter/material.dart';
import 'package:winpoi/core/services/firestore_service.dart';
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Renk paleti
const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
const Color secondaryColor = Color(0xFFE28B33); // Turuncu
const Color textColor = Color(0xFF424242); // Koyu Gri

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
  final _poiCostController = TextEditingController();
  final _imageController = TextEditingController();
  final _durationController = TextEditingController();

  bool _isLoading = false;
  final bool _isDeleting = false;

  Future<void> _addCompetition() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
          poiCost: int.parse(_poiCostController.text),
          endTime: endTime,
          image: _imageController.text,
        );

        await _firestoreService.addCompetition(competition);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Yarışma başarıyla eklendi'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Hata: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    // Bildirim gönder (FCM topic kullanarak)
    try {
      // Firebase Console üzerinden "contests" topic'ine notification gönderilebilir
      // Şimdilik sadece console'a log yazalım
      print('Yeni yarışma oluşturuldu: ${_titleController.text}');
      // TODO: FCM API kullanarak topic notification gönder
    } catch (e) {
      print('Bildirim gönderilirken hata: $e');
    }
  }

  Future<void> _deleteCompetition(String competitionId) async {
    try {
      await _firestoreService.deleteCompetition(competitionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Yarışma başarıyla silindi'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Hata tipine göre farklı mesajlar göster
      String errorMessage;
      if (e.toString().contains('Yarışma bulunamadı')) {
        errorMessage = 'Yarışma bulunamadı veya zaten silinmiş';
      } else if (e.toString().contains('yetkiniz bulunmuyor')) {
        errorMessage = 'Bu işlem için yetkiniz bulunmuyor';
      } else if (e.toString().contains('network')) {
        errorMessage = 'İnternet bağlantısını kontrol edin ve tekrar deneyin';
      } else {
        errorMessage =
            'Yarışma silinirken bir hata oluştu. Lütfen tekrar deneyin.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'TAMAM',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }

      // Debug için console'a da yazdır
      debugPrint('Yarışma silme hatası: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      String competitionId, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yarışmayı Sil'),
        content:
            Text('"$title" yarışmasını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _deleteCompetition(competitionId);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _poiCostController.clear();
    _imageController.clear();
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yarışma Yönetimi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mevcut Yarışmalar Listesi
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('competitions')
                  .where('endTime', isGreaterThan: Timestamp.now())
                  .orderBy('endTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final competitions = snapshot.data!.docs;

                if (competitions.isEmpty) {
                  return const Center(
                    child: Text('Aktif yarışma bulunmuyor'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktif Yarışmalar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: competitions.length,
                      itemBuilder: (context, index) {
                        final competition =
                            competitions[index].data() as Map<String, dynamic>;
                        final competitionId = competitions[index].id;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              competition['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              competition['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(
                                competitionId,
                                competition['title'] ?? '',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Yarışma Ekleme Formu
            const Text(
              'Yeni Yarışma Ekle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık
                  _buildGradientTextField(
                    controller: _titleController,
                    label: 'Yarışma Başlığı',
                    icon: Icons.title,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // Açıklama
                  _buildGradientTextField(
                    controller: _descriptionController,
                    label: 'Açıklama',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // Katılım Puanı
                  _buildGradientTextField(
                    controller: _poiCostController,
                    label: 'Katılım Puanı',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Bu alan gerekli';
                      if (int.tryParse(value!) == null) {
                        return 'Geçerli bir tam sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Görsel URL
                  _buildGradientTextField(
                    controller: _imageController,
                    label: 'Görsel URL',
                    icon: Icons.image,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Bu alan gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // Süre (Saat)
                  _buildGradientTextField(
                    controller: _durationController,
                    label: 'Yarışma Süresi (Saat)',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                    suffixText: 'saat',
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
                    onPressed: _isLoading ? null : _addCompetition,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Ekleniyor...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
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
          ],
        ),
      ),
    );
  }

  Widget _buildGradientTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15.5,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: primaryColor, size: 22),
        suffixText: suffixText,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            width: 2,
            style: BorderStyle.solid,
            color: primaryColor.withOpacity(0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            width: 2.2,
            style: BorderStyle.solid,
            color: secondaryColor.withOpacity(0.7),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            width: 2,
            style: BorderStyle.solid,
            color: primaryColor.withOpacity(0.18),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _poiCostController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
