import 'package:supabase_flutter/supabase_flutter.dart';

class SorteggiService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getGare() async {
    final data = await supabase
        .from('gare')
        .select('''
          *,
          trofeo:trofei(*)
        ''')
        .eq(
          'deleted',
          false,
        )
        .order(
          'data_gara',
        );

    return List<Map<String, dynamic>>.from(
      data,
    );
  }

  Future<List<Map<String, dynamic>>> getIscrizioniByGara(
    String garaId,
  ) async {
    final data = await supabase
        .from('iscrizioni')
        .select('''
          *,
          pescatore:pescatori(*),
          gruppo:gruppi(*)
        ''')
        .eq(
          'gara_id',
          garaId,
        )
        .eq(
          'deleted',
          false,
        );

    return List<Map<String, dynamic>>.from(
      data,
    );
  }

  Future<List<Map<String, dynamic>>> getPresorteggioByGara(
    String garaId,
  ) async {
    final data = await supabase
        .from('presorteggi')
        .select('''
        *,
        pescatore:pescatore_id (
          id,
          nome,
          cognome,
          societa:societa_id (
            id,
            nome
          )
        ),
        gruppo:gruppo_id (
          id,
          nome,
          lettera,
          tipo,
          societa:societa_id (
            id,
            nome
          )
        )
      ''')
        .eq(
          'gara_id',
          garaId,
        )
        .eq(
          'deleted',
          false,
        );

    return List<Map<String, dynamic>>.from(
      data,
    );
  }

  Future<void> eliminaPresorteggio(
    String garaId,
  ) async {
    await supabase.from('presorteggi').delete().eq(
          'gara_id',
          garaId,
        );
  }

  Future<void> salvaPresorteggio(
    List<Map<String, dynamic>> righe,
  ) async {
    await supabase.from('presorteggi').insert(
          righe,
        );
  }

  Future<List<Map<String, dynamic>>> getSorteggioByGara(
    String garaId,
  ) async {
    final data = await supabase
        .from('sorteggi')
        .select('''
          *,
          pescatore:pescatori(*),
          gruppo:gruppi(*)
        ''')
        .eq(
          'gara_id',
          garaId,
        )
        .eq(
          'deleted',
          false,
        );

    return List<Map<String, dynamic>>.from(
      data,
    );
  }

  Future<void> eliminaSorteggio(
    String garaId,
  ) async {
    await supabase.from('sorteggi').delete().eq(
          'gara_id',
          garaId,
        );
  }

  Future<void> salvaSorteggio(
    List<Map<String, dynamic>> righe,
  ) async {
    await supabase.from('sorteggi').insert(
          righe,
        );
  }
}
