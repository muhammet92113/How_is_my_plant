# Proje Yapısı

```
bitkim_nasil/
├── README.md                           # Ana proje açıklaması
├── PROJECT_STRUCTURE.md                # Bu dosya
├── pubspec.yaml                        # Flutter bağımlılıkları
├── pubspec.lock                        # Flutter bağımlılık kilidi
├── .gitignore                          # Git ignore kuralları
│
├── lib/                                # Flutter uygulama kodu
│   ├── main.dart                       # Ana uygulama girişi
│   ├── screens/                        # Ekran dosyaları
│   ├── widgets/                        # Widget bileşenleri
│   ├── services/                       # Servis katmanı
│   ├── models/                         # Veri modelleri
│   └── utils/                          # Yardımcı fonksiyonlar
│
├── arduino/                            # Arduino IoT projesi
│   ├── README.md                       # Arduino kurulum rehberi
│   └── plant_monitor.ino               # ESP32 sensör kodu
│
├── supabase_edge_functions/            # Supabase Edge Functions
│   ├── README.md                       # Edge Functions rehberi
│   ├── get_plants.ts                   # Bitki verilerini getir
│   ├── create_user_profile.ts          # Kullanıcı profili oluştur
│   ├── chatbot_gemini.ts               # AI chatbot
│   ├── send_notification.ts            # Bildirim gönder
│   └── update_fcm_token.ts             # FCM token güncelle
│
├── android/                            # Android platform dosyaları
├── ios/                                # iOS platform dosyaları
├── web/                                # Web platform dosyaları
├── windows/                            # Windows platform dosyaları
├── macos/                              # macOS platform dosyaları
└── linux/                              # Linux platform dosyaları
```

## Teknoloji Stack

### Frontend
- **Flutter**: Cross-platform mobil uygulama
- **Dart**: Programlama dili

### Backend
- **Supabase**: Backend-as-a-Service
  - PostgreSQL veritabanı
  - Authentication
  - Real-time subscriptions
  - Edge Functions

### AI ve Bildirimler
- **Google Gemini**: AI chatbot
- **Firebase Cloud Messaging**: Push notifications

### IoT
- **ESP32**: Mikrodenetleyici
- **Arduino**: IoT programlama
- **Sensörler**: Toprak nem ve ışık sensörleri

## Veri Akışı

1. **ESP32** → Sensör verilerini okur
2. **Arduino** → Verileri Supabase'e gönderir
3. **Supabase** → Verileri PostgreSQL'de saklar
4. **Flutter App** → Verileri Supabase'den alır
5. **Edge Functions** → AI işlemleri ve bildirimler
6. **Gemini AI** → Bitki bakım tavsiyeleri
7. **Firebase** → Push notifications

## Güvenlik

- Tüm API anahtarları environment variables olarak saklanır
- Row Level Security (RLS) politikaları etkin
- Service role key sadece edge functions'da kullanılır
- Client-side'da sadece anon key kullanılır

## Deployment

### Flutter App
- Android: Google Play Store
- iOS: App Store
- Web: Vercel/Netlify

### Supabase
- Edge Functions: Supabase Dashboard
- Database: Otomatik yönetim

### Arduino
- ESP32'ye Arduino IDE ile yükleme
