# Supabase Edge Functions

Bu klasör, Bitkim Nasıl projesi için Supabase Edge Functions'ları içerir.

## Edge Functions Listesi

### 1. `get_plants.ts`
**Endpoint**: `GET /functions/v1/get_plants`
**Amaç**: Kullanıcının bitkilerini ve son sensör verilerini getirir
**Gerekli Environment Variables**:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 2. `create_user_profile.ts`
**Endpoint**: `POST /functions/v1/create_user_profile`
**Amaç**: Yeni kullanıcı profili oluşturur
**Gerekli Environment Variables**:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

### 3. `chatbot_gemini.ts`
**Endpoint**: `POST /functions/v1/chatbot_gemini`
**Amaç**: Gemini AI ile bitki bakım tavsiyesi verir
**Gerekli Environment Variables**:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `GEMINI_API_KEY`

### 4. `send_notification.ts`
**Endpoint**: `POST /functions/v1/send_notification`
**Amaç**: Firebase Cloud Messaging ile bildirim gönderir
**Gerekli Environment Variables**:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

### 5. `update_fcm_token.ts`
**Endpoint**: `POST /functions/v1/update_fcm_token`
**Amaç**: Kullanıcının FCM token'ını günceller
**Gerekli Environment Variables**:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## Kurulum ve Yapılandırma

### 1. Supabase CLI Kurulumu
```bash
npm install -g supabase
```

### 2. Supabase Projesine Bağlanma
```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### 3. Environment Variables Ayarlama

Supabase Dashboard'da her edge function için environment variables ayarlayın:

#### Temel Değişkenler
- `SUPABASE_URL`: Supabase proje URL'iniz
- `SUPABASE_ANON_KEY`: Supabase anonim anahtarınız
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase service role anahtarınız

#### AI ve Bildirim Değişkenleri
- `GEMINI_API_KEY`: Google Gemini API anahtarınız
- `FIREBASE_PROJECT_ID`: Firebase proje ID'niz
- `FIREBASE_CLIENT_EMAIL`: Firebase service account email
- `FIREBASE_PRIVATE_KEY`: Firebase private key

### 4. Edge Functions Deployment
```bash
# Tüm edge functions'ları deploy et
supabase functions deploy

# Belirli bir function'ı deploy et
supabase functions deploy get_plants
supabase functions deploy create_user_profile
supabase functions deploy chatbot_gemini
supabase functions deploy send_notification
supabase functions deploy update_fcm_token
```

## Veritabanı Şeması

### Tablolar

#### `auth.users` (Supabase Auth)
- `id` (uuid, primary key)

#### `user_profiles`
- `id` (uuid, primary key, references auth.users.id)
- `fcm_token` (text, nullable)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

#### `plants`
- `id` (uuid, primary key)
- `name` (text)
- `species` (text)
- `description` (text, nullable)
- `user_id` (uuid, references auth.users.id)
- `created_at` (timestamptz)

#### `sensor_data`
- `id` (uuid, primary key)
- `plant_id` (uuid, references plants.id)
- `humidity` (numeric)
- `light` (numeric)
- `recorded_at` (timestamptz)

#### `ai_results`
- `id` (uuid, primary key)
- `plant_id` (uuid, references plants.id)
- `status` (text)
- `message` (text)
- `analyzed_at` (timestamptz)

## Row Level Security (RLS) Politikaları

### plants tablosu
```sql
-- Kullanıcılar sadece kendi bitkilerini görebilir
CREATE POLICY "Users can view own plants" ON plants
FOR SELECT USING (auth.uid() = user_id);

-- Kullanıcılar sadece kendi bitkilerini ekleyebilir
CREATE POLICY "Users can insert own plants" ON plants
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Kullanıcılar sadece kendi bitkilerini güncelleyebilir
CREATE POLICY "Users can update own plants" ON plants
FOR UPDATE USING (auth.uid() = user_id);
```

### sensor_data tablosu
```sql
-- Kullanıcılar sadece kendi bitkilerinin sensör verilerini görebilir
CREATE POLICY "Users can view own sensor data" ON sensor_data
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM plants 
    WHERE plants.id = sensor_data.plant_id 
    AND plants.user_id = auth.uid()
  )
);
```

### user_profiles tablosu
```sql
-- Kullanıcılar sadece kendi profillerini görebilir
CREATE POLICY "Users can view own profile" ON user_profiles
FOR SELECT USING (auth.uid() = id);

-- Kullanıcılar sadece kendi profillerini güncelleyebilir
CREATE POLICY "Users can update own profile" ON user_profiles
FOR UPDATE USING (auth.uid() = id);
```

## API Kullanım Örnekleri

### Bitkileri Getir
```javascript
const { data, error } = await supabase.functions.invoke('get_plants', {
  headers: {
    Authorization: `Bearer ${userToken}`
  }
});
```

### Chatbot Kullan
```javascript
const { data, error } = await supabase.functions.invoke('chatbot_gemini', {
  body: {
    plant_id: 'plant-uuid',
    message: 'Bitkimin yaprakları sararıyor, ne yapmalıyım?',
    plant_info: {
      name: 'Çiçeğim',
      species: 'Orkide',
      current_moisture: 60,
      current_light: 800
    }
  }
});
```

### FCM Token Güncelle
```javascript
const { data, error } = await supabase.functions.invoke('update_fcm_token', {
  body: {
    user_id: 'user-uuid',
    fcm_token: 'firebase-fcm-token'
  }
});
```

## Güvenlik Notları

1. **API Anahtarları**: Hiçbir API anahtarını kod içinde saklamayın
2. **Environment Variables**: Tüm hassas bilgileri environment variables olarak saklayın
3. **RLS**: Row Level Security politikalarını mutlaka etkinleştirin
4. **Service Role Key**: Service role key'i sadece edge functions'da kullanın
5. **Anon Key**: Client-side kodda sadece anon key kullanın

## Hata Ayıklama

### Logları Görüntüleme
```bash
supabase functions logs
```

### Belirli Function Logları
```bash
supabase functions logs chatbot_gemini
```

### Canlı Logları İzleme
```bash
supabase functions logs --follow
```

## Test

### Local Development
```bash
supabase start
supabase functions serve
```

### Production Test
```bash
curl -X POST https://your-project.supabase.co/functions/v1/chatbot_gemini \
  -H "Content-Type: application/json" \
  -d '{"message": "test message"}'
```
