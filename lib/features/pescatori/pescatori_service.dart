import 'package:supabase_flutter/supabase_flutter.dart';

class PescatoriService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPescatori() async {
    final data = await _supabase
        .from('pescatori')
        .select('''
          *,
          societa:societa_id(
            id,
            nome
          )
        ''')
        .order('cognome');

    return List<Map<String, dynamic>>.from(data);
  }
}