import 'package:block/core/providers/app_providers.dart';
import 'package:block/data/local/shared_preferences/shared_preferences_keys.dart';
import 'package:block/domain/models/block_skin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'skin_provider.g.dart';

@Riverpod(keepAlive: true)
class SkinNotifier extends _$SkinNotifier {
  @override
  BlockSkin build() {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final savedId = prefs.getString(SharedPreferencesKeys.selectedSkin);
    return getSkinById(savedId ?? 'flat');
  }

  Future<void> selectSkin(String skinId) async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setString(SharedPreferencesKeys.selectedSkin, skinId);
    state = getSkinById(skinId);
  }
}
