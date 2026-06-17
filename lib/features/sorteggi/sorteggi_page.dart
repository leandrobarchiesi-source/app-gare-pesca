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

  final partecipantiPerSettoreController =
      TextEditingController(
    text: '10',
  );

  String posizioneTecnico = 'B';

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
            final nomeTrofeo =
                g['trofeo']?['nome'];

            final testo =
                nomeTrofeo != null
                    ? '$nomeTrofeo - ${g['nome']}'
                    : g['nome'];

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
          controller:
              partecipantiPerSettoreController,
          keyboardType:
              TextInputType.number,
          decoration: const InputDecoration(
            labelText:
                'Partecipanti per settore',
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        DropdownButtonFormField<String>(
          value: posizioneTecnico,
          decoration: const InputDecoration(
            labelText:
                'Posizione settore tecnico',
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

            final iscrizioni =
                await service.getIscrizioniByGara(
              garaSelezionata!,
            );

            final gara = gare.firstWhere(
              (g) => g['id'] == garaSelezionata,
            );

            final zone = <int, int>{};

            for (final i in iscrizioni) {
              final zona = i['zona'] as int;

              zone[zona] =
                  (zone[zona] ?? 0) + 1;
            }

            final nuovaAnteprima =
                <String>[];

            nuovaAnteprima.add(
              'MODALITA: ${gara['modalita_gara']}',
            );

            final zoneOrdinate =
                zone.keys.toList()
                  ..sort();

            for (final zona in zoneOrdinate) {
              nuovaAnteprima.add('');

              nuovaAnteprima.add(
                'Zona $zona',
              );

              nuovaAnteprima.add(
                'Concorrenti: ${zone[zona]}',
              );
            }

            setState(() {
              anteprima =
                  nuovaAnteprima;
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
            padding:
                const EdgeInsets.only(
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