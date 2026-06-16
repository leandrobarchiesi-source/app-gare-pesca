import 'package:flutter/material.dart';
import 'iscrizioni_service.dart';

class IscrizioneForm extends StatefulWidget {
  const IscrizioneForm({
    super.key,
  });

  @override
  State<IscrizioneForm> createState() => _IscrizioneFormState();
}

class _IscrizioneFormState extends State<IscrizioneForm> {
  final service = IscrizioniService();

  List<Map<String, dynamic>> gare = [];
  List<Map<String, dynamic>> pescatori = [];
  List<String> pescatoriGiaIscritti = [];

  String? garaId;
  String? pescatoreId;
  String? pescatore1Id;
  String? pescatore2Id;
  String? societaId;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    caricaDati();
  }

  Future<void> caricaDati() async {
    final g = await service.getGare();
    final p = await service.getPescatori();

    setState(() {
      gare = g;
      pescatori = p;
    });
  }

  Future<void> caricaPescatoriGiaIscritti() async {
    if (garaId == null) {
      return;
    }

    final ids = await service.getPescatoriGiaIscritti(
      garaId!,
    );

    setState(() {
      pescatoriGiaIscritti = ids;
    });
  }

  Future<void> salva() async {
    if (garaId == null) {
      return;
    }

    final garaSelezionata = gare.firstWhere((g) => g['id'] == garaId);

    final modalita = garaSelezionata['modalita_gara'] ?? '';

    if (modalita == 'Singola') {
      if (pescatoreId == null) {
        return;
      }
    }

    if (modalita == 'Coppie a Box') {
      if (pescatore1Id == null || pescatore2Id == null) {
        return;
      }
    }

    setState(() => loading = true);

    try {
      if (modalita == 'Singola') {
        final giaIscritto = await service.pescatoreGiaIscritto(
          garaId!,
          pescatoreId!,
        );

        if (giaIscritto) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pescatore già iscritto alla gara',
              ),
            ),
          );

          return;
        }

        await service.insertIscrizione({
          'gara_id': garaId,
          'pescatore_id': pescatoreId,
          'gruppo_id': null,
          'zona': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (modalita == 'Coppie a Box') {
        final giaIscritto1 = await service.pescatoreGiaIscritto(
          garaId!,
          pescatore1Id!,
        );

        final giaIscritto2 = await service.pescatoreGiaIscritto(
          garaId!,
          pescatore2Id!,
        );

        if (giaIscritto1 || giaIscritto2) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Uno dei pescatori è già iscritto',
              ),
            ),
          );

          return;
        }

        final gruppo = await service.createGruppo({
          'gara_id': garaId,
          'societa_id': societaId,
          'tipo': 'COPPIA',
          'nome': 'Coppia',
          'lettera': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.insertIscrizione({
          'gara_id': garaId,
          'pescatore_id': pescatore1Id,
          'gruppo_id': gruppo!['id'],
          'zona': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.insertIscrizione({
          'gara_id': garaId,
          'pescatore_id': pescatore2Id,
          'gruppo_id': gruppo['id'],
          'zona': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final garaSelezionata = gare.where((g) => g['id'] == garaId);

    String modalita = '';
    String tipoComposizione = '';

    if (garaSelezionata.isNotEmpty) {
      modalita = garaSelezionata.first['modalita_gara'] ?? '';

      tipoComposizione = garaSelezionata.first['tipo_composizione'] ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuova Iscrizione',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: garaId,
            decoration: const InputDecoration(
              labelText: 'Gara',
            ),
            items: gare.map((g) {
              return DropdownMenuItem<String>(
                value: g['id'],
                child: Text(
                  g['nome'],
                ),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                garaId = v;
              });
            },
          ),
          const SizedBox(height: 12),
          if (garaId != null)
            ListTile(
              title: const Text('Modalità'),
              subtitle: Text(
                modalita,
              ),
            ),
          const SizedBox(height: 12),
          if (modalita == 'Singola')
            DropdownButtonFormField<String>(
              value: pescatoreId,
              decoration: const InputDecoration(
                labelText: 'Pescatore',
              ),
              items: pescatori.map((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(
                    '${p['cognome']} ${p['nome']}',
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  pescatoreId = v;
                });
              },
            ),
          if (modalita == 'Coppie a Box' && tipoComposizione == 'Libera') ...[
            const SizedBox(height: 12),
            Text(
              'Coppia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore1Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore 1',
              ),
              items: pescatori.map((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(
                    '${p['cognome']} ${p['nome']}',
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  pescatore1Id = v;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore2Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore 2',
              ),
              items: pescatori
                  .where(
                (p) => p['id'] != pescatore1Id,
              )
                  .map((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(
                    '${p['cognome']} ${p['nome']}',
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  pescatore2Id = v;
                });
              },
            ),
          ],
          if (modalita == 'Coppie a Box' &&
              tipoComposizione == 'Di Società') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: societaId,
              decoration: const InputDecoration(
                labelText: 'Società',
              ),
              items: pescatori
                  .map((p) => p['societa'])
                  .where((s) => s != null)
                  .fold<Map<String, dynamic>>(
                    {},
                    (map, s) {
                      map[s['id']] = s;
                      return map;
                    },
                  )
                  .values
                  .map((s) {
                    return DropdownMenuItem<String>(
                      value: s['id'],
                      child: Text(
                        s['nome'],
                      ),
                    );
                  })
                  .toList(),
              onChanged: (v) {
                setState(() {
                  societaId = v;
                  pescatore1Id = null;
                  pescatore2Id = null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore1Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore 1',
              ),
              items: pescatori
                  .where(
                (p) => p['societa_id'] == societaId,
              )
                  .map((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(
                    '${p['cognome']} ${p['nome']}',
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  pescatore1Id = v;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore2Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore 2',
              ),
              items: pescatori
                  .where(
                (p) => p['societa_id'] == societaId && p['id'] != pescatore1Id,
              )
                  .map((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(
                    '${p['cognome']} ${p['nome']}',
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  pescatore2Id = v;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : salva,
            child: const Text(
              'Salva',
            ),
          ),
        ],
      ),
    );
  }
}
