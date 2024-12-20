import 'package:isar/isar.dart';

import '../collections/spend_time_place.dart';

class SpendTimePlacesRepository {
  ///
  IsarCollection<SpendTimePlace> getCollection({required Isar isar}) => isar.spendTimePlaces;

  ///
  Future<List<SpendTimePlace>?> getSpendTimePlaceList({required Isar isar}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    return spendTimePlacesCollection.where().sortByDate().thenByTime().thenByPlace().findAll();
  }

  ///
  Future<List<SpendTimePlace>?> getDateSpendTimePlaceList(
      {required Isar isar, required Map<String, dynamic> param}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    return spendTimePlacesCollection
        .filter()
        .dateStartsWith(param['date'] as String)
        .sortByDate()
        .thenByTime()
        .findAll();
  }

  ///
  Future<List<SpendTimePlace>?> getSpendTypeSpendTimePlaceList(
      {required Isar isar, required Map<String, dynamic> param}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    return spendTimePlacesCollection
        .filter()
        .spendTypeEqualTo(param['item'] as String)
        .sortByDate()
        .thenByTime()
        .findAll();
  }

  ///
  Future<void> inputSpendTimePriceList({required Isar isar, required List<SpendTimePlace> spendTimePriceList}) async {
    for (final SpendTimePlace element in spendTimePriceList) {
      inputSpendTimePrice(isar: isar, spendTimePlace: element);
    }
  }

  ///
  Future<void> inputSpendTimePrice({required Isar isar, required SpendTimePlace spendTimePlace}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    await isar.writeTxn(() async => spendTimePlacesCollection.put(spendTimePlace));
  }

  ///
  Future<void> updateSpendTimePriceList({required Isar isar, required List<SpendTimePlace> spendTimePriceList}) async {
    for (final SpendTimePlace element in spendTimePriceList) {
      updateSpendTimePlace(isar: isar, spendTimePlace: element);
    }
  }

  ///
  Future<void> updateSpendTimePlace({required Isar isar, required SpendTimePlace spendTimePlace}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    await spendTimePlacesCollection.put(spendTimePlace);
  }

  ///
  Future<void> deleteSpendTimePriceList({required Isar isar, required List<SpendTimePlace>? spendTimePriceList}) async {
    spendTimePriceList?.forEach((SpendTimePlace element) => deleteSpendTimePrice(isar: isar, id: element.id));
  }

  ///
  Future<void> deleteSpendTimePrice({required Isar isar, required int id}) async {
    final IsarCollection<SpendTimePlace> spendTimePlacesCollection = getCollection(isar: isar);
    await isar.writeTxn(() async => spendTimePlacesCollection.delete(id));
  }
}
