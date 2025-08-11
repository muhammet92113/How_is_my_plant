import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<User?> signUp(String email, String password) async {
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<User?> signIn(String email, String password) async {
    final AuthResponse res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
