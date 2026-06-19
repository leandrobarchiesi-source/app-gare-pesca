import 'package:flutter/material.dart';
import 'gare_service.dart';
import 'gara_form.dart';

class GarePage extends StatefulWidget {
  const GarePage({super.key});

  @override
  State<GarePage> createState() => _GarePageState();
}

class _GarePageState extends State<GarePage> {
  final service = GareService();

  List<Map<String, dynamic>> gare = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {
    final dati = await service.getGare();

    setState(() {
      gare = dati;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gruppi = <String, List<Map<String, dynamic>>>{};

    for (final g in gare) {
      final trofeo = g['trofeo']?['nome'] ?? '🎣 Gare Individuali';
      gruppi.putIfAbsent(
        trofeo,
        () => [],
      );

      gruppi[trofeo]!.add(g);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gare'),
      ),
      body: ListView(
        children: gruppi.entries.map((gruppo) {
          return ExpansionTile(
            title: Text(
              gruppo.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: gruppo.value.map((g) {
              return ListTile(
                title: Text(
                  g['nome'] ?? '',
                ),
                subtitle: Text(
                  g['luogo'] ?? '',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GaraForm(
                              gara: g,
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
                        final conferma = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text(
                              'Elimina Gara',
                            ),
                            content: Text(
                              'Eliminare ${g['nome']}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  false,
                                ),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  true,
                                ),
                                child: const Text('Si'),
                              ),
                            ],
                          ),
                        );

                        if (conferma == true) {
                          await service.deleteGara(
                            g['id'],
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GaraForm(),
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
