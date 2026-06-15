import 'package:flutter/material.dart';
import 'pescatori_service.dart';

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

    print('PESCATORI TROVATI: ${dati.length}');
    print(dati);

    setState(() {
      pescatori = dati;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pescatori'),
      ),
      body: pescatori.isEmpty
          ? const Center(
              child: Text('Nessun pescatore presente'),
            )
          : ListView.builder(
              itemCount: pescatori.length,
              itemBuilder: (context, index) {
                final p = pescatori[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    '${p['cognome'] ?? ''} ${p['nome'] ?? ''}',
                  ),
                  subtitle: Text(
                    p['telefono'] ?? '',
                  ),
                );
              },
            ),
    );
  }
}