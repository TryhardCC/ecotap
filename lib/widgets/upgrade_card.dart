import 'package:flutter/material.dart';
import '../models/upgrade.dart';

class UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final dynamic gameState;  // Using dynamic since we only need a few properties
  final Function(Offset) onParticles;

  const UpgradeCard({
    super.key,
    required this.upgrade,
    required this.gameState,
    required this.onParticles,
  });

  String _getResourceSymbol(String resourceType) {
    switch (resourceType.toLowerCase()) {
      case 'nature':
        return '🌿';
      case 'favor':
        return '❤️';
      case 'human population':
        return '👤';
      case 'money':
        return '💵';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAffordMoney = gameState.money >= upgrade.currentCost;
    final canAffordNature = upgrade.baseNatureCost > 0 
        ? gameState.nature >= upgrade.currentNatureCost
        : true;
    
    final wouldGoNegative = upgrade.baseNatureCost > 0 
        ? (gameState.nature - upgrade.currentNatureCost) < 0
        : false;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (canAffordMoney && canAffordNature) ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: (canAffordMoney && canAffordNature) ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            upgrade.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            upgrade.description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level: ${upgrade.level}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (upgrade.baseCost > 0)
                    Text(
                      'Cost: ${upgrade.currentCost.toStringAsFixed(0)} ${_getResourceSymbol('money')}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (upgrade.baseNatureCost > 0)
                    Text(
                      'Cost: ${upgrade.currentNatureCost.toStringAsFixed(0)} ${_getResourceSymbol('nature')}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (canAffordMoney && canAffordNature && !wouldGoNegative)
                  ? () {
                      gameState.purchaseUpgrade(upgrade);
                      onParticles(const Offset(100, 100));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: wouldGoNegative ? Colors.red.shade600 : Colors.green.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 