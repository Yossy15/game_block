// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_match_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onlineMatchViewModelHash() =>
    r'4c9fde0bc0e20d8ababb073fa1313bee78087063';

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

abstract class _$OnlineMatchViewModel
    extends BuildlessAutoDisposeNotifier<OnlineMatchState> {
  late final String roomCode;
  late final String playerId;

  OnlineMatchState build(String roomCode, String playerId);
}

/// See also [OnlineMatchViewModel].
@ProviderFor(OnlineMatchViewModel)
const onlineMatchViewModelProvider = OnlineMatchViewModelFamily();

/// See also [OnlineMatchViewModel].
class OnlineMatchViewModelFamily extends Family<OnlineMatchState> {
  /// See also [OnlineMatchViewModel].
  const OnlineMatchViewModelFamily();

  /// See also [OnlineMatchViewModel].
  OnlineMatchViewModelProvider call(String roomCode, String playerId) {
    return OnlineMatchViewModelProvider(roomCode, playerId);
  }

  @override
  OnlineMatchViewModelProvider getProviderOverride(
    covariant OnlineMatchViewModelProvider provider,
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
  String? get name => r'onlineMatchViewModelProvider';
}

/// See also [OnlineMatchViewModel].
class OnlineMatchViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          OnlineMatchViewModel,
          OnlineMatchState
        > {
  /// See also [OnlineMatchViewModel].
  OnlineMatchViewModelProvider(String roomCode, String playerId)
    : this._internal(
        () => OnlineMatchViewModel()
          ..roomCode = roomCode
          ..playerId = playerId,
        from: onlineMatchViewModelProvider,
        name: r'onlineMatchViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$onlineMatchViewModelHash,
        dependencies: OnlineMatchViewModelFamily._dependencies,
        allTransitiveDependencies:
            OnlineMatchViewModelFamily._allTransitiveDependencies,
        roomCode: roomCode,
        playerId: playerId,
      );

  OnlineMatchViewModelProvider._internal(
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
  OnlineMatchState runNotifierBuild(covariant OnlineMatchViewModel notifier) {
    return notifier.build(roomCode, playerId);
  }

  @override
  Override overrideWith(OnlineMatchViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: OnlineMatchViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<OnlineMatchViewModel, OnlineMatchState>
  createElement() {
    return _OnlineMatchViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OnlineMatchViewModelProvider &&
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
mixin OnlineMatchViewModelRef
    on AutoDisposeNotifierProviderRef<OnlineMatchState> {
  /// The parameter `roomCode` of this provider.
  String get roomCode;

  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _OnlineMatchViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          OnlineMatchViewModel,
          OnlineMatchState
        >
    with OnlineMatchViewModelRef {
  _OnlineMatchViewModelProviderElement(super.provider);

  @override
  String get roomCode => (origin as OnlineMatchViewModelProvider).roomCode;
  @override
  String get playerId => (origin as OnlineMatchViewModelProvider).playerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
