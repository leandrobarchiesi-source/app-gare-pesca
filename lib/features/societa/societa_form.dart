import 'package:flutter/material.dart';
import 'societa_service.dart';

class SocietaForm extends StatefulWidget {

  final Map<String, dynamic>? societa;

  const SocietaForm({
    super.key,
    this.societa,
  });

  @override
  State<SocietaForm> createState() => _SocietaFormState();
}

class _SocietaFormState extends State<SocietaForm> {

  final nomeCtrl = TextEditingController();
  final cittaCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.societa != null) {
      nomeCtrl.text = widget.societa!['nome'] ?? '';
      cittaCtrl.text = widget.societa!['citta'] ?? '';
      telefonoCtrl.text = widget.societa!['telefono'] ?? '';
      emailCtrl.text = widget.societa!['email'] ?? '';
    }
  }

  Future<void> salva() async {

    try {

      setState(() => loading = true);

      final service = SocietaService();

      if (widget.societa == null) {

        await service.insertSocieta(
          nome: nomeCtrl.text.trim(),
          citta: cittaCtrl.text.trim(),
          telefono: telefonoCtrl.text.trim(),
          email: emailCtrl.text.trim(),
        );

      } else {

        await service.updateSocieta(
          widget.societa!['id'],
          {
            'nome': nomeCtrl.text.trim(),
            'citta': cittaCtrl.text.trim(),
            'telefono': telefonoCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

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
          widget.societa == null
              ? 'Nuova Società'
              : 'Modifica Società',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: cittaCtrl,
              decoration: const InputDecoration(
                labelText: 'Città',
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
      ),
    );
  }
}