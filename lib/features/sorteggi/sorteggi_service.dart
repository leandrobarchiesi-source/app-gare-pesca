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
      );

  return List<Map<String, dynamic>>.from(
    data,
  );
}
}