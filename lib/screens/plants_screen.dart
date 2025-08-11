import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';
import '../services/plant_service.dart';
import 'add_plant_screen.dart';

class PlantsScreen extends StatefulWidget {
  final bool pickMode;
  const PlantsScreen({super.key, this.pickMode = true});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<Map<String, dynamic>> plants = [];
  final PlantService _plantService = PlantService();

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    try {
      final data = await _plantService.fetchPlants();
      setState(() {
        plants = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitkiler alınamadı: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitkilerim')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Direkt bitki ekleme ekranını açıyoruz
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlantScreen()));
          if (added == true) fetchPlants();
        },
        child: const Icon(Icons.add),
      ),
      body: plants.isEmpty
          ? const Center(child: Text('Henüz bitki eklenmemiş'))
          : ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return Card(
                  child: ListTile(
                    title: Text(plant['name'] ?? '-'),
                    subtitle: Text(plant['species'] != null ? 'Tür: ${plant['species']}' : (plant['description'] ?? '')),
                    onTap: () {
                      if (widget.pickMode) {
                        Navigator.pop(context, {
                          'id': plant['id'].toString(),
                          'name': plant['name']?.toString() ?? '-',
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(
                              plantId: plant['id'].toString(),
                              plantName: plant['name']?.toString() ?? '-',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
