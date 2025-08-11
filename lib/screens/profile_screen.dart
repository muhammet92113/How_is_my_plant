import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Kullanıcı'),
          subtitle: Text(user?.email ?? '-'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Kayıtlı Cihaz'),
          subtitle: const Text('ESP32_001'),
          trailing: TextButton(onPressed: () {}, child: const Text('Değiştir')),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (!context.mounted) return;
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
          child: const Text('Çıkış Yap'),
        )
      ],
    );
  }
}