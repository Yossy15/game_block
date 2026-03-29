import 'package:block/logic/game_controller.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScorePopupWidget extends StatelessWidget {
  final ScorePopup popup;

  const ScorePopupWidget({super.key, required this.popup});

  // ── ธีมสีตามระดับคะแนน ──────────────────────────────────────────────────
  _ScoreTier _getTier(int score) {
    if (score >= 200) {
      return _ScoreTier(
        primary: const Color(0xFFFF2D78), // neon pink
        secondary: const Color(0xFFFF6EAD),
        glow: const Color(0xFFFF2D78),
        label: '★ EPIC',
        showLabel: true,
        glowRadius: 18.0,
      );
    } else if (score >= 100) {
      return _ScoreTier(
        primary: const Color(0xFFFFD600), // electric yellow
        secondary: const Color(0xFFFFF176),
        glow: const Color(0xFFFFD600),
        label: '✦ GREAT',
        showLabel: true,
        glowRadius: 14.0,
      );
    } else if (score >= 50) {
      return _ScoreTier(
        primary: const Color(0xFF00E5FF), // cyan
        secondary: const Color(0xFF80DEEA),
        glow: const Color(0xFF00BCD4),
        label: 'NICE',
        showLabel: false,
        glowRadius: 10.0,
      );
    } else {
      return _ScoreTier(
        primary: Colors.white,
        secondary: const Color(0xFFB0BEC5),
        glow: Colors.white54,
        label: '',
        showLabel: false,
        glowRadius: 6.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = _getTier(popup.score);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        // ── Animation curve ──────────────────────────────────────────────
        // 0.0–0.15 : pop-in (scale overshoot)
        // 0.15–0.65: float & hold
        // 0.65–1.0 : fade out + rise
        final double upwardShift = value * 80;

        double scale;
        double opacity;

        if (value < 0.15) {
          // elastic pop: 0 → 1.25 → 1.0
          final t = value / 0.15;
          scale = _elasticOut(t, amplitude: 1.25);
        } else if (value < 0.65) {
          // gentle pulse ± 3%
          final t = (value - 0.15) / 0.5;
          scale = 1.0 + math.sin(t * math.pi * 2) * 0.03;
        } else {
          // shrink out
          final t = (value - 0.65) / 0.35;
          scale = 1.0 - t * 0.2;
        }

        opacity = value < 0.65 ? 1.0 : 1.0 - ((value - 0.65) / 0.35);

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -upwardShift),
            child: Transform.scale(
              scale: scale.clamp(0.0, 2.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── COMBO badge ─────────────────────────────────────────
                  if (popup.combo > 1) ...[
                    _ComboBadge(combo: popup.combo),
                    const SizedBox(height: 3),
                  ],

                  // ── Tier label (EPIC / GREAT) ────────────────────────
                  if (tier.showLabel) ...[
                    _TierLabel(tier: tier),
                    const SizedBox(height: 2),
                  ],

                  // ── Score number ─────────────────────────────────────
                  _ScoreText(score: popup.score, tier: tier),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Elastic overshoot easing  t ∈ [0,1] → ค่าสูงสุด = amplitude
  static double _elasticOut(double t, {double amplitude = 1.2}) {
    if (t == 0 || t == 1) return t;
    return amplitude *
            math.pow(2, -10 * t) *
            math.sin((t - 0.075) * (2 * math.pi) / 0.3) +
        1;
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ComboBadge extends StatelessWidget {
  final int combo;
  const _ComboBadge({required this.combo});

  @override
  Widget build(BuildContext context) {
    // สีเปลี่ยนตาม combo count
    final List<Color> gradientColors = combo >= 5
        ? [const Color(0xFFFF2D78), const Color(0xFFFF6600)] // hot
        : combo >= 3
        ? [const Color(0xFFFF6600), const Color(0xFFFFD600)] // warm
        : [const Color(0xFF7C4DFF), const Color(0xFFE040FB)]; // purple

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⚡',
            style: TextStyle(fontSize: 9, decoration: TextDecoration.none),
          ),
          const SizedBox(width: 3),
          Text(
            'COMBO ×$combo',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierLabel extends StatelessWidget {
  final _ScoreTier tier;
  const _TierLabel({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Text(
      tier.label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: tier.primary,
        letterSpacing: 2.0,
        decoration: TextDecoration.none,
        shadows: [
          Shadow(color: tier.glow.withOpacity(0.9), blurRadius: 8),
          Shadow(color: tier.glow.withOpacity(0.5), blurRadius: 16),
        ],
      ),
    );
  }
}

class _ScoreText extends StatelessWidget {
  final int score;
  final _ScoreTier tier;
  const _ScoreText({required this.score, required this.tier});

  @override
  Widget build(BuildContext context) {
    // ขนาดตัวอักษรขยายตามคะแนน
    final double fontSize = score >= 200
        ? 32
        : score >= 100
        ? 28
        : score >= 50
        ? 24
        : 20;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Glow layer (blur shadow) ──
        Text(
          '+$score',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..color = tier.glow.withOpacity(0.7)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, tier.glowRadius),
            decoration: TextDecoration.none,
          ),
        ),
        // ── Outline layer ──
        Text(
          '+$score',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = Colors.black.withOpacity(0.35),
            decoration: TextDecoration.none,
          ),
        ),
        // ── Fill layer (gradient shimmer) ──
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tier.secondary, tier.primary],
          ).createShader(bounds),
          child: Text(
            '+$score',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white, // ShaderMask ทับสีนี้
              letterSpacing: score >= 100 ? 1.5 : 0.5,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data class ───────────────────────────────────────────────────────────────

class _ScoreTier {
  final Color primary;
  final Color secondary;
  final Color glow;
  final String label;
  final bool showLabel;
  final double glowRadius;

  const _ScoreTier({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.label,
    required this.showLabel,
    required this.glowRadius,
  });
}
