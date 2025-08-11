// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'notifications_settings_screen.dart';
import 'plant_chatbot_screen.dart';
import 'plants_screen.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import '../services/current_plant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentIndex = 0;

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _supabase.auth.signOut();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final plantId = context.watch<CurrentPlant>().plantId;
    return [
      IconButton(
        icon: const Icon(Icons.chat_bubble_outline),
        tooltip: 'Sohbet',
        onPressed: () {
          if (plantId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Önce bir bitki seçin')),
            );
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => PlantChatbotScreen(plantId: plantId)));
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Çıkış Yap',
        onPressed: () => _showLogoutDialog(context),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentPlant = context.watch<CurrentPlant>();
    final pages = [
      DashboardScreen(plantName: currentPlant.plantName ?? 'Seçilmedi'),
      const HistoryScreen(),
      const NotificationsSettingsScreen(),
      const PlantsScreen(),
    ];

    final titles = [
      'Ana Sayfa',
      'Geçmiş',
      'Bildirimler',
      'Bitkilerim',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: _buildActions(context),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.query_stats_outlined), selectedIcon: Icon(Icons.query_stats), label: 'Geçmiş'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Bildirimler'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Bitki Ekle'),
        ],
      ),
    );
  }
}
