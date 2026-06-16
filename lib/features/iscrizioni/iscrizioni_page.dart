import 'package:flutter/material.dart';
import 'iscrizioni_service.dart';
import 'iscrizione_form.dart';

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

  @override
  Widget build(BuildContext context) {
    final gruppi = <String, List<Map<String, dynamic>>>{};

    for (final i in iscrizioni) {
      final gara = i['gara']?['nome'] ?? 'Senza Gara';

      gruppi.putIfAbsent(
        gara,
        () => [],
      );

      gruppi[gara]!.add(i);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iscrizioni',
        ),
      ),
      body: ListView(
        children: gruppi.entries.map(
          (gruppo) {
            return ExpansionTile(
              title: Text(
                gruppo.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: gruppo.value.map(
                (i) {
                  final pescatore = i['pescatore'];

                  final nome = pescatore == null
                      ? ''
                      : '${pescatore['cognome']} ${pescatore['nome']}';

                  return ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: Text(
                      nome,
                    ),
                    subtitle: Text(
                      i['zona'] == null ? '' : 'Zona ${i['zona']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                          ),
                          onPressed: () async {
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

                            if (conferma == true) {
                              await service.deleteIscrizione(
                                i['id'],
                              );

                              await carica();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
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
