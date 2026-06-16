import 'package:flutter/material.dart';
import 'gare_service.dart';

class GaraForm extends StatefulWidget {
  final Map<String, dynamic>? gara;

  const GaraForm({
    super.key,
    this.gara,
  });

  @override
  State<GaraForm> createState() => _GaraFormState();
}

class _GaraFormState extends State<GaraForm> {
  final service = GareService();

  final nomeCtrl = TextEditingController();
  final numeroProvaCtrl = TextEditingController();
  final luogoCtrl = TextEditingController();
  final numZoneCtrl = TextEditingController();
  final componentiCtrl = TextEditingController();

  List<Map<String, dynamic>> trofei = [];
  List<Map<String, dynamic>> societa = [];

  String? trofeoId;
  String? societaId;

  String modalitaGara = 'Singola';
  String tipoComposizione = 'Libera';

  final modalitaDisponibili = [
    'Singola',
    'Coppie Separate',
    'Coppie a Box',
    'Squadre Separate',
    'Squadre a Box',
  ];

  DateTime? dataGara;

  bool loading = false;

  @override
  void initState() {
    print(widget.gara);
    super.initState();

    caricaDati();

    if (widget.gara != null) {
      final g = widget.gara!;

      trofeoId = g['trofeo_id'];
      societaId = g['societa_organizzatrice_id'];

      nomeCtrl.text = g['nome'] ?? '';
      numeroProvaCtrl.text = g['numero_prova']?.toString() ?? '';
      luogoCtrl.text = g['luogo'] ?? '';
      numZoneCtrl.text = g['num_zone']?.toString() ?? '';

      final mg = g['modalita_gara'];

      modalitaGara = mg == null || mg.toString().trim().isEmpty
          ? 'Singola'
          : mg.toString();
      tipoComposizione = (g['tipo_composizione'] ?? '').toString().isEmpty
          ? 'Libera'
          : g['tipo_composizione'];
      componentiCtrl.text = g['componenti_squadra']?.toString() ?? '';
      if (componentiCtrl.text.isEmpty) {
        switch (modalitaGara) {
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
        }
      }

      if (g['data_gara'] != null) {
        dataGara = DateTime.parse(
          g['data_gara'],
        );
      }
    }
  }

  Future<void> caricaDati() async {
    final t = await service.getTrofei();
    final s = await service.getSocieta();

    setState(() {
      trofei = t;
      societa = s;
    });
  }

