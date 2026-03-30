import 'dart:math';

import 'package:block/domain/models/online_room.dart';
import 'package:block/presentation/view_models/online_match_state.dart';
import 'package:block/presentation/view_models/online_match_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const _kBlue = Color(0xFF4A5CF0);
const _kRed = Color(0xFFE83535);

class OnlineMatchResult extends ConsumerWidget {
  const OnlineMatchResult({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(onlineMatchViewModelProvider(roomCode, playerId));
    final match = matchState.match;
    final participants = [...?match?.participants];
    final me = _findParticipant(participants, playerId);
    final opponent = _findOpponent(participants, playerId);
    final standings = [...?match?.result?.standings]
      ..sort((a, b) => a.place.compareTo(b.place));
    final isFinished = match?.isFinished ?? false;
    final didWin = match?.result?.winnerPlayerId == playerId;
    final isPlaying = !isFinished && me?.status != 'waiting';

    // ME — top zone เสมอ
    final myName = me?.name ?? 'Player 01';
    final myScore = (isFinished
            ? (_scoreForPlayer(standings, me?.playerId) ?? me?.score ?? 0)
            : (me?.score ?? 0))
        .toString();
    final myBadge = isFinished
        ? (didWin ? 'WINNER' : 'LOSER')
        : (isPlaying ? 'PLAYING' : 'WAITING');

    // OPPONENT — bottom zone เสมอ
    final opName = opponent?.name ?? 'Player 02';
    final opScore = isFinished
        ? '${_scoreForPlayer(standings, opponent?.playerId) ?? opponent?.score ?? 0}'
        : (opponent == null || opponent.isPlaying) ? '---' : '${opponent.score}';
    final opBadge = isFinished
        ? (didWin ? 'LOSER' : 'WINNER')
        : (opponent?.isPlaying == true ? 'PLAYING' : 'WAITING');

    // สีของ top zone ตามสถานะผู้เล่น
    final topColor = didWin ? _kBlue : _kRed;
    final botColor = didWin ? _kRed : _kBlue;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E14),
      body: SafeArea(
        child: _MatchCard(
          topColor: topColor,
          botColor: botColor,
          headline: _buildHeadline(matchState, me),
          topName: myName,
          topBadge: myBadge,
          topScore: myScore,
          topIsWinner: isFinished && didWin,
          botName: opName,
          botBadge: opBadge,
          botScore: opScore,
          botIsWinner: isFinished && !didWin,
          isFinished: isFinished,
          isLive: isPlaying && !isFinished,
          didWin: didWin,
          showRematch: !matchState.roomDeleted,
          onHome: () => context.goNamed('mode'),
          onRematch: () => context.goNamed(
            'online-lobby',
            queryParameters: {'roomCode': roomCode, 'playerId': playerId},
          ),
        ),
      ),
    );
  }
}

// ─── Match Card ───────────────────────────────────────────────────────────────
class _MatchCard extends StatefulWidget {
  const _MatchCard({
    required this.topColor,
    required this.botColor,
    required this.headline,
    required this.topName,
    required this.topBadge,
    required this.topScore,
    required this.topIsWinner,
    required this.botName,
    required this.botBadge,
    required this.botScore,
    required this.botIsWinner,
    required this.isFinished,
    required this.isLive,
    required this.didWin,
    required this.showRematch,
    required this.onHome,
    required this.onRematch,
  });

