import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRandomNote() async {
    // Notes from C4 to B4 (7 notes)
    final note = _random.nextInt(7);
    await _audioPlayer.play(AssetSource('sounds/note$note.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade100,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildResourceBar(),
              Expanded(
                child: _buildMainArea(),
              ),
              Expanded(
                flex: 2,
                child: _buildUpgradesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceBar() {
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
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gameState.levelTitle,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildResourceColumn(String label, String value, String rate, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getResourceDisplay(label, showLabel: true),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          rate,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMainArea() {
    return GestureDetector(
      onTapDown: (_) async {
        final gameState = Provider.of<GameState>(context, listen: false);
        gameState.tap();
        await _playRandomNote();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.green.shade700,
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).scale(
              duration: const Duration(milliseconds: 1000),
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap to collect resources!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradesList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gameState.upgrades.length,
            itemBuilder: (context, index) {
              final upgrade = gameState.upgrades[index];
              return _buildUpgradeCard(upgrade, gameState);
            },
          );
        },
      ),
    );
  }

  Widget _buildUpgradeCard(Upgrade upgrade, GameState gameState) {
    final canAfford = upgrade.baseNatureCost > 0 
        ? gameState.nature >= upgrade.currentNatureCost
        : gameState.money >= upgrade.currentCost;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canAfford ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: canAfford ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            upgrade.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            upgrade.description,
            style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (upgrade.baseNatureCost > 0)
                    Text(
                      'Cost: ${upgrade.currentNatureCost.toStringAsFixed(0)} ${_getResourceSymbol('nature')}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
              onPressed: canAfford
                  ? () => gameState.purchaseUpgrade(upgrade)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.poppins(
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