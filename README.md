# Bitkim Nasıl

Flutter ile geliştirilmiş bir mobil uygulama projesi. Bu proje, kullanıcılara çeşitli konularda bilgi ve rehberlik sağlamak amacıyla tasarlanmıştır.

## Özellikler

- Modern ve kullanıcı dostu arayüz
- Gemini AI entegrasyonu ile chatbot özelliği
- Supabase backend entegrasyonu
- Cross-platform destek (iOS, Android, Web)

## Teknolojiler

- **Frontend**: Flutter
- **Backend**: Supabase
- **AI**: Google Gemini
- **Edge Functions**: Deno
- **IoT**: ESP32 (Arduino)

## Kurulum

1. Flutter SDK'yı yükleyin
2. Projeyi klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/bitkim_nasil.git
   cd bitkim_nasil
   ```
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Proje Bileşenleri

### Flutter Uygulaması
Ana mobil uygulama, kullanıcı arayüzü ve Gemini AI chatbot entegrasyonu.

### Supabase Edge Functions
Proje, 5 farklı Supabase Edge Function kullanır:
- **get_plants**: Kullanıcının bitkilerini ve sensör verilerini getirir
- **create_user_profile**: Yeni kullanıcı profili oluşturur
- **chatbot_gemini**: Gemini AI ile bitki bakım tavsiyesi verir
- **send_notification**: Firebase Cloud Messaging ile bildirim gönderir
- **update_fcm_token**: Kullanıcının FCM token'ını günceller

Detaylı kurulum ve yapılandırma için `supabase_edge_functions/README.md` dosyasına bakın.

### Arduino IoT Sistemi
ESP32 tabanlı sensör sistemi, bitki izleme için toprak nem ve ışık seviyesi verilerini toplar. Detaylar için `arduino/` klasörüne bakın.

## Katkıda Bulunma

1. Bu repository'yi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik eklendi'`)
4. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
