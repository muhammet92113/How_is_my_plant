import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../services/plant_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_plant_screen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'plant_chatbot_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  final String plantName;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  double currentSoil = 0;
  double currentLight = 0;
  List<FlSpot> soilData = [];
  List<FlSpot> lightData = [];
  double avgSoil = 0;
  double avgLight = 0;
  final PlantService _plantService = PlantService();
  Timer? _refreshTimer;
  List<Map<String, dynamic>> sampledData = [];
  String? aiAdvice;
  bool aiLoading = false;

  @override
  void initState() {
    super.initState();
    loadFromSupabase();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadFromSupabase();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadFromSupabase() async {
    final now = DateTime.now();
    final data = await Supabase.instance.client
        .from('sensor_data')
        .select('soil_moisture:humidity, light_level:light, recorded_at')
        .eq('plant_id', widget.plantId)
        .gte('recorded_at', now.subtract(const Duration(hours: 24)).toIso8601String())
        .order('recorded_at', ascending: true);

    if (data is List && data.isNotEmpty) {
      setState(() {
        soilData = data.asMap().entries.map((e) => FlSpot(
          e.key.toDouble(),
          (e.value['soil_moisture'] as num?)?.toDouble() ?? 0,
        )).toList();
        lightData = data.asMap().entries.map((e) => FlSpot(
          e.key.toDouble(),
          (e.value['light_level'] as num?)?.toDouble() ?? 0,
        )).toList();

        avgSoil = soilData.isNotEmpty ? soilData.map((e) => e.y).reduce((a, b) => a + b) / soilData.length : 0;
        avgLight = lightData.isNotEmpty ? lightData.map((e) => e.y).reduce((a, b) => a + b) / lightData.length : 0;

        currentSoil = soilData.isNotEmpty ? soilData.last.y : 0;
        currentLight = lightData.isNotEmpty ? lightData.last.y : 0;

        sampledData = data.where((row) {
          try {
            final ts = row['recorded_at'];
            if (ts == null || ts.toString().isEmpty) return false;
            final dt = DateTime.tryParse(ts.toString());
            if (dt == null) return false;
            return dt.minute == 0 || dt.minute == 30;
          } catch (_) { return false; }
        }).map((row) => row as Map<String, dynamic>).toList();
      });
    } else {
      setState(() {
        soilData = [];
        lightData = [];
        avgSoil = 0;
        avgLight = 0;
        currentSoil = 0;
        currentLight = 0;
        sampledData = [];
      });
    }
  }

  Future<void> _deletePlant() async {
    try {
      await _plantService.deletePlant(widget.plantId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitki silindi')),
      );
      Navigator.pop(context, true); // Silme sonrası geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitki silinemedi: $e')),
      );
    }
  }

  String getSoilStatus(double value) {
    if (value < 40) return "Düşük";
    if (value <= 60) return "Orta";
    return "Yüksek";
  }

  String getLightStatus(double value) {
    if (value < 500) return "Düşük";
    if (value <= 1500) return "Orta";
    return "Yüksek";
  }

  String evaluateStatus(double value, String type) {
    if (type == 'soil') {
      if (value < 40) return 'Kötü';
      if (value <= 60) return 'Orta';
      return 'İyi';
    } else {
      if (value < 500) return 'Kötü';
      if (value <= 1500) return 'Orta';
      return 'İyi';
    }
  }

  Future<void> getAIAdvice() async {
    setState(() { aiLoading = true; aiAdvice = null; });
    try {
      final url = Uri.parse('https://ghrmrpazuoivzmtyrmhl.supabase.co/functions/v1/analyze-plant');
      final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plant_id': widget.plantId,
          'avg_soil': avgSoil,
          'avg_light': avgLight,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() { aiAdvice = data['advice'] ?? data['message'] ?? res.body; });
      } else {
        setState(() { aiAdvice = 'Tavsiye alınamadı: ${res.body}'; });
      }
    } catch (e) {
      setState(() { aiAdvice = 'Tavsiye alınamadı: $e'; });
    } finally {
      setState(() { aiLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plantName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPlantScreen(
                    plantId: widget.plantId,
                    initialName: widget.plantName,
                  ),
                ),
              );
              if (result == true) {
                setState(() {}); // Gerekirse veriyi tazele
              }
            },
            tooltip: 'Bitkiyi Düzenle',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePlant,
            tooltip: 'Bitkiyi Sil',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🌱 Bitki Adı
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Bitki Adı: ${widget.plantName}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📊 Anlık durum
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Anlık Nem ve Işık Durumu:", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Nem Oranı: ${currentSoil.toStringAsFixed(1)}% (${getSoilStatus(currentSoil)})"),
                    Text("Alınan Işık: ${currentLight.toStringAsFixed(0)} lux (${getLightStatus(currentLight)})"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📈 Son gün ortalama
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Son Gün Ortalama Durum:", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: soilData,
                              isCurved: true,
                              color: Colors.brown,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: lightData,
                              isCurved: true,
                              color: Colors.yellow.shade700,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Ortalama Nem: ${avgSoil.toStringAsFixed(1)}% (${getSoilStatus(avgSoil)})"),
                    Text("Ortalama Işık: ${avgLight.toStringAsFixed(0)} lux (${getLightStatus(avgLight)})"),
                  ],
                ),
              ),
            ),
            if (soilData.isEmpty || lightData.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Bu bitkiye ait sensör verisi bulunamadı.', style: TextStyle(color: Colors.red)),
              ),
            // Grafik ve analiz kartlarından sonra tabloyu ekle
            if (sampledData.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('30 Dakikada Bir Ölçülen Değerler', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Zaman')),
                            DataColumn(label: Text('Nem')),
                            DataColumn(label: Text('Işık')),
                          ],
                          rows: sampledData.map((row) {
                            final ts = row['recorded_at'];
                            final dt = DateTime.tryParse(ts ?? '') ?? DateTime(2000);
                            return DataRow(cells: [
                              DataCell(Text('${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}')),
                              DataCell(Text('${row['soil_moisture'] ?? row['humidity'] ?? '-'}')),
                              DataCell(Text('${row['light'] ?? row['light_level'] ?? '-'}')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Tablo sonrası ortalama ve AI tavsiye kartı
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Günlük Ortalama Durum', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ortalama Nem: ${avgSoil.toStringAsFixed(1)}%  (${evaluateStatus(avgSoil, 'soil')})'),
                    Text('Ortalama Işık: ${avgLight.toStringAsFixed(0)} lux  (${evaluateStatus(avgLight, 'light')})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bitki Bakım Tavsiyesi (AI)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: aiLoading ? null : getAIAdvice,
                      child: aiLoading ? const CircularProgressIndicator() : const Text('Tavsiye Al'),
                    ),
                    if (aiAdvice != null) ...[
                      const SizedBox(height: 8),
                      Text(aiAdvice!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Bitki Bakım Chatbotu'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlantChatbotScreen(plantId: widget.plantId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
