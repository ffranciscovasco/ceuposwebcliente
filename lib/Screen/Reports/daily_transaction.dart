import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/daily_transaction_provider.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/model/daily_transaction_model.dart';
import '../../PDF/print_pdf.dart';
import '../../Provider/profile_provider.dart';
import '../../currency.dart';
import '../Expenses/expense_details.dart';
import '../Income/income_details.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../Widgets/noDataFound.dart';

class DailyTransaction extends StatefulWidget {
  const DailyTransaction({super.key});

  @override
  State<DailyTransaction> createState() => _DailyTransactionState();
}

class _DailyTransactionState extends State<DailyTransaction> {
  double calculateTotalPaymentIn(List<DailyTransactionModel> dailyTransaction) {
    double total = 0.0;
    for (var element in dailyTransaction) {
      total += element.paymentIn;
    }
    return total;
  }

  double calculateTotalPaymentOut(List<DailyTransactionModel> dailyTransaction) {
    double total = 0.0;
    for (var element in dailyTransaction) {
      total += element.paymentOut;
    }
    return total;
  }

  String searchItem = '';

  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<String> month = ['Este mês', 'Mês passado', 'Ú 6 meses', 'Este ano', 'View All'];

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
            case 'View All':
              {
                selectedDate = DateTime(1900, 01, 01);
                selected2ndDate = DateTime.now();
              }
              break;
          }
        });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, watch) {
      final dailyTransactionReport = ref.watch(dailyTransactionProvider);
      final profile = ref.watch(profileDetailsProvider);
      return dailyTransactionReport.when(
        data: (dailyReport) {
          List<DailyTransactionModel> reTransaction = [];
          for (var element in dailyReport.reversed.toList()) {
            if ((selectedDate.isBefore(DateTime.parse(element.date)) || DateTime.parse(element.date).isAtSameMomentAs(selectedDate)) &&
                (selected2ndDate.isAfter(DateTime.parse(element.date)) || DateTime.parse(element.date).isAtSameMomentAs(selected2ndDate))) {
              reTransaction.add(element);
            }
          }
          return Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: kWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 125,
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
                            const SizedBox(width: 20.0),
                            Container(
                                height: 30,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), border: Border.all(color: kGreyTextColor)),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(shape: BoxShape.rectangle, color: kGreyTextColor),
                                      width: 100,
                                      height: 30,
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
                                    reTransaction.isNotEmpty ? myFormat.format(double.tryParse(reTransaction.first.remainingBalance.toStringAsFixed(2)) ?? 0) : '0',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                  ),
                                  Text(
                                    lang.S.of(context).remainingBalance,
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
                                    '${reTransaction.isNotEmpty ? myFormat.format(double.tryParse(calculateTotalPaymentOut(reTransaction).toStringAsFixed(2)) ?? 0) : 0} $currency',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                  ),
                                  Text(
                                    lang.S.of(context).totalpaymentIn,
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
                                color: const Color(0xFFFED3D3),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${reTransaction.isNotEmpty ? myFormat.format(double.tryParse(calculateTotalPaymentIn(reTransaction).toStringAsFixed(2)) ?? 0) : 0} $currency',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                  ),
                                  Text(
                                    lang.S.of(context).totalPaymentOut,
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
                  reTransaction.isNotEmpty
                      ? Container(
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
                              Text(
                                lang.S.of(context).dailyTransaction,
                                style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5.0),
                              Divider(
                                thickness: 1.0,
                                color: kGreyTextColor.withOpacity(0.2),
                              ),
                              const ExportButton().visible(false),
                              SizedBox(
                                height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(kbgColor),
                                    showBottomBorder: false,
                                    columnSpacing: 0.0,
                                    columns: [
                                      DataColumn(
                                        label: Text(lang.S.of(context).name, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text(lang.S.of(context).date, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text(lang.S.of(context).type, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(lang.S.of(context).total, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(lang.S.of(context).paymentIn, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(lang.S.of(context).paymentOut, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(lang.S.of(context).balance, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(lang.S.of(context).action, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    rows: List.generate(
                                      reTransaction.length,
                                      (index) => reTransaction.last.date != reTransaction[index].date
                                          ? DataRow(cells: [
                                              DataCell(
                                                Text(reTransaction[index].name, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                              ),
                                              DataCell(
                                                Text(reTransaction[index].date.substring(0, 10), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                              ),
                                              DataCell(
                                                Text(reTransaction[index].type, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                              ),
                                              DataCell(
                                                Text(myFormat.format(double.tryParse(reTransaction[index].total.toStringAsFixed(2)) ?? 0),
                                                    style: kTextStyle.copyWith(color: kGreyTextColor)),
                                              ),
                                              DataCell(
                                                Text(
                                                    myFormat.format(double.tryParse(reTransaction[index].paymentIn.toStringAsFixed(2)) ?? 0) == '0'
                                                        ? ''
                                                        : myFormat.format(double.tryParse(reTransaction[index].paymentIn.toStringAsFixed(2)) ?? 0),
                                                    style: kTextStyle.copyWith(color: Colors.green)),
                                              ),
                                              DataCell(
                                                Text(
                                                    myFormat.format(double.tryParse(reTransaction[index].paymentOut.toStringAsFixed(2)) ?? 0) == '0'
                                                        ? ''
                                                        : myFormat.format(double.tryParse(reTransaction[index].paymentOut.toStringAsFixed(2)) ?? 0),
                                                    style: kTextStyle.copyWith(color: Colors.red)),
                                              ),
                                              DataCell(
                                                Text(myFormat.format(double.tryParse(reTransaction[index].remainingBalance.toStringAsFixed(2)) ?? 0)),
                                              ),
                                              DataCell(
                                                Theme(
                                                  data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                  child: PopupMenuButton(
                                                    surfaceTintColor: Colors.white,
                                                    icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (BuildContext bc) => [
                                                      PopupMenuItem(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            if (reTransaction[index].type == 'Sale') {
                                                              await GeneratePdfAndPrint().printSaleInvoice(
                                                                  personalInformationModel: profile.value!, saleTransactionModel: reTransaction[index].saleTransactionModel!);
                                                              // SaleInvoice(
                                                              //   transitionModel: reTransaction[index].saleTransactionModel!,
                                                              //   personalInformationModel: profile.value!,
                                                              //   isPosScreen: false,
                                                              // ).launch(context);
                                                            } else if (reTransaction[index].type == 'Sale Return') {
                                                              await GeneratePdfAndPrint().printSaleReturnInvoice(
                                                                  personalInformationModel: profile.value!, saleTransactionModel: reTransaction[index].saleTransactionModel!);
                                                            } else if (reTransaction[index].type == 'Purchase') {
                                                              await GeneratePdfAndPrint().printPurchaseInvoice(
                                                                  personalInformationModel: profile.value!,
                                                                  purchaseTransactionModel: reTransaction[index].purchaseTransactionModel!);

                                                              // PurchaseInvoice(
                                                              //   transitionModel: reTransaction[index].purchaseTransactionModel!,
                                                              //   personalInformationModel: profile.value!,
                                                              //   isPurchase: false,
                                                              // ).launch(context);
                                                            } else if (reTransaction[index].type == 'Purchase Return') {
                                                              await GeneratePdfAndPrint().printPurchaseReturnInvoice(
                                                                  personalInformationModel: profile.value!,
                                                                  purchaseTransactionModel: reTransaction[index].purchaseTransactionModel!);
                                                            } else if (reTransaction[index].type == 'Due Collection' || reTransaction[index].type == 'Due Payment') {
                                                              await GeneratePdfAndPrint().printDueInvoice(
                                                                  personalInformationModel: profile.value!, dueTransactionModel: reTransaction[index].dueTransactionModel!);
                                                              // DueInvoice(
                                                              //   dueTransactionModel: reTransaction[index].dueTransactionModel!,
                                                              //   personalInformationModel: profile.value!,
                                                              // ).launch(context);
                                                            } else if (reTransaction[index].type == 'Expense') {
                                                              showDialog(
                                                                barrierDismissible: false,
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return StatefulBuilder(
                                                                    builder: (context, setStates) {
                                                                      return Dialog(
                                                                        surfaceTintColor: Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                        ),
                                                                        child: ExpenseDetails(expense: reTransaction[index].expenseModel!, manuContext: bc),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            } else if (reTransaction[index].type == 'Income') {
                                                              showDialog(
                                                                barrierDismissible: false,
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return StatefulBuilder(
                                                                    builder: (context, setStates) {
                                                                      return Dialog(
                                                                        surfaceTintColor: Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                        ),
                                                                        child: IncomeDetails(income: reTransaction[index].incomeModel!, manuContext: bc),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                                              const SizedBox(width: 4.0),
                                                              Text(
                                                                'Print',
                                                                style: kTextStyle.copyWith(color: kTitleColor),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      Navigator.pushNamed(context, '$value');
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ])
                                          : DataRow(cells: [
                                              DataCell(
                                                Text(lang.S.of(context).openingBalance),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                              DataCell(
                                                Text(myFormat.format(profile.value!.shopOpeningBalance)),
                                              ),
                                              const DataCell(
                                                Text(''),
                                              ),
                                            ]),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : EmptyWidget(title: lang.S.of(context).noTransactionFound),
                ],
              ));
        },
        error: (e, stack) {
          return Center(
            child: Text(e.toString()),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    });
  }
}
