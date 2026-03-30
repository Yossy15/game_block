class OnlineRoom {
  const OnlineRoom({
    required this.roomCode,
    required this.hostSocketId,
    required this.hostPlayerId,
    required this.playerCount,
    required this.players,
    required this.matchDurationSeconds,
    required this.currentMatch,
  });

  final String roomCode;
  final String? hostSocketId;
  final String? hostPlayerId;
  final int playerCount;
  final List<OnlineRoomPlayer> players;
  final int? matchDurationSeconds;
  final OnlineRoomMatch? currentMatch;

  factory OnlineRoom.fromJson(Map<String, dynamic> json) {
    return OnlineRoom(
      roomCode: json['roomCode'] as String,
      hostSocketId: json['hostSocketId'] as String?,
      hostPlayerId: json['hostPlayerId'] as String?,
      playerCount: json['playerCount'] as int? ?? 0,
      players: (json['players'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => OnlineRoomPlayer.fromJson(item as Map<String, dynamic>))
          .toList(),
      matchDurationSeconds: (json['matchDurationSeconds'] as num?)?.toInt(),
      currentMatch: json['currentMatch'] is Map<String, dynamic>
          ? OnlineRoomMatch.fromJson(json['currentMatch'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OnlineRoomPlayer {
  const OnlineRoomPlayer({
    required this.playerId,
    required this.socketId,
    required this.name,
    required this.joinedAt,
    required this.isHost,
  });

  final String playerId;
  final String? socketId;
  final String name;
  final String joinedAt;
  final bool isHost;

  factory OnlineRoomPlayer.fromJson(Map<String, dynamic> json) {
    return OnlineRoomPlayer(
      playerId: json['playerId'] as String,
      socketId: json['socketId'] as String?,
      name: json['name'] as String? ?? '',
      joinedAt: json['joinedAt'] as String? ?? '',
      isHost: json['isHost'] as bool? ?? false,
    );
  }
}

class OnlineRoomSession {
  const OnlineRoomSession({
    required this.roomCode,
    required this.playerId,
    required this.room,
  });

  final String roomCode;
  final String playerId;
  final OnlineRoom room;

  factory OnlineRoomSession.fromJson(Map<String, dynamic> json) {
    return OnlineRoomSession(
      roomCode: json['roomCode'] as String,
      playerId: json['playerId'] as String,
      room: OnlineRoom.fromJson(json['room'] as Map<String, dynamic>),
    );
  }
}

class OnlineRoomMatch {
  const OnlineRoomMatch({
    required this.matchId,
    required this.status,
    required this.durationSeconds,
    required this.startedAt,
    required this.endsAt,
    required this.scores,
    required this.playerStatuses,
    required this.participants,
    required this.endedReason,
    required this.result,
  });

  final String matchId;
  final String status;
  final int? durationSeconds;
  final String? startedAt;
  final String? endsAt;
  final Map<String, int> scores;
  final Map<String, String> playerStatuses;
  final List<OnlineRoomMatchParticipant> participants;
  final String? endedReason;
  final OnlineRoomMatchResult? result;

  bool get isActive => status == 'active';
  bool get isFinished => status == 'finished';
  bool get isUnlimitedTime => durationSeconds == null;

  factory OnlineRoomMatch.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final rawStatuses =
        json['playerStatuses'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return OnlineRoomMatch(
      matchId: json['matchId'] as String? ?? '',
      status: json['status'] as String? ?? 'idle',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      startedAt: json['startedAt'] as String?,
      endsAt: json['endsAt'] as String?,
      scores: rawScores.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
      playerStatuses: rawStatuses.map(
        (key, value) => MapEntry(key, value as String? ?? 'playing'),
      ),
      participants: (json['participants'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (item) =>
                OnlineRoomMatchParticipant.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      endedReason: json['endedReason'] as String?,
      result: json['result'] is Map<String, dynamic>
          ? OnlineRoomMatchResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OnlineRoomMatchResult {
  const OnlineRoomMatchResult({
    required this.winnerPlayerId,
    required this.standings,
  });

  final String? winnerPlayerId;
  final List<OnlineRoomMatchStanding> standings;

  factory OnlineRoomMatchResult.fromJson(Map<String, dynamic> json) {
    return OnlineRoomMatchResult(
      winnerPlayerId: json['winnerPlayerId'] as String?,
      standings: (json['standings'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (item) =>
                OnlineRoomMatchStanding.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class OnlineRoomMatchStanding {
  const OnlineRoomMatchStanding({
    required this.playerId,
    required this.name,
    required this.score,
    required this.place,
    required this.status,
  });

  final String playerId;
  final String name;
  final int score;
  final int place;
  final String status;

  factory OnlineRoomMatchStanding.fromJson(Map<String, dynamic> json) {
    return OnlineRoomMatchStanding(
      playerId: json['playerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      place: json['place'] as int? ?? 0,
      status: json['status'] as String? ?? 'finished',
    );
  }
}

class OnlineRoomMatchParticipant {
  const OnlineRoomMatchParticipant({
    required this.playerId,
    required this.name,
    required this.score,
    required this.status,
  });

  final String playerId;
  final String name;
  final int score;
  final String status;

  bool get isWaiting => status == 'waiting';
  bool get isPlaying => status == 'playing';
  bool get hasLeft => status == 'left';

  factory OnlineRoomMatchParticipant.fromJson(Map<String, dynamic> json) {
    return OnlineRoomMatchParticipant(
      playerId: json['playerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'playing',
    );
  }
}
