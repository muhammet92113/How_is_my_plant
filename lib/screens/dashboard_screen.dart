import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/current_plant.dart';
import '../services/sensor_service.dart';
import 'plants_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? plantName;
  const DashboardScreen({super.key, this.plantName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SensorService _sensorService = SensorService();
  double? soilMoisture;
  int? lightLux;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final plantId = context.read<CurrentPlant>().plantId;
    if (plantId == null) return;
    final latest = await _sensorService.fetchLatestReading(plantId);
    if (!mounted) return;
    setState(() {
      soilMoisture = (latest?['soil_moisture'] as num?)?.toDouble();
      lightLux = (latest?['light_level'] as num?)?.toInt();
    });
  }

  // Moisture value mapping from 0-4095 to 0-100
  double mapMoistureValue(double rawValue) {
    // Map 0-4095 to 0-100
    // 0 = very dry (0%), 4095 = very wet (100%)
    return (rawValue / 4095) * 100;
  }

  Future<void> _pickPlant(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlantsScreen()),
    );
    if (result is Map<String, String>) {
      if (!mounted) return;
      context.read<CurrentPlant>().setPlant(id: result['id']!, name: result['name']!);
    }
  }

  (String, Color) _soilStatus(double v) {
    if (v < 40) return ('Düşük', Colors.red);
    if (v <= 60) return ('Orta', Colors.amber);
    return ('İyi', Colors.green);
  }

  (String, Color) _lightStatus(int v) {
    if (v < 500) return ('Düşük', Colors.red);
    if (v <= 1500) return ('Orta', Colors.amber);
    return ('İyi', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final plantName = context.watch<CurrentPlant>().plantName ?? widget.plantName ?? 'Seçilmedi';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Bitkin: $plantName', style: Theme.of(context).textTheme.titleLarge),
            ),
            IconButton(
              onPressed: () => _pickPlant(context),
              icon: const Icon(Icons.eco),
              tooltip: 'Bitki Seç',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Toprak Nem Durumu', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Toprak nemi: ${soilMoisture != null ? mapMoistureValue(soilMoisture!).toStringAsFixed(1) : '-'}%'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: soilMoisture == null ? Colors.grey.shade300 : _soilStatus(mapMoistureValue(soilMoisture!)).$2.withOpacity(.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    soilMoisture == null ? '—' : _soilStatus(mapMoistureValue(soilMoisture!)).$1,
                    style: TextStyle(color: soilMoisture == null ? Colors.grey : _soilStatus(mapMoistureValue(soilMoisture!)).$2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('☀️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Işık Durumu', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Işık seviyesi: ${lightLux?.toString() ?? '-'} lux'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: lightLux == null ? Colors.grey.shade300 : _lightStatus(lightLux!).$2.withOpacity(.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    lightLux == null ? '—' : _lightStatus(lightLux!).$1,
                    style: TextStyle(color: lightLux == null ? Colors.grey : _lightStatus(lightLux!).$2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}