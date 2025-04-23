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