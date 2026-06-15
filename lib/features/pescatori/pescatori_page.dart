import 'package:flutter/material.dart';
import 'pescatori_service.dart';
import 'pescatore_form.dart';

class PescatoriPage extends StatefulWidget {
  const PescatoriPage({super.key});

  @override
  State<PescatoriPage> createState() => _PescatoriPageState();
}

class _PescatoriPageState extends State<PescatoriPage> {
  final service = PescatoriService();

  List<Map<String, dynamic>> pescatori = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {
    final dati = await service.getPescatori();

    setState(() {
      pescatori = dati;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gruppi = <String, List<Map<String, dynamic>>>{};

    for (final p in pescatori) {
      final societa =
          p['societa']?['nome'] ?? 'Senza società';

      gruppi.putIfAbsent(
        societa,
        () => [],
      );

      gruppi[societa]!.add(p);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pescatori'),
      ),

      body: ListView(
        children: gruppi.entries.map((g) {

          return ExpansionTile(
            title: Text(
              g.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            children: g.value.map((p) {

              return ListTile(
                leading: const Icon(Icons.person),

                title: Text(
                  '${p['cognome']} ${p['nome']}',
                ),

                subtitle: Text(
                  p['telefono'] ?? '',
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {

                        final result =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PescatoreForm(
                              pescatore: p,
                            ),
                          ),
                        );

                        if (result == true) {
                          await carica();
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {

                        final conferma =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                            title: const Text(
                              'Elimina pescatore',
                            ),
                            content: Text(
                              'Eliminare ${p['cognome']} ${p['nome']}?',
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

                        if (conferma == true) {

                          await service.deletePescatore(
                            p['id'],
                          );

                          await carica();
                        }
                      },
                    ),

                  ],
                ),
              );

            }).toList(),
          );

        }).toList(),
      ),

      floatingActionButton:
          FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {

          final result =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PescatoreForm(),
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