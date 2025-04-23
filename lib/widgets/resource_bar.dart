import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class ResourceBar extends StatelessWidget {
  const ResourceBar({super.key});

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  String _getResourceDisplay(String resourceType, {bool showLabel = false}) {
    final symbol = _getResourceSymbol(resourceType);
    return showLabel ? '$symbol $resourceType' : symbol;
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildResourceColumn(String label, String value, String rate, Color color) {
      final gameState = Provider.of<GameState>(context);
      final isNegativeNature = label == 'Nature' && double.parse(value) < 0;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getResourceDisplay(label, showLabel: true),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isNegativeNature ? Colors.red : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNegativeNature ? Colors.red : null,
            ),
          ),
          Text(
            rate,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                _formatDate(gameState.currentDate),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gameState.levelTitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResourceColumn(
                    'Human Population',
                    gameState.humanPopulation.toStringAsFixed(0),
                    '${gameState.naturePerSecond.toStringAsFixed(1)}/s',
                    Colors.blue,
                  ),
                  _buildResourceColumn(
                    'Nature',
                    gameState.nature.toStringAsFixed(1),
                    '${gameState.naturePerSecond.toStringAsFixed(1)}/s',
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResourceColumn(
                    'Money',
                    gameState.money.toStringAsFixed(1),
                    '${gameState.moneyPerSecond.toStringAsFixed(1)}/s',
                    Colors.amber,
                  ),
                  _buildResourceColumn(
                    'Favor',
                    gameState.favor.toStringAsFixed(1),
                    '${gameState.favorPerSecond.toStringAsFixed(1)}/s',
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
} 