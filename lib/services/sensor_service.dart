import 'package:supabase_flutter/supabase_flutter.dart';

class SensorService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, num>?> fetchLatestReading(String plantId) async {
    final res = await _client
        .from('sensor_data')
        .select('soil_moisture:humidity, light_level:light, recorded_at')
        .eq('plant_id', plantId)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (res == null) return null;
    return {
      'soil_moisture': (res['soil_moisture'] as num?) ?? 0,
      'light_level': (res['light_level'] as num?) ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> fetchHistory(String plantId, Duration back) async {
    final sinceIso = DateTime.now().subtract(back).toIso8601String();
    final data = await _client
        .from('sensor_data')
        .select('soil_moisture:humidity, light_level:light, recorded_at')
        .eq('plant_id', plantId)
        .gte('recorded_at', sinceIso)
        .order('recorded_at', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }
}