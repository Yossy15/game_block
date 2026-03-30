import 'package:block/domain/models/online_room.dart';
import 'package:block/presentation/view_models/online_room_lobby_state.dart';
import 'package:block/presentation/view_models/online_room_lobby_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnlineRoomLobbyScreen extends ConsumerWidget {
  const OnlineRoomLobbyScreen({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = onlineRoomLobbyViewModelProvider(roomCode, playerId);
    final lobbyState = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen<OnlineRoomLobbyState>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.pendingMatchId != null && next.pendingMatchId != previous?.pendingMatchId) {
        final room = next.room;
        viewModel.consumePendingMatchNavigation();
        context.goNamed(
          'game',
          queryParameters: {
            'timerMode': '${room?.matchDurationSeconds != null}',
            'online': 'true',
            'roomCode': roomCode,
            'playerId': playerId,
            if (room?.matchDurationSeconds != null)
              'matchDurationSeconds': '${room!.matchDurationSeconds}',
          },
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080112),
              Color(0xFF14061F),
              Color(0xFF2A0E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: lobbyState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _LobbyContent(
                        room: lobbyState.room,
                        playerId: playerId,
                        isLeaving: lobbyState.isLeaving,
                        isStarting: lobbyState.isStarting,
                        restStatus: lobbyState.restStatus,
                        socketStatus: lobbyState.socketStatus,
                        attachStatus: lobbyState.attachStatus,
                        onLeave: () async {
                          final left = await viewModel.leaveRoom(
                            roomCode: roomCode,
                            playerId: playerId,
                          );
                          if (left && context.mounted) {
                            context.goNamed('mode');
                          }
                        },
                        onEnterGame: () async {
                          final room = lobbyState.room;
                          final isActiveMatch = room?.currentMatch?.isActive ?? false;
                          if (isActiveMatch) {
                            context.goNamed(
                              'game',
                              queryParameters: {
                                'timerMode': '${room?.matchDurationSeconds != null}',
                                'online': 'true',
                                'roomCode': roomCode,
                                'playerId': playerId,
                                if (room?.matchDurationSeconds != null)
                                  'matchDurationSeconds': '${room!.matchDurationSeconds}',
                              },
                            );
                            return;
                          }

                          await viewModel.startMatch(
                            roomCode: roomCode,
                            playerId: playerId,
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyContent extends StatelessWidget {
  const _LobbyContent({
    required this.room,
    required this.playerId,
    required this.isLeaving,
    required this.isStarting,
    required this.restStatus,
    required this.socketStatus,
    required this.attachStatus,
    required this.onLeave,
    required this.onEnterGame,
  });

  final OnlineRoom? room;
  final String playerId;
  final bool isLeaving;
  final bool isStarting;
  final String restStatus;
  final String socketStatus;
  final String attachStatus;
  final VoidCallback onLeave;
  final Future<void> Function() onEnterGame;

  @override
  Widget build(BuildContext context) {
    final players = room?.players ?? const <OnlineRoomPlayer>[];
    final matchingPlayers = players.where((item) => item.playerId == playerId);
    final currentPlayer = matchingPlayers.isEmpty ? null : matchingPlayers.first;
    final isHost = currentPlayer?.isHost ?? false;
    final isActiveMatch = room?.currentMatch?.isActive ?? false;
    final canStartMatch = isHost && players.length >= 2;
    final durationLabel = room?.matchDurationSeconds == null
        ? 'UNLIMITED MATCH'
        : '${(room!.matchDurationSeconds! / 60).round()}-MIN MATCH';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ROOM ${room?.roomCode ?? '-'}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const Gap(10),
        Text(
          isActiveMatch
              ? 'Match is already active. Enter now to join the 5-minute battle.'
              : 'Gather players here, then let the host start a 5-minute battle.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 14,
          ),
        ),
        const Gap(24),
        // DEBUG STATUS block kept here for future troubleshooting.
        // Container(
        //   padding: const EdgeInsets.all(14),
        //   decoration: BoxDecoration(
        //     color: Colors.black.withValues(alpha: 0.18),
        //     borderRadius: BorderRadius.circular(16),
        //     border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'DEBUG STATUS',
        //         style: TextStyle(
        //           color: Colors.white.withValues(alpha: 0.7),
        //           fontSize: 11,
        //           fontWeight: FontWeight.w800,
        //           letterSpacing: 2,
        //         ),
        //       ),
        //       const Gap(10),
        //       _DebugLine(label: 'REST', value: restStatus),
        //       const Gap(6),
        //       _DebugLine(label: 'SOCKET', value: socketStatus),
        //       const Gap(6),
        //       _DebugLine(label: 'ATTACH', value: attachStatus),
        //     ],
        //   ),
        // ),
        // const Gap(16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAYERS (${players.length})',
                style: GoogleFonts.itim(
                                color: Colors.white.withValues(alpha: 0.62),
                                letterSpacing: 2.2,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                // style: TextStyle(
                //   color: Colors.white.withValues(alpha: 0.62),
                //   fontSize: 11,
                //   fontWeight: FontWeight.w700,
                //   letterSpacing: 2.2,
                // ),
              ),
              const Gap(12),
              for (final player in players) ...[
                _PlayerTile(player: player),
                const Gap(10),
              ],
            ],
          ),
        ),
        const Gap(20),
        FilledButton(
          onPressed: isStarting || (!isActiveMatch && !canStartMatch)
              ? null
              : () async {
                  await onEnterGame();
                },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.itim(
                                // color: Colors.white,
                                letterSpacing: 2,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
            // textStyle: const TextStyle(
            //   fontSize: 13,
            //   fontWeight: FontWeight.w800,
            //   letterSpacing: 2,
            // ),
          ),
          child: isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isActiveMatch ? 'ENTER MATCH' : 'START $durationLabel'),
        ),
        if (!isActiveMatch && !canStartMatch) ...[
          const Gap(10),
          Text(
            isHost
                ? 'Need at least 2 players in the room before starting.'
                : 'Waiting for the host to start the match.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
        ],
        const Gap(12),
        OutlinedButton(
          onPressed: isLeaving ? null : onLeave,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          child: isLeaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('LEAVE ROOM'),
        ),
      ],
    );
  }
}

// class _DebugLine extends StatelessWidget {
//   const _DebugLine({required this.label, required this.value});
//
//   final String label;
//   final String value;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 72,
//           child: Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.5),
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player});

  final OnlineRoomPlayer player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.isHost
              ? const Color(0xFFFF6B2F).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: player.isHost
                ? const Color(0xFFFF6B2F).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: GoogleFonts.itim(
                                color: Colors.white,
                                // fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
              // style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.itim(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                  // style: const TextStyle(
                  //   color: Colors.white,
                  //   fontSize: 15,
                  //   fontWeight: FontWeight.w700,
                  // ),
                ),
                const Gap(3),
                Text(
                  player.isHost ? 'Host' : 'Guest',
                  style: GoogleFonts.itim(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                                // fontWeight: FontWeight.w500,
                              ),
                  // style: TextStyle(
                  //   color: Colors.white.withValues(alpha: 0.55),
                  //   fontSize: 12,
                  // ),
                ),
              ],
            ),
          ),
          Icon(
            player.socketId != null ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: player.socketId != null
                ? const Color(0xFF61E786)
                : Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
