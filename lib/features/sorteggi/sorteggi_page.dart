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

    int numeroSettore = 0;

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

        numeroSettore++;
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

  @override
  Widget build(BuildContext context) {
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
            onChanged: (v) {
              setState(() {
                garaSelezionata = v;
              });
            },
          ),
          const SizedBox(
            height: 16,
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
                  }

                  numeroSettore++;
                }
              }

              setState(() {
                anteprima = nuovaAnteprima;
              });
            },
            child: const Text(
              'Genera Presorteggio',
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
        ],
      ),
    );
  }
}
