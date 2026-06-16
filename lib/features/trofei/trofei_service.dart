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

    // Aggiorna automaticamente
    // tutte le gare del trofeo

    await _supabase.from('gare').update({
      'modalita': values['modalita_gara'],
      'modalita_gara': values['modalita_gara'],
      'num_zone': values['num_zone'],
      'componenti_squadra': values['componenti_squadra'],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('trofeo_id', id);
  }

  Future<void> deleteTrofeo(
    String id,
  ) async {
    // Elimina logicamente il trofeo

    await _supabase.from('trofei').update({
      'deleted': true,
    }).eq('id', id);

    // Elimina logicamente
    // tutte le gare associate

    await _supabase.from('gare').update({
      'deleted': true,
    }).eq('trofeo_id', id);
  }
}
