import 'package:flutter/material.dart';
import '../services/plant_service.dart';

class EditPlantScreen extends StatefulWidget {
  final String plantId;
  final String initialName;
  final String? initialDescription;
  final String? initialSpecies;

  const EditPlantScreen({
    Key? key,
    required this.plantId,
    required this.initialName,
    this.initialDescription,
    this.initialSpecies,
  }) : super(key: key);

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final PlantService _plantService = PlantService();
  bool _isLoading = false;
  String? _species;

  final List<String> speciesOptions = const [
    'Fesleğen', 'Aloe Vera', 'Kaktüs', 'Sarmaşık', 'Orkide', 'Begonya', 'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _species = widget.initialSpecies;
  }

  Future<void> _updatePlant() async {
    setState(() => _isLoading = true);
    try {
      await _plantService.updatePlant(
        widget.plantId,
        name: _nameController.text,
        description: _descController.text.isEmpty ? null : _descController.text,
        species: _species,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitki güncellendi')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitkiyi Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Bitki Adı', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _species,
              items: speciesOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _species = v),
              decoration: const InputDecoration(labelText: 'Tür', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updatePlant,
                    child: const Text('Kaydet'),
                  ),
          ],
        ),
      ),
    );
  }
}