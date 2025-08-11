import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_scanner_screen.dart';
import '../services/plant_service.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _customSpeciesController = TextEditingController();
  final PlantService _plantService = PlantService();
  String? _species;
  bool _scanned = false; // QR tarama gerekli

  final List<String> speciesOptions = const [
    'Fesleğen', 'Aloe Vera', 'Kaktüs', 'Sarmaşık', 'Orkide', 'Begonya', 'Diğer'
  ];

  Future<void> _addPlant() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final species = (_species == 'Diğer')
        ? _customSpeciesController.text.trim()
        : _species?.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bitki adını girin')),
      );
      return;
    }
    if (species == null || species.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tür seçin veya spesifik tür girin')),
      );
      return;
    }
    if (!_scanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen QR kodu okutun')),
      );
      return;
    }
    try {
      await _plantService.addPlant(
        name,
        description: desc.isEmpty ? null : desc,
        species: species,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitki başarıyla eklendi')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitki eklenemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitki Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Bitki Adı *',
                border: OutlineInputBorder(),
                hintText: 'Örn: Fesleğen',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _species,
              items: speciesOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _species = v),
              decoration: const InputDecoration(
                labelText: 'Tür Seç *',
                border: OutlineInputBorder(),
                hintText: 'Bitki türünü seçin',
              ),
            ),
            if (_species == 'Diğer') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customSpeciesController,
                decoration: const InputDecoration(
                  labelText: 'Spesifik tür gir *',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Monstera Deliciosa',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                border: OutlineInputBorder(),
                hintText: 'Bitki hakkında notlar...',
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
                        const Icon(Icons.qr_code_scanner, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('QR Kod Tarama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (_scanned) 
                          const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final status = await Permission.camera.request();
                        if (status.isDenied) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kamera izni gerekli')),
                          );
                          return;
                        }
                        
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                        if (!mounted) return;
                        setState(() => _scanned = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR kod başarıyla okundu')),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(_scanned ? 'QR okundu' : 'QR kod okut'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _addPlant,
              child: const Text('Bitkiyi Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
