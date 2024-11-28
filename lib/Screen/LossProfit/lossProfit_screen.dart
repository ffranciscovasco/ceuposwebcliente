import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;

class LossProfitScreen extends StatefulWidget {
  const LossProfitScreen({
    Key? key,
  }) : super(key: key);

  static const String route = '/Loss_Profit';

  @override
  State<LossProfitScreen> createState() => _LossProfitScreenState();
}

class _LossProfitScreenState extends State<LossProfitScreen> {
  void showLossProfitDetails({required SaleTransactionModel transitionModel}) {
    double profit({required AddToCartModel productModel}) {
      if (productModel.taxType == 'Exclusive') {
        return (double.parse(productModel.subTotal.toString()) -
                (double.parse(productModel.productPurchasePrice.toString()) +
                    calculateAmountFromPercentage((productModel.groupTaxRate.toString() ?? '').toDouble(), productModel.productPurchasePrice))) *
            productModel.quantity.toDouble();
      } else {
        return (double.parse(productModel.subTotal.toString()) - double.parse(productModel.productPurchasePrice.toString())) * productModel.quantity.toDouble();
      }
    }

    double allProductTotalProfit({required SaleTransactionModel transitionModel}) {
      double profit = 0;
      for (var element in transitionModel.productList!) {
        if (element.taxType == 'Exclusive') {
          ((double.parse(element.subTotal.toString()) -
                          (double.parse(element.productPurchasePrice.toString()) +
                              calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), element.productPurchasePrice))) *
                      element.quantity.toDouble())
                  .isNegative
              ? null
              : profit += (double.parse(element.subTotal.toString()) -
                      (double.parse(element.productPurchasePrice.toString()) +
                          calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), element.productPurchasePrice))) *
                  element.quantity.toDouble();
        } else {
          ((double.parse(element.subTotal.toString()) - double.parse(element.productPurchasePrice.toString())) * element.quantity.toDouble()).isNegative
              ? null
              : profit += (double.parse(element.subTotal.toString()) - double.parse(element.productPurchasePrice.toString())) * element.quantity.toDouble();
        }
      }
      return profit;
    }

    double allProductTotalLoss({required SaleTransactionModel transitionModel}) {
      double loss = 0;

      for (var element in transitionModel.productList!) {
        if (element.taxType == 'Exclusive') {
          ((double.parse(element.subTotal.toString()) -
                          double.parse(element.productPurchasePrice.toString()) +
                          calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), element.productPurchasePrice)) *
                      element.quantity.toDouble())
                  .isNegative
              ? loss += ((double.parse(element.subTotal.toString()) -
                          (double.parse(element.productPurchasePrice.toString()) +
                              calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), element.productPurchasePrice))) *
                      element.quantity.toDouble())
                  .abs()
              : null;
        } else {
          ((double.parse(element.subTotal.toString()) - double.parse(element.productPurchasePrice.toString())) * element.quantity.toDouble()).isNegative
              ? loss += ((double.parse(element.subTotal.toString()) - double.parse(element.productPurchasePrice.toString())) * element.quantity.toDouble()).abs()
              : null;
        }
      }
      return loss;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              surfaceTintColor: kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 820,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Fatura: ${transitionModel.invoiceNumber} - ${transitionModel.customerName}',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 25.0).onTap(() => {finish(context)})
                            ],
                          ),
                        ),
                        const Divider(thickness: 1.0, color: kLitGreyColor),
                        const SizedBox(height: 10.0),
                        DataTable(
                          headingRowColor: MaterialStateProperty.all(kbgColor),
                          showBottomBorder: false,
                          columnSpacing: 0.0,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black26),
                            // borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: 250,
                                child: Text(
                                  lang.S.of(context).itemName,
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(lang.S.of(context).quantity, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 120,
                                child: Text(
                                  lang.S.of(context).purchase,
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Venda',
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  lang.S.of(context).profit,
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(width: 100, child: Text(lang.S.of(context).loss, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold))),
                            ),
                          ],
                          rows: List.generate(
                            transitionModel.productList!.length + 1,
                            (index) => DataRow(cells: [
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? Text(
                                        lang.S.of(context).total,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    : Text(transitionModel.productList![index].productName.toString(),
                                        maxLines: 2, overflow: TextOverflow.ellipsis, style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? Text(transitionModel.totalQuantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold))
                                    : Text(transitionModel.productList![index].quantity.toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? const Text('')
                                    : Text(myFormat.format(double.tryParse(transitionModel.productList![index].productPurchasePrice.toString()) ?? 0),
                                        style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? const Text('')
                                    : Text(myFormat.format(double.tryParse(transitionModel.productList![index].subTotal.toString()) ?? 0),
                                        style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? Text(myFormat.format(double.tryParse(allProductTotalProfit(transitionModel: transitionModel).toStringAsFixed(2)) ?? 0),
                                        style: const TextStyle(fontWeight: FontWeight.bold))
                                    : Text(
                                        profit(productModel: transitionModel.productList![index]).isNegative
                                            ? ''
                                            : myFormat.format(double.tryParse(profit(productModel: transitionModel.productList![index]).toStringAsFixed(2)) ?? 0),
                                        style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                              DataCell(
                                index == transitionModel.productList!.length
                                    ? Text(myFormat.format(double.tryParse(allProductTotalLoss(transitionModel: transitionModel).toStringAsFixed(2)) ?? 0),
                                        style: const TextStyle(fontWeight: FontWeight.bold))
                                    : Text(
                                        profit(productModel: transitionModel.productList![index]).isNegative
                                            ? myFormat.format(double.tryParse(profit(productModel: transitionModel.productList![index]).abs().toString()) ?? 0)
                                            : '',
                                        style: kTextStyle.copyWith(color: kGreyTextColor)),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.S.of(context).totalProfit),
                            Text(myFormat.format(double.tryParse(allProductTotalProfit(transitionModel: transitionModel).toStringAsFixed(2)) ?? 0)),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.S.of(context).totalLoss),
                            Text('- ${myFormat.format(double.tryParse(allProductTotalLoss(transitionModel: transitionModel).toStringAsFixed(2)) ?? 0)}'),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.S.of(context).totalDiscount),
                            Text('- ${transitionModel.discountAmount}'),
                          ],
                        ),
                        const Divider(thickness: 1.0, color: kLitGreyColor),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // border: Border.all(width: 1, color: Colors.green),
                            color: transitionModel.lossProfit!.isNegative ? Colors.redAccent.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transitionModel.lossProfit!.isNegative ? 'Perda total' : 'Lucro total',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  myFormat.format(double.tryParse(transitionModel.lossProfit!.abs().toStringAsFixed(2)) ?? 0),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double calculateTotalProfit(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      element.lossProfit!.isNegative ? null : total += element.lossProfit!;
    }
    return total;
  }

  double getTotalDue(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      total += element.dueAmount!;
    }
    return total;
  }

  double calculateTotalSale(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      total += element.totalAmount!;
    }
    return total;
  }

  double calculateTotalLoss(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      element.lossProfit!.isNegative ? total += element.lossProfit! : null;
    }
    return total.abs();
  }

  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  DateTime selected2ndDate = DateTime.now();

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selected2ndDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selected2ndDate) {
      setState(() {
        selected2ndDate = picked;
      });
    }
  }

  ScrollController mainScroll = ScrollController();
  List<String> month = ['Este mês', 'Mês passado', 'Últimos 6 meses', 'Este ano'];

  String selectedMonth = 'Este mês';

  DropdownButton<String> getMonth() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in month) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedMonth,
      onChanged: (value) {
        setState(() {
          selectedMonth = value!;
          switch (selectedMonth) {
            case 'Este mês':
              {
                var date = DateTime(DateTime.now().year, DateTime.now().month, 1).toString();

                selectedDate = DateTime.parse(date);
                selected2ndDate = DateTime.now();
              }
              break;
            case 'Mês passado':
              {
                selectedDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
                selected2ndDate = DateTime(DateTime.now().year, DateTime.now().month, 0);
              }
              break;
            case 'Últimos 6 meses':
              {
                selectedDate = DateTime(DateTime.now().year, DateTime.now().month - 6, 1);
                selected2ndDate = DateTime.now();
              }
              break;
            case 'Este ano':
              {
                selectedDate = DateTime(DateTime.now().year, 1, 1);
                selected2ndDate = DateTime.now();
              }
              break;
          }
        });
      },
    );
  }

  String searchItem = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
  }

  // Function to calculate the amount from a given percentage
  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kDarkWhite,
        body: Scrollbar(
          controller: mainScroll,
          child: SingleChildScrollView(
            controller: mainScroll,
            scrollDirection: Axis.horizontal,
            child: Consumer(builder: (_, ref, watch) {
              AsyncValue<List<SaleTransactionModel>> transactionReport = ref.watch(transitionProvider);
              return transactionReport.when(data: (transaction) {
                final reTransaction = transaction.reversed.toList();
                List<SaleTransactionModel> showAbleSaleTransactions = [];
                for (var element in reTransaction) {
                  if ((element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()) || element.customerName.toLowerCase().contains(searchItem.toLowerCase())) &&
                      (selectedDate.isBefore(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selectedDate)) &&
                      (selected2ndDate.isAfter(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selected2ndDate))) {
                    showAbleSaleTransactions.add(element);
                  }
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: SideBarWidget(
                        index: 9,
                        isTab: false,
                      ),
                    ),
                    Container(
                      // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                      width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                      decoration: const BoxDecoration(color: kDarkWhite),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //_______________________________top_bar____________________________
                            const TopBar(),

                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: kWhite,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///____________day_filter________________________________________________________________
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 155,
                                          child: FormField(
                                            builder: (FormFieldState<dynamic> field) {
                                              return InputDecorator(
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                child: Theme(
                                                    data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                    child: DropdownButtonHideUnderline(child: getMonth())),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                            height: 30,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), border: Border.all(color: kGreyTextColor)),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 70,
                                                  height: 30,
                                                  decoration: const BoxDecoration(shape: BoxShape.rectangle, color: kGreyTextColor),
                                                  child: Center(
                                                    child: Text(
                                                      lang.S.of(context).between,
                                                      style: kTextStyle.copyWith(color: kWhite),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Text(
                                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                ).onTap(() => _selectDate(context)),
                                                const SizedBox(width: 10.0),
                                                Text(
                                                  lang.S.of(context).to,
                                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Text(
                                                  '${selected2ndDate.day}/${selected2ndDate.month}/${selected2ndDate.year}',
                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                ).onTap(() => _selectedDate(context)),
                                                const SizedBox(width: 10.0),
                                              ],
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color(0xFFCFF4E3),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transaction.length.toString(),
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                              ),
                                              Text(
                                                lang.S.of(context).totalSale,
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color(0xFFFEE7CB),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${myFormat.format(double.tryParse(getTotalDue(transaction).toString()) ?? 0)} $currency',
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                              ),
                                              Text(
                                                lang.S.of(context).unPaid,
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color(0xFF2DB0F6).withOpacity(0.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${myFormat.format(double.tryParse(calculateTotalSale(transaction).toStringAsFixed(2)) ?? 0)} $currency',
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                              ),
                                              Text(
                                                lang.S.of(context).totalAmount,
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color(0xFF15CD75).withOpacity(0.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${myFormat.format(double.tryParse(calculateTotalProfit(transaction).toStringAsFixed(2)) ?? 0)} $currency',
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                              ),
                                              Text(
                                                lang.S.of(context).totalProfit,
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color(0xFFFF2525).withOpacity(.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${myFormat.format(double.tryParse(calculateTotalLoss(transaction).toStringAsFixed(2)) ?? 0)} $currency',
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                              ),
                                              Text(
                                                lang.S.of(context).totalLoss,
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0, right: 20, left: 20),
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: kWhite,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          lang.S.of(context).lossOrProfit,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),

                                        ///___________search________________________________________________-
                                        Container(
                                          height: 40.0,
                                          width: 300,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), border: Border.all(color: kGreyTextColor.withOpacity(0.1))),
                                          child: AppTextField(
                                            showCursor: true,
                                            cursorColor: kTitleColor,
                                            onChanged: (value) {
                                              setState(() {
                                                searchItem = value;
                                              });
                                            },
                                            textFieldType: TextFieldType.NAME,
                                            decoration: kInputDecoration.copyWith(
                                              contentPadding: const EdgeInsets.all(10.0),
                                              hintText: (lang.S.of(context).searchByInvoiceOrName),
                                              hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                              border: InputBorder.none,
                                              enabledBorder: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                                borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                                borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                                              ),
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    color: kGreyTextColor.withOpacity(0.1),
                                                  ),
                                                  child: const Icon(
                                                    FeatherIcons.search,
                                                    color: kTitleColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1.0,
                                      color: kGreyTextColor.withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 5.0),
                                    showAbleSaleTransactions.isNotEmpty
                                        ? Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(15),
                                                decoration: const BoxDecoration(color: kbgColor),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const SizedBox(width: 50, child: Text('Nr')),
                                                    SizedBox(width: 78, child: Text(lang.S.of(context).date)),
                                                    SizedBox(width: 50, child: Text(lang.S.of(context).invoice)),
                                                    SizedBox(width: 150, child: Text(lang.S.of(context).partyName)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).saleAmount)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).payingAmount)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).dueAmount)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).profitPlus)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).lossminus)),
                                                    SizedBox(width: 70, child: Text(lang.S.of(context).action)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const AlwaysScrollableScrollPhysics(),
                                                  itemCount: showAbleSaleTransactions.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(15),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              ///______________S.L__________________________________________________
                                                              SizedBox(
                                                                width: 50,
                                                                child: Text((index + 1).toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                              ),

                                                              ///______________Date__________________________________________________
                                                              SizedBox(
                                                                width: 78,
                                                                child: Text(
                                                                  showAbleSaleTransactions[index].purchaseDate.substring(0, 10),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                                ),
                                                              ),

                                                              ///____________Invoice_________________________________________________
                                                              SizedBox(
                                                                width: 50,
                                                                child: Text(showAbleSaleTransactions[index].invoiceNumber,
                                                                    maxLines: 2, overflow: TextOverflow.ellipsis, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                              ),

                                                              ///______Party Name___________________________________________________________
                                                              SizedBox(
                                                                width: 150,
                                                                child: Text(
                                                                  showAbleSaleTransactions[index].customerName,
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Sale Amount____________________________________________________
                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  myFormat.format(double.tryParse(showAbleSaleTransactions[index].totalAmount.toString()) ?? 0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________PayAmount____________________________________________________

                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  myFormat.format(double.tryParse((showAbleSaleTransactions[index].totalAmount!.toDouble() -
                                                                              showAbleSaleTransactions[index].dueAmount!.toDouble())
                                                                          .toString()) ??
                                                                      0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________DueAmount____________________________________________________

                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  myFormat.format(double.tryParse(showAbleSaleTransactions[index].dueAmount.toString()) ?? 0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Profit____________________________________________________

                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  showAbleSaleTransactions[index].lossProfit!.isNegative
                                                                      ? ''
                                                                      : myFormat.format(double.tryParse(showAbleSaleTransactions[index].lossProfit!.toStringAsFixed(2)) ?? 0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Loss____________________________________________________

                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  showAbleSaleTransactions[index].lossProfit!.isNegative
                                                                      ? myFormat.format(double.tryParse(showAbleSaleTransactions[index].lossProfit!.toStringAsFixed(2)) ?? 0)
                                                                      : '',
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///_______________Action_________________________________________________
                                                              SizedBox(
                                                                width: 70,
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    showLossProfitDetails(transitionModel: showAbleSaleTransactions[index]);
                                                                  },
                                                                  child: Text(
                                                                    lang.S.of(context).show,
                                                                    style: const TextStyle(color: Colors.blue),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width: double.infinity,
                                                          height: 1,
                                                          color: kGreyTextColor.withOpacity(0.2),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : EmptyWidget(title: lang.S.of(context).noTransactionFound),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }, error: (e, stack) {
                return Center(
                  child: Text(e.toString()),
                );
              }, loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
            }),
          ),
        ));
  }
}
