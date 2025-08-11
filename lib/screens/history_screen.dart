import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/current_plant.dart';
import '../services/sensor_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String range = '1gün';
  final SensorService _sensorService = SensorService();
  List<Map<String, dynamic>> rows = [];
  bool loading = false;
  String? _lastPlantId;

  void setRange(String r) {
    setState(() => range = r);
    _load();
  }

  Duration _durationForRange(String r) {
    switch (r) {
      case '1saat':
        return const Duration(hours: 1);
      case '1hafta':
        return const Duration(days: 7);
      case '1gün':
      default:
        return const Duration(days: 1);
    }
  }

  Future<void> _load() async {
    final plantId = context.read<CurrentPlant>().plantId;
    if (plantId == null) return;
    _lastPlantId = plantId;
    setState(() => loading = true);
    final data = await _sensorService.fetchHistory(plantId, _durationForRange(range));
    if (!mounted) return;
    setState(() {
      rows = data;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentId = context.watch<CurrentPlant>().plantId;
    if (currentId != null && currentId != _lastPlantId) {
      _load(); // Bitki değiştiğinde otomatik yenile
    }
  }

  List<FlSpot> _spots(String key) {
    final List<FlSpot> s = [];
    for (int i = 0; i < rows.length; i++) {
      final v = rows[i][key];
      double y;
      if (key == 'soil_moisture') {
        // Apply moisture mapping for soil moisture data
        y = mapMoistureValue((v as num?)?.toDouble() ?? 0.0);
      } else {
        y = (v is num) ? v.toDouble() : 0.0;
      }
      s.add(FlSpot(i.toDouble(), y));
    }
    return s;
  }

  (double, double, double) _stats(String key) {
    final values = rows.map((e) {
      final v = (e[key] as num?)?.toDouble() ?? 0;
      if (key == 'soil_moisture') {
        // Apply moisture mapping for soil moisture data
        return mapMoistureValue(v);
      }
      return v;
    }).toList();
    if (values.isEmpty) return (0, 0, 0);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;
    return (min, max, avg);
  }

  // Moisture value mapping from 0-4095 to 0-100
  double mapMoistureValue(double rawValue) {
    // Map 0-4095 to 0-100
    // 0 = very dry (0%), 4095 = very wet (100%)
    return (rawValue / 4095) * 100;
  }

  // Akıllı zaman etiketleri - veri aralığına göre farklı formatlar
  List<String> _timeLabels() {
    if (rows.isEmpty) return [];
    
    final List<String> labels = [];
    final int totalPoints = rows.length;
    
    // Veri aralığını hesapla
    if (totalPoints > 1) {
      final firstTime = DateTime.tryParse(rows.first['recorded_at'] ?? '') ?? DateTime(2000);
      final lastTime = DateTime.tryParse(rows.last['recorded_at'] ?? '') ?? DateTime(2000);
      final duration = lastTime.difference(firstTime);
      
      if (duration.inDays >= 7) {
        // Son 1 hafta: Günlere böl (Pazartesi, Salı, Çarşamba...)
        _addWeeklyLabels(labels);
      } else {
        // Son 1 gün: 4'er saat arayla (00:00, 04:00, 08:00, 12:00, 16:00, 20:00)
        _addDailyLabels(labels);
      }
    }
    
    return labels;
  }

  // Haftalık etiketler (Pazartesi, Salı, Çarşamba...)
  void _addWeeklyLabels(List<String> labels) {
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    
    for (int i = 0; i < rows.length; i++) {
      if (i == 0 || i == rows.length - 1 || i % (rows.length ~/ 7) == 0) {
        final ts = rows[i]['recorded_at'];
        final dt = DateTime.tryParse(ts ?? '') ?? DateTime(2000);
        final dayOfWeek = dt.weekday - 1; // 1=Pazartesi, 7=Pazar
        labels.add(dayNames[dayOfWeek]);
      } else {
        labels.add('');
      }
    }
  }

  // Günlük etiketler (4'er saat arayla)
  void _addDailyLabels(List<String> labels) {
    for (int i = 0; i < rows.length; i++) {
      if (i == 0 || i == rows.length - 1 || i % (rows.length ~/ 6) == 0) {
        final ts = rows[i]['recorded_at'];
        final dt = DateTime.tryParse(ts ?? '') ?? DateTime(2000);
        labels.add('${dt.hour.toString().padLeft(2, '0')}:00');
      } else {
        labels.add('');
      }
    }
  }



  Widget _lineChart(List<FlSpot> spots, Color color, {String yUnit = '', double maxY = 100}) {
    final timeLabels = _timeLabels();
    
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: spots.isEmpty ? 1 : spots.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)}$yUnit',
                        const TextStyle(color: Colors.white),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [color.withOpacity(0.2), color]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.18), color.withOpacity(0.04)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: maxY / 5, // 5 aralık
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}$yUnit',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final v = value.toInt();
                  if (v < 0 || v >= timeLabels.length) return const SizedBox();
                  final label = timeLabels[v];
                  if (label.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Colors.transparent),
              right: BorderSide(color: Colors.transparent),
              left: BorderSide(color: Color(0x11000000)),
              bottom: BorderSide(color: Color(0x11000000)),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxY / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.black12, strokeWidth: 1),
            getDrawingVerticalLine: (v) => FlLine(color: Colors.black12, strokeWidth: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soilSpots = _spots('soil_moisture');
    final lightSpots = _spots('light_level');
    final soilStats = _stats('soil_moisture');
    final lightStats = _stats('light_level');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Text('Zaman aralığı: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: range,
                items: const [
                  DropdownMenuItem(value: '1gün', child: Text('Son 1 gün')),
                  DropdownMenuItem(value: '1hafta', child: Text('Son 1 hafta')),
                ],
                onChanged: (v) {
                  setState(() => range = v ?? '1gün');
                  _load();
                },
              ),
            ]),
            FilledButton.icon(
              onPressed: loading ? null : _load,
              icon: loading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (loading) const Center(child: CircularProgressIndicator()) else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nem Grafiği'),
                  const SizedBox(height: 8),
                  _lineChart(soilSpots, Colors.blue, yUnit: '%', maxY: 100),
                  const SizedBox(height: 8),
                  Text('Min: ${soilStats.$1.toStringAsFixed(1)}%  Max: ${soilStats.$2.toStringAsFixed(1)}%  Ortalama: ${soilStats.$3.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Işık Grafiği'),
                  const SizedBox(height: 8),
                  _lineChart(lightSpots, Colors.yellow.shade700, yUnit: ' lx', maxY: 5000),
                  const SizedBox(height: 8),
                  Text('Min: ${lightStats.$1.toStringAsFixed(0)} lux  Max: ${lightStats.$2.toStringAsFixed(0)} lux  Ortalama: ${lightStats.$3.toStringAsFixed(0)} lux'),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }
}