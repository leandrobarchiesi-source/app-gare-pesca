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
  List<String?> pescatoriSquadra = [];
  List<int?> zoneSquadra = [];

  String? garaId;
  String? pescatoreId;
  String? pescatore1Id;
  String? pescatore2Id;
  String? societaId;

  int? zona1;
  int? zona2;

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
    pescatoriSquadra = [];
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

    final componentiSquadra = garaSelezionata['componenti_squadra'] ?? 1;

    if (modalita == 'Individuale') {
      if (pescatoreId == null) {
        return;
      }
    }

    if (modalita == 'Coppie a Box') {
      if (pescatore1Id == null || pescatore2Id == null) {
        return;
      }
    }

    if (modalita == 'Coppie a Zone') {
      if (pescatore1Id == null ||
          pescatore2Id == null ||
          zona1 == null ||
          zona2 == null) {
        return;
      }

      if (zona1 == zona2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Le due zone devono essere diverse',
            ),
          ),
        );

        return;
      }
    }

    if (modalita == 'Squadre a Box') {
      if (pescatoriSquadra.length != componentiSquadra) {
        return;
      }

      if (pescatoriSquadra.any((p) => p == null)) {
        return;
      }
    }

    if (modalita == 'Squadre a Zone') {
      if (pescatoriSquadra.length != componentiSquadra) {
        return;
      }

      if (pescatoriSquadra.any((p) => p == null)) {
        return;
      }
    }

    setState(() => loading = true);

    if (modalita == 'Squadre a Zone') {
      if (pescatoriSquadra.length != componentiSquadra) {
        return;
      }

      if (pescatoriSquadra.any((p) => p == null)) {
        return;
      }
    }

    try {
      if (modalita == 'Individuale') {
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

        final gruppiEsistenti = await service.getGruppiByGara(
          garaId!,
        );

        final gruppiSocieta = gruppiEsistenti
            .where(
              (g) => g['societa_id'] == societaId,
            )
            .toList();

        final lettera = String.fromCharCode(
          65 + gruppiSocieta.length,
        );

        String nomeGruppo;

        if (societaId != null) {
          final societaSelezionata = pescatori.firstWhere(
            (p) => p['societa_id'] == societaId,
          )['societa'];

          nomeGruppo = '${societaSelezionata['nome']} $lettera';
        } else {
          final pescatore1 = pescatori.firstWhere(
            (p) => p['id'] == pescatore1Id,
          );

          final pescatore2 = pescatori.firstWhere(
            (p) => p['id'] == pescatore2Id,
          );

          nomeGruppo = '${pescatore1['cognome']}-${pescatore2['cognome']}';
        }

        final gruppo = await service.createGruppo({
          'gara_id': garaId,
          'societa_id': societaId,
          'tipo': 'COPPIA',
          'nome': nomeGruppo,
          'lettera': societaId == null ? null : lettera,
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
      if (modalita == 'Coppie a Zone') {
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

        final gruppiEsistenti = await service.getGruppiByGara(
          garaId!,
        );

        final gruppiSocieta = gruppiEsistenti
            .where(
              (g) => g['societa_id'] == societaId,
            )
            .toList();

        final lettera = String.fromCharCode(
          65 + gruppiSocieta.length,
        );

        String nomeGruppo;

        if (societaId != null) {
          final societaSelezionata = pescatori.firstWhere(
            (p) => p['societa_id'] == societaId,
          )['societa'];

          nomeGruppo = '${societaSelezionata['nome']} $lettera';
        } else {
          final pescatore1 = pescatori.firstWhere(
            (p) => p['id'] == pescatore1Id,
          );

          final pescatore2 = pescatori.firstWhere(
            (p) => p['id'] == pescatore2Id,
          );

          nomeGruppo = '${pescatore1['cognome']}-${pescatore2['cognome']}';
        }

        final gruppo = await service.createGruppo({
          'gara_id': garaId,
          'societa_id': societaId,
          'tipo': 'COPPIA',
          'nome': nomeGruppo,
          'lettera': societaId == null ? null : lettera,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.insertIscrizione({
          'gara_id': garaId,
          'pescatore_id': pescatore1Id,
          'gruppo_id': gruppo!['id'],
          'zona': zona1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.insertIscrizione({
          'gara_id': garaId,
          'pescatore_id': pescatore2Id,
          'gruppo_id': gruppo['id'],
          'zona': zona2,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (modalita == 'Squadre a Box') {
        final gruppiEsistenti = await service.getGruppiByGara(
          garaId!,
        );

        final gruppiSocieta = gruppiEsistenti
            .where(
              (g) => g['societa_id'] == societaId,
            )
            .toList();

        final lettera = String.fromCharCode(
          65 + gruppiSocieta.length,
        );

        String nomeGruppo;

        if (societaId != null) {
          final societaSelezionata = pescatori.firstWhere(
            (p) => p['societa_id'] == societaId,
          )['societa'];

          nomeGruppo = '${societaSelezionata['nome']} $lettera';
        } else {
          final cognomi = pescatori
              .where(
                (p) => pescatoriSquadra.contains(
                  p['id'],
                ),
              )
              .map(
                (p) => p['cognome'],
              )
              .join('-');

          nomeGruppo = cognomi;
        }

        final gruppo = await service.createGruppo({
          'gara_id': garaId,
          'societa_id': societaId,
          'tipo': 'SQUADRA',
          'nome': nomeGruppo,
          'lettera': societaId == null ? null : lettera,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        for (final pescatoreId in pescatoriSquadra) {
          await service.insertIscrizione({
            'gara_id': garaId,
            'pescatore_id': pescatoreId,
            'gruppo_id': gruppo!['id'],
            'zona': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      if (modalita == 'Squadre a Zone') {
        final gruppiEsistenti = await service.getGruppiByGara(
          garaId!,
        );

        final gruppiSocieta = gruppiEsistenti
            .where(
              (g) => g['societa_id'] == societaId,
            )
            .toList();

        final lettera = String.fromCharCode(
          65 + gruppiSocieta.length,
        );

        String nomeGruppo;

        if (societaId != null) {
          final societaSelezionata = pescatori.firstWhere(
            (p) => p['societa_id'] == societaId,
          )['societa'];

          nomeGruppo = '${societaSelezionata['nome']} $lettera';
        } else {
          final cognomi = pescatori
              .where(
                (p) => pescatoriSquadra.contains(
                  p['id'],
                ),
              )
              .map(
                (p) => p['cognome'],
              )
              .join('-');

          nomeGruppo = cognomi;
        }

        final gruppo = await service.createGruppo({
          'gara_id': garaId,
          'societa_id': societaId,
          'tipo': 'SQUADRA',
          'nome': nomeGruppo,
          'lettera': societaId == null ? null : lettera,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        for (int i = 0; i < pescatoriSquadra.length; i++) {
          await service.insertIscrizione({
            'gara_id': garaId,
            'pescatore_id': pescatoriSquadra[i],
            'gruppo_id': gruppo!['id'],
            'zona': i + 1,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
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
    int numZone = 1;
    int componentiSquadra = 1;

    if (garaSelezionata.isNotEmpty) {
      componentiSquadra = garaSelezionata.first['componenti_squadra'] ?? 1;
    }

    if (garaSelezionata.isNotEmpty) {
      numZone = garaSelezionata.first['num_zone'] ?? 1;
    }
    String tipoComposizione = '';

    if (garaSelezionata.isNotEmpty) {
      modalita = garaSelezionata.first['modalita_gara'] ?? '';

      tipoComposizione = garaSelezionata.first['tipo_composizione'] ?? '';
    }

    print('MODALITA: $modalita');
    print('TIPO: $tipoComposizione');
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
            onChanged: (v) async {
              setState(() {
                garaId = v;
                pescatoreId = null;
                pescatore1Id = null;
                pescatore2Id = null;
                societaId = null;
                pescatoriSquadra = [];
                zoneSquadra = [];
              });

              await caricaPescatoriGiaIscritti();
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
          if (modalita == 'Individuale')
            DropdownButtonFormField<String>(
              value: pescatoreId,
              decoration: const InputDecoration(
                labelText: 'Pescatore',
              ),
              items: pescatori
                  .where(
                (p) => !pescatoriGiaIscritti.contains(
                  p['id'],
                ),
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
                  pescatoreId = v;
                });
              },
            ),
          if (modalita == 'Coppie a Box' && tipoComposizione == '') ...[
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
              items: pescatori
                  .where(
                (p) => !pescatoriGiaIscritti.contains(
                  p['id'],
                ),
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
                (p) =>
                    p['id'] != pescatore1Id &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
          if (modalita == 'Coppie a Box' && tipoComposizione == 'Società') ...[
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
                (p) =>
                    p['societa_id'] == societaId &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
                (p) =>
                    p['societa_id'] == societaId &&
                    p['id'] != pescatore1Id &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
          if (modalita == 'Coppie a Zone' && tipoComposizione == '') ...[
            const SizedBox(height: 12),
            Text(
              'Coppia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore1Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore Zona 1',
              ),
              items: pescatori
                  .where(
                (p) => !pescatoriGiaIscritti.contains(
                  p['id'],
                ),
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
            DropdownButtonFormField<int>(
              value: zona1,
              decoration: const InputDecoration(
                labelText: 'Zona Pescatore 1',
              ),
              items: List.generate(
                numZone,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    'Zona ${i + 1}',
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  zona1 = v;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore2Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore Zona 2',
              ),
              items: pescatori
                  .where(
                (p) =>
                    p['id'] != pescatore1Id &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: zona2,
              decoration: const InputDecoration(
                labelText: 'Zona Pescatore 2',
              ),
              items: List.generate(
                numZone,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    'Zona ${i + 1}',
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  zona2 = v;
                });
              },
            ),
          ],
          if (modalita == 'Coppie a Zone' && tipoComposizione == 'Società') ...[
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
                labelText: 'Pescatore Zona 1',
              ),
              items: pescatori
                  .where(
                (p) =>
                    p['societa_id'] == societaId &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
            DropdownButtonFormField<int>(
              value: zona1,
              decoration: const InputDecoration(
                labelText: 'Zona Pescatore 1',
              ),
              items: List.generate(
                numZone,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    'Zona ${i + 1}',
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  zona1 = v;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pescatore2Id,
              decoration: const InputDecoration(
                labelText: 'Pescatore Zona 2',
              ),
              items: pescatori
                  .where(
                (p) =>
                    p['societa_id'] == societaId &&
                    p['id'] != pescatore1Id &&
                    !pescatoriGiaIscritti.contains(
                      p['id'],
                    ),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: zona2,
              decoration: const InputDecoration(
                labelText: 'Zona Pescatore 2',
              ),
              items: List.generate(
                numZone,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    'Zona ${i + 1}',
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  zona2 = v;
                });
              },
            ),
          ],
          if (modalita == 'Squadre a Box' && tipoComposizione == '') ...[
            const SizedBox(height: 12),
            Text(
              'Squadra',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...List.generate(
              componentiSquadra,
              (index) {
                while (pescatoriSquadra.length <= index) {
                  pescatoriSquadra.add(null);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: pescatoriSquadra[index],
                    decoration: InputDecoration(
                      labelText: 'Pescatore ${index + 1}',
                    ),
                    items: pescatori
                        .where(
                      (p) =>
                          !pescatoriGiaIscritti.contains(
                            p['id'],
                          ) &&
                          !pescatoriSquadra
                              .whereType<String>()
                              .where(
                                (id) => id != pescatoriSquadra[index],
                              )
                              .contains(
                                p['id'],
                              ),
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
                        pescatoriSquadra[index] = v;
                      });
                    },
                  ),
                );
              },
            ),
          ],
          if (modalita == 'Squadre a Box' && tipoComposizione == 'Società') ...[
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
                  pescatoriSquadra = List.filled(componentiSquadra, null);
                });
              },
            ),
            const SizedBox(height: 12),
            ...List.generate(
              componentiSquadra,
              (index) {
                while (pescatoriSquadra.length <= index) {
                  pescatoriSquadra.add(null);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: pescatoriSquadra[index],
                    decoration: InputDecoration(
                      labelText: 'Pescatore ${index + 1}',
                    ),
                    items: pescatori
                        .where(
                      (p) =>
                          p['societa_id'] == societaId &&
                          !pescatoriGiaIscritti.contains(
                            p['id'],
                          ) &&
                          !pescatoriSquadra
                              .whereType<String>()
                              .where(
                                (id) => id != pescatoriSquadra[index],
                              )
                              .contains(
                                p['id'],
                              ),
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
                        pescatoriSquadra[index] = v;
                      });
                    },
                  ),
                );
              },
            ),
          ],
          if (modalita == 'Squadre a Zone' && tipoComposizione == '') ...[
            const SizedBox(height: 12),
            Text(
              'Squadra',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...List.generate(
              componentiSquadra,
              (index) {
                while (pescatoriSquadra.length <= index) {
                  pescatoriSquadra.add(null);
                }

                while (zoneSquadra.length <= index) {
                  zoneSquadra.add(index + 1);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          value: pescatoriSquadra[index],
                          decoration: InputDecoration(
                            labelText: 'Pescatore ${index + 1}',
                          ),
                          items: pescatori
                              .where(
                            (p) =>
                                !pescatoriGiaIscritti.contains(
                                  p['id'],
                                ) &&
                                !pescatoriSquadra
                                    .whereType<String>()
                                    .where(
                                      (id) => id != pescatoriSquadra[index],
                                    )
                                    .contains(
                                      p['id'],
                                    ),
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
                              pescatoriSquadra[index] = v;
                            });
                          },
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Zona ${index + 1}',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          if (modalita == 'Squadre a Zone' &&
              tipoComposizione == 'Società') ...[
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
                  pescatoriSquadra = List.filled(componentiSquadra, null);
                });
              },
            ),
            const SizedBox(height: 12),
            ...List.generate(
              componentiSquadra,
              (index) {
                while (pescatoriSquadra.length <= index) {
                  pescatoriSquadra.add(null);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: pescatoriSquadra[index],
                          decoration: InputDecoration(
                            labelText: 'Pescatore ${index + 1}',
                          ),
                          items: pescatori
                              .where(
                            (p) =>
                                p['societa_id'] == societaId &&
                                !pescatoriGiaIscritti.contains(
                                  p['id'],
                                ) &&
                                !pescatoriSquadra
                                    .whereType<String>()
                                    .where(
                                      (id) => id != pescatoriSquadra[index],
                                    )
                                    .contains(
                                      p['id'],
                                    ),
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
                              pescatoriSquadra[index] = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(
                          'Zona ${index + 1}',
                        ),
                      ),
                    ],
                  ),
                );
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
