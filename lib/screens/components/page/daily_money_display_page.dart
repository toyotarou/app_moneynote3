import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../collections/bank_name.dart';
import '../../../collections/emoney_name.dart';
import '../../../collections/money.dart';
import '../../../collections/spend_item.dart';
import '../../../collections/spend_time_place.dart';
import '../../../enums/deposit_type.dart';
import '../../../extensions/extensions.dart';
import '../../../state/app_params/app_params_notifier.dart';
import '../../../utilities/functions.dart';
import '../bank_price_input_alert.dart';
import '../money_input_alert.dart';
import '../parts/bank_emoney_blank_message.dart';
import '../parts/error_dialog.dart';
import '../parts/money_dialog.dart';
import '../spend_time_place_input_alert.dart';

class DailyMoneyDisplayPage extends ConsumerStatefulWidget {
  const DailyMoneyDisplayPage({
    super.key,
    required this.date,
    required this.isar,
    required this.moneyList,
    required this.onedayMoneyTotal,
    required this.beforeMoneyList,
    required this.beforeMoneyTotal,
    required this.bankPricePadMap,
    required this.bankPriceTotalPadMap,
    required this.spendTimePlaceList,
    required this.bankNameList,
    required this.emoneyNameList,
    required this.spendItemList,
  });

  final DateTime date;
  final Isar isar;

  final List<Money> moneyList;
  final int onedayMoneyTotal;

  final List<Money> beforeMoneyList;
  final int beforeMoneyTotal;

  final Map<String, Map<String, int>> bankPricePadMap;
  final Map<String, int> bankPriceTotalPadMap;

  final List<SpendTimePlace> spendTimePlaceList;

  final List<BankName> bankNameList;
  final List<EmoneyName> emoneyNameList;

  final List<SpendItem> spendItemList;

  @override
  ConsumerState<DailyMoneyDisplayPage> createState() => _DailyMoneyDisplayAlertState();
}

class _DailyMoneyDisplayAlertState extends ConsumerState<DailyMoneyDisplayPage> {
  ///
  @override
  Widget build(BuildContext context) {
    final oneday = widget.date.yyyymmdd;

    final beforeDate = DateTime(oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

    final onedayBankTotal = (widget.bankPriceTotalPadMap[oneday] != null) ? widget.bankPriceTotalPadMap[oneday] : 0;
    final beforeBankTotal = (widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] != null) ? widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] : 0;

