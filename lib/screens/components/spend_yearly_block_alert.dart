// ignore_for_file: depend_on_referenced_packages

// import 'package:collection/collection.dart';
//

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../collections/spend_item.dart';
import '../../collections/spend_time_place.dart';
import '../../extensions/extensions.dart';
import '../../repository/spend_items_repository.dart';
import '../../repository/spend_time_places_repository.dart';
import '../../utilities/functions.dart';
import 'each_month_item_summary_alert.dart';
import 'parts/money_dialog.dart';
import 'spend_yearly_graph_alert.dart';

class SpendYearlyBlockAlert extends ConsumerStatefulWidget {
  const SpendYearlyBlockAlert({super.key, required this.date, required this.isar, required this.allSpendTimePlaceList});

  final DateTime date;
  final Isar isar;
  final List<SpendTimePlace> allSpendTimePlaceList;

  @override
  ConsumerState<SpendYearlyBlockAlert> createState() => _SpendYearlyBlockAlertState();
}

class _SpendYearlyBlockAlertState extends ConsumerState<SpendYearlyBlockAlert> {
  // ignore: use_late_for_private_fields_and_variables
  List<SpendTimePlace>? yearlySpendTimePlaceList = <SpendTimePlace>[];

  Map<String, List<int>> _yearlySpendSumMap = <String, List<int>>{};

  List<SpendItem>? _spendItemList = <SpendItem>[];

  ///
  void _init() {
    _makeYearlySpendSumMap();

    _makeSpendItemList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    // ignore: always_specify_types
    Future(_init);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[const Text('年間使用金額比較'), Text(widget.date.yyyy)],
              ),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox.shrink(),
                  GestureDetector(
                    onTap: () {
                      MoneyDialog(
                        context: context,
                        widget: EachMonthItemSummaryAlert(
                          spendItemList: _spendItemList ?? <SpendItem>[],
                          spendTimePlaceList: widget.allSpendTimePlaceList,
                        ),
                      );
                    },
                    child: Icon(Icons.summarize_outlined, color: Colors.white.withOpacity(0.6), size: 20),
                  ),
                ],
              ),
              Expanded(child: _displayYearlySpendSumMap()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _makeYearlySpendSumMap() async {
    final Map<String, dynamic> param = <String, dynamic>{};
    param['date'] = widget.date.yyyy;

    await SpendTimePlacesRepository()
        .getDateSpendTimePlaceList(isar: widget.isar, param: param)
        .then((List<SpendTimePlace>? value) {
      setState(() {
        yearlySpendTimePlaceList = value;

        if (value != null) {
          _yearlySpendSumMap = makeYearlySpendItemSumMap(spendItemList: _spendItemList, spendTimePlaceList: value);
        }
      });
    });
  }

  ///
  Widget _displayYearlySpendSumMap() {
    final List<Widget> list = <Widget>[];

    final Map<String, String> spendItemColorMap = <String, String>{};
    if (_spendItemList!.isNotEmpty) {
      for (final SpendItem element in _spendItemList!) {
        spendItemColorMap[element.spendItemName] = element.color;
      }
    }

    final double oneWidth = context.screenSize.width / 6;

    int allTotal = 0;
    int spendTotal = 0;

    final Map<String, int> eachItemSpendMap = <String, int>{};

    _yearlySpendSumMap.forEach((String key, List<int> value) {
      final List<Widget> list2 = <Widget>[];

      final Map<int, String> map = <int, String>{};

      int sum = 0;

      for (final int element in value) {
        map[element] = '';
        sum += element;
      }

      eachItemSpendMap[key] = sum;

      allTotal += sum;

      if (sum >= 0) {
        spendTotal += sum;
      }

      if (map.isNotEmpty) {
        final String? lineColor =
            (spendItemColorMap[key] != null && spendItemColorMap[key] != '') ? spendItemColorMap[key] : '0xffffffff';

        list.add(Container(
          width: context.screenSize.width,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.indigo.withOpacity(0.8), Colors.transparent],
              stops: const <double>[0.7, 1],
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: Color(lineColor!.toInt()), fontSize: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text(key), Text(sum.toString().toCurrency())],
            ),
          ),
        ));

        // value.mapIndexed((index, element) {
        //   list2.add(
        //     Stack(
        //       children: [
        //         Container(
        //           width: oneWidth,
        //           padding: const EdgeInsets.all(2),
        //           margin: const EdgeInsets.all(2),
        //           decoration: BoxDecoration(
        //               border: Border.all(color: Colors.white.withOpacity(0.4))),
        //           alignment: Alignment.topRight,
        //           child: Text(
        //             element.toString().toCurrency(),
        //             style: TextStyle(
        //                 color: ((index + 1) == widget.date.month)
        //                     ? Colors.yellowAccent
        //                     : Colors.white),
        //           ),
        //         ),
        //         Container(
        //           padding: const EdgeInsets.all(5),
        //           child: Text((index + 1).toString().padLeft(2, '0'),
        //               style: const TextStyle(color: Colors.grey)),
        //         ),
        //       ],
        //     ),
        //   );
        // });

        int i = 1;
        for (final int element in value) {
          list2.add(
            Stack(
              children: <Widget>[
                Container(
                  width: oneWidth,
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.4))),
                  alignment: Alignment.topRight,
                  child: Text(
                    element.toString().toCurrency(),
                    style: TextStyle(color: (i == widget.date.month) ? Colors.yellowAccent : Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Text(i.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );

          i++;
        }
      }

      list.add(Wrap(children: list2));
    });

    list
      ..add(const SizedBox(height: 20))
      ..add(
        Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(color: Colors.yellowAccent.withOpacity(0.1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Total', style: TextStyle(color: Colors.yellowAccent)),
                  Text(allTotal.toString().toCurrency(), style: const TextStyle(color: Colors.yellowAccent)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text('Spend Total', style: TextStyle(color: Colors.lightBlueAccent)),
                      const SizedBox(width: 20),
                      if (spendTotal > 0)
                        GestureDetector(
                          onTap: () => MoneyDialog(
                            context: context,
                            widget: SpendYearlyGraphAlert(
                              spendTotal: spendTotal,
                              spendItemList: _spendItemList ?? <SpendItem>[],
                              eachItemSpendMap: eachItemSpendMap,
                            ),
                            clearBarrierColor: true,
                          ),
                          child: const Icon(Icons.pie_chart, color: Colors.lightBlueAccent, size: 15),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  Text(spendTotal.toString().toCurrency(), style: const TextStyle(color: Colors.lightBlueAccent)),
                ],
              ),
            ),
          ],
        ),
      )
      ..add(const SizedBox(height: 20));

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => list[index],
            childCount: list.length,
          ),
        ),
      ],
    );
  }

  ///
  Future<void> _makeSpendItemList() async => SpendItemsRepository()
      .getSpendItemList(isar: widget.isar)
      .then((List<SpendItem>? value) => setState(() => _spendItemList = value));
}
