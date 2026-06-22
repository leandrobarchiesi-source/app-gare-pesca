import 'package:flutter/material.dart';
import 'sorteggi_service.dart';

class SorteggiPage extends StatefulWidget {
  const SorteggiPage({
    super.key,
  });

  @override
  State<SorteggiPage> createState() => _SorteggiPageState();
}

class _SorteggiPageState extends State<SorteggiPage> {
  final service = SorteggiService();

  List<Map<String, dynamic>> gare = [];
  List<String> anteprima = [];
  List<String> anteprimaSorteggio = [];
  List<Map<String, dynamic>> righeSorteggio = [];
  List<Map<String, dynamic>> presorteggio = [];
  List<int> settoriDisponibili = [];

  List<String> lettereDisponibili = [];

  final Map<int, TextEditingController> controllerSettori = {};

  final Map<String, TextEditingController> controllerConcorrenti = {};
  Map<String, dynamic>? garaInfo;

  int numeroIscritti = 0;

  int numeroSquadreOCoppie = 0;

  int numeroSettori = 0;
  int? settoreTecnicoNumero;

  String? settoreTecnicoLettera;

  bool presorteggioPresente = false;

  String? garaSelezionata;

  final partecipantiPerSettoreController = TextEditingController(
    text: '10',
  );

  String posizioneTecnico = 'B';

  List<Map<String, dynamic>> calcolaSettori(
    int concorrenti,
    int dimensioneSettore,
    String posizioneTecnico,
  ) {
    final settori = <Map<String, dynamic>>[];

    if (concorrenti <= dimensioneSettore) {
      settori.add({
        'lettera': 'A',
        'posti': concorrenti,
        'tecnico': false,
      });

      return settori;
    }

    final completi = concorrenti ~/ dimensioneSettore;

    final resto = concorrenti % dimensioneSettore;

    if (resto == 0) {
      for (int i = 0; i < completi; i++) {
        settori.add({
          'lettera': String.fromCharCode(65 + i),
          'posti': dimensioneSettore,
          'tecnico': false,
        });
      }

      return settori;
    }

    if (completi == 1) {
      settori.add({
        'lettera': 'A',
        'posti': dimensioneSettore,
        'tecnico': false,
      });

      settori.add({
        'lettera': 'B',
        'posti': resto,
        'tecnico': true,
      });

      return settori;
    }

    for (int i = 0; i < completi + 1; i++) {
      final lettera = String.fromCharCode(65 + i);

      if (lettera == posizioneTecnico) {
        settori.add({
          'lettera': lettera,
          'posti': resto,
          'tecnico': true,
        });
      } else {
        settori.add({
          'lettera': lettera,
          'posti': dimensioneSettore,
          'tecnico': false,
        });
      }
    }

    return settori;
  }

  List<Map<String, dynamic>> distribuisciConcorrenti(
    List<Map<String, dynamic>> concorrenti,
    List<Map<String, dynamic>> settori,
  ) {
    final copia = List<Map<String, dynamic>>.from(
      concorrenti,
    );

    copia.shuffle();

    int indiceConcorrente = 0;

    for (final settore in settori) {
      final posti = settore['posti'] as int;

      final assegnati = <Map<String, dynamic>>[];

      for (int i = 0; i < posti && indiceConcorrente < copia.length; i++) {
        assegnati.add(
          copia[indiceConcorrente],
        );

        indiceConcorrente++;
      }

      settore['concorrenti'] = assegnati;
    }

    return settori;
  }

  String letteraDaIndice(
    int indice,
  ) {
    const lettere = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];