  final Color topColor, botColor;
  final String headline;
  final String topName, topBadge, topScore;
  final bool topIsWinner;
  final String botName, botBadge, botScore;
  final bool botIsWinner;
  final bool isFinished, isLive, didWin, showRematch;
  final VoidCallback onHome, onRematch;

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _fade, _btnFade;
  late Animation<Offset> _topSlide, _botSlide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _topSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)));
    _botSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)));
    _btnFade = CurvedAnimation(parent: _ac, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Stack(
        children: [
          // background เต็มจอ
          Positioned.fill(
            child: CustomPaint(
              painter: _SplitPainter(topColor: widget.topColor, botColor: widget.botColor),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _NoisePainter())),

          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                _HeadlinePill(text: widget.headline),
                const SizedBox(height: 12),

                // panels แบ่งพื้นที่ด้วย LayoutBuilder
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      const divH = 48.0;
                      final panelH = (box.maxHeight - divH) / 2;
                      return Column(
                        children: [
                          // TOP = ME: name/badge บนซ้าย, ring ล่างขวา
                          SizedBox(
                            height: panelH,
                            width: double.infinity,
                            child: SlideTransition(
                              position: _topSlide,
                              child: _TopPanel(
                                name: widget.topName,
                                badge: widget.topBadge,
                                score: widget.topScore,
                                isWinner: widget.topIsWinner,
                              ),
                            ),
                          ),

                          _VsDivider(isLive: widget.isLive),

                          // BOTTOM = OPPONENT: ring บนซ้าย, name/badge ล่างขวา
                          SizedBox(
                            height: panelH,
                            width: double.infinity,
                            child: SlideTransition(
                              position: _botSlide,
                              child: _BottomPanel(
                                name: widget.botName,
                                badge: widget.botBadge,
                                score: widget.botScore,
                                isWinner: widget.botIsWinner,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _btnFade,
                  child: _ButtonGroup(
                    isFinished: widget.isFinished,
                    didWin: widget.didWin,
                    showRematch: widget.showRematch,
                    onHome: widget.onHome,
                    onRematch: widget.onRematch,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Panel (ME) ───────────────────────────────────────────────────────────
// name + badge → บนซ้าย   |   score ring → ล่างขวา (ใกล้ VS)
class _TopPanel extends StatelessWidget {
  const _TopPanel({
    required this.name,
    required this.badge,
    required this.score,
    required this.isWinner,
  });
  final String name, badge, score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlayerName(name: name),
              const SizedBox(height: 8),
              _StatusBadge(label: badge, isWinner: isWinner),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _ScoreRing(score: score, isWinner: isWinner),
        ),
      ],
    );
  }
}

// ─── Bottom Panel (OPPONENT) ──────────────────────────────────────────────────
// score ring → บนซ้าย (ใกล้ VS)   |   badge + name → ล่างขวา
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.name,
    required this.badge,
    required this.score,
    required this.isWinner,
  });
  final String name, badge, score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 150,
          left: 0,
          child: _ScoreRing(score: score, isWinner: isWinner),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(label: badge, isWinner: isWinner),
              const SizedBox(height: 8),
              _PlayerName(name: name),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────
class _PlayerName extends StatelessWidget {
  const _PlayerName({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isWinner});
  final String label;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isWinner ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isWinner ? Colors.transparent : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWinner) ...[
            const Icon(Icons.emoji_events_rounded, size: 13, color: Color(0xFF1a1a2e)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: isWinner ? const Color(0xFF1a1a2e) : Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.isWinner});
  final String score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(isWinner ? 0.2 : 0.1),
        border: Border.all(
          color: Colors.white.withOpacity(isWinner ? 0.95 : 0.4),
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score,
            style: GoogleFonts.spaceGrotesk(
              fontSize: score.length > 4 ? 15 : 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'PTS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlinePill extends StatelessWidget {
  const _HeadlinePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

class _VsDivider extends StatelessWidget {
  const _VsDivider({required this.isLive});
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Transform.translate(
        offset: const Offset(0, 90),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLive) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1ECC7A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    isLive ? 'LIVE' : 'VS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: const Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Button Group ─────────────────────────────────────────────────────────────
class _ButtonGroup extends StatelessWidget {
  const _ButtonGroup({
    required this.isFinished,
    required this.didWin,
    required this.showRematch,
    required this.onHome,
    required this.onRematch,
  });
  final bool isFinished, didWin, showRematch;
  final VoidCallback onHome, onRematch;

  @override
  Widget build(BuildContext context) {
    if (!isFinished) return const SizedBox.shrink();
    return Column(
      children: [
        if (showRematch) ...[
          _ActionButton(label: 'PLAY AGAIN', icon: Icons.replay_rounded, primary: true, onTap: onRematch),
          const SizedBox(height: 10),
        ],
        _ActionButton(label: 'GO HOME', icon: Icons.home_rounded, primary: !showRematch, onTap: onHome),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: widget.primary ? Colors.white : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: widget.primary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: widget.primary ? const Color(0xFF1a1a2e) : Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: widget.primary ? const Color(0xFF1a1a2e) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────
class _SplitPainter extends CustomPainter {
  const _SplitPainter({required this.topColor, required this.botColor});
  final Color topColor, botColor;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width, H = size.height;
    canvas.drawPath(
      Path()..moveTo(0, 0)..lineTo(W, 0)..lineTo(W, H * 0.56)..lineTo(0, H * 0.73)..close(),
      Paint()..color = topColor,
    );
    canvas.drawPath(
      Path()..moveTo(0, H * 0.65)..lineTo(W, H * 0.46)..lineTo(W, H)..lineTo(0, H)..close(),
      Paint()..color = botColor,
    );
    final sp = Paint()..color = Colors.white.withOpacity(0.07);
    for (final ox in [0.06, 0.26, 0.46]) {
      canvas.drawPath(
        Path()..moveTo(W * ox, H * 0.52)..lineTo(W * ox + 52, H * 0.45)..lineTo(W * ox + 66, H * 0.49)..lineTo(W * ox + 14, H * 0.56)..close(),
        sp,
      );
    }
    for (final ox in [0.52, 0.72, 0.90]) {
      canvas.drawPath(
        Path()..moveTo(W * ox, H * 0.57)..lineTo(W * ox + 52, H * 0.64)..lineTo(W * ox + 38, H * 0.68)..lineTo(W * ox - 14, H * 0.61)..close(),
        sp,
      );
    }
  }

  @override
  bool shouldRepaint(_SplitPainter old) => old.topColor != topColor || old.botColor != botColor;
}

class _NoisePainter extends CustomPainter {
  static final _rng = Random(77);
  static final _dots = List.generate(200, (_) => [_rng.nextDouble(), _rng.nextDouble()]);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.022);
    for (final d in _dots) {
      canvas.drawCircle(Offset(d[0] * size.width, d[1] * size.height), 0.9, p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
OnlineRoomMatchParticipant? _findParticipant(List<OnlineRoomMatchParticipant> p, String id) {
  for (final x in p) { if (x.playerId == id) return x; }
  return null;
}

OnlineRoomMatchParticipant? _findOpponent(List<OnlineRoomMatchParticipant> p, String id) {
  for (final x in p) { if (x.playerId != id) return x; }
  return null;
}

int? _scoreForPlayer(List<OnlineRoomMatchStanding> standings, String? id) {
  if (id == null) return null;
  for (final s in standings) { if (s.playerId == id) return s.score; }
  return null;
}

String _buildHeadline(OnlineMatchState state, OnlineRoomMatchParticipant? me) {
  final match = state.match;
  if (match == null) return state.roomDeleted ? 'ROOM CLOSED' : 'CONNECTING...';
  if (match.isFinished) return match.endedReason == 'player_left' ? 'OPPONENT LEFT' : 'FINAL RESULT';
  if (me?.status == 'waiting') return 'WAITING FOR OPPONENT';
  return 'MATCH IN PROGRESS';
}