import 'package:supabase_flutter/supabase_flutter.dart';

class GareService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getGare() async {
    final data = await _supabase.from('gare').select('''
          *,
          trofeo:trofeo_id (
            id,
            nome
          ),
          societa:societa_organizzatrice_id (
            id,
            nome
          )
        ''').eq('deleted', false).order('data_gara');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getTrofei() async {
    final data = await _supabase
        .from('trofei')
        .select()
        .eq('deleted', false)
        .order('nome');

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

  Future<void> insertGara(
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('gare').insert(values);
  }

  Future<void> updateGara(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('gare').update(values).eq('id', id);
  }

  Future<void> deleteGara(
    String id,
  ) async {
    await _supabase.from('iscrizioni').update({
      'deleted': true,
    }).eq('gara_id', id);

    await _supabase.from('gruppi').update({
      'deleted': true,
    }).eq('gara_id', id);

    await _supabase.from('gare').update({
      'deleted': true,
    }).eq('id', id);
  }
}
