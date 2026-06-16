import 'package:flutter/material.dart';
import 'trofei_service.dart';

class TrofeoForm extends StatefulWidget {
  final Map<String, dynamic>? trofeo;

  const TrofeoForm({
    super.key,
    this.trofeo,
  });

  @override
  State<TrofeoForm> createState() => _TrofeoFormState();
}

class _TrofeoFormState extends State<TrofeoForm> {
  final service = TrofeiService();

  final nomeCtrl = TextEditingController();
  final descrizioneCtrl = TextEditingController();
  final numZoneCtrl = TextEditingController();
  final componentiCtrl = TextEditingController();
  final numProveCtrl = TextEditingController();

  String modalitaGara = 'Singola';
  String tipoComposizione = 'Libera';

  final modalitaDisponibili = [
    'Singola',
    'Coppie Separate',
    'Coppie a Box',
    'Squadre Separate',
    'Squadre a Box',
  ];

  DateTime? dataInizio;
  DateTime? dataFine;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.trofeo != null) {
      final t = widget.trofeo!;

      nomeCtrl.text = t['nome'] ?? '';
      descrizioneCtrl.text = t['descrizione'] ?? '';

      modalitaGara = (t['modalita_gara'] ?? '').toString().isEmpty
          ? 'Singola'
          : t['modalita_gara'];

      tipoComposizione = (t['tipo_composizione'] ?? '').toString().isEmpty
          ? 'Libera'
          : t['tipo_composizione'];

      numZoneCtrl.text = t['num_zone']?.toString() ?? '';

      componentiCtrl.text = t['componenti_squadra']?.toString() ?? '';

      numProveCtrl.text = t['num_prove']?.toString() ?? '';

      if (t['data_inizio'] != null) {
        dataInizio = DateTime.parse(t['data_inizio']);
      }

      if (t['data_fine'] != null) {
        dataFine = DateTime.parse(t['data_fine']);
      }
    }
  }

  Future<void> salva() async {
    final zone = int.tryParse(numZoneCtrl.text) ?? 0;

    final numProve = int.tryParse(numProveCtrl.text) ?? 0;

    if (zone < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Numero zone non valido',
          ),
        ),
      );
      return;
    }

    if (numProve < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Numero prove non valido',
          ),
        ),
      );
      return;
    }

    if (modalitaGara == 'Coppie Separate' && zone < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coppie Separate richiede almeno 2 zone',
          ),
        ),
      );
      return;
    }

    if (modalitaGara == 'Squadre Separate' && zone < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Squadre Separate richiede almeno 2 zone',
          ),
        ),
      );
      return;
    }

    int componenti;

    switch (modalitaGara) {
      case 'Singola':
        componenti = 1;
        break;

      case 'Coppie Separate':
      case 'Coppie a Box':
        componenti = 2;
        break;

      case 'Squadre Separate':
        componenti = zone;
        break;

      case 'Squadre a Box':
        componenti = int.tryParse(componentiCtrl.text) ?? 0;

        if (componenti < 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Inserire i componenti squadra',
              ),
            ),
          );
          return;
        }
        break;

      default:
        componenti = 1;
    }

    setState(() => loading = true);

    try {
      final values = {
        'nome': nomeCtrl.text.trim(),
        'descrizione': descrizioneCtrl.text.trim(),
        'data_inizio': dataInizio?.toIso8601String(),
        'data_fine': dataFine?.toIso8601String(),
        'modalita_gara': modalitaGara,
        'tipo_composizione': tipoComposizione,
        'num_zone': zone,
        'componenti_squadra': componenti,
        'num_prove': numProve,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (widget.trofeo == null) {
        values['created_at'] = DateTime.now().toIso8601String();

        await service.insertTrofeo(values);
      } else {
        await service.updateTrofeo(
          widget.trofeo!['id'],
          values,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> scegliDataInizio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataInizio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataInizio = data;
      });
    }
  }

  Future<void> scegliDataFine() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataFine ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataFine = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trofeo == null ? 'Nuovo Trofeo' : 'Modifica Trofeo',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descrizioneCtrl,
            decoration: const InputDecoration(
              labelText: 'Descrizione',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: modalitaGara,
            decoration: const InputDecoration(
              labelText: 'Modalità Gara',
            ),
            items: modalitaDisponibili.map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(m),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                modalitaGara = v;

                switch (v) {
                  case 'Singola':
                    componentiCtrl.text = '1';
                    break;

                  case 'Coppie Separate':
                  case 'Coppie a Box':
                    componentiCtrl.text = '2';
                    break;

                  case 'Squadre Separate':
                    componentiCtrl.text = numZoneCtrl.text;
                    break;

                  case 'Squadre a Box':
                    componentiCtrl.text = '';
                    break;
                }
              });
            },
          ),
          if (modalitaGara != 'Singola') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: tipoComposizione,
              decoration: const InputDecoration(
                labelText: 'Composizione',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Libera',
                  child: Text('Libera'),
                ),
                DropdownMenuItem(
                  value: 'Di Società',
                  child: Text('Di Società'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;

                setState(() {
                  tipoComposizione = v;
                });
              },
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: numZoneCtrl,
            onChanged: (value) {
              if (modalitaGara == 'Squadre Separate') {
                setState(() {
                  componentiCtrl.text = value;
                });
              }
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Numero Zone',
            ),
          ),
          if (modalitaGara == 'Squadre a Box') ...[
            const SizedBox(height: 12),
            TextField(
              controller: componentiCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Componenti Squadra',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: numProveCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Numero Prove',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(
              dataInizio == null
                  ? 'Data Inizio'
                  : dataInizio!.toString().substring(0, 10),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: scegliDataInizio,
          ),
          ListTile(
            title: Text(
              dataFine == null
                  ? 'Data Fine'
                  : dataFine!.toString().substring(0, 10),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: scegliDataFine,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : salva,
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
