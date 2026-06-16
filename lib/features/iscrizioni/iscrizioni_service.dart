import 'package:supabase_flutter/supabase_flutter.dart';

class IscrizioniService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getIscrizioni() async {
    final data = await _supabase.from('iscrizioni').select('''
          *,
          gara:gara_id (
            id,
            nome,
            modalita_gara,
            num_zone,
            componenti_squadra
          ),
          pescatore:pescatore_id (
            id,
            nome,
            cognome
          ),
          gruppo:gruppo_id (
            id,
            nome,
            lettera
          )
        ''').eq('deleted', false).order('created_at');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getGare() async {
    final data = await _supabase
        .from('gare')
        .select()
        .eq('deleted', false)
        .order('data_gara');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPescatori() async {
    final data = await _supabase.from('pescatori').select('''
          *,
          societa:societa_id (
            id,
            nome
          )
        ''').eq('deleted', false).order('cognome');

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

  Future<void> insertGruppo(
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('gruppi').insert(values);
  }

  Future<Map<String, dynamic>?> createGruppo(
    Map<String, dynamic> values,
  ) async {
    final result =
        await _supabase.from('gruppi').insert(values).select().single();

    return result;
  }

  Future<void> updateGruppo(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('gruppi').update(values).eq('id', id);
  }

  Future<void> deleteGruppo(
    String id,
  ) async {
    await _supabase.from('gruppi').update({
      'deleted': true,
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getGruppiByGara(
    String garaId,
  ) async {
    final data = await _supabase
        .from('gruppi')
        .select()
        .eq('gara_id', garaId)
        .eq('deleted', false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPescatoriBySocieta(
    String societaId,
  ) async {
    final data = await _supabase
        .from('pescatori')
        .select()
        .eq('societa_id', societaId)
        .eq('deleted', false)
        .order('cognome');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<String>> getPescatoriGiaIscritti(
    String garaId,
  ) async {
    final data = await _supabase
        .from('iscrizioni')
        .select('pescatore_id')
        .eq('gara_id', garaId)
        .eq('deleted', false);

    return data
        .map<String>(
          (e) => e['pescatore_id'].toString(),
        )
        .toList();
  }

  Future<void> insertIscrizione(
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('iscrizioni').insert(values);
  }

  Future<void> updateIscrizione(
    String id,
    Map<String, dynamic> values,
  ) async {
    await _supabase.from('iscrizioni').update(values).eq('id', id);
  }

  Future<void> deleteIscrizione(
    String id,
  ) async {
    await _supabase.from('iscrizioni').update({
      'deleted': true,
    }).eq('id', id);
  }

  Future<bool> pescatoreGiaIscritto(
    String garaId,
    String pescatoreId,
  ) async {
    final data = await _supabase
        .from('iscrizioni')
        .select('id')
        .eq('gara_id', garaId)
        .eq('pescatore_id', pescatoreId)
        .eq('deleted', false);

    return data.isNotEmpty;
  }
}
