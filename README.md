# WinPoi - Konum Tabanlı Mobil Oyun Uygulaması

WinPoi, kullanıcıların sanal haritalar üzerinde ödülleri arayarak gerçek ödüller kazandığı konum-tabanlı bir mobil oyun uygulamasıdır.

## 🚀 Özellikler

- **Konum-Tabanlı Ödül Arama**: Gerçek dünya haritalarında sanal ödülleri arama
- **Zaman Bazlı Yarışmalar**: 10-24 saat süren yarışmalara katılım
- **XP ve Yetenek Sistemi**: Oyun içi ilerlemeler
- **Gerçek Zamanlı Sıralama**: Canlı liderlik tablosu
- **Sosyal Özellikler**: Kullanıcı profilleri ve istatistikler

## 🛠️ Teknoloji Stack'i

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider Pattern
- **Mimari**: Clean Architecture
- **Error Handling**: Kapsamlı hata yönetimi sistemi

## 🎯 Error Handling Sistemi

WinPoi, gelişmiş bir error handling sistemi kullanır:

### 🔧 Temel Bileşenler

#### 1. Exception Sınıfları (`lib/core/errors/app_exception.dart`)
```dart
// Temel exception sınıfı
abstract class AppException implements Exception {
  final String message;
  final String code;
  final String? details;
}

// Özel exception türleri
- AuthException      // Kimlik doğrulama hataları
- DatabaseException  // Veritabanı hataları
- NetworkException   // Ağ bağlantı hataları
- ValidationException // Validasyon hataları
- BusinessException  // İş mantığı hataları
- StorageException   // Dosya/depolama hataları
```

#### 2. Error Handler (`lib/core/errors/error_handler.dart`)
```dart
// Firebase hatalarını kullanıcı dostu mesajlara dönüştürür
ErrorHandler.handleError(dynamic error)

// Hata türüne göre UI renkleri ve ikonlar
ErrorHandler.getErrorColor(AppException exception)
ErrorHandler.getErrorIcon(AppException exception)

// Retry mekanizması kontrolü
ErrorHandler.shouldRetry(AppException exception)
```

#### 3. Error Widget'ları (`lib/core/errors/error_widgets.dart`)
```dart
// Farklı kullanım senaryoları için widget'lar
ErrorSnackBar.show()        // SnackBar ile hata gösterimi
ErrorPageWidget()           // Tam sayfa hata ekranı
InlineErrorWidget()         // Liste içi hata gösterimi
LoadingErrorWidget()        // Loading sırasında hata
```

#### 4. Async Error Handling (`lib/core/errors/async_error_handler.dart`)
```dart
// Future extension'ları
future.handleErrors()                    // Temel hata yakalama
future.handleErrorsWithTimeout()         // Timeout ile hata yakalama
future.catchWithSnackBar(context)       // UI ile entegre hata gösterimi
future.withRetry()                       // Retry mekanizması

// Provider mixin'i
AsyncErrorHandlerMixin                   // ChangeNotifier için hata yönetimi
```

### 📝 Kullanım Örnekleri

#### Basit Async İşlem
```dart
Future<void> _login() async {
  final authProvider = context.read<AuthProvider>();
  final result = await authProvider.signInWithEmail(
    email: email,
    password: password,
  );
  
  if (result != null && mounted) {
    Navigator.pushReplacementNamed('/home');
  } else if (authProvider.hasError && mounted) {
    ErrorSnackBar.show(context, authProvider.error!);
  }
}
```

#### Retry Mekanizması
```dart
Future<UserCredential?> signInWithRetry() async {
  return await runAsyncWithRetry<UserCredential>(
    () => _authService.signInWithEmail(email: email, password: password),
    maxRetries: 3,
    delay: Duration(seconds: 2),
  );
}
```

#### Provider'da Error Handling
```dart
class AuthProvider extends ChangeNotifier with AsyncErrorHandlerMixin {
  Future<UserCredential?> signIn(String email, String password) async {
    return await runAsync<UserCredential>(() async {
      return await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    });
  }
}
```

