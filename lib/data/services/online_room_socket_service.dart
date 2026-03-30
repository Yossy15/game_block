import 'package:block/core/network/dio_client.dart';
import 'package:block/domain/models/online_room.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

part 'online_room_socket_service.g.dart';

class OnlineRoomSocketService {
  OnlineRoomSocketService();

  io.Socket? _socket;

  void connect({
    void Function()? onConnected,
    void Function(OnlineRoom room)? onRoomUpdated,
    void Function(OnlineRoom room)? onMatchStarted,
    void Function(OnlineRoom room)? onMatchUpdated,
    void Function(OnlineRoom room)? onMatchFinished,
    void Function(String roomCode)? onRoomDeleted,
    required void Function(String message) onError,
  }) {
    _socket ??= io.io(
      apiBaseUrl,
      io.OptionBuilder()
          .setTransports(kIsWeb ? ['polling', 'websocket'] : ['websocket'])
          .setPath('/socket.io')
          .enableForceNew()
          .disableMultiplex()
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(6)
          .setReconnectionDelay(1500)
          .setTimeout(30000)
          .build(),
    );

    _socket!
      ..off('roomUpdated')
      ..off('roomAttached')
      ..off('matchStarted')
      ..off('matchUpdated')
      ..off('matchFinished')
      ..off('roomDeleted')
      ..off('error')
      ..off('connect')
      ..off('reconnect_attempt')
      ..off('connect_error')
      ..on('connect', (_) {
        onConnected?.call();
      })
      ..on('reconnect_attempt', (attempt) {
        onError('Socket reconnect attempt: $attempt');
      })
      ..on('roomUpdated', (data) {
        if (onRoomUpdated != null) {
          onRoomUpdated(OnlineRoom.fromJson(Map<String, dynamic>.from(data as Map)));
        }
      })
      ..on('roomAttached', (data) {
        if (onRoomUpdated != null) {
          onRoomUpdated(OnlineRoom.fromJson(Map<String, dynamic>.from(data as Map)));
        }
      })
      ..on('matchStarted', (data) {
        if (onMatchStarted != null) {
          onMatchStarted(OnlineRoom.fromJson(Map<String, dynamic>.from(data as Map)));
        }
      })
      ..on('matchUpdated', (data) {
        if (onMatchUpdated != null) {
          onMatchUpdated(OnlineRoom.fromJson(Map<String, dynamic>.from(data as Map)));
        }
      })
      ..on('matchFinished', (data) {
        if (onMatchFinished != null) {
          onMatchFinished(OnlineRoom.fromJson(Map<String, dynamic>.from(data as Map)));
        }
      })
      ..on('roomDeleted', (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final deletedRoomCode = map['roomCode'] as String? ?? '';
        if (onRoomDeleted != null) {
          onRoomDeleted(deletedRoomCode);
        }
      })
      ..on('error', (error) {
        onError(error.toString());
      })
      ..on('connect_error', (error) {
        onError(error.toString());
      });

    if (!(_socket!.connected)) {
      _socket!.connect();
      return;
    }

    onConnected?.call();
  }

  void attachRoom({
    required String roomCode,
    required String playerId,
    required void Function(OnlineRoom room) onAttached,
    required void Function(String message) onError,
  }) {
    _socket?.emitWithAck(
      'attachRoom',
      {
        'roomCode': roomCode,
        'playerId': playerId,
      },
      ack: (response) {
        final map = Map<String, dynamic>.from(response as Map);
        if (map['ok'] == true && map['room'] is Map) {
          onAttached(OnlineRoom.fromJson(Map<String, dynamic>.from(map['room'] as Map)));
          return;
        }
        onError(map['message'] as String? ?? 'Unable to attach room.');
      },
    );
  }

  void leaveRoom({
    required String roomCode,
    required String playerId,
    void Function()? onLeft,
    void Function(String message)? onError,
  }) {
    _socket?.emitWithAck(
      'leaveRoom',
      {
        'roomCode': roomCode,
        'playerId': playerId,
      },
      ack: (response) {
        final map = Map<String, dynamic>.from(response as Map);
        if (map['ok'] == true) {
          onLeft?.call();
          return;
        }
        onError?.call(map['message'] as String? ?? 'Unable to leave room.');
      },
    );
  }

  void startMatch({
    required String roomCode,
    required String playerId,
    required void Function(OnlineRoom room) onStarted,
    required void Function(String message) onError,
  }) {
    _socket?.emitWithAck(
      'startMatch',
      {
        'roomCode': roomCode,
        'playerId': playerId,
      },
      ack: (response) {
        final map = Map<String, dynamic>.from(response as Map);
        if (map['ok'] == true && map['room'] is Map) {
          onStarted(OnlineRoom.fromJson(Map<String, dynamic>.from(map['room'] as Map)));
          return;
        }
        onError(map['message'] as String? ?? 'Unable to start match.');
      },
    );
  }

  void updateMatchScore({
    required String roomCode,
    required String playerId,
    required int score,
    void Function(OnlineRoom room)? onUpdated,
    void Function(String message)? onError,
  }) {
    _socket?.emitWithAck(
      'updateMatchScore',
      {
        'roomCode': roomCode,
        'playerId': playerId,
        'score': score,
      },
      ack: (response) {
        final map = Map<String, dynamic>.from(response as Map);
        if (map['ok'] == true) {
          if (onUpdated != null && map['room'] is Map) {
            onUpdated(
              OnlineRoom.fromJson(Map<String, dynamic>.from(map['room'] as Map)),
            );
          }
          return;
        }
        onError?.call(map['message'] as String? ?? 'Unable to update score.');
      },
    );
  }

  void completeMatchRun({
    required String roomCode,
    required String playerId,
    required int score,
    void Function(OnlineRoom room)? onUpdated,
    void Function(String message)? onError,
  }) {
    _socket?.emitWithAck(
      'completeMatchRun',
      {
        'roomCode': roomCode,
        'playerId': playerId,
        'score': score,
      },
      ack: (response) {
        final map = Map<String, dynamic>.from(response as Map);
        if (map['ok'] == true) {
          if (onUpdated != null && map['room'] is Map) {
            onUpdated(
              OnlineRoom.fromJson(Map<String, dynamic>.from(map['room'] as Map)),
            );
          }
          return;
        }
        onError?.call(map['message'] as String? ?? 'Unable to lock score.');
      },
    );
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

@Riverpod(keepAlive: true)
OnlineRoomSocketService onlineRoomSocketService(Ref ref) {
  final service = OnlineRoomSocketService();
  ref.onDispose(service.disconnect);
  return service;
}
