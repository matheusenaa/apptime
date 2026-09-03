import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Escudo estilizado genérico (monograma "V") do App Time Vasco.
///
/// Não utiliza a marca oficial do clube (protegida por direitos autorais);
/// apresenta um emblema simples em preto/branco com detalhe da Cruz de Malta.
class VascoCrest extends StatelessWidget {
  final double size;
  const VascoCrest({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF000000)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cruz de Malta estilizada (4 braços em vermelho)
          CustomPaint(
            size: Size(size * 0.5, size * 0.5),
            painter: _CrossPainter(AppConstants.vascoRed),
          ),
          Text(
            'V',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta uma simplificação geométrica da Cruz de Malta (4 V invertidos).
class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final c = size.center(Offset.zero);

    // 4 braços em forma de "V" apontando para fora
    final paths = <Path>[
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx - w * 0.20, c.dy - h * 0.34)
        ..lineTo(c.dx + w * 0.20, c.dy - h * 0.34)
        ..close(),
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx - w * 0.20, c.dy + h * 0.34)
        ..lineTo(c.dx + w * 0.20, c.dy + h * 0.34)
        ..close(),
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx - w * 0.34, c.dy - h * 0.20)
        ..lineTo(c.dx - w * 0.34, c.dy + h * 0.20)
        ..close(),
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + w * 0.34, c.dy - h * 0.20)
        ..lineTo(c.dx + w * 0.34, c.dy + h * 0.20)
        ..close(),
    ];
    for (final p in paths) {
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) =>
      oldDelegate.color != color;
}
