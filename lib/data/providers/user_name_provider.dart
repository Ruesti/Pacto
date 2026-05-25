import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/onboarding_screen.dart';

final userNameProvider =
    AsyncNotifierProvider<UserNameNotifier, String?>(UserNameNotifier.new);

class UserNameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => getUserName();

  Future<void> setName(String? name) async {
    await setUserName(name);
    final trimmed = name?.trim();
    state = AsyncData(trimmed?.isEmpty == true ? null : trimmed);
  }
}
