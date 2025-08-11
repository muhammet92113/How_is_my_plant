import 'package:supabase_flutter/supabase_flutter.dart';

class PlantService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPlants() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }
    final data = await _client
        .from('plants')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>?> getPlant(String plantId) async {
    final data = await _client
        .from('plants')
        .select()
        .eq('id', plantId)
        .single();
    return data as Map<String, dynamic>?;
  }

  Future<void> addPlant(String name, {String? description, String? deviceId, String? species}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Kullanıcı oturumu yok');
    }
    await _client.from('plants').insert({
      'name': name,
      'user_id': userId,
      'description': description,
      'species': species,
      // created_at Supabase tarafında default now() ile dolacak
    });
  }

  Future<void> updatePlant(String plantId, {required String name, String? description, String? species}) async {
    await _client.from('plants').update({
      'name': name,
      'description': description,
      'species': species,
    }).eq('id', plantId);
  }
  Future<void> deletePlant(String plantId) async {
    await _client.from('plants').delete().eq('id', plantId);
  }
}