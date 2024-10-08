import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'money_graph_response_state.dart';

final AutoDisposeStateNotifierProvider<MoneyGraphNotifier,
        MoneyGraphResponseState> moneyGraphProvider =
    StateNotifierProvider.autoDispose<MoneyGraphNotifier,
        MoneyGraphResponseState>((AutoDisposeStateNotifierProviderRef<
            MoneyGraphNotifier, MoneyGraphResponseState>
        ref) {
  return MoneyGraphNotifier(const MoneyGraphResponseState());
});

class MoneyGraphNotifier extends StateNotifier<MoneyGraphResponseState> {
  MoneyGraphNotifier(super.state);

  ///
  Future<void> setDisplayGraphFlag({required String flag}) async =>
      state = state.copyWith(displayGraphFlag: flag);
}
