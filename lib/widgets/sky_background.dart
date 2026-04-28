import 'package:flutter/material.dart';

// Replaces:
// .sky { background: linear-gradient(to bottom, #87ceeb 70%, #228B22 70%); }
// .cloud { animation: moveCloud 60s linear infinite; }
class SkyBackground extends StatefulWidget {
  const SkyBackground({super.key});

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground>
    with TickerProviderStateMixin {
  
  // One AnimationController per cloud
  // Replaces: animation-delay on each .cloud CSS class
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _cloud3Controller;

  late Animation<double> _cloud1Animation;
  late Animation<double> _cloud2Animation;
  late Animation<double> _cloud3Animation;

  @override
  void initState() {
    super.initState();

    // Cloud 1 — fastest, no delay
    // Replaces: .cloud1 { animation-delay: 0s; }
    _cloud1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    );
    _cloud1Animation = Tween<double>(begin: -0.2, end: 1.1).animate(
      CurvedAnimation(parent: _cloud1Controller, curve: Curves.linear),
    );
    _cloud1Controller.repeat(); // loops forever like infinite in CSS

    // Cloud 2 — starts partway through
    // Replaces: .cloud2 { animation-delay: 15s; }
    _cloud2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 150),
    );
    _cloud2Animation = Tween<double>(begin: -0.3, end: 1.1).animate(
      CurvedAnimation(parent: _cloud2Controller, curve: Curves.linear),
    );
    // Delay the start by jumping forward in the animation
    _cloud2Controller.forward(from: 0.3);
    _cloud2Controller.repeat();

    // Cloud 3 — starts even later
    // Replaces: .cloud3 { animation-delay: 30s; }
    _cloud3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    );
    _cloud3Animation = Tween<double>(begin: -0.4, end: 1.1).animate(
      CurvedAnimation(parent: _cloud3Controller, curve: Curves.linear),
    );
    _cloud3Controller.forward(from: 0.5);
    _cloud3Controller.repeat();
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _cloud3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // ─── Sky gradient background ───────────────────
        // Replaces: background: linear-gradient(to bottom, #87ceeb 70%, #228B22 70%)
        Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.72, 0.72, 1.0],
              colors: [
                Color(0xFF87CEEB), // sky blue top
                Color(0xFF87CEEB), // sky blue bottom
                Color(0xFF228B22), // grass green starts here
                Color(0xFF228B22), // grass green
              ],
            ),
          ),
        ),

        // ─── Animated Clouds ───────────────────────────
        // Cloud 1
        AnimatedBuilder(
          animation: _cloud1Animation,
          builder: (context, child) {
            return Positioned(
              top: 70,
              // Moves cloud from left (-150px) to right (130% screen width)
              // Replaces: @keyframes moveCloud { 0% translateX(0) → 100% translateX(130vw) }
              left: _cloud1Animation.value * screenWidth,
              child: child!,
            );
          },
          child: _buildCloud(width: 120, height: 70),
        ),

        // Cloud 2
        AnimatedBuilder(
          animation: _cloud2Animation,
          builder: (context, child) {
            return Positioned(
              top: 130,
              left: _cloud2Animation.value * screenWidth,
              child: child!,
            );
          },
          child: _buildCloud(width: 150, height: 80),
        ),

        // Cloud 3
        AnimatedBuilder(
          animation: _cloud3Animation,
          builder: (context, child) {
            return Positioned(
              top: 200,
              left: _cloud3Animation.value * screenWidth,
              child: child!,
            );
          },
          child: _buildCloud(width: 180, height: 90),
        ),
      ],
    );
  }

  // Builds one cloud shape using stacked ovals
  // Replaces: .cloud, .cloud::before, .cloud::after CSS
  Widget _buildCloud({required double width, required double height}) {
    return SizedBox(
      width: width + 60,
      height: height + 30,
      child: Stack(
        children: [
          // Main cloud body
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Cloud puff top-left — replaces .cloud::before
          Positioned(
            bottom: height * 0.3,
            left: width * 0.15,
            child: Container(
              width: width * 0.55,
              height: width * 0.55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Cloud puff top-right — replaces .cloud::after
          Positioned(
            bottom: height * 0.2,
            left: width * 0.4,
            child: Container(
              width: width * 0.48,
              height: width * 0.48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}