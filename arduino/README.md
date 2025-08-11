# Arduino Plant Monitor

Bu Arduino projesi, ESP32 kullanarak bitki izleme sistemi için sensör verilerini toplar ve Supabase veritabanına gönderir.

## Donanım Gereksinimleri

- ESP32 geliştirme kartı
- Toprak nem sensörü (analog)
- LDR (Işık sensörü) - analog
- Bağlantı kabloları

## Bağlantı Şeması

- **Toprak Nem Sensörü**: GPIO 34 (Analog pin)
- **LDR Sensörü**: GPIO 35 (Analog pin)

## Kurulum

1. Arduino IDE'yi yükleyin
2. ESP32 board paketini yükleyin
3. Gerekli kütüphaneleri yükleyin:
   - WiFi
   - HTTPClient
   - time

## Yapılandırma

Kod içerisinde aşağıdaki değişkenleri kendi değerlerinizle güncelleyin:

```cpp
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
String supabaseUrl = "YOUR_SUPABASE_URL";
String supabaseApiKey = "YOUR_SUPABASE_API_KEY";
String plantId = "YOUR_PLANT_ID";
```

## Özellikler

- Toprak nem seviyesi ölçümü
- Işık seviyesi ölçümü
- Wi-Fi bağlantısı
- NTP zaman senkronizasyonu
- Supabase'e otomatik veri gönderimi
- ISO 8601 zaman formatı

## Veri Formatı

Supabase'e gönderilen JSON verisi:

```json
{
  "plant_id": "468f42d6-376e-4087-b0fb-6dc589ad73e3",
  "humidity": 2048,
  "light": 1024,
  "recorded_at": "2025-01-11T10:30:00Z"
}
```

## Çalışma Prensibi

1. ESP32 başlatılır ve Wi-Fi'ya bağlanır
2. NTP sunucularından zaman senkronizasyonu yapılır
3. Her saniye sensör verileri okunur
4. Veriler JSON formatında Supabase'e gönderilir
5. Bağlantı koptuğunda otomatik olarak yeniden bağlanır

## Sorun Giderme

- **Wi-Fi bağlantı sorunu**: SSID ve şifrenizi kontrol edin
- **Sensör okuma sorunu**: Bağlantıları ve pin numaralarını kontrol edin
- **Supabase bağlantı sorunu**: API anahtarınızı ve URL'yi kontrol edin
