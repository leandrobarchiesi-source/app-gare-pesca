import 'package:flutter/material.dart';
import 'iscrizioni_service.dart';

class ModificaSquadraForm extends StatefulWidget {
  final List<Map<String, dynamic>> iscrizioni;

  const ModificaSquadraForm({
    super.key,
    required this.iscrizioni,
  });

  @override
  State<ModificaSquadraForm> createState() => _ModificaSquadraFormState();
}

class _ModificaSquadraFormState extends State<ModificaSquadraForm> {
  final service = IscrizioniService();

  List<Map<String, dynamic>> pescatori = [];
  List<String?> pescatoriSquadra = [];
  List<int?> zoneSquadra = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    caricaPescatori();

    final ordinati = List<Map<String, dynamic>>.from(
      widget.iscrizioni,
    )..sort(
        (a, b) => (a['zona'] ?? 999).compareTo(
          b['zona'] ?? 999,
        ),
      );

    for (final i in ordinati) {
      pescatoriSquadra.add(
        i['pescatore_id'],
      );

      zoneSquadra.add(
        i['zona'],
      );
    }
  }

  Future<void> caricaPescatori() async {
    final data = await service.getPescatori();

    setState(() {
      pescatori = data;
    });
  }

Future<void> salva() async {
  final zone = zoneSquadra.whereType<int>().toList();

if (zone.length != zone.toSet().length) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Non possono esserci zone duplicate',
      ),
    ),
  );

  return;
}
  setState(() => loading = true);

  try {
    final ordinati = List<Map<String, dynamic>>.from(
      widget.iscrizioni,
    )..sort(
        (a, b) => (a['zona'] ?? 999).compareTo(
          b['zona'] ?? 999,
        ),
      );

    for (int i = 0; i < ordinati.length; i++) {
      await service.updateIscrizione(
        ordinati[i]['id'],
        {
          'pescatore_id': pescatoriSquadra[i],
          'zona': zoneSquadra[i],
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }

    if (!mounted) return;

    Navigator.pop(
      context,
      true,
    );
  } finally {
    if (mounted) {
      setState(
        () => loading = false,
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final separata = widget.iscrizioni.any(
      (i) => i['zona'] != null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifica Squadra',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(
            pescatoriSquadra.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: pescatoriSquadra[index],
                        decoration: InputDecoration(
                          labelText: 'Pescatore ${index + 1}',
                        ),
items: pescatori
    .where(
      (p) =>
          !pescatoriSquadra
              .whereType<String>()
              .where(
                (id) => id != pescatoriSquadra[index],
              )
              .contains(
                p['id'],
              ),
    )
                                .map<DropdownMenuItem<String>>(
                          (p) {
                            return DropdownMenuItem<String>(
                              value: p['id'],
                              child: Text(
                                '${p['cognome']} ${p['nome']}',
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (v) {
                          setState(() {
                            pescatoriSquadra[index] = v;
                          });
                        },
                      ),
                    ),
                    if (separata) ...[
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<int>(
                          value: zoneSquadra[index],
                          decoration: const InputDecoration(
                            labelText: 'Zona',
                          ),
                          items: List.generate(
                            pescatoriSquadra.length,
                            (i) => i + 1,
                          ).map(
                            (zona) {
                              return DropdownMenuItem<int>(
                                value: zona,
                                child: Text(
                                  zona.toString(),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (v) {
                            setState(() {
                              zoneSquadra[index] = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
            onPressed: loading ? null : salva,
            child: const Text(
              'Salva',
            ),
          ),
        ],
      ),
    );
  }
}
