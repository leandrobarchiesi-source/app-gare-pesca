import 'package:flutter/material.dart';
import 'iscrizioni_service.dart';
import 'iscrizione_form.dart';
import 'modifica_coppia_form.dart';
import 'modifica_squadra_form.dart';

class IscrizioniPage extends StatefulWidget {
  const IscrizioniPage({super.key});

  @override
  State<IscrizioniPage> createState() => _IscrizioniPageState();
}

class _IscrizioniPageState extends State<IscrizioniPage> {
  final service = IscrizioniService();

  List<Map<String, dynamic>> iscrizioni = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {
    final dati = await service.getIscrizioni();

    setState(() {
      iscrizioni = dati;
    });
  }

  Future<void> eliminaIscrizione(
    Map<String, dynamic> iscrizione,
  ) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Elimina Iscrizione',
        ),
        content: const Text(
          'Confermi?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text('Si'),
          ),
        ],
      ),
    );

    if (conferma != true) {
      return;
    }

    final gruppo = iscrizione['gruppo'];

    // ISCRIZIONE SINGOLA
    if (gruppo == null) {
      await service.deleteIscrizione(
        iscrizione['id'],
      );

      await carica();
      return;
    }

    // COPPIA / SQUADRA
    final gruppoId = gruppo['id'];

    final iscrizioniGruppo = await service.getIscrizioniByGruppo(
      gruppoId,
    );

    for (final i in iscrizioniGruppo) {
      await service.deleteIscrizione(
        i['id'],
      );
    }

    await service.deleteGruppo(
      gruppoId,
    );

    await carica();
  }

  @override
  Widget build(BuildContext context) {
    final gare = <String, List<Map<String, dynamic>>>{};

    for (final i in iscrizioni) {
      final gara = i['gara']?['nome'] ?? 'Senza Gara';

      gare.putIfAbsent(
        gara,
        () => [],
      );

      gare[gara]!.add(i);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iscrizioni',
        ),
      ),
      body: ListView(
        children: gare.entries.map(
          (garaEntry) {
            final iscrizioniGara = garaEntry.value;

            final singoli = <Map<String, dynamic>>[];

            final gruppi = <String, List<Map<String, dynamic>>>{};

            for (final i in iscrizioniGara) {
              final gruppo = i['gruppo'];

              if (gruppo == null) {
                singoli.add(i);
                continue;
              }

              final nomeGruppo = gruppo['nome'] ?? 'Gruppo';

              gruppi.putIfAbsent(
                nomeGruppo,
                () => [],
              );

              gruppi[nomeGruppo]!.add(i);
            }

            return ExpansionTile(
              title: Text(
                garaEntry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                // ISCRITTI SINGOLI
                ...singoli.map(
                  (i) {
                    final pescatore = i['pescatore'];

                    return ListTile(
                      leading: const Icon(
                        Icons.person,
                      ),
                      title: Text(
                        '${pescatore['cognome']} ${pescatore['nome']}',
                      ),
                      subtitle: Text(
                        i['zona'] == null ? '' : 'Zona ${i['zona']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),
                        onPressed: () async {
                          await eliminaIscrizione(
                            i,
                          );
                        },
                      ),
                    );
                  },
                ),

                // COPPIE / SQUADRE
                ...gruppi.entries.map(
                  (g) {
                    return ExpansionTile(
                      leading: const Icon(
                        Icons.groups,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              g.key,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed: () async {
                              final tipoGruppo =
                                  g.value.first['gruppo']?['tipo'] ?? '';

                              bool? result;

                              if (tipoGruppo == 'COPPIA') {
                                result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ModificaCoppiaForm(
                                      iscrizioni: g.value,
                                    ),
                                  ),
                                );
                              }

                              if (tipoGruppo == 'SQUADRA') {
                                result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ModificaSquadraForm(
                                      iscrizioni: g.value,
                                    ),
                                  ),
                                );
                              }

                              if (result == true) {
                                await carica();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () async {
                              await eliminaIscrizione(
                                g.value.first,
                              );
                            },
                          ),
                        ],
                      ),
                      children: (List<Map<String, dynamic>>.from(g.value)
                            ..sort(
                              (a, b) => (a['zona'] ?? 999).compareTo(
                                b['zona'] ?? 999,
                              ),
                            ))
                          .map(
                        (i) {
                          final pescatore = i['pescatore'];

                          return ListTile(
                            leading: const Icon(
                              Icons.person,
                            ),
                            title: Text(
                              '${pescatore['cognome']} ${pescatore['nome']}',
                            ),
                            subtitle: i['zona'] == null
                                ? null
                                : Text(
                                    'Zona ${i['zona']}',
                                  ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const IscrizioneForm(),
            ),
          );

          if (result == true) {
            await carica();
          }
        },
      ),
    );
  }
}
