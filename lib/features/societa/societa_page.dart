import 'package:flutter/material.dart';
import 'societa_service.dart';

class SocietaPage extends StatefulWidget {
  const SocietaPage({super.key});

  @override
  State<SocietaPage> createState() => _SocietaPageState();
}

class _SocietaPageState extends State<SocietaPage> {

  final service = SocietaService();

  List<Map<String,dynamic>> societa = [];

  @override
  void initState() {
    super.initState();
    carica();
  }

  Future<void> carica() async {

    final dati = await service.getSocieta();

    setState(() {
      societa = dati;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Società'),
      ),
      body: ListView.builder(
        itemCount: societa.length,
        itemBuilder: (context,index){

          final s = societa[index];

          return ListTile(
            title: Text(s['nome'] ?? ''),
            subtitle: Text(
              s['citta'] ?? '',
            ),
          );
        },
      ),
    );
  }
}