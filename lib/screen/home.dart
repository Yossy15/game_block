import 'package:block/logic/game_controller.dart';
import 'package:block/screen/widgets/display.dart';
import 'package:block/screen/widgets/draggable_block.dart';
import 'package:block/screen/widgets/game_over.dart';
import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:gap/gap.dart';

class Home extends StatefulWidget {
  final bool isTimerMode;
  const Home({super.key, this.isTimerMode = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = GameController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameStateChanged);
    _controller.startTimer(widget.isTimerMode);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  bool _hasShownGameOver = false;

  void _onGameStateChanged() async {
    setState(() {});

    if (_controller.isGameOver && !_hasShownGameOver) {
      _hasShownGameOver = true;

      // ✅ รอ update score ให้เสร็จจริง
      await _controller.handleGameOver();

      // ✅ หน่วง 3 วินาที
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameOver(
            score: _controller.score,
            onRestart: () {
              Navigator.of(context).pop();
              _controller.resetGame();
              _hasShownGameOver = false;
            },
            bestScore: _controller.isTimerMode
                ? _controller.highScoreTimer
                : _controller.highScore,
          ),
        ),
      );
    }
  }

  // void _showGameOverDialog() {
  //   return GameOver(
  //     score: _controller.score,
  //     onRestart: () {
  //       Navigator.of(context).pop();
  //       _controller.resetGame();
  //       _hasShownGameOver = false;
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScore(),
                Gap(20),
                Display(controller: _controller),
                Container(
                  height: 100,
                  transform: Matrix4.translationValues(0, -120, 0),
                  child: _buildBlockSlots(),
                ),
              ],
            ),

            // 🔥 GAME OVER OVERLAY
            if (_controller.isGameOver) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildScore() {
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
                size: 28,
              ),
              const Gap(8),
              Text(
                _controller.timeString,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.redAccent,
                  fontFamily: 'monospace',
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text(
            //   'Score: ',
            //   style: TextStyle(
            //     fontSize: 32,
            //     fontWeight: FontWeight.bold,
            //     decoration: TextDecoration.none,
            //     color: Colors.black,
            //   ),
            // ),
            AnimatedDigitWidget(
              value: _controller.score,
              textStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black,
              ),
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
            const Text(
              'BEST: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                decoration: TextDecoration.none,
              ),
            ),
            AnimatedDigitWidget(
              value:
                  _controller.score >
                      (_controller.isTimerMode
                          ? _controller.highScoreTimer
                          : _controller.highScore)
                  ? _controller.score
                  : (_controller.isTimerMode
                        ? _controller.highScoreTimer
                        : _controller.highScore),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlockSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(slotCount, (index) {
        final block = _controller.blockSlots[index];
        if (block == null) {
          return const SizedBox(
            width: 120, // สอดคล้องกับขนาด hit area ของตัวที่มีบล็อก
            height: 120,
          );
        }
        // ใช้ ValueKey เพื่อให้ Flutter รู้ว่าบล็อกนี้เป็นตัวเดิม
        return DraggableBlock(
          key: ValueKey('slot-$index-${block.hashCode}'),
          block: block,
          slotIndex: index,
        );
      }),
    );
  }

  Widget _buildGameOverOverlay() {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "GAME OVER",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
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