  Future<void> scegliData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataGara ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataGara = data;
      });
    }
  }

  Future<void> salva() async {
    if (trofeoId != null) {
      final trofeo = trofei.firstWhere(
        (t) => t['id'] == trofeoId,
      );

      modalitaGara = (trofeo['modalita_gara'] ?? 'Singola').toString();

      numZoneCtrl.text = (trofeo['num_zone'] ?? '').toString();

      componentiCtrl.text = (trofeo['componenti_squadra'] ?? '').toString();
    }
    final zone = int.tryParse(numZoneCtrl.text) ?? 0;

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

    int? componenti = int.tryParse(componentiCtrl.text);

    if (componenti == null) {
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
      }
    }

    setState(() => loading = true);

    try {
      final values = {
        'trofeo_id': trofeoId,
        'societa_organizzatrice_id': societaId,
        'nome': nomeCtrl.text.trim(),
        'manifestazione': '',
        'numero_prova': int.tryParse(
          numeroProvaCtrl.text,
        ),
        'luogo': luogoCtrl.text.trim(),
        'data_gara': dataGara?.toIso8601String(),
        'modalita': modalitaGara,
        'modalita_gara': modalitaGara,
        'tipo_composizione': tipoComposizione,
        'num_zone': zone,
        'componenti_squadra': componenti,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (widget.gara == null) {
        values['created_at'] = DateTime.now().toIso8601String();

        await service.insertGara(
          values,
        );
      } else {
        await service.updateGara(
          widget.gara!['id'],
          values,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gara == null ? 'Nuova Gara' : 'Modifica Gara',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String?>(
            value: trofei.any(
              (t) => t['id'] == trofeoId,
            )
                ? trofeoId
                : null,
            decoration: const InputDecoration(
              labelText: 'Trofeo',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Nessun Trofeo'),
              ),
              ...trofei.map((t) {
                return DropdownMenuItem<String?>(
                  value: t['id'],
                  child: Text(t['nome']),
                );
              }),
            ],
            onChanged: (v) {
              setState(() {
                trofeoId = v;

                if (v != null) {
                  final trofeo = trofei.firstWhere(
                    (t) => t['id'] == v,
                  );

                  modalitaGara =
                      (trofeo['modalita_gara'] ?? 'Singola').toString();

                  numZoneCtrl.text = (trofeo['num_zone'] ?? '').toString();

                  componentiCtrl.text =
                      (trofeo['componenti_squadra'] ?? '').toString();
                  tipoComposizione =
                      (trofeo['tipo_composizione'] ?? 'Libera').toString();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: societa.any(
              (s) => s['id'] == societaId,
            )
                ? societaId
                : null,
            decoration: const InputDecoration(
              labelText: 'Società Organizzatrice',
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
            controller: nomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome Gara',
            ),
          ),
          const SizedBox(height: 12),
          if (trofeoId != null) ...[
            ListTile(
              title: const Text('Modalità Gara'),
              subtitle: Text(modalitaGara),
            ),
            ListTile(
              title: const Text('Composizione'),
              subtitle: Text(tipoComposizione),
            ),
            ListTile(
              title: const Text('Numero Zone'),
              subtitle: Text(numZoneCtrl.text),
            ),
            if (trofeoId == null && modalitaGara == 'Squadre Separate') ...[
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Componenti Squadra'),
                subtitle: Text(
                  componentiCtrl.text.isEmpty ? '-' : componentiCtrl.text,
                ),
              ),
            ],
            if (trofeoId == null && modalitaGara == 'Squadre a Box') ...[
              const SizedBox(height: 12),
              TextField(
                controller: componentiCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Componenti Squadra',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ],
          ],
          if (trofeoId == null)
            DropdownButtonFormField<String>(
              value: modalitaDisponibili.contains(
                modalitaGara,
              )
                  ? modalitaGara
                  : 'Singola',
              decoration: const InputDecoration(
                labelText: 'Modalità Gara',
              ),
              items: modalitaDisponibili.map((m) {
                return DropdownMenuItem<String>(
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
          if (trofeoId == null && modalitaGara != 'Singola')
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
          const SizedBox(height: 12),
          if (trofeoId != null)
            TextField(
              controller: numeroProvaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numero Prova',
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: luogoCtrl,
            decoration: const InputDecoration(
              labelText: 'Luogo',
            ),
          ),
          const SizedBox(height: 12),
          if (trofeoId == null)
            TextField(
              controller: numZoneCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numero Zone',
              ),
              onChanged: (value) {
                if (modalitaGara == 'Squadre Separate') {
                  setState(() {
                    componentiCtrl.text = value;
                  });
                }
              },
            ),
          if (trofeoId == null &&
              (modalitaGara == 'Squadre Separate' ||
                  modalitaGara == 'Squadre a Box')) ...[
            const SizedBox(height: 12),
            ListTile(
              title: const Text(
                'Componenti Squadra',
              ),
              subtitle: Text(
                componentiCtrl.text.isEmpty ? '-' : componentiCtrl.text,
              ),
            ),
          ],
          if (trofeoId == null && modalitaGara == 'Squadre a Box') ...[
            const SizedBox(height: 12),
            TextField(
              controller: componentiCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Componenti Squadra',
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            title: Text(
              dataGara == null
                  ? 'Data Gara'
                  : dataGara!.toString().substring(0, 10),
            ),
            trailing: const Icon(
              Icons.calendar_month,
            ),
            onTap: scegliData,
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
