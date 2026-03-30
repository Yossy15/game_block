import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

class GameOver extends StatefulWidget {
  const GameOver({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onRestart,
  });

  final int score;
  final int bestScore;
  final VoidCallback onRestart;

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glitchController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _cardSlide;
  late Animation<double> _scaleAnim;
  late Animation<double> _glitchAnim;

  bool _isNewBest = false;

  @override
  void initState() {
    super.initState();

    _isNewBest = widget.score >= widget.bestScore && widget.score > 0;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
          ),
        );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _glitchAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_glitchController);

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _glitchController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goNamed('mode');
      },
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.4,
              colors: [Color(0xFF1A0A2E), Color(0xFF0D0118), Color(0xFF050008)],
            ),
          ),
          child: Stack(
            children: [
              // Background grid lines
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),

              // Floating particles
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ParticlePainter(_particleController.value),
                    );
                  },
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(20),

                    // GAME OVER title with glitch effect
                    SlideTransition(
                      position: _titleSlide,
                      child: AnimatedBuilder(
                        animation: _glitchAnim,
                        builder: (context, _) {
                          return _GlitchText(
                            text: 'GAME OVER',
                            glitch: _glitchAnim.value,
                          );
                        },
                      ),
                    ),

                    const Gap(8),

                    // Subtitle line
                    SlideTransition(
                      position: _titleSlide,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DotDivider(),
                          const Gap(10),
                          Text(
                            'BETTER LUCK NEXT TIME',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 4,
                              color: Colors.white.withValues(alpha: 0.35),
                              fontFamily: 'monospace',
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const Gap(10),
                          _DotDivider(),
                        ],
                      ),
                    ),

                    const Gap(36),

                    if (_isNewBest) ...[
                      const Gap(16),
                      SlideTransition(
                        position: _cardSlide,
                        child: _NewBestBadge(),
                      ),
                    ],

                    const Gap(36),

                    // Score cards
                    SlideTransition(
                      position: _cardSlide,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: _ScoreCard(
                                  label: 'BEST',
                                  value: widget.bestScore,
                                  accent: const Color(0xFFFF6B2F),
                                  highlight: _isNewBest,
                                ),
                              ),
                              const Gap(12),
                              SizedBox(
                                width: double.infinity,
                                child: _ScoreCard(
                                  label: 'SCORE',
                                  value: widget.score,
                                  accent: const Color(0xFF7B2FFF),
                                  highlight: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // if (_isNewBest) ...[
                    //   const Gap(16),
                    //   SlideTransition(
                    //     position: _cardSlide,
                    //     child: _NewBestBadge(),
                    //   ),
                    // ],
                    const Gap(40),

                    // Restart button
                    SlideTransition(
                      position: _cardSlide,
                      child: ZoBreathingBorder(
                        borderWidth: 2.0,
                        borderRadius: BorderRadius.circular(14),
                        colors: const [
                          Color(0xFF7B2FFF),
                          Color(0xFFFF2FD4),
                          Color(0xFFFF6B2F),
                          Color(0xFF2FFFFF),
                        ],
                        child: _RestartButton(onTap: widget.onRestart),
                      ),
                    ),

                    const Gap(20),

                    SlideTransition(
                      position: _cardSlide,
                      child: ZoBreathingBorder(
                        borderWidth: 2.0,
                        borderRadius: BorderRadius.circular(14),
                        colors: const [
                          Color(0xFF7B2FFF),
                          Color(0xFFFF2FD4),
                          Color(0xFFFF6B2F),
                          Color(0xFF2FFFFF),
                        ],
                        child: _HomeButton(),
                      ),
                    ),

                    const Gap(20),

                    // Hint text
                    SlideTransition(
                      position: _cardSlide,
                      child: Text(
                        'tap to play again',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.2),
                          fontFamily: 'monospace',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    const Gap(20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GlitchText extends StatelessWidget {
  const _GlitchText({required this.text, required this.glitch});

  final String text;
  final double glitch;

  @override
  Widget build(BuildContext context) {
    final offset = (glitch * 3 - 1.5).clamp(-3.0, 3.0);
    return Stack(
      children: [
        // Red channel offset
        Transform.translate(
          offset: Offset(offset, 0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: const Color(0xFFFF2060).withValues(alpha: 0.6),
              decoration: TextDecoration.none,
              fontFamily: 'monospace',
            ),
          ),
        ),
        // Cyan channel offset
        Transform.translate(
          offset: Offset(-offset, 0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: const Color(0xFF00FFFF).withValues(alpha: 0.4),
              decoration: TextDecoration.none,
              fontFamily: 'monospace',
            ),
          ),
        ),
        // Main white text
        Text(
          text,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.highlight,
  });

  final String label;
  final int value;
  final Color accent;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? accent.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.08),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.8),
              decoration: TextDecoration.none,
              fontFamily: 'monospace',
            ),
          ),
          const Gap(8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              decoration: TextDecoration.none,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NewBestBadge extends StatefulWidget {
  @override
  State<_NewBestBadge> createState() => _NewBestBadgeState();
}

class _NewBestBadgeState extends State<_NewBestBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B2F).withValues(alpha: 0.15 + _ctrl.value * 0.1),
                const Color(0xFFFFD700).withValues(alpha: 0.15 + _ctrl.value * 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFFF6B2F),
                const Color(0xFFFFD700),
                _ctrl.value,
              )!.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✦',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFD700),
                  decoration: TextDecoration.none,
                ),
              ),
              const Gap(6),
              const Text(
                'NEW BEST',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD700),
                  decoration: TextDecoration.none,
                  fontFamily: 'monospace',
                ),
              ),
              const Gap(6),
              const Text(
                '✦',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFD700),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RestartButton extends StatefulWidget {
  const _RestartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<_RestartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 180,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0118),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
              const Gap(8),
              const Text(
                'PLAY AGAIN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatefulWidget {
  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.forward();
        _ctrl.reverse();
        context.goNamed('mode');
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 180,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0118),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded, color: Colors.white, size: 22),
              const Gap(8),
              const Text(
                'HOME',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DotDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
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

    const step = 40.0;

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

  static final List<_Particle> _particles = List.generate(20, (i) {
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      speed: 0.05 + _rng.nextDouble() * 0.08,
      size: 1.5 + _rng.nextDouble() * 2.5,
      phase: _rng.nextDouble(),
    );
  });

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress + p.phase) % 1.0;
      final y = (p.y - t * p.speed * 3) % 1.0;
      final opacity = (sin(t * pi) * 0.5).clamp(0.0, 0.5);

      final paint = Paint()
        ..color = const Color(0xFF7B2FFF).withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

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
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });
}



