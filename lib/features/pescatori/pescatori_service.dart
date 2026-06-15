import 'package:supabase_flutter/supabase_flutter.dart';

class PescatoriService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPescatori() async {
    final data = await _supabase
        .from('pescatori')
        .select('''
          *,
          societa:societa_id (
            id,
            nome
          )
        ''')
        .eq('deleted', false)
        .order('cognome');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getSocieta() async {
    final data = await _supabase
        .from('societa')
        .select()
        .eq('deleted', false)
        .order('nome');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertPescatore(Map<String, dynamic> values) async {
    await _supabase.from('pescatori').insert(values);
  }

  Future<void> updatePescatore(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase
        .from('pescatori')
        .update(values)
        .eq('id', id);
  }

  Future<void> deletePescatore(String id) async {
    await _supabase
        .from('pescatori')
        .update({'deleted': true})
        .eq('id', id);
  }
}