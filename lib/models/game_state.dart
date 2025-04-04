import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  double _resources = 0;
  double _resourcesPerSecond = 0;
  List<Upgrade> _upgrades = [];
  int _cityLevel = 1;

  double get resources => _resources;
  double get resourcesPerSecond => _resourcesPerSecond;
  List<Upgrade> get upgrades => _upgrades;
  int get cityLevel => _cityLevel;

  GameState() {
    _initializeUpgrades();
    _loadGame();
    _startResourceGeneration();
  }

  void _initializeUpgrades() {
    _upgrades = [
      Upgrade(
        id: 'solar_panel',
        name: 'Solar Panel',
        description: 'Generate clean energy',
        baseCost: 10,
        baseProduction: 0.1,
        level: 0,
      ),
      Upgrade(
        id: 'recycling_center',
        name: 'Recycling Center',
        description: 'Process waste into resources',
        baseCost: 50,
        baseProduction: 0.5,
        level: 0,
      ),
      Upgrade(
        id: 'wind_turbine',
        name: 'Wind Turbine',
        description: 'Harness wind power',
        baseCost: 100,
        baseProduction: 1.0,
        level: 0,
      ),
    ];
  }

  void tap() {
    _resources += 1;
    notifyListeners();
    _saveGame();
  }

  void purchaseUpgrade(Upgrade upgrade) {
    if (_resources >= upgrade.currentCost) {
      _resources -= upgrade.currentCost;
      upgrade.level++;
      _recalculateResourcesPerSecond();
      notifyListeners();
      _saveGame();
    }
  }

  void _recalculateResourcesPerSecond() {
    _resourcesPerSecond = _upgrades.fold(0, (sum, upgrade) => sum + (upgrade.baseProduction * upgrade.level));
  }

  void _startResourceGeneration() {
    Future.delayed(const Duration(seconds: 1), () {
      _resources += _resourcesPerSecond;
      notifyListeners();
      _saveGame();
      _startResourceGeneration();
    });
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('resources', _resources);
    await prefs.setInt('cityLevel', _cityLevel);
    for (var upgrade in _upgrades) {
      await prefs.setInt('upgrade_${upgrade.id}', upgrade.level);
    }
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _resources = prefs.getDouble('resources') ?? 0;
    _cityLevel = prefs.getInt('cityLevel') ?? 1;
    for (var upgrade in _upgrades) {
      upgrade.level = prefs.getInt('upgrade_${upgrade.id}') ?? 0;
    }
    _recalculateResourcesPerSecond();
    notifyListeners();
  }
}

class Upgrade {
  final String id;
  final String name;
  final String description;
  final double baseCost;
  final double baseProduction;
  int level;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.baseProduction,
    this.level = 0,
  });

  double get currentCost => baseCost * (1.15 * level);
  double get currentProduction => baseProduction * level;
} 