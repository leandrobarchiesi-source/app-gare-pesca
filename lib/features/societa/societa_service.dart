import 'package:supabase_flutter/supabase_flutter.dart';

class SocietaService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getSocieta() async {
    final data = await _supabase
        .from('societa')
        .select()
        .eq('deleted', false)
        .order('nome');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertSocieta({
    required String nome,
    String? citta,
    String? telefono,
    String? email,
  }) async {
    await _supabase.from('societa').insert({
      'nome': nome,
      'citta': citta,
      'telefono': telefono,
      'email': email,
    });
  }

  Future<void> updateSocieta(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase
        .from('societa')
        .update(values)
        .eq('id', id);
  }

  Future<void> deleteSocieta(String id) async {
    await _supabase
        .from('societa')
        .update({'deleted': true})
        .eq('id', id);
  }
}