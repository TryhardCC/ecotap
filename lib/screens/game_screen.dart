import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../models/upgrade.dart';
import '../widgets/resource_bar.dart';
import '../widgets/upgrade_card.dart';
import '../widgets/animations/floating_number.dart';
import '../widgets/animations/particle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  late AnimationController _resourcePulseController;
  late AnimationController _burnFlashController;
  List<FloatingNumber> _floatingNumbers = [];
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _resourcePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _burnFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _resourcePulseController.dispose();
    _burnFlashController.dispose();
    super.dispose();
  }

  void _addFloatingNumber(String text, Offset position, Color color) {
    setState(() {
      _floatingNumbers.add(FloatingNumber(
        text: text,
        position: position,
        color: color,
        createdAt: DateTime.now(),
      ));
    });
  }

  void _addParticles(Offset position, Color color) {
    setState(() {
      for (int i = 0; i < 10; i++) {
        _particles.add(Particle(
          position: position,
          color: color,
          createdAt: DateTime.now(),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 5,
            (_random.nextDouble() - 0.5) * 5,
          ),
        ));
      }
    });
  }

  void _cleanupOldAnimations() {
    final now = DateTime.now();
    setState(() {
      _floatingNumbers.removeWhere((f) => now.difference(f.createdAt).inMilliseconds > 1000);
      _particles.removeWhere((p) => now.difference(p.createdAt).inMilliseconds > 1000);
    });
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

  Future<void> _playRandomNote() async {
    // Notes from C4 to B4 (7 notes)
    final note = _random.nextInt(7);
    await _audioPlayer.play(AssetSource('sounds/note$note.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  const ResourceBar(),
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
          AnimatedBuilder(
            animation: _burnFlashController,
            builder: (context, child) {
              return IgnorePointer(
                child: Container(
                  color: Colors.red.withOpacity(0.3 * _burnFlashController.value),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainArea() {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.isGameOver) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Game Over!',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 20),
                Text(
                  gameState.gameOverReason,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    color: Colors.grey.shade700,
                  ),
                ).animate().fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => gameState.restartGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Restart Game',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn().scale(),
              ],
            ),
          );
        }

        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  gameState.tap();
                  await _playRandomNote();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Help Nature',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  if (gameState.nature >= 5) {
                    gameState.burn();
                    await _playRandomNote();
                    _burnFlashController.forward(from: 0).then((_) {
                      _burnFlashController.reverse();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Burn Nature',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              return UpgradeCard(
                upgrade: upgrade,
                gameState: gameState,
                onParticles: (position) => _addParticles(position, Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}

class FloatingNumber {
  final String text;
  final Offset position;
  final Color color;
  final DateTime createdAt;

  FloatingNumber({
    required this.text,
    required this.position,
    required this.color,
    required this.createdAt,
  });
}

class Particle {
  final Offset position;
  final Color color;
  final DateTime createdAt;
  final Offset velocity;

  Particle({
    required this.position,
    required this.color,
    required this.createdAt,
    required this.velocity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    for (var particle in particles) {
      final age = now.difference(particle.createdAt).inMilliseconds / 1000.0;
      if (age > 1) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(1 - age)
        ..style = PaintingStyle.fill;

      final position = Offset(
        particle.position.dx + particle.velocity.dx * age * 50,
        particle.position.dy + particle.velocity.dy * age * 50,
      );

      canvas.drawCircle(position, (1 - age) * 4, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 