import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rncxfrmxduzshesxjhgv.supabase.co',
    anonKey: 'sb_publishable_w8_K88m2cZkmFV-bDCa-ug_LBtcu-wj',
  );

  runApp(const GarePescaApp());
}

class GarePescaApp extends StatelessWidget {
  const GarePescaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestione Gare Pesca',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
home: const LoginPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Gare Pesca'),
      ),
      body: Center(
        child: Text(
          user == null
              ? 'Supabase collegato - Nessun utente autenticato'
              : 'Utente: ${user.email}',
        ),
      ),
    );
  }
}
