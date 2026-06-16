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

  DateTime? dataInizio;
  DateTime? dataFine;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.trofeo != null) {
      nomeCtrl.text = widget.trofeo!['nome'] ?? '';

      descrizioneCtrl.text = widget.trofeo!['descrizione'] ?? '';

      if (widget.trofeo!['data_inizio'] != null) {
        dataInizio = DateTime.parse(
          widget.trofeo!['data_inizio'],
        );
      }

      if (widget.trofeo!['data_fine'] != null) {
        dataFine = DateTime.parse(
          widget.trofeo!['data_fine'],
        );
      }
    }
  }

  Future<void> salva() async {
    setState(() => loading = true);

    try {
      final values = {
        'nome': nomeCtrl.text.trim(),
        'descrizione': descrizioneCtrl.text.trim(),
        'data_inizio': dataInizio?.toIso8601String(),
        'data_fine': dataFine?.toIso8601String(),
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
          ListTile(
            title: Text(
              dataInizio == null
                  ? 'Data inizio'
                  : dataInizio!.toString().substring(0, 10),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: scegliDataInizio,
          ),
          ListTile(
            title: Text(
              dataFine == null
                  ? 'Data fine'
                  : dataFine!.toString().substring(0, 10),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: scegliDataFine,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loading ? null : salva,
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
