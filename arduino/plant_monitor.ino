#include <WiFi.h>
#include <HTTPClient.h>
#include <time.h>

// WiFi Ayarları - Kendi değerlerinizle değiştirin
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Supabase Ayarları - Kendi değerlerinizle değiştirin
String supabaseUrl = "YOUR_SUPABASE_URL/rest/v1/sensor_data"; 
String supabaseApiKey = "YOUR_SUPABASE_ANON_KEY"; 

#define SOIL_PIN 34  
#define LDR_PIN 35    

// Bitki ID'si - Kendi bitki ID'nizle değiştirin
String plantId = "YOUR_PLANT_ID"; 

void setup() {
  Serial.begin(115200);

  // ADC ayarları: 12-bit çözünürlük ve geniş giriş aralığı için 11 dB attenuasyon
  analogReadResolution(12);
  analogSetPinAttenuation(SOIL_PIN, ADC_11db);
  analogSetPinAttenuation(LDR_PIN, ADC_11db);

  WiFi.begin(ssid, password);
  Serial.print("Wi-Fi'a bağlanılıyor");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi bağlandı!");

  // Zaman senkronizasyonu
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("Zaman senkronizasyonu başlatıldı. Lütfen birkaç saniye bekleyin...");

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nZaman senkronize edildi!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // Sensör verilerini oku
    int soilRawValue = analogRead(SOIL_PIN);
    int soilValue = 4095 - soilRawValue; // 0 ↔ 4095 tersleme
    int lightRawValue = analogRead(LDR_PIN);  
    int lightValue = 4095 - lightRawValue;    

    Serial.print("Toprak Nemi: ");
    Serial.print(soilValue);
    Serial.print(" | Işık: ");
    Serial.println(lightValue);

    // JSON verisi oluştur
    String jsonData = "{";
    jsonData += "\"plant_id\": \"" + plantId + "\",";
    jsonData += "\"humidity\": " + String(soilValue) + ",";
    jsonData += "\"light\": " + String(lightValue) + ",";
    jsonData += "\"recorded_at\": \"" + getISOTime() + "\"";
    jsonData += "}";

    // Supabase'e POST isteği gönder
    HTTPClient http;
    http.begin(supabaseUrl);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Accept", "application/json");
    http.addHeader("apikey", supabaseApiKey);
    http.addHeader("Authorization", "Bearer " + supabaseApiKey);
    http.addHeader("Prefer", "return=representation");

    int httpResponseCode = http.POST(jsonData);

    if (httpResponseCode > 0) {
      Serial.print("Supabase yanıt kodu: ");
      Serial.println(httpResponseCode);
      Serial.println(http.getString());
    } else {
      Serial.print("HTTP hata kodu: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  } else {
    Serial.println("Wi-Fi bağlantısı koptu, yeniden bağlanılıyor...");
    WiFi.begin(ssid, password);
  }

  delay(1000); // 1 saniyede bir veri gönder
}

// ISO 8601 Zaman Formatı
String getISOTime() {
  time_t now;
  time(&now);
  // 3 saat geri kaydır (Türkiye saati UTC+3 olduğu için UTC'ye göre 3 saat önce)
  now -= 3 * 3600;

  struct tm timeinfo;
  gmtime_r(&now, &timeinfo);

  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}
