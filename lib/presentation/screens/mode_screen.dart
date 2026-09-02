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
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _card1Slide;
  late Animation<Offset> _card2Slide;

  @override
  void initState() {
    super.initState();

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
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            color: const Color(0xFFF9FAFB), // Minimal light background
            child: Stack(
              children: [
                // Minimal grid background
                Positioned.fill(child: CustomPaint(painter: _GridPainter())),

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
                                color: Colors.black.withValues(alpha: 0.4),
                                fontFamily: 'sans-serif',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'BLOCK',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: Color(0xFF111827),
                                decoration: TextDecoration.none,
                                fontFamily: 'sans-serif',
                              ),
                            ),
                            const Gap(6),
                            Container(
                              width: 64,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
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
                                      description: 'No time limit\nPlace & clear',
                                      icon: Icons.grid_4x4_rounded,
                                      accentColor: const Color(0xFF3B82F6),
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
                                      description: 'Race the clock\nBeat your best',
                                      icon: Icons.timer_rounded,
                                      accentColor: const Color(0xFFEF4444),
                                      onTap: () => _goToHome(context, isTimerMode: true),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Row(
                              children: [
                                Expanded(
                                  child: SlideTransition(
                                    position: _card2Slide,
                                    child: _ModeCard(
                                      label: 'BATTER\n(Online)',
                                      badge: 'CHALLENGE',
                                      description: 'Create room\nJoin by code',
                                      icon: Icons.wifi_tethering_rounded,
                                      accentColor: const Color(0xFF8B5CF6),
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
                            color: Colors.black.withValues(alpha: 0.3),
                            fontFamily: 'sans-serif',
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        title: const Text(
          'Exit Game',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Colors.black54, fontFamily: 'sans-serif'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.black38, fontFamily: 'sans-serif'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'EXIT',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontFamily: 'sans-serif',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? widget.accentColor.withValues(alpha: 0.8)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                    color: widget.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: _hovered ? 0.3 : 0.1),
                    ),
                  ),
                  child: Text(
                    widget.badge,
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                      fontFamily: 'sans-serif',
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
                    color: _hovered
                        ? widget.accentColor.withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    border: Border.all(
                      color: _hovered
                          ? widget.accentColor.withValues(alpha: 0.5)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _hovered ? widget.accentColor : const Color(0xFF9CA3AF),
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
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xFF1F2937),
                    decoration: TextDecoration.none,
                    fontFamily: 'sans-serif',
                  ),
                ),

                const Gap(8),

                // Description
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.none,
                    fontFamily: 'sans-serif',
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
                      color: widget.accentColor,
                      size: 18,
                    ),
                    const Gap(4),
                    Text(
                      'START',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: widget.accentColor,
                        decoration: TextDecoration.none,
                        fontFamily: 'sans-serif',
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
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
