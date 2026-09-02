import 'dart:math' as math;

import 'package:block/presentation/view_models/game_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScorePopupWidget extends StatelessWidget {
  final ScorePopup popup;

  const ScorePopupWidget({super.key, required this.popup});

  _ScoreTier _getTier(int score) {
    if (score >= 200) {
      return _ScoreTier(
        primary: const Color(0xFFF43F5E), // Rose
        label: 'EPIC',
        showLabel: true,
      );
    } else if (score >= 100) {
      return _ScoreTier(
        primary: const Color(0xFFF59E0B), // Amber
        label: 'GREAT',
        showLabel: true,
      );
    } else if (score >= 50) {
      return _ScoreTier(
        primary: const Color(0xFF3B82F6), // Blue
        label: 'NICE',
        showLabel: false,
      );
    } else {
      return _ScoreTier(
        primary: const Color(0xFF4B5563), // Gray
        label: '',
        showLabel: false,
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
        final double upwardShift = value * 80;
        double scale;
        double opacity;

        if (value < 0.15) {
          final t = value / 0.15;
          scale = _elasticOut(t, amplitude: 1.25);
        } else if (value < 0.65) {
          final t = (value - 0.15) / 0.5;
          scale = 1.0 + math.sin(t * math.pi * 2) * 0.03;
        } else {
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
                  if (popup.combo > 1) ...[
                    _ComboBadge(combo: popup.combo),
                    const SizedBox(height: 4),
                  ],
                  if (tier.showLabel) ...[
                    _TierLabel(tier: tier),
                    const SizedBox(height: 2),
                  ],
                  _ScoreText(score: popup.score, tier: tier),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static double _elasticOut(double t, {double amplitude = 1.2}) {
    if (t == 0 || t == 1) return t;
    return amplitude *
            math.pow(2, -10 * t) *
            math.sin((t - 0.075) * (2 * math.pi) / 0.3) +
        1;
  }
}

class _ComboBadge extends StatelessWidget {
  final int combo;
  const _ComboBadge({required this.combo});

  @override
  Widget build(BuildContext context) {
    final Color color = combo >= 5
        ? const Color(0xFFEF4444)
        : combo >= 3
        ? const Color(0xFFF59E0B)
        : const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            'COMBO x$combo',
            style: GoogleFonts.itim(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.2,
              decoration: TextDecoration.none,
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
      style: GoogleFonts.itim(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: tier.primary,
        letterSpacing: 2.0,
        decoration: TextDecoration.none,
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
    final double fontSize = score >= 200
        ? 40
        : score >= 100
        ? 34
        : score >= 50
        ? 28
        : 24;

    return Text(
      '+$score',
      style: GoogleFonts.itim(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: tier.primary,
        letterSpacing: score >= 100 ? 1.5 : 0.5,
        decoration: TextDecoration.none,
      ),
    );
  }
}

class _ScoreTier {
  final Color primary;
  final String label;
  final bool showLabel;

  const _ScoreTier({
    required this.primary,
    required this.label,
    required this.showLabel,
  });
}
