import 'dart:math';
import 'package:flutter/material.dart';

// Replaces:
// .grass { background: linear-gradient(to top, #228B22, #32CD32); }
// + the JS flower generation loop
class GrassLayer extends StatelessWidget {
  const GrassLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 110,
        width: screenWidth,
        child: Stack(
          children: [
            // ─── Grass base ──────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF228B22), // dark green
                    Color(0xFF32CD32), // lime green
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
            ),

            // ─── Flowers ──────────────────────────────
            // Replaces the JS flower generation loop:
            // for (let i = 0; i < 50; i++) { ... }
            ..._buildFlowers(screenWidth),
          ],
        ),
      ),
    );
  }

  // Generates 50 flowers at random positions
  // Each flower = stem + petals + center
  List<Widget> _buildFlowers(double screenWidth) {
    final random = Random(42); // seed=42 gives same layout every time
    final flowers = <Widget>[];

    for (int i = 0; i < 50; i++) {
      final left = random.nextDouble() * (screenWidth - 10);
      final bottomOffset = random.nextDouble() * 25;
      final stemHeight = 15.0 + random.nextDouble() * 20;

      flowers.add(
        Positioned(
          left: left,
          bottom: bottomOffset,
          child: _buildFlower(stemHeight: stemHeight),
        ),
      );
    }
    return flowers;
  }

  // Builds one flower: stem + 4 petals + yellow center
  // Replaces: .flower, .flower::before, .flower::after, .flower-stem CSS
  Widget _buildFlower({required double stemHeight}) {
    return SizedBox(
      width: 16,
      height: stemHeight + 16,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Stem — replaces .flower-stem
          Positioned(
            bottom: 0,
            child: Container(
              width: 2,
              height: stemHeight,
              color: const Color(0xFF228B22),
            ),
          ),
          // Petals — replaces .flower::before and .flower::after
          Positioned(
            top: 0,
            child: SizedBox(
              width: 16,
              height: 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top petal
                  Positioned(
                    top: 0,
                    left: 3,
                    child: _petal(),
                  ),
                  // Bottom petal
                  Positioned(
                    bottom: 0,
                    left: 3,
                    child: _petal(),
                  ),
                  // Left petal
                  Positioned(
                    left: 0,
                    top: 3,
                    child: _petal(),
                  ),
                  // Right petal
                  Positioned(
                    right: 0,
                    top: 3,
                    child: _petal(),
                  ),
                  // Yellow center — replaces .flower { background: yellow }
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // One pink petal — replaces .flower::before / .flower::after
  Widget _petal() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Colors.pink,
        shape: BoxShape.circle,
      ),
    );
  }
}