import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  // Resources
  double _humanPopulation = 8319183028; // 8 billion starting population
  double _nature = 0;
  double _money = 0;
  double _favor = 0;

  // Resource generation rates
  double _naturePerSecond = 0;
  double _moneyPerSecond = 0;
  double _favorPerSecond = 0;

  // Date tracking
  DateTime _currentDate = DateTime(2026, 1, 1);
  static const double _annualPopulationGrowthRate = 0.01; // 1% annual growth
  static const int _secondsPerDay = 1; // 1 second = 1 day in game time

  List<Upgrade> _upgrades = [];
  int _cityLevel = 1;

  // Getters
  double get humanPopulation => _humanPopulation;
  double get nature => _nature;
  double get money => _money;
  double get favor => _favor;
  double get naturePerSecond => _naturePerSecond;
  double get moneyPerSecond => _moneyPerSecond;
  double get favorPerSecond => _favorPerSecond;
  List<Upgrade> get upgrades => _upgrades;
  int get cityLevel => _cityLevel;
  DateTime get currentDate => _currentDate;

  String get levelTitle {
    if (_favor >= 2000) return 'World Leader';
    if (_favor >= 600) return 'President';
    if (_favor >= 300) return 'Governor';
    if (_favor >= 100) return 'Mayor';
    return 'Activist';
  }

  GameState() {
    _initializeUpgrades();
    _startResourceGeneration();
  }

  void _initializeUpgrades() {
    _upgrades = [
      Upgrade(
        id: 'solar_panel',
        name: 'Solar Panel',
        description: 'Generate clean energy and 🌿',
        baseCost: 10,
        baseNatureProduction: 0.1,
        baseMoneyProduction: 0.05,
        level: 0,
      ),
      Upgrade(
        id: 'recycling_center',
        name: 'Recycling Center',
        description: 'Process waste into resources and generate 💵',
        baseCost: 50,
        baseNatureProduction: 0.2,
        baseMoneyProduction: 0.2,
        level: 0,
      ),
      Upgrade(
        id: 'wind_turbine',
        name: 'Wind Turbine',
        description: 'Harness wind power and generate 🌿',
        baseCost: 100,
        baseNatureProduction: 0.5,
        baseMoneyProduction: 0.1,
        level: 0,
      ),
      Upgrade(
        id: 'nature_sanctuary',
        name: 'Nature Sanctuary',
        description: 'Create a sanctuary that generates ❤️',
        baseCost: 0,
        baseNatureCost: 100,
        baseNatureProduction: 0,
        baseMoneyProduction: 0,
        baseFavorProduction: 0.5,
        level: 0,
      ),
    ];
  }

  void tap() {
    _money += 1;
    notifyListeners();
  }

  void purchaseUpgrade(Upgrade upgrade) {
    if (upgrade.baseNatureCost > 0) {
      if (_nature >= upgrade.currentNatureCost) {
        _nature -= upgrade.currentNatureCost;
        upgrade.level++;
        _recalculateResourcesPerSecond();
        notifyListeners();
      }
    } else if (_money >= upgrade.currentCost) {
      _money -= upgrade.currentCost;
      upgrade.level++;
      _recalculateResourcesPerSecond();
      notifyListeners();
    }
  }

  void _recalculateResourcesPerSecond() {
    _naturePerSecond = _upgrades.fold(0, (sum, upgrade) => 
      sum + (upgrade.baseNatureProduction * upgrade.level));
    _moneyPerSecond = _upgrades.fold(0, (sum, upgrade) => 
      sum + (upgrade.baseMoneyProduction * upgrade.level));
    _favorPerSecond = _upgrades.fold(0, (sum, upgrade) => 
      sum + (upgrade.baseFavorProduction * upgrade.level));
  }

  void _startResourceGeneration() {
    Future.delayed(const Duration(seconds: 1), () {
      // Update date (1 second = 1 day)
      _currentDate = _currentDate.add(const Duration(days: 1));
      
      // Calculate daily population growth (annual rate / 365)
      double dailyGrowthRate = _annualPopulationGrowthRate / 365;
      _humanPopulation *= (1 + dailyGrowthRate);
      
      // Update other resources
      _nature += _naturePerSecond;
      _money += _moneyPerSecond;
      _favor += _favorPerSecond;
      
      notifyListeners();
      _startResourceGeneration();
    });
  }
}

class Upgrade {
  final String id;
  final String name;
  final String description;
  final double baseCost;
  final double baseNatureCost;
  final double baseNatureProduction;
  final double baseMoneyProduction;
  final double baseFavorProduction;
  int level;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    this.baseNatureCost = 0,
    required this.baseNatureProduction,
    required this.baseMoneyProduction,
    this.baseFavorProduction = 0,
    this.level = 0,
  });

  double get currentCost => baseCost * (1.15 * (level + 1));
  double get currentNatureCost => baseNatureCost * (1.15 * (level + 1));
  double get currentNatureProduction => baseNatureProduction * level;
  double get currentMoneyProduction => baseMoneyProduction * level;
  double get currentFavorProduction => baseFavorProduction * level;
} 