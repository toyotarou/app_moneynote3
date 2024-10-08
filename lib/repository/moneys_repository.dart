import 'package:isar/isar.dart';

import '../collections/money.dart';

class MoneysRepository {
  ///
  IsarCollection<Money> getCollection({required Isar isar}) => isar.moneys;

  ///
  Future<Money?> getMoney({required Isar isar, required int id}) async {
    final IsarCollection<Money> moneysCollection = getCollection(isar: isar);
    return moneysCollection.get(id);
  }

  ///
  Future<List<Money>?> getMoneyList({required Isar isar}) async {
    final IsarCollection<Money> moneysCollection = getCollection(isar: isar);
    return moneysCollection.where().sortByDate().findAll();
  }

  ///
  Future<List<Money>?> getDateMoneyList(
      {required Isar isar, required Map<String, dynamic> param}) async {
    final IsarCollection<Money> moneysCollection = getCollection(isar: isar);
    return moneysCollection
        .filter()
        .dateEqualTo(param['date'] as String)
        .findAll();
  }

  ///
  Future<void> inputMoneyList(
      {required Isar isar, required List<Money> moneyList}) async {
    for (final Money element in moneyList) {
      inputMoney(isar: isar, money: element);
    }
  }

  ///
  Future<void> inputMoney({required Isar isar, required Money money}) async {
    final IsarCollection<Money> moneysCollection = getCollection(isar: isar);
    await isar.writeTxn(() async => moneysCollection.put(money));
  }

  ///
  Future<void> updateMoney({required Isar isar, required Money money}) async {
    final IsarCollection<Money> moneysCollection = getCollection(isar: isar);
    await moneysCollection.put(money);
  }
}
