import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = 'https://<your-supabase-project>.supabase.co/functions/v1';

  Future<void> sendPushNotification(String plantId, String message, String userAccessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-push-notification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userAccessToken', // Supabase auth token
      },
      body: jsonEncode({
        'plant_id': plantId,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      print('Bildirim gönderildi');
    } else {
      print('Bildirim gönderme hatası: ${response.body}');
    }
  }
}
