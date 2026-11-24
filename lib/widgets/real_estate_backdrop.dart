import 'package:flutter/material.dart';

/// Painted real-estate skyline at dusk. No image assets needed.
class RealEstateBackdrop extends StatelessWidget {
  const RealEstateBackdrop({super.key});
  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(child: CustomPaint(painter: _SkylinePainter()));
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A2A22), Color(0xFF174C3C), Color(0xFF3E9B7A)],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );
    // Soft glow
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.2),
      size.width * 0.28,
      Paint()
        ..shader =
            RadialGradient(
              colors: [const Color(0x55F5D58A), const Color(0x00F5D58A)],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.78, size.height * 0.2),
                radius: size.width * 0.28,
              ),
            ),
    );
    _layer(canvas, size, 0.3, const Color(0x44062018), 0.2, 7);
    _layer(canvas, size, 0.2, const Color(0x77062018), 0.14, 11);
    _layer(
      canvas,
      size,
      0.08,
      const Color(0xCC051A14),
      0.07,
      13,
      windows: true,
    );
  }

  void _layer(
    Canvas canvas,
    Size size,
    double maxHeight,
    Color color,
    double minHeight,
    int seed, {
    bool windows = false,
  }) {
    final paint = Paint()..color = color;
    final window = Paint()..color = const Color(0xAAF5D58A);
    var x = -10.0;
    var n = seed;
    while (x < size.width) {
      n = (n * 37 + 11) % 97;
      final w = 36.0 + (n % 5) * 9;
      final h = size.height * (minHeight + (n % 7) / 7 * maxHeight * 0.9);
      final top = size.height - h;
      canvas.drawRect(Rect.fromLTWH(x, top, w, h), paint);
      if (windows) {
        for (var wy = top + 10; wy < size.height - 8; wy += 14) {
          for (var wx = x + 7; wx < x + w - 8; wx += 11) {
            if ((wx * 7 + wy * 3).toInt() % 5 < 2) {
              canvas.drawRect(Rect.fromLTWH(wx, wy, 4, 6), window);
            }
          }
        }
      }
      x += w + 4;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
