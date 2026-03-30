// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameViewModelHash() => r'2e96545544a4093bceff4eb946d577923f558503';

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

abstract class _$GameViewModel extends BuildlessAutoDisposeNotifier<GameState> {
  late final bool isTimerMode;
  late final int? matchDurationSeconds;

  GameState build(bool isTimerMode, int? matchDurationSeconds);
}

/// See also [GameViewModel].
@ProviderFor(GameViewModel)
const gameViewModelProvider = GameViewModelFamily();

/// See also [GameViewModel].
class GameViewModelFamily extends Family<GameState> {
  /// See also [GameViewModel].
  const GameViewModelFamily();

  /// See also [GameViewModel].
  GameViewModelProvider call(bool isTimerMode, int? matchDurationSeconds) {
    return GameViewModelProvider(isTimerMode, matchDurationSeconds);
  }

  @override
  GameViewModelProvider getProviderOverride(
    covariant GameViewModelProvider provider,
  ) {
    return call(provider.isTimerMode, provider.matchDurationSeconds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameViewModelProvider';
}

/// See also [GameViewModel].
class GameViewModelProvider
    extends AutoDisposeNotifierProviderImpl<GameViewModel, GameState> {
  /// See also [GameViewModel].
  GameViewModelProvider(bool isTimerMode, int? matchDurationSeconds)
    : this._internal(
        () => GameViewModel()
          ..isTimerMode = isTimerMode
          ..matchDurationSeconds = matchDurationSeconds,
        from: gameViewModelProvider,
        name: r'gameViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameViewModelHash,
        dependencies: GameViewModelFamily._dependencies,
        allTransitiveDependencies:
            GameViewModelFamily._allTransitiveDependencies,
        isTimerMode: isTimerMode,
        matchDurationSeconds: matchDurationSeconds,
      );

  GameViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isTimerMode,
    required this.matchDurationSeconds,
  }) : super.internal();

  final bool isTimerMode;
  final int? matchDurationSeconds;

  @override
  GameState runNotifierBuild(covariant GameViewModel notifier) {
    return notifier.build(isTimerMode, matchDurationSeconds);
  }

  @override
  Override overrideWith(GameViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameViewModelProvider._internal(
        () => create()
          ..isTimerMode = isTimerMode
          ..matchDurationSeconds = matchDurationSeconds,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isTimerMode: isTimerMode,
        matchDurationSeconds: matchDurationSeconds,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<GameViewModel, GameState> createElement() {
    return _GameViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameViewModelProvider &&
        other.isTimerMode == isTimerMode &&
        other.matchDurationSeconds == matchDurationSeconds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isTimerMode.hashCode);
    hash = _SystemHash.combine(hash, matchDurationSeconds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameViewModelRef on AutoDisposeNotifierProviderRef<GameState> {
  /// The parameter `isTimerMode` of this provider.
  bool get isTimerMode;

  /// The parameter `matchDurationSeconds` of this provider.
  int? get matchDurationSeconds;
}

class _GameViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<GameViewModel, GameState>
    with GameViewModelRef {
  _GameViewModelProviderElement(super.provider);

  @override
  bool get isTimerMode => (origin as GameViewModelProvider).isTimerMode;

  @override
  int? get matchDurationSeconds =>
      (origin as GameViewModelProvider).matchDurationSeconds;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
