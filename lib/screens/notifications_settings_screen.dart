import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  double moistureThreshold = 30;
  bool moistureAlertsEnabled = true;
  bool lightAlerts = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Nem Uyarıları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Switch(
                      value: moistureAlertsEnabled,
                      onChanged: (value) => setState(() => moistureAlertsEnabled = value),
                    ),
                  ],
                ),
                if (moistureAlertsEnabled) ...[
                  const SizedBox(height: 12),
                  const Text('Nem % kaçın altına düşerse uyarı gönderilsin?'),
                  const SizedBox(height: 8),
                  Slider(
                    value: moistureThreshold,
                    min: 10,
                    max: 80,
                    divisions: 14,
                    label: '${moistureThreshold.toInt()}%',
                    onChanged: (v) => setState(() => moistureThreshold = v),
                  ),
                  Text('Eşik değeri: ${moistureThreshold.toInt()}%', 
                       style: const TextStyle(color: Colors.grey)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Işık Uyarıları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Switch(
                      value: lightAlerts,
                      onChanged: (value) => setState(() => lightAlerts = value),
                    ),
                  ],
                ),
                if (lightAlerts) ...[
                  const SizedBox(height: 8),
                  const Text('Işık seviyesi düşükse haber ver'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Genel Bildirimler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Switch(
                      value: notificationsEnabled,
                      onChanged: (value) => setState(() => notificationsEnabled = value),
                    ),
                  ],
                ),
                if (notificationsEnabled) ...[
                  const SizedBox(height: 8),
                  const Text('Tüm bildirimleri etkinleştir'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            // TODO: Ayarları Supabase'e kaydet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ayarlar kaydedildi')),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text('Ayarları Kaydet'),
        ),
      ],
    );
  }
}