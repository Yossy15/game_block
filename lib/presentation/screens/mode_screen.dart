import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _card1Slide;
  late Animation<Offset> _card2Slide;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );
    _card1Slide = Tween<Offset>(begin: const Offset(-0.4, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.15, 1.0, curve: Curves.elasticOut),
          ),
        );
    _card2Slide = Tween<Offset>(begin: const Offset(0.4, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
          ),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _goToHome(BuildContext context, {bool isTimerMode = false}) {
    context.pushNamed(
      'game',
      queryParameters: {'timerMode': isTimerMode.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog(context);
        if (shouldPop == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.4,
                colors: [
                  Color(0xFF1A0A2E),
                  Color(0xFF0D0118),
                  Color(0xFF050008),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Grid
                Positioned.fill(child: CustomPaint(painter: _GridPainter())),

                // Particles
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, _) => CustomPaint(
                      painter: _ParticlePainter(_particleController.value),
                    ),
                  ),
                ),

                // Content
                SafeArea(
                  child: Column(
                    children: [
                      const Gap(60),

                      // Title section
                      SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            Text(
                              '— SELECT MODE —',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 5,
                                color: Colors.white.withValues(alpha: 0.3),
                                fontFamily: 'monospace',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'BLOCK',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Gap(6),
                            Container(
                              width: 64,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7B2FFF),
                                    Color(0xFFFF6B2F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Mode cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SlideTransition(
                                    position: _card1Slide,
                                    child: _ModeCard(
                                      label: 'CLASSIC',
                                      badge: 'FREE PLAY',
                                      description:
                                          'No time limit\nPlace & clear',
                                      icon: Icons.grid_4x4_rounded,
                                      accentColor: const Color(0xFF7B2FFF),
                                      onTap: () => _goToHome(
                                        context,
                                        isTimerMode: false,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: SlideTransition(
                                    position: _card2Slide,
                                    child: _ModeCard(
                                      label: 'TIMER',
                                      badge: 'CHALLENGE',
                                      description:
                                          'Race the clock\nBeat your best',
                                      icon: Icons.timer_rounded,
                                      accentColor: const Color(0xFFFF6B2F),
                                      onTap: () =>
                                          _goToHome(context, isTimerMode: true),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Row(
                              children: [
                                // Expanded(
                                //   child: SlideTransition(
                                //     position: _card1Slide,
                                //     child: _ModeCard(
                                //       label: 'DUO\n(Online)',
                                //       badge: 'FREE PLAY',
                                //       description: 'No time limit\nPlace & clear',
                                //       icon: Icons.grid_4x4_rounded,
                                //       accentColor: const Color(0xFF7B2FFF),
                                //       onTap: () {},
                                //     ),
                                //   ),
                                // ),
                                // const Gap(16),
                                Expanded(
                                  child: SlideTransition(
                                    position: _card2Slide,
                                    child: _ModeCard(
                                      label: 'BATTER\n(Online)',
                                      badge: 'CHALLENGE',
                                      description:
                                          'Create room\nJoin by code',
                                      icon: Icons.wifi_tethering_rounded,
                                      accentColor: const Color(0xFFFF6B2F),
                                      onTap: () => context.pushNamed('online-room'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Bottom hint
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Text(
                          'tap a mode to start',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            color: Colors.white.withValues(alpha: 0.2),
                            fontFamily: 'monospace',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Exit Game',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white30, fontFamily: 'monospace'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'EXIT',
              style: TextStyle(
                color: Color(0xFFFF6B2F),
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.label,
    required this.badge,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final String badge;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.accentColor.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? widget.accentColor.withValues(alpha: 0.8)
                    : widget.accentColor.withValues(alpha: 0.6), // เพิ่มความสว่างนีออนแม้ไม่ hover
                width: 1.5,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.18),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: _hovered ? 0.5 : 0.25),
                    ),
                  ),
                  child: Text(
                    widget.badge,
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor.withValues(alpha: _hovered ? 1.0 : 0.75),
                      fontFamily: 'monospace',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const Gap(14),

                // Icon circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withValues(alpha: _hovered ? 0.3 : 0.12),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: _hovered ? 0.9 : 0.7),
                      width: 1.8,
                    ),
                    boxShadow: _hovered
                        ? [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor.withValues(alpha: _hovered ? 1.0 : 0.8),
                    size: 26,
                  ),
                ),

                const Gap(14),

                // Label
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontFamily: 'monospace',
                  ),
                ),

                const Gap(8),

                // Description
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.7,
                    letterSpacing: 0.5,
                    color: Colors.white.withValues(alpha: 0.38),
                    decoration: TextDecoration.none,
                    fontFamily: 'monospace',
                  ),
                ),

                const Gap(20),

                // Start row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: widget.accentColor.withValues(alpha: _hovered ? 1.0 : 0.6),
                      size: 18,
                    ),
                    const Gap(4),
                    Text(
                      'START',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: widget.accentColor.withValues(alpha: _hovered ? 1.0 : 0.6),
                        decoration: TextDecoration.none,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const step = 36.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final List<_Particle> _particles = List.generate(28, (i) {
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      speed: 0.03 + _rng.nextDouble() * 0.06,
      size: 1.5 + _rng.nextDouble() * 2.5,
      phase: _rng.nextDouble(),
      isOrange: i % 3 == 0,
    );
  });

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress + p.phase) % 1.0;
      final y = ((p.y - t * p.speed * 3) % 1.0 + 1.0) % 1.0;
      final opacity = (sin(t * pi) * 0.5).clamp(0.0, 0.5);

      final paint = Paint()
        ..color = p.isOrange
            ? const Color(0xFFFF6B2F).withValues(alpha: opacity)
            : const Color(0xFF7B2FFF).withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, speed, size, phase;
  final bool isOrange;
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
    required this.isOrange,
  });
}



