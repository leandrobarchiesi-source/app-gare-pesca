import 'package:flutter/material.dart';
import 'iscrizioni_service.dart';

class ModificaCoppiaForm extends StatefulWidget {
  final List<Map<String, dynamic>> iscrizioni;

  const ModificaCoppiaForm({
    super.key,
    required this.iscrizioni,
  });

  @override
  State<ModificaCoppiaForm> createState() => _ModificaCoppiaFormState();
}

class _ModificaCoppiaFormState extends State<ModificaCoppiaForm> {
  final service = IscrizioniService();

  List<Map<String, dynamic>> pescatori = [];

  String? pescatore1Id;
  String? pescatore2Id;

  int? zona1;
  int? zona2;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    caricaPescatori();

    final ordinati = List<Map<String, dynamic>>.from(
      widget.iscrizioni,
    )..sort(
        (a, b) => (a['zona'] ?? 0).compareTo(
          b['zona'] ?? 0,
        ),
      );

    pescatore1Id = ordinati[0]['pescatore_id'];

    pescatore2Id = ordinati[1]['pescatore_id'];

    zona1 = ordinati[0]['zona'];
    zona2 = ordinati[1]['zona'];
  }

  Future<void> caricaPescatori() async {
    final data = await service.getPescatori();

    setState(() {
      pescatori = data;
    });
  }

  Future<void> salva() async {
    if (zona1 == zona2) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Le zone devono essere diverse',
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
          (a, b) => (a['zona'] ?? 0).compareTo(
            b['zona'] ?? 0,
          ),
        );

      await service.updateIscrizione(
        ordinati[0]['id'],
        {
          'pescatore_id': pescatore1Id,
          'zona': zona1,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      await service.updateIscrizione(
        ordinati[1]['id'],
        {
          'pescatore_id': pescatore2Id,
          'zona': zona2,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

@override
Widget build(BuildContext context) {
  final separate = widget.iscrizioni.any(
    (i) => i['zona'] != null,
  );

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Modifica Coppia',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: pescatore1Id,
                decoration: const InputDecoration(
                  labelText: 'Pescatore 1',
                ),
                items: pescatori
                    .where(
                      (p) => p['id'] != pescatore2Id,
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
                    pescatore1Id = v;
                  });
                },
              ),
            ),
            if (separate) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: zona1,
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      zona1 = v;
                    });
                  },
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: pescatore2Id,
                decoration: const InputDecoration(
                  labelText: 'Pescatore 2',
                ),
                items: pescatori
                    .where(
                      (p) => p['id'] != pescatore1Id,
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
                    pescatore2Id = v;
                  });
                },
              ),
            ),
            if (separate) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: zona2,
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      zona2 = v;
                    });
                  },
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

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
