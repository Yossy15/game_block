import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

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

  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _cardSlide;
  late Animation<double> _scaleAnim;

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
          color: const Color(0xFFF9FAFB),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(20),

                // GAME OVER title
                SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Color(0xFF111827),
                      decoration: TextDecoration.none,
                      fontFamily: 'sans-serif',
                    ),
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
                          color: Colors.black.withValues(alpha: 0.4),
                          fontFamily: 'sans-serif',
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
                              accent: const Color(0xFFF59E0B),
                              highlight: _isNewBest,
                            ),
                          ),
                          const Gap(12),
                          SizedBox(
                            width: double.infinity,
                            child: _ScoreCard(
                              label: 'SCORE',
                              value: widget.score,
                              accent: const Color(0xFF3B82F6),
                              highlight: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Gap(40),

                // Restart button
                SlideTransition(
                  position: _cardSlide,
                  child: _RestartButton(onTap: widget.onRestart),
                ),

                const Gap(20),

                SlideTransition(
                  position: _cardSlide,
                  child: _HomeButton(),
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
                      color: Colors.black.withValues(alpha: 0.3),
                      fontFamily: 'sans-serif',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const Gap(20),
              ],
            ),
          ),
        ),
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? accent : const Color(0xFFE5E7EB),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: highlight ? accent : const Color(0xFF6B7280),
              decoration: TextDecoration.none,
              fontFamily: 'sans-serif',
            ),
          ),
          const Gap(8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              decoration: TextDecoration.none,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NewBestBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '✦',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFF59E0B),
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
              color: Color(0xFFF59E0B),
              decoration: TextDecoration.none,
              fontFamily: 'sans-serif',
            ),
          ),
          const Gap(6),
          const Text(
            '✦',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFF59E0B),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
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
          width: 200,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
              const Gap(8),
              const Text(
                'PLAY AGAIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: 'sans-serif',
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
          width: 200,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded, color: Color(0xFF111827), size: 24),
              const Gap(8),
              const Text(
                'HOME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFF111827),
                  decoration: TextDecoration.none,
                  fontFamily: 'sans-serif',
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
        color: Colors.black.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}
