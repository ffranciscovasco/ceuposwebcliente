import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Reports/print%20loss%20profit%20report/print_loss_profit_report.dart';

import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;

import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';

class LossProfitReport extends StatefulWidget {
  const LossProfitReport({
    Key? key,
  }) : super(key: key);

  static const String route = '/Loss_Profit';

  @override
  State<LossProfitReport> createState() => _LossProfitReportState();
}

class _LossProfitReportState extends State<LossProfitReport> {
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
  List<String> month = ['Este mês', 'Mês passado', 'Ú 6 meses', 'Este ano'];

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
            case 'Ú 6 meses':
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Consumer(builder: (_, ref, watch) {
        final personalData = ref.watch(profileDetailsProvider);
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              const SizedBox(height: 20.0),
              Container(
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
                        const SizedBox(width: 10.0),
                        personalData.when(data: (snapShot) {
                          return Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: kMainColor), color: kWhite),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  onPressed: () async {
                                    await GenerateLossProfitReport().printLossProfitReport(
                                      personalInformationModel: snapShot,
                                      saleTransactionModel: showAbleSaleTransactions ?? [],
                                      fromDate: selectedDate.toString(),
                                      toDate: selected2ndDate.toString(),
                                      saleAmount: calculateTotalSale(transaction).toStringAsFixed(2),
                                      profit: calculateTotalProfit(transaction).toStringAsFixed(2),
                                      loss: calculateTotalLoss(transaction).toStringAsFixed(2),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: kMainColor,
                                  ),
                                  hoverColor: kMainColor.withOpacity(0.1),
                                  style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  )),
                                  color: kMainColor,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: kMainColor), color: kWhite),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  onPressed: () async {
                                    await DownloadLossProfitReport().printLossProfitReport(
                                      personalInformationModel: snapShot,
                                      saleTransactionModel: showAbleSaleTransactions ?? [],
                                      fromDate: selectedDate.toString(),
                                      toDate: selected2ndDate.toString(),
                                      saleAmount: calculateTotalSale(transaction).toStringAsFixed(2),
                                      profit: calculateTotalProfit(transaction).toStringAsFixed(2),
                                      loss: calculateTotalLoss(transaction).toStringAsFixed(2),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.download_outlined,
                                    color: kMainColor,
                                  ),
                                  hoverColor: kMainColor.withOpacity(0.1),
                                  style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  )),
                                  color: kMainColor,
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
                        })
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
                                    SizedBox(width: 70, child: Text(lang.S.of(context).profitPlus)),
                                    SizedBox(width: 70, child: Text(lang.S.of(context).lossminus)),
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

                                              ///___________Profit____________________________________________________

                                              SizedBox(
                                                width: 70,
                                                child: Text(
                                                  showAbleSaleTransactions[index].lossProfit!.isNegative
                                                      ? '0'
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
                                                      : '0',
                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
