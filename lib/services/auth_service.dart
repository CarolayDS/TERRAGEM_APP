import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String nombre,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
      await _supabase.from('usuarios').insert({
        'auth_id': user.id,
        'nombre': nombre,
        'correo': email,
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthApiException catch (e) {
      if (e.code == 'email_not_confirmed') {
        throw Exception("Debes confirmar tu correo antes de iniciar sesión.");
      } else if (e.code == 'invalid_credentials') {
        throw Exception("Correo o contraseña incorrectos.");
      } else {
        throw Exception("Error al iniciar sesión: ${e.message}");
      }
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUsuarioData() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('usuarios')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();

    return response;
  }
}
