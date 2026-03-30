import 'package:animated_digit/animated_digit.dart';
import 'package:block/core/constants/game_constants.dart';
import 'package:block/presentation/view_models/game_state.dart';
import 'package:block/presentation/view_models/game_view_model.dart';
import 'package:block/presentation/view_models/online_match_state.dart';
import 'package:block/presentation/view_models/online_match_view_model.dart';
import 'package:block/presentation/widgets/display.dart';
import 'package:block/presentation/widgets/draggable_block.dart';
import 'package:block/presentation/widgets/game_over.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool isTimerMode;
  final bool isOnline;
  final String? roomCode;
  final String? playerId;
  final int? matchDurationSeconds;

  const HomeScreen({
    super.key,
    this.isTimerMode = false,
    this.isOnline = false,
    this.roomCode,
    this.playerId,
    this.matchDurationSeconds,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasShownGameOver = false;
  bool _hasShownOnlineResult = false;

  Future<void> _handleGameOver(GameState gameState, GameViewModel viewModel) async {
    if (widget.isOnline || _hasShownGameOver || !gameState.isGameOver) {
      return;
    }

    _hasShownGameOver = true;
    await viewModel.handleGameOver();
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameOver(
          score: gameState.score,
          bestScore: gameState.isTimerMode
              ? gameState.highScoreTimer
              : gameState.highScore,
          onRestart: () {
            Navigator.of(context).pop();
            viewModel.resetGame();
            _hasShownGameOver = false;
          },
        ),
      ),
    );
  }

  Future<void> _handleOnlineResultDialog() async {
    if (_hasShownOnlineResult || !mounted || widget.playerId == null || widget.roomCode == null) {
      return;
    }

    _hasShownOnlineResult = true;
    context.goNamed(
      'online-result',
      queryParameters: {
        'roomCode': widget.roomCode!,
        'playerId': widget.playerId!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = gameViewModelProvider(
      widget.isTimerMode,
      widget.matchDurationSeconds,
    );
    final gameState = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    final onlineProvider = widget.isOnline && widget.roomCode != null && widget.playerId != null
        ? onlineMatchViewModelProvider(widget.roomCode!, widget.playerId!)
        : null;
    final onlineMatchState = onlineProvider != null ? ref.watch(onlineProvider) : null;
    final onlineMatchViewModel = onlineProvider != null
        ? ref.read(onlineProvider.notifier)
        : null;

    ref.listen<GameState>(provider, (previous, next) {
      if (widget.isOnline && widget.roomCode != null && widget.playerId != null) {
        onlineMatchViewModel?.submitScore(
          roomCode: widget.roomCode!,
          playerId: widget.playerId!,
          score: next.score,
          force: previous?.score != next.score,
        );

        if (previous?.isGameOver != true && next.isGameOver) {
          onlineMatchViewModel?.completeRun(
            roomCode: widget.roomCode!,
            playerId: widget.playerId!,
            score: next.score,
          );
          _handleOnlineResultDialog();
        }
      }

      _handleGameOver(next, viewModel);
    });

    if (onlineProvider != null) {
      ref.listen<OnlineMatchState>(onlineProvider, (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }

        if (next.match?.isFinished == true) {
          _handleOnlineResultDialog();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScore(gameState),
                if (widget.isOnline) _buildOnlineBanner(onlineMatchState),
                const Gap(20),
                Display(state: gameState, viewModel: viewModel),
                Transform.translate(
                  offset: const Offset(0, -90),
                  child: SizedBox(
                    height: 100,
                    child: _buildBlockSlots(gameState),
                  ),
                ),
              ],
            ),
            if (gameState.isGameOver && !widget.isOnline) _buildGameOverOverlay(gameState),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineBanner(OnlineMatchState? onlineMatchState) {
    final room = onlineMatchState?.room;
    final match = room?.currentMatch;
    final scores = match?.scores ?? const <String, int>{};
    final currentScore = widget.playerId == null ? null : scores[widget.playerId!];
    final leaderId = scores.entries.isEmpty
        ? null
        : (scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
    final leaders = room?.players.where((player) => player.playerId == leaderId);
    final leader = leaders == null || leaders.isEmpty ? null : leaders.first;
    final leaderScore = leaderId == null ? null : scores[leaderId];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B2F).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFFF6B2F).withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              'ONLINE ROOM ${widget.roomCode ?? '-'}',
              style: GoogleFonts.itim(
                                color: Color(0xFFFF6B2F),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.2,
                              ),
              // style: const TextStyle(
              //   color: Color(0xFFFF6B2F),
              //   fontSize: 11,
              //   fontWeight: FontWeight.w800,
              //   letterSpacing: 2.2,
              // ),
            ),
          ),
          const Gap(6),
          Text(
            match == null
                ? 'Connecting online match...'
                : match.isFinished
                ? 'Match finished. Final score is locked.'
                : currentScore != null && leader != null && leaderScore != null
                ? 'Your score $currentScore • Leader: ${leader.name} $leaderScore'
                : '5-minute online battle is active.',
            style: GoogleFonts.itim(
                                color: Colors.black.withValues(alpha: 0.45),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
            // style: TextStyle(
            //   color: Colors.black.withValues(alpha: 0.45),
            //   fontSize: 11,
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore(GameState gameState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isTimerMode) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Colors.redAccent,
                size: 24,
              ),
              const Gap(8),
              Text(
                gameState.timeString,
                style: GoogleFonts.itim(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                                // fontFamily: 'monospace',
                                decoration: TextDecoration.none,
                              ),
                // style: const TextStyle(
                //   fontSize: 36,
                //   fontWeight: FontWeight.w900,
                //   color: Colors.redAccent,
                //   fontFamily: 'monospace',
                //   decoration: TextDecoration.none,
                // ),
              ),
            ],
          ),
          // const Gap(8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDigitWidget(
              value: gameState.score,
              textStyle: GoogleFonts.itim(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
              // textStyle: const TextStyle(
              //   fontSize: 32,
              //   fontWeight: FontWeight.bold,
              //   decoration: TextDecoration.none,
              //   color: Colors.black,
              // ),
            ),
          ],
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: Colors.orangeAccent,
              size: 20,
            ),
            const Gap(4),
            Text(
              'BEST: ',
              style: GoogleFonts.itim(
                                // color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                decoration: TextDecoration.none,
                              ),
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              //   color: Colors.black54,
              //   decoration: TextDecoration.none,
              // ),
            ),
            AnimatedDigitWidget(
              value: gameState.score >
                      (gameState.isTimerMode
                          ? gameState.highScoreTimer
                          : gameState.highScore)
                  ? gameState.score
                  : (gameState.isTimerMode
                        ? gameState.highScoreTimer
                        : gameState.highScore),
              textStyle: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                decoration: TextDecoration.none,
                              ),
              // textStyle: const TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              //   color: Colors.black54,
              //   decoration: TextDecoration.none,
              // ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlockSlots(GameState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(slotCount, (index) {
        final block = gameState.blockSlots[index];
        if (block == null) {
          return const SizedBox(width: 120, height: 120);
        }

        return DraggableBlock(
          key: ValueKey('slot-$index-${block.hashCode}'),
          block: block,
          slotIndex: index,
        );
      }),
    );
  }

  Widget _buildGameOverOverlay(GameState gameState) {
    final title = widget.isOnline
        ? gameState.remainingSeconds == 0
            ? 'TIME UP'
            : 'NO MOVES'
        : 'GAME OVER';
    final subtitle = widget.isOnline
        ? gameState.remainingSeconds == 0
            ? 'Waiting for final match result...'
            : 'Your score is locked until the timer ends.'
        : null;

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.itim(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                decoration: TextDecoration.none,
                              ),
                // style: TextStyle(
                //   fontSize: 42,
                //   fontWeight: FontWeight.bold,
                //   color: Colors.red,
                //   decoration: TextDecoration.none,
                //   fontFamily: 'monospace',
                // ),
              ),
              if (subtitle != null) ...[
                Gap(12),
                Text(
                  subtitle,
                  style: GoogleFonts.itim(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                  // style: TextStyle(
                  //   fontSize: 14,
                  //   fontWeight: FontWeight.w500,
                  //   color: Colors.white,
                  //   decoration: TextDecoration.none,
                  // ),
                ),
                Gap(20),
                FilledButton(
                  onPressed: () => context.goNamed('mode'),
                  child: Text('GO HOME'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
