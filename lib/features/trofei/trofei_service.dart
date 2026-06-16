import 'package:supabase_flutter/supabase_flutter.dart';

class TrofeiService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTrofei() async {
    final data = await _supabase
        .from('trofei')
        .select()
        .eq('deleted', false)
        .order('nome');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertTrofeo(
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('trofei').insert(values);
  }

  Future<void> updateTrofeo(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('trofei').update(values).eq('id', id);
  }

  Future<void> deleteTrofeo(
    String id,
  ) async {
    await _supabase.from('trofei').update({
      'deleted': true,
    }).eq('id', id);
  }
}
