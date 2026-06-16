import 'package:flutter/material.dart';
import 'trofei_service.dart';
import 'trofeo_form.dart';

class TrofeiPage extends StatefulWidget {
  const TrofeiPage({super.key});

  @override
  State<TrofeiPage> createState() => _TrofeiPageState();
}

class _TrofeiPageState extends State<TrofeiPage> {
  final service = TrofeiService();

  List<Map<String, dynamic>> trofei = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {
    final dati = await service.getTrofei();

    setState(() {
      trofei = dati;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trofei'),
      ),
      body: ListView.builder(
        itemCount: trofei.length,
        itemBuilder: (context, index) {
          final t = trofei[index];

          return ListTile(
            title: Text(
              t['nome'] ?? '',
            ),
            subtitle: Text(
              t['descrizione'] ?? '',
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
                        builder: (_) => TrofeoForm(
                          trofeo: t,
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
                        title: const Text('Elimina'),
                        content: Text(
                          'Eliminare ${t['nome']}?',
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
                      await service.deleteTrofeo(
                        t['id'],
                      );

                      await carica();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TrofeoForm(),
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
