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
      'tipo_composizione': values['tipo_composizione'],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('trofeo_id', id);
  }

  Future<void> deleteTrofeo(
    String id,
  ) async {
    final gare = await _supabase
        .from('gare')
        .select('id')
        .eq('trofeo_id', id)
        .eq('deleted', false);

    for (final gara in gare) {
      await _supabase.from('iscrizioni').update({
        'deleted': true,
      }).eq('gara_id', gara['id']);

      await _supabase.from('gruppi').update({
        'deleted': true,
      }).eq('gara_id', gara['id']);
    }

    await _supabase.from('gare').update({
      'deleted': true,
    }).eq('trofeo_id', id);

    await _supabase.from('trofei').update({
      'deleted': true,
    }).eq('id', id);
  }
}
