import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  // Supabase configuration - Replace with your own values
  static const String _anonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL';

  static Future<String> getChatbotResponse({
    required String plantId,
    required String message,
    required String jwt,
    List<Map<String, dynamic>>? history,
    Map<String, dynamic>? plantInfo,
  }) async {
    try {
      // Edge function URL'ini düzelt
      final url = Uri.parse('$_supabaseUrl/functions/v1/chatbot-response');
      final authToken = (jwt.isNotEmpty ? jwt : _anonKey);

      print('Chatbot API çağrısı: $url');
      print('Plant ID: $plantId');
      print('Message: $message');

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'apikey': _anonKey,
        },
        body: jsonEncode({
          'plant_id': plantId,
          'message': message,
          if (history != null) 'history': history,
          if (plantInfo != null) 'plant_info': plantInfo,
        }),
      );

      print('Chatbot API response status: ${res.statusCode}');
      print('Chatbot API response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['response'] ?? 'No response received';
      } else if (res.statusCode == 404) {
        throw Exception('Chatbot function not found. Please check if the edge function is deployed.');
      } else {
        throw Exception('Chatbot error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('Chatbot service error: $e');
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        throw Exception('Chatbot servisi bulunamadı. Lütfen daha sonra tekrar deneyin.');
      }
      throw Exception('Chatbot hatası: $e');
    }
  }
}