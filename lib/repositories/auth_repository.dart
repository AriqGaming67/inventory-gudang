import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': 'staff'},
    );

    if (response.user != null) {
      try {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'role': 'staff',
        });
      } catch (e) {
        // Abaikan jika duplicate constraint
      }
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