#### Widget'da Error Durumu
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.hasError) {
      return InlineErrorWidget(
        exception: authProvider.error!,
        onRetry: () => authProvider.retryLastOperation(),
      );
    }
    
    return YourContentWidget();
  },
)
```

### 🔍 Hata Türleri ve Mesajları

#### Firebase Auth Hataları
- `user-not-found` → "Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı"
- `wrong-password` → "Hatalı şifre girdiniz"
- `email-already-in-use` → "Bu e-posta adresi zaten kullanımda"
- `weak-password` → "Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin"

#### Firestore Hataları
- `permission-denied` → "Bu işlem için yetkiniz yok"
- `not-found` → "Aradığınız veri bulunamadı"
- `unavailable` → "Servis şu anda kullanılamıyor"

#### Network Hataları
- `network_error` → "İnternet bağlantısı sorunu"
- `timeout_error` → "İstek zaman aşımına uğradı"

### 🎨 UI/UX Özellikleri

- **Renk Kodları**: Her hata türü için özel renkler
- **İkonlar**: Hata türüne uygun ikonlar
- **Animasyonlar**: Yumuşak geçişler ve feedback
- **Retry Buttons**: Uygun durumlarda tekrar deneme seçeneği
- **Loading States**: İşlem sırasında kullanıcı bildirimi

### 🔧 Yapılandırma

#### Global Error Handler Başlatma
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handling'i başlat
  GlobalErrorHandler.initialize();
  
  runApp(MyApp());
}
```

#### Debug Logging
Debug modda tüm hatalar konsola detaylı şekilde yazdırılır:
```
🚨 ERROR: user-not-found
📝 Message: Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı
📋 Details: Firebase: There is no user record corresponding to this identifier
📍 Stack Trace: ...
──────────────────────────────────────────────────
```

## 📱 Getting Started

### Prerequisites
- Flutter SDK (3.5.4+)
- Dart SDK
- Firebase CLI
- Android Studio / VS Code

### Installation

1. **Repository'yi klonlayın**
```bash
git clone https://github.com/your-username/winpoi.git
cd winpoi
```

2. **Dependencies'leri yükleyin**
```bash
flutter pub get
```

3. **Firebase yapılandırmasını tamamlayın**
```bash
flutterfire configure
```

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 🏗️ Proje Yapısı

```
lib/
├── core/
│   ├── errors/              # Error handling sistemi
│   │   ├── app_exception.dart
│   │   ├── error_handler.dart
│   │   ├── error_widgets.dart
│   │   └── async_error_handler.dart
│   ├── models/              # Veri modelleri
│   ├── providers/           # State management
│   ├── services/            # Backend servisleri
│   ├── theme/               # UI tema sistemi
│   └── navigation/          # Navigasyon sistemi
├── features/                # Özellik bazlı modüller
│   ├── auth/                # Kimlik doğrulama
│   ├── home_page/           # Ana sayfa
│   ├── profile_page/        # Profil yönetimi
│   ├── leadboard_page/      # Liderlik tablosu
│   ├── admin/               # Admin paneli
│   ├── game/                # Oyun sistemi
│   ├── onboarding/          # Karşılama ekranları
│   └── notifications/       # Bildirim sistemi
└── assets/                  # Görsel kaynaklar
```

## 🧪 Testing

```bash
# Unit testleri çalıştır
flutter test

# Integration testleri çalıştır
flutter drive --target=test_driver/app.dart

# Widget testleri çalıştır
flutter test test/widget_test.dart
```

## 📚 Dokümantasyon

- [PRD (Product Requirements Document)](lib/PRD.md)
- [Cursor AI Kuralları](lib/cursor-rules.md)
- [API Dokümantasyonu](docs/api.md)
- [UI/UX Rehberi](docs/ui-guide.md)

## 🤝 Contributing

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit'leyin (`git commit -m 'Add some amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 License

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👥 Takım

- **Geliştirici**: [Your Name]
- **Tasarımcı**: [Designer Name]
- **Project Manager**: [PM Name]

## 📞 İletişim

- Email: your.email@example.com
- Website: https://winpoi.app
- Discord: [Discord Server Link]

---

## 🆕 Changelog

### v1.0.0 (2024-01-XX)
- ✅ Temel kimlik doğrulama sistemi
- ✅ Ana sayfa ve navigasyon
- ✅ Profil yönetimi
- ✅ Kapsamlı error handling sistemi
- ✅ Firebase entegrasyonu
- 🔄 Unity oyun entegrasyonu (devam ediyor)
- 🔄 Ödeme sistemi (planlanan)

**Error Handling Sistemi v1.0**
- ✅ Özel exception sınıfları
- ✅ Firebase error mapping
- ✅ UI error widget'ları  
- ✅ Async error handling extensions
- ✅ Global error management
- ✅ Retry mekanizması
- ✅ Kullanıcı dostu hata mesajları
