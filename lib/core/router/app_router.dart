import 'package:block/presentation/screens/home_screen.dart';
import 'package:block/presentation/screens/online_room_lobby_screen.dart';
import 'package:block/presentation/screens/mode_screen.dart';
import 'package:block/presentation/screens/online_room_screen.dart';
import 'package:block/presentation/widgets/online_match_result.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'mode',
        builder: (context, state) => const ModeScreen(),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) {
          final isTimerMode = state.uri.queryParameters['timerMode'] == 'true';
          final isOnline = state.uri.queryParameters['online'] == 'true';
          final roomCode = state.uri.queryParameters['roomCode'];
          final playerId = state.uri.queryParameters['playerId'];
          final matchDurationSeconds = int.tryParse(
            state.uri.queryParameters['matchDurationSeconds'] ?? '',
          );

          return HomeScreen(
            isTimerMode: isTimerMode,
            isOnline: isOnline,
            roomCode: roomCode,
            playerId: playerId,
            matchDurationSeconds: matchDurationSeconds,
          );
        },
      ),
      GoRoute(
        path: '/online',
        name: 'online-room',
        builder: (context, state) => const OnlineRoomScreen(),
      ),
      GoRoute(
        path: '/online/lobby',
        name: 'online-lobby',
        builder: (context, state) {
          final roomCode = state.uri.queryParameters['roomCode'];
          final playerId = state.uri.queryParameters['playerId'];

          if (roomCode == null || playerId == null) {
            return const ModeScreen();
          }

          return OnlineRoomLobbyScreen(roomCode: roomCode, playerId: playerId);
        },
      ),
      GoRoute(
        path: '/online/result',
        name: 'online-result',
        builder: (context, state) {
          final roomCode = state.uri.queryParameters['roomCode'];
          final playerId = state.uri.queryParameters['playerId'];

          if (roomCode == null || playerId == null) {
            return const ModeScreen();
          }

          return OnlineMatchResult(roomCode: roomCode, playerId: playerId);
        },
      ),
    ],
  );
}