    return lettere[indice];
  }

  @override
  void initState() {
    super.initState();

    caricaGare();
  }

  Future<void> caricaGare() async {
    try {
      final data = await service.getGare();

      setState(() {
        gare = List<Map<String, dynamic>>.from(
          data,
        );
      });
    } catch (e) {
      print(
        'ERRORE GARE: $e',
      );
    }
  }

  Future<void> aggiornaRiepilogo() async {
    if (garaSelezionata == null) {
      return;
    }

    final gara = gare.firstWhere(
      (g) => g['id'] == garaSelezionata,
    );

    final iscrizioni = await service.getIscrizioniByGara(
      garaSelezionata!,
    );

    final presorteggi = await service.getPresorteggioByGara(
      garaSelezionata!,
    );

    final modalita = gara['modalita_gara'] ?? '';

    int squadreOCoppie = 0;

    if (modalita.contains('Box')) {
      final gruppi = <String>{};

      for (final i in iscrizioni) {
        final gruppo = i['gruppo'];

        if (gruppo == null) continue;

        gruppi.add(
          gruppo['id'],
        );
      }

      squadreOCoppie = gruppi.length;
    }

    final settori = <String>{};

    for (final p in presorteggi) {
      settori.add(
        '${p['zona']}-${p['settore_numero']}',
      );
    }

    setState(() {
      garaInfo = gara;

      numeroIscritti = iscrizioni.length;

      numeroSquadreOCoppie = squadreOCoppie;

      numeroSettori = settori.length;

      presorteggioPresente = presorteggi.isNotEmpty;
    });
  }

  List<Widget> _buildPresorteggioVisualizzato() {
    final widgets = <Widget>[];

    final righe = List<Map<String, dynamic>>.from(
      presorteggio,
    );

    righe.sort(
      (a, b) {
        final zona = (a['zona'] as int).compareTo(
          b['zona'] as int,
        );

        if (zona != 0) {
          return zona;
        }

        return (a['settore_numero'] as int).compareTo(
          b['settore_numero'] as int,
        );
      },
    );

    int? zonaCorrente;
    int? settoreCorrente;

    for (final r in righe) {
      debugPrint(r.toString());
      if (zonaCorrente != r['zona'] || settoreCorrente != r['settore_numero']) {
        zonaCorrente = r['zona'];
        settoreCorrente = r['settore_numero'];

        widgets.add(
          const SizedBox(
            height: 12,
          ),
        );

        widgets.add(
          Text(
            'Zona $zonaCorrente - Settore $settoreCorrente',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      final modalita = garaInfo?['modalita_gara'] ?? '';

      final tipoComposizione = garaInfo?['tipo_composizione'] ?? '';

      String nome;

      final pescatore = r['pescatore'];
      final gruppo = r['gruppo'];

      if (modalita.contains('Box')) {
        nome = gruppo?['nome'] ?? 'Gruppo';
      } else if (pescatore != null) {
        final nomePescatore = '${pescatore['cognome']} ${pescatore['nome']}';

        if (modalita == 'Individuale') {
          final societa = pescatore['societa']?['nome'];

          nome = nomePescatore;

          if (societa != null && societa.toString().isNotEmpty) {
            nome += ' ($societa)';
          }
        } else if (modalita.contains('Coppie') && tipoComposizione.isEmpty) {
          final societa = pescatore['societa']?['nome'];

          nome = nomePescatore;

          if (societa != null && societa.toString().isNotEmpty) {
            nome += ' ($societa)';
          }
        } else {
          nome = nomePescatore;

          final nomeGruppo = gruppo?['nome'];

          if (nomeGruppo != null && nomeGruppo.toString().isNotEmpty) {
            nome += ' ($nomeGruppo)';
          }
        }
      } else {
        nome = 'Dato mancante';
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
          ),
          child: Text(
            '${r['concorrente_lettera']} - $nome',
          ),
        ),
      );
    }

    return widgets;
  }

  void verificaEstrazioni() {
    final errori = <String>[];

    if (settoriDisponibili.length == 2 && settoreTecnicoNumero != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            'Verifica OK',
          ),
          content: const Text(
            '✓ Estrazioni valide',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final lettereInserite = <String>{};

    for (final s in settoriDisponibili) {
      if (s == settoreTecnicoNumero) {
        lettereInserite.add(
          settoreTecnicoLettera!,
        );
        continue;
      }
      final valore = controllerSettori[s]!.text.trim().toUpperCase();

      if (valore.isEmpty) {
        errori.add(
          'Settore $s non compilato',
        );
        continue;
      }

      if (lettereInserite.contains(
        valore,
      )) {
        errori.add(
          'Lettera $valore duplicata',
        );
      }

      lettereInserite.add(
        valore,
      );
    }

    for (int i = 0; i < settoriDisponibili.length; i++) {
      final attesa = String.fromCharCode(
        65 + i,
      );

      if (!lettereInserite.contains(
        attesa,
      )) {
        errori.add(
          'Manca lettera $attesa',
        );
      }
    }

    final numeriInseriti = <int>{};

    for (final l in lettereDisponibili) {
      final testo = controllerConcorrenti[l]!.text.trim();

      if (testo.isEmpty) {
        errori.add(
          'Concorrente $l non compilato',
        );
        continue;
      }

      final numero = int.tryParse(testo);

      if (numero == null) {
        errori.add(
          '$l contiene un valore non valido',
        );
        continue;
      }

      if (numeriInseriti.contains(
        numero,
      )) {
        errori.add(
          'Numero $numero duplicato',
        );
      }

      numeriInseriti.add(
        numero,
      );
    }

    for (int i = 1; i <= lettereDisponibili.length; i++) {
      if (!numeriInseriti.contains(
        i,
      )) {
        errori.add(
          'Manca numero $i',
        );
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          errori.isEmpty ? 'Verifica OK' : 'Errori rilevati',
        ),
        content: Text(
          errori.isEmpty ? '✓ Estrazioni valide' : errori.join('\n'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: const Text(
              'OK',
            ),
          ),
        ],
      ),
    );
  }

  void generaAnteprimaSorteggio() {
    final mappaSettori = <int, String>{};

    if (settoriDisponibili.length == 1) {
      mappaSettori[settoriDisponibili.first] = 'A';
    }

    if (settoriDisponibili.length == 2 && settoreTecnicoNumero != null) {
      final normale = settoriDisponibili.firstWhere(
        (s) => s != settoreTecnicoNumero,
      );

      mappaSettori[normale] = 'A';

      mappaSettori[settoreTecnicoNumero!] = settoreTecnicoLettera!;
    }

    final mappaConcorrenti = <String, int>{};

    for (final s in settoriDisponibili) {
      if (mappaSettori.containsKey(s)) {
        continue;
      }

      if (s == settoreTecnicoNumero) {
        mappaSettori[s] = settoreTecnicoLettera!;
        continue;
      }

      mappaSettori[s] = controllerSettori[s]!.text.trim().toUpperCase();
    }
    for (final l in lettereDisponibili) {
      mappaConcorrenti[l] = int.parse(
        controllerConcorrenti[l]!.text,
      );
    }

    final righe = <Map<String, dynamic>>[];

    for (final r in presorteggio) {
      righe.add({
        'gara_id': r['gara_id'],
        'zona': r['zona'],
        'settore_lettera': mappaSettori[r['settore_numero']] ?? '',
        'posto_numero': mappaConcorrenti[r['concorrente_lettera']] ?? 0,
        'pescatore_id': r['pescatore_id'],
        'gruppo_id': r['gruppo_id'],
        'tecnico': r['tecnico'] ?? false,
        'pescatore': r['pescatore'],
        'gruppo': r['gruppo'],
      });
    }

    // RINUMERAZIONE SETTORI TECNICI

    final gruppiTecnici = <String, List<Map<String, dynamic>>>{};

    for (final r in righe.where((e) => e['tecnico'] == true)) {
      final chiave = '${r['zona']}_${r['settore_lettera']}';

      gruppiTecnici.putIfAbsent(
        chiave,
        () => [],
      );

      gruppiTecnici[chiave]!.add(r);
    }

    for (final gruppo in gruppiTecnici.values) {
      gruppo.sort(
        (a, b) => (a['posto_numero'] as int).compareTo(
          b['posto_numero'] as int,
        ),
      );

      for (int i = 0; i < gruppo.length; i++) {
        gruppo[i]['posto_numero'] = i + 1;
      }
    }

    righe.sort(
      (a, b) {
        final zona = (a['zona'] as int).compareTo(
          b['zona'] as int,
        );

        if (zona != 0) {
          return zona;
        }

        final settore = (a['settore_lettera'] as String).compareTo(
          b['settore_lettera'] as String,
        );

        if (settore != 0) {
          return settore;
        }

        return (a['posto_numero'] as int).compareTo(
          b['posto_numero'] as int,
        );
      },
    );

    final nuovaAnteprima = <String>[];

    int? zonaCorrente;

    String? settoreCorrente;

    for (final r in righe) {
      if (zonaCorrente != r['zona']) {
        zonaCorrente = r['zona'];

        settoreCorrente = null;

        nuovaAnteprima.add('');

        nuovaAnteprima.add(
          'Zona $zonaCorrente',
        );
      }

      if (settoreCorrente != r['settore_lettera']) {
        settoreCorrente = r['settore_lettera'];

        nuovaAnteprima.add('');

        nuovaAnteprima.add(
          'Settore $settoreCorrente',
        );
      }

      String nome;

      if (r['gruppo'] != null &&
          (garaInfo?['modalita_gara'] ?? '').contains(
            'Box',
          )) {
        nome = r['gruppo']['nome'];
      } else {
        final pescatore = r['pescatore'];

        nome = '${pescatore['cognome']} ${pescatore['nome']}';
      }

      nuovaAnteprima.add(
        'Posto ${r['posto_numero']} - $nome',
      );
    }

    setState(() {
      anteprimaSorteggio = nuovaAnteprima;

      righeSorteggio = righe;
    });
  }

  Future<void> salvaSorteggioDefinitivo() async {
    if (garaSelezionata == null) {
      return;
    }

    if (righeSorteggio.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Generare prima il sorteggio',
          ),
        ),
      );
      return;
    }

    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Salva Sorteggio',
        ),
        content: const Text(
          'Confermare il salvataggio del sorteggio definitivo?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'No',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text(
              'Si',
            ),
          ),
        ],
      ),
    );

    if (conferma != true) {
      return;
    }

    await service.eliminaSorteggio(
      garaSelezionata!,
    );

    final righeDaSalvare = righeSorteggio
        .map(
          (r) => {
            'gara_id': r['gara_id'],
            'zona': r['zona'],
            'settore_lettera': r['settore_lettera'],
            'posto_numero': r['posto_numero'],
            'pescatore_id': r['pescatore_id'],
            'gruppo_id': r['gruppo_id'],
            'tecnico': r['tecnico'],
          },
        )
        .toList();

    await service.salvaSorteggio(
      righeDaSalvare,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Sorteggio salvato',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mostraEstrazioneSettori = settoriDisponibili.length > 1 &&
        !(settoriDisponibili.length == 2 && settoreTecnicoNumero != null);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sorteggi',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: garaSelezionata,
            decoration: const InputDecoration(
              labelText: 'Gara',
            ),
            items: gare.map((g) {
              final nomeTrofeo = g['trofeo']?['nome'];

              final testo =
                  nomeTrofeo != null ? '$nomeTrofeo - ${g['nome']}' : g['nome'];

              return DropdownMenuItem<String>(
                value: g['id'],
                child: Text(
                  testo,
                ),
              );
            }).toList(),
            onChanged: (v) async {
              setState(() {
                garaSelezionata = v;
              });

              await aggiornaRiepilogo();
            },
          ),
          const SizedBox(
            height: 16,
          ),
          if (garaInfo != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RIEPILOGO GARA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Trofeo: ${garaInfo!['trofeo']?['nome'] ?? '-'}',
                    ),
                    Text(
                      'Modalità: ${garaInfo!['modalita_gara']}',
                    ),
                    Text(
                      'Zone: ${garaInfo!['num_zone'] ?? 1}',
                    ),
                    Text(
                      'Iscritti: $numeroIscritti',
                    ),
                    if ((garaInfo!['modalita_gara'] ?? '').contains('Squadre'))
                      Text(
                        'Squadre: $numeroSquadreOCoppie',
                      ),
                    if ((garaInfo!['modalita_gara'] ?? '').contains('Coppie'))
                      Text(
                        'Coppie: $numeroSquadreOCoppie',
                      ),
                    Text(
                      'Settori: $numeroSettori',
                    ),
                    Text(
                      'Presorteggio: '
                      '${presorteggioPresente ? 'SI' : 'NO'}',
                    ),
                  ],
                ),
              ),
            ),
          TextFormField(
            controller: partecipantiPerSettoreController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Partecipanti per settore',
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          DropdownButtonFormField<String>(
            value: posizioneTecnico,
            decoration: const InputDecoration(
              labelText: 'Posizione settore tecnico',
            ),
            items: const [
              DropdownMenuItem(
                value: 'A',
                child: Text('A'),
              ),
              DropdownMenuItem(
                value: 'B',
                child: Text('B'),
              ),
              DropdownMenuItem(
                value: 'C',
                child: Text('C'),
              ),
              DropdownMenuItem(
                value: 'D',
                child: Text('D'),
              ),
              DropdownMenuItem(
                value: 'E',
                child: Text('E'),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                posizioneTecnico = v;
              });
            },
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
            onPressed: () async {
              if (garaSelezionata == null) {
                return;
              }

              final iscrizioni = await service.getIscrizioniByGara(
                garaSelezionata!,
              );

              final gara = gare.firstWhere(
                (g) => g['id'] == garaSelezionata,
              );

              final righeDaSalvare = <Map<String, dynamic>>[];

              await service.eliminaPresorteggio(
                garaSelezionata!,
              );

              final zone = <int, int>{};

              final numZone = gara['num_zone'] ?? 1;

              if (numZone == 1) {
                zone[1] = iscrizioni.length;
              } else {
                for (final i in iscrizioni) {
                  final zona = i['zona'];

                  if (zona == null) continue;

                  zone[zona] = (zone[zona] ?? 0) + 1;
                }
              }
              final nuovaAnteprima = <String>[];

              nuovaAnteprima.add(
                'MODALITA: ${gara['modalita_gara']}',
              );

              final zoneOrdinate = zone.keys.toList()..sort();

              for (final zona in zoneOrdinate) {
                nuovaAnteprima.add('');

                nuovaAnteprima.add(
                  'Zona $zona',
                );

                final settori = calcolaSettori(
                  zone[zona]!,
                  int.parse(
                    partecipantiPerSettoreController.text,
                  ),
                  posizioneTecnico,
                );

                final modalita = gara['modalita_gara'] ?? '';

                List<Map<String, dynamic>> concorrentiZona;

                if (modalita.contains('Box')) {
                  final gruppi = <String, Map<String, dynamic>>{};

                  for (final i in iscrizioni) {
                    final gruppo = i['gruppo'];

                    if (gruppo == null) continue;

                    if (gruppo['deleted'] == true) {
                      continue;
                    }

                    gruppi[gruppo['id']] = {
                      'gruppo': gruppo,
                    };
                  }
                  concorrentiZona = gruppi.values.toList();
                } else {
                  concorrentiZona = iscrizioni.where(
                    (i) {
                      final numZone = gara['num_zone'] ?? 1;

                      if (numZone == 1) {
                        return true;
                      }

                      return i['zona'] == zona;
                    },
                  ).toList();
                }

                final settoriCompleti = distribuisciConcorrenti(
                  concorrentiZona,
                  settori,
                );

                int numeroSettore = 1;

                for (final settore in settoriCompleti) {
                  nuovaAnteprima.add('');

                  final titolo = settore['tecnico']
                      ? 'Settore $numeroSettore (Tecnico)'
                      : 'Settore $numeroSettore';

                  nuovaAnteprima.add(
                    titolo,
                  );

                  final concorrenti =
                      settore['concorrenti'] as List<Map<String, dynamic>>;

                  for (int i = 0; i < concorrenti.length; i++) {
                    final c = concorrenti[i];

                    final lettera = letteraDaIndice(i);

                    final tecnico = settore['tecnico'] == true;

                    String nome;

                    final modalita = gara['modalita_gara'] ?? '';

                    if (modalita.contains('Box')) {
                      nome = c['gruppo']['nome'];
                    } else {
                      nome =
                          '${c['pescatore']['cognome']} ${c['pescatore']['nome']}';
                    }

                    nuovaAnteprima.add(
                      '$lettera - $nome',
                    );

                    if (modalita.contains('Box')) {
                      righeDaSalvare.add({
                        'gara_id': garaSelezionata,
                        'zona': zona,
                        'settore_numero': numeroSettore,
                        'concorrente_lettera': lettera,
                        'gruppo_id': c['gruppo']['id'],
                        'pescatore_id': null,
                        'tecnico': tecnico,
                      });
                    } else {
                      righeDaSalvare.add({
                        'gara_id': garaSelezionata,
                        'zona': zona,
                        'settore_numero': numeroSettore,
                        'concorrente_lettera': lettera,
                        'pescatore_id': c['pescatore']['id'],
                        'gruppo_id': c['gruppo']?['id'],
                        'tecnico': tecnico,
                      });
                    }
                  }

                  numeroSettore++;
                }
              }

              await service.salvaPresorteggio(
                righeDaSalvare,
              );

              setState(() {
                anteprima = nuovaAnteprima;
              });
            },
            child: const Text(
              'Genera Presorteggio',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (garaSelezionata == null) {
                return;
              }

              final dati = await service.getPresorteggioByGara(
                garaSelezionata!,
              );

              final settori = <int>{};

              final lettere = <String>{};

              int? tecnicoNumero;

              for (final r in dati) {
                settori.add(
                  r['settore_numero'],
                );

                lettere.add(
                  r['concorrente_lettera'],
                );

                if (r['tecnico'] == true) {
                  tecnicoNumero = r['settore_numero'];
                }
              }
              final listaSettori = settori.toList()..sort();

              final listaLettere = lettere.toList()..sort();

              for (final s in listaSettori) {
                controllerSettori.putIfAbsent(
                  s,
                  () => TextEditingController(),
                );
              }

              for (final l in listaLettere) {
                controllerConcorrenti.putIfAbsent(
                  l,
                  () => TextEditingController(),
                );
              }

              setState(() {
                presorteggio = dati;

                settoriDisponibili = listaSettori;

                lettereDisponibili = listaLettere;

                settoreTecnicoNumero = tecnicoNumero;

                settoreTecnicoLettera =
                    tecnicoNumero != null ? posizioneTecnico : null;
              });
              debugPrint(
                'Tecnico: $settoreTecnicoNumero - $settoreTecnicoLettera',
              );
              debugPrint(
                'Righe presorteggio: ${dati.length}',
              );
            },
            child: const Text(
              'Carica Presorteggio',
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ...anteprima.map(
            (riga) => Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: Text(
                riga,
              ),
            ),
          ),
          if (mostraEstrazioneSettori) ...[
            const SizedBox(
              height: 24,
            ),
            const Text(
              'ESTRAZIONE SETTORI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ...settoriDisponibili.map(
              (s) {
                final isTecnico = settoreTecnicoNumero == s;

                if (isTecnico) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            'Settore Tecnico →',
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: settoreTecnicoLettera,
                            enabled: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          'Settore $s →',
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controllerSettori[s],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          if (lettereDisponibili.isNotEmpty) ...[
            const SizedBox(
              height: 24,
            ),
            const Text(
              'ESTRAZIONE CONCORRENTI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ...lettereDisponibili.map(
              (l) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$l →',
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controllerConcorrenti[l],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (presorteggio.isNotEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: verificaEstrazioni,
              child: const Text(
                'Verifica Estrazioni',
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: generaAnteprimaSorteggio,
              child: const Text(
                'Genera Sorteggio Definitivo',
              ),
            ),
          ],
          if (presorteggio.isNotEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Presorteggio salvato',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._buildPresorteggioVisualizzato(),
            if (anteprimaSorteggio.isNotEmpty) ...[
              const SizedBox(
                height: 24,
              ),
              const Divider(),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'SORTEGGIO DEFINITIVO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ...anteprimaSorteggio.map(
                (riga) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Text(
                    riga,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                onPressed: salvaSorteggioDefinitivo,
                icon: const Icon(
                  Icons.save,
                ),
                label: const Text(
                  'Salva Sorteggio',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
