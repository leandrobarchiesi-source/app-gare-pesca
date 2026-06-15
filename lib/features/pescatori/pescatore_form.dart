import 'package:flutter/material.dart';
import 'pescatori_service.dart';

class PescatoreForm extends StatefulWidget {
  final Map<String, dynamic>? pescatore;

  const PescatoreForm({
    super.key,
    this.pescatore,
  });

  @override
  State<PescatoreForm> createState() => _PescatoreFormState();
}

class _PescatoreFormState extends State<PescatoreForm> {
  final service = PescatoriService();

  final cognomeCtrl = TextEditingController();
  final nomeCtrl = TextEditingController();
  final tesseraCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  List<Map<String, dynamic>> societa = [];

  String? societaId;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    caricaSocieta();

    if (widget.pescatore != null) {
      cognomeCtrl.text = widget.pescatore!['cognome'] ?? '';
      nomeCtrl.text = widget.pescatore!['nome'] ?? '';
      tesseraCtrl.text = widget.pescatore!['tessera'] ?? '';
      telefonoCtrl.text = widget.pescatore!['telefono'] ?? '';
      emailCtrl.text = widget.pescatore!['email'] ?? '';

      societaId = widget.pescatore!['societa_id'];
    }
  }

  Future<void> caricaSocieta() async {
    final dati = await service.getSocieta();

    setState(() {
      societa = dati;
    });
  }

  Future<void> salva() async {
    setState(() => loading = true);

    try {
      final valori = {
        'societa_id': societaId,
        'cognome': cognomeCtrl.text.trim(),
        'nome': nomeCtrl.text.trim(),
        'tessera': tesseraCtrl.text.trim(),
        'telefono': telefonoCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (widget.pescatore == null) {
        valori['created_at'] = DateTime.now().toIso8601String();

        await service.insertPescatore(valori);
      } else {
        await service.updatePescatore(
          widget.pescatore!['id'],
          valori,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pescatore == null
              ? 'Nuovo Pescatore'
              : 'Modifica Pescatore',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          DropdownButtonFormField<String>(
            value: societaId,
            decoration: const InputDecoration(
              labelText: 'Società',
            ),
            items: societa.map((s) {
              return DropdownMenuItem<String>(
                value: s['id'],
                child: Text(s['nome']),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                societaId = v;
              });
            },
          ),

          const SizedBox(height: 12),

          TextField(
            controller: cognomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Cognome',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: nomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: tesseraCtrl,
            decoration: const InputDecoration(
              labelText: 'Tessera',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: telefonoCtrl,
            decoration: const InputDecoration(
              labelText: 'Telefono',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
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