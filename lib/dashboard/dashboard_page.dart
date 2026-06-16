import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../features/societa/societa_page.dart';
import '../features/pescatori/pescatori_page.dart';
import '../features/trofei/trofei_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Gare Pesca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
        children: [
          _menuCard(
            context,
            icon: Icons.business,
            titolo: 'Società',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SocietaPage(),
                ),
              );
            },
          ),
          _menuCard(
            context,
            icon: Icons.people,
            titolo: 'Pescatori',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PescatoriPage(),
                ),
              );
            },
          ),
          _menuCard(
            context,
            icon: Icons.emoji_events,
            titolo: 'Trofei',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TrofeiPage(),
                ),
              );
            },
          ),
          _menuCard(
            context,
            icon: Icons.phishing,
            titolo: 'Gare',
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          user?.email ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String titolo,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
            ),
            const SizedBox(height: 10),
            Text(
              titolo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
