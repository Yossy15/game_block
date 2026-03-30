// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_room_lobby_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onlineRoomLobbyViewModelHash() =>
    r'a8635f31b425cf866a30cd2684edb8b30dcd1f25';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$OnlineRoomLobbyViewModel
    extends BuildlessAutoDisposeNotifier<OnlineRoomLobbyState> {
  late final String roomCode;
  late final String playerId;

  OnlineRoomLobbyState build(String roomCode, String playerId);
}

/// See also [OnlineRoomLobbyViewModel].
@ProviderFor(OnlineRoomLobbyViewModel)
const onlineRoomLobbyViewModelProvider = OnlineRoomLobbyViewModelFamily();

/// See also [OnlineRoomLobbyViewModel].
class OnlineRoomLobbyViewModelFamily extends Family<OnlineRoomLobbyState> {
  /// See also [OnlineRoomLobbyViewModel].
  const OnlineRoomLobbyViewModelFamily();

  /// See also [OnlineRoomLobbyViewModel].
  OnlineRoomLobbyViewModelProvider call(String roomCode, String playerId) {
    return OnlineRoomLobbyViewModelProvider(roomCode, playerId);
  }

  @override
  OnlineRoomLobbyViewModelProvider getProviderOverride(
    covariant OnlineRoomLobbyViewModelProvider provider,
  ) {
    return call(provider.roomCode, provider.playerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'onlineRoomLobbyViewModelProvider';
}

/// See also [OnlineRoomLobbyViewModel].
class OnlineRoomLobbyViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          OnlineRoomLobbyViewModel,
          OnlineRoomLobbyState
        > {
  /// See also [OnlineRoomLobbyViewModel].
  OnlineRoomLobbyViewModelProvider(String roomCode, String playerId)
    : this._internal(
        () => OnlineRoomLobbyViewModel()
          ..roomCode = roomCode
          ..playerId = playerId,
        from: onlineRoomLobbyViewModelProvider,
        name: r'onlineRoomLobbyViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$onlineRoomLobbyViewModelHash,
        dependencies: OnlineRoomLobbyViewModelFamily._dependencies,
        allTransitiveDependencies:
            OnlineRoomLobbyViewModelFamily._allTransitiveDependencies,
        roomCode: roomCode,
        playerId: playerId,
      );

  OnlineRoomLobbyViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomCode,
    required this.playerId,
  }) : super.internal();

  final String roomCode;
  final String playerId;

  @override
  OnlineRoomLobbyState runNotifierBuild(
    covariant OnlineRoomLobbyViewModel notifier,
  ) {
    return notifier.build(roomCode, playerId);
  }

  @override
  Override overrideWith(OnlineRoomLobbyViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: OnlineRoomLobbyViewModelProvider._internal(
        () => create()
          ..roomCode = roomCode
          ..playerId = playerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomCode: roomCode,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    OnlineRoomLobbyViewModel,
    OnlineRoomLobbyState
  >
  createElement() {
    return _OnlineRoomLobbyViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OnlineRoomLobbyViewModelProvider &&
        other.roomCode == roomCode &&
        other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomCode.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OnlineRoomLobbyViewModelRef
    on AutoDisposeNotifierProviderRef<OnlineRoomLobbyState> {
  /// The parameter `roomCode` of this provider.
  String get roomCode;

  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _OnlineRoomLobbyViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          OnlineRoomLobbyViewModel,
          OnlineRoomLobbyState
        >
    with OnlineRoomLobbyViewModelRef {
  _OnlineRoomLobbyViewModelProviderElement(super.provider);

  @override
  String get roomCode => (origin as OnlineRoomLobbyViewModelProvider).roomCode;
  @override
  String get playerId => (origin as OnlineRoomLobbyViewModelProvider).playerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
