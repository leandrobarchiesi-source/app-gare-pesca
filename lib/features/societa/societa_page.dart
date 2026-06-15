import 'package:flutter/material.dart';
import 'societa_service.dart';
import 'societa_form.dart';

class SocietaPage extends StatefulWidget {
  const SocietaPage({super.key});

  @override
  State<SocietaPage> createState() => _SocietaPageState();
}

class _SocietaPageState extends State<SocietaPage> {
  final service = SocietaService();

  List<Map<String, dynamic>> societa = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {
    final dati = await service.getSocieta();

    setState(() {
      societa = dati;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Società'),
      ),

      body: ListView.builder(
        itemCount: societa.length,
        itemBuilder: (context, index) {
          final s = societa[index];

          return ListTile(
            title: Text(
              s['nome'] ?? '',
            ),

            subtitle: Text(
              s['citta'] ?? '',
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
                        builder: (_) => SocietaForm(
                          societa: s,
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
                        title: const Text('Elimina società'),
                        content: Text(
                          "Eliminare ${s['nome']}?",
                        ),
                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('No'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Si'),
                          ),

                        ],
                      ),
                    );

                    if (conferma == true) {

                      await service.deleteSocieta(
                        s['id'],
                      );

                      await carica();
                    }
                  },
                ),

              ],
            ),

            onTap: () async {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocietaForm(
                    societa: s,
                  ),
                ),
              );

              if (result == true) {
                await carica();
              }
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SocietaForm(),
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