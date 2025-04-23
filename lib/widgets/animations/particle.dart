import 'package:flutter/material.dart';

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