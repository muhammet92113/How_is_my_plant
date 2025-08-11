import 'package:flutter/foundation.dart';

class CurrentPlant extends ChangeNotifier {
  String? _plantId;
  String? _plantName;

  String? get plantId => _plantId;
  String? get plantName => _plantName;

  void setPlant({required String id, required String name}) {
    _plantId = id;
    _plantName = name;
    notifyListeners();
  }
}