    final spendDiff = (widget.beforeMoneyTotal + beforeBankTotal!) - (widget.onedayMoneyTotal + onedayBankTotal!);

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(width: context.screenSize.width),
                const SizedBox(height: 20),
                _displayTopInfoPlate(),
                const SizedBox(height: 20),
                _displaySingleMoney(),
                const SizedBox(height: 20),
                _displayBankNames(),
                const SizedBox(height: 20),
                _displayEmoneyNames(),
                const SizedBox(height: 20),
                if (spendDiff != 0) ...[
                  _displaySpendTimePlaceList(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayTopInfoPlate() {
    final oneday = widget.date.yyyymmdd;

    final beforeDate = DateTime(oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

    final onedayBankTotal = (widget.bankPriceTotalPadMap[oneday] != null) ? widget.bankPriceTotalPadMap[oneday] : 0;
    final beforeBankTotal = (widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] != null) ? widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] : 0;

    final beforeTotal = widget.beforeMoneyTotal + beforeBankTotal!;
    final onedayTotal = widget.onedayMoneyTotal + onedayBankTotal!;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 24, spreadRadius: 16, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: context.screenSize.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start'),
                      Text(beforeTotal.toString().toCurrency()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End'),
                      Text(onedayTotal.toString().toCurrency()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Spend'),
                      Row(
                        children: [
                          _getBubbleComment(beforeTotal: beforeTotal, onedayTotal: onedayTotal),
                          const SizedBox(width: 10),
                          Text(
                            ((widget.beforeMoneyTotal + beforeBankTotal) - (widget.onedayMoneyTotal + onedayBankTotal)).toString().toCurrency(),
                            style: TextStyle(color: (widget.onedayMoneyTotal == 0) ? const Color(0xFFFBB6CE) : Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _getBubbleComment({required int beforeTotal, required int onedayTotal}) {
    var text = '';
    var color = Colors.transparent;

    if (beforeTotal > 0 && onedayTotal > beforeTotal) {
      text = '増えた！';
      color = Colors.indigoAccent.withOpacity(0.6);
    }

    if (beforeTotal == 0 && onedayTotal > 0) {
      text = '初日';
      color = Colors.orangeAccent.withOpacity(0.6);
    }

    if (text == '') {
      return Container();
    }

    return Row(
      children: [
        Bubble(
          color: color,
          nip: BubbleNip.rightTop,
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  ///
  Widget _displaySingleMoney() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.screenSize.width,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CURRENCY', overflow: TextOverflow.ellipsis),
              GestureDetector(
                onTap: () => MoneyDialog(
                  context: context,
                  widget: MoneyInputAlert(
                    date: widget.date,
                    isar: widget.isar,
                    onedayMoneyList: widget.moneyList,
                    beforedayMoneyList: widget.beforeMoneyList,
                  ),
                ),
                child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                widget.onedayMoneyTotal.toString().toCurrency(),
                style: const TextStyle(color: Colors.yellowAccent),
              ),
            ],
          ),
        ),
        _displayMoneyParts(key: '10000', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_10000 : 0),
        _displayMoneyParts(key: '5000', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_5000 : 0),
        _displayMoneyParts(key: '2000', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_2000 : 0),
        _displayMoneyParts(key: '1000', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_1000 : 0),
        _displayMoneyParts(key: '500', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_500 : 0),
        _displayMoneyParts(key: '100', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_100 : 0),
        _displayMoneyParts(key: '50', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_50 : 0),
        _displayMoneyParts(key: '10', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_10 : 0),
        _displayMoneyParts(key: '5', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_5 : 0),
        _displayMoneyParts(key: '1', value: (widget.moneyList.isNotEmpty) ? widget.moneyList[0].yen_1 : 0),
        const SizedBox(height: 20),
      ],
    );
  }

  ///
  Widget _displayMoneyParts({required String key, required int value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(key), Text(value.toString().toCurrency())],
      ),
    );
  }

  ///
  Widget _displayBankNames() {
    final list = <Widget>[
      Container(
        width: context.screenSize.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
        ),
        child: const Text('BANK', overflow: TextOverflow.ellipsis),
      )
    ];

    if (widget.bankNameList.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 10),
          BankEmoneyBlankMessage(deposit: '金融機関', isar: widget.isar),
          const SizedBox(height: 30),
        ],
      ));
    } else {
      final list2 = <Widget>[];

      var sum = 0;
      for (var i = 0; i < widget.bankNameList.length; i++) {
        if (widget.bankPricePadMap['${widget.bankNameList[i].depositType}-${widget.bankNameList[i].id}'] != null) {
          final bankPriceMap = widget.bankPricePadMap['${widget.bankNameList[i].depositType}-${widget.bankNameList[i].id}'];
          if (bankPriceMap![widget.date.yyyymmdd] != null) {
            sum += bankPriceMap[widget.date.yyyymmdd]!;
          }
        }
      }

      list2.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(sum.toString().toCurrency(), style: const TextStyle(color: Colors.yellowAccent)),
          ],
        ),
      ));

      for (var i = 0; i < widget.bankNameList.length; i++) {
        list2.add(
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.bankNameList[i].bankName, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text(widget.bankNameList[i].branchName, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _getListPrice(depositType: widget.bankNameList[i].depositType, id: widget.bankNameList[i].id).toString().toCurrency(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => MoneyDialog(
                        context: context,
                        widget: BankPriceInputAlert(
                          date: widget.date,
                          isar: widget.isar,
                          depositType: DepositType.bank,
                          bankName: widget.bankNameList[i],
                          from: 'DailyMoneyDisplayPage',
                        ),
                      ),
                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      list.add(Column(children: list2));
    }

    return Column(children: list);
  }

  ///
  Widget _displayEmoneyNames() {
    final list = <Widget>[
      Container(
        width: context.screenSize.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
        ),
        child: const Text('E-MONEY', overflow: TextOverflow.ellipsis),
      )
    ];

    if (widget.emoneyNameList.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 10),
          BankEmoneyBlankMessage(deposit: '電子マネー', index: 1, isar: widget.isar),
          const SizedBox(height: 30),
        ],
      ));
    } else {
      final list2 = <Widget>[];

      var sum = 0;
      for (var i = 0; i < widget.emoneyNameList.length; i++) {
        if (widget.bankPricePadMap['${widget.emoneyNameList[i].depositType}-${widget.emoneyNameList[i].id}'] != null) {
          final bankPriceMap = widget.bankPricePadMap['${widget.emoneyNameList[i].depositType}-${widget.emoneyNameList[i].id}'];

          if (bankPriceMap![widget.date.yyyymmdd] != null) {
            sum += bankPriceMap[widget.date.yyyymmdd]!;
          }
        }
      }

      list2.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(sum.toString().toCurrency(), style: const TextStyle(color: Colors.yellowAccent)),
          ],
        ),
      ));

      for (var i = 0; i < widget.emoneyNameList.length; i++) {
        list2.add(
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(widget.emoneyNameList[i].emoneyName, maxLines: 2, overflow: TextOverflow.ellipsis)),
                Row(
                  children: [
                    Text(
                      _getListPrice(depositType: widget.emoneyNameList[i].depositType, id: widget.emoneyNameList[i].id).toString().toCurrency(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => MoneyDialog(
                        context: context,
                        widget: BankPriceInputAlert(
                          date: widget.date,
                          isar: widget.isar,
                          depositType: DepositType.emoney,
                          emoneyName: widget.emoneyNameList[i],
                          from: 'DailyMoneyDisplayPage',
                        ),
                      ),
                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      list.add(Column(children: list2));
    }

    return Column(children: list);
  }

  ///
  int _getListPrice({required String depositType, required int id}) {
    var listPrice = 0;
    if (widget.bankPricePadMap['$depositType-$id'] != null) {
      final bankPriceMap = widget.bankPricePadMap['$depositType-$id'];
      if (bankPriceMap![widget.date.yyyymmdd] != null) {
        listPrice = bankPriceMap[widget.date.yyyymmdd]!;
      }
    }

    return listPrice;
  }

  ///
  Widget _displaySpendTimePlaceList() {
    final list = <Widget>[
      Column(
        children: [
          Container(
            width: context.screenSize.width,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SPEND', overflow: TextOverflow.ellipsis),
                GestureDetector(
                  onTap: () async {
                    if (widget.onedayMoneyTotal == 0) {
                      Future.delayed(
                        Duration.zero,
                        () => error_dialog(context: context, title: '登録できません。', content: '先にCURRENCYを入力してください。'),
                      );

                      return;
                    }

                    final oneday = widget.date.yyyymmdd;

                    final beforeDate = DateTime(oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

                    final onedayBankTotal = (widget.bankPriceTotalPadMap[oneday] != null) ? widget.bankPriceTotalPadMap[oneday] : 0;
                    final beforeBankTotal =
                        (widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] != null) ? widget.bankPriceTotalPadMap[beforeDate.yyyymmdd] : 0;

                    await ref.read(appParamProvider.notifier).setInputButtonClicked(flag: false);

                    if (mounted) {
                      await MoneyDialog(
                        context: context,
                        widget: SpendTimePlaceInputAlert(
                          date: widget.date,
                          spend: (widget.beforeMoneyTotal + beforeBankTotal!) - (widget.onedayMoneyTotal + onedayBankTotal!),
                          isar: widget.isar,
                          spendTimePlaceList: widget.spendTimePlaceList,
                        ),
                      );
                    }
                  },
                  child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    if (widget.spendTimePlaceList.isNotEmpty) {
      final spendItemColorMap = <String, String>{};
      if (widget.spendItemList.isNotEmpty) {
        widget.spendItemList.forEach((element) => spendItemColorMap[element.spendItemName] = element.color);
      }

      var sum = 0;
      makeMonthlySpendItemSumMap(spendItemList: widget.spendItemList, spendTimePlaceList: widget.spendTimePlaceList)
          .forEach((key, value) => sum += value);

      list.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(sum.toString().toCurrency(), style: const TextStyle(color: Colors.yellowAccent)),
          ],
        ),
      ));

      makeMonthlySpendItemSumMap(spendTimePlaceList: widget.spendTimePlaceList, spendItemList: widget.spendItemList).forEach((key, value) {
        final lineColor = (spendItemColorMap[key] != null && spendItemColorMap[key] != '') ? spendItemColorMap[key] : '0xffffffff';

        list.add(Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(child: Text(key, style: TextStyle(color: Color(lineColor!.toInt())))),
              Text(value.toString().toCurrency(), style: TextStyle(color: Color(lineColor.toInt()))),
            ],
          ),
        ));
      });
    }

    return Column(mainAxisSize: MainAxisSize.min, children: list);
  }
}
