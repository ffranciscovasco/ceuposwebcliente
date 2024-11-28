import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../PDF/print_pdf.dart';
import '../../Provider/due_transaction_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/due_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/noDataFound.dart';

class DueReportWidget extends StatefulWidget {
  const DueReportWidget({super.key});

  @override
  State<DueReportWidget> createState() => _DueReportWidgetState();
}

class _DueReportWidgetState extends State<DueReportWidget> {
  String selectedMonth = 'Este mês';

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

  List<String> month = ['Este mês', 'Mês passado', 'Ú 6 meses', 'Este ano', 'Ver tudo'];

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
            case 'Ver tudo':
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

  String searchItem = '';
  double calculatePayableAmount(List<DueTransactionModel> dueTransactionModel) {
    double total = 0.0;
    for (var element in dueTransactionModel) {
      total += element.totalDue!;
    }
    return total;
  }

  double calculateDueAmount(List<DueTransactionModel> dueTransactionModel) {
    double total = 0.0;
    for (var element in dueTransactionModel) {
      total += element.dueAmountAfterPay!;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, watch) {
      final dueReport = ref.watch(dueTransactionProvider);
      return dueReport.when(data: (dueReport) {
        List<DueTransactionModel> reTransaction = [];
        for (var element in dueReport.reversed.toList()) {
          if ((element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()) || element.customerName.toLowerCase().contains(searchItem.toLowerCase())) &&
              (selectedDate.isBefore(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selectedDate)) &&
              (selected2ndDate.isAfter(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selected2ndDate))) {
            reTransaction.add(element);
          }
        }
        final profile = ref.watch(profileDetailsProvider);
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
                    ///____________day_filter________________________________________________________________
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: FormField(
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                child: DropdownButtonHideUnderline(child: getMonth()),
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
                                myFormat.format(double.tryParse(reTransaction.length.toString()) ?? 0),
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
                                '${myFormat.format(double.tryParse(calculateDueAmount(reTransaction).toString()) ?? 0)} $currency',
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
                            color: const Color(0xFFFED3D3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${myFormat.format(double.tryParse(calculatePayableAmount(reTransaction).toString()) ?? 0)} $currency',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                              ),
                              Text(
                                lang.S.of(context).totalPaid,
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
                          lang.S.of(context).dueTransaction,
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
                              hintText: (lang.S.of(context).searchByInvoice),
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
                    const SizedBox(height: 10.0),
                    reTransaction.isNotEmpty
                        ? Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(color: kbgColor),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(width: 35, child: Text('Nr')),
                                    SizedBox(width: 75, child: Text(lang.S.of(context).date)),
                                    SizedBox(width: 50, child: Text(lang.S.of(context).invoice)),
                                    SizedBox(width: 100, child: Text(lang.S.of(context).partyName)),
                                    SizedBox(width: 95, child: Text(lang.S.of(context).partyType)),
                                    SizedBox(width: 70, child: Text(lang.S.of(context).amount)),
                                    SizedBox(width: 60, child: Text(lang.S.of(context).due)),
                                    SizedBox(width: 50, child: Text(lang.S.of(context).status)),
                                    const SizedBox(width: 30, child: Icon(FeatherIcons.settings)),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reTransaction.length,
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
                                              width: 40,
                                              child: Text((index + 1).toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                            ),

                                            ///______________Date__________________________________________________
                                            SizedBox(
                                              width: 75,
                                              child: Text(
                                                reTransaction[index].purchaseDate.substring(0, 10),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
                                              ),
                                            ),

                                            ///____________Invoice_________________________________________________
                                            SizedBox(
                                              width: 50,
                                              child: Text(reTransaction[index].invoiceNumber,
                                                  maxLines: 2, overflow: TextOverflow.ellipsis, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                            ),

                                            ///______Party Name___________________________________________________________
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                reTransaction[index].customerName,
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            ///___________Party Type______________________________________________

                                            SizedBox(
                                              width: 95,
                                              child: Text(
                                                reTransaction[index].paymentType.toString(),
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            ///___________Amount____________________________________________________
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                myFormat.format(double.tryParse(reTransaction[index].totalDue.toString()) ?? 0),
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            ///___________Due____________________________________________________

                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                myFormat.format(double.tryParse(reTransaction[index].dueAmountAfterPay.toString()) ?? 0),
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            ///___________Due____________________________________________________

                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                reTransaction[index].isPaid! ? 'Pago' : "Devendo",
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            ///_______________actions_________________________________________________
                                            SizedBox(
                                              width: 30,
                                              child: Theme(
                                                data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                child: PopupMenuButton(
                                                  surfaceTintColor: Colors.white,
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder: (BuildContext bc) => [
                                                    PopupMenuItem(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          await GeneratePdfAndPrint()
                                                              .printDueInvoice(personalInformationModel: profile.value!, dueTransactionModel: reTransaction[index]);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                                            const SizedBox(width: 4.0),
                                                            Text(
                                                              lang.S.of(context).print,
                                                              style: kTextStyle.copyWith(color: kTitleColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          AnchorElement(
                                                              href:
                                                                  "data:application/octet-stream;charset=utf-16le;base64,${base64Encode(await GeneratePdfAndPrint().generateDueDocument(personalInformation: profile.value!, transactions: reTransaction[index]))}")
                                                            ..setAttribute("download", "${invoiceFileName}_D-${reTransaction[index].invoiceNumber}.pdf")
                                                            ..click();
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(MdiIcons.filePdfBox, size: 18.0, color: kTitleColor),
                                                            const SizedBox(width: 4.0),
                                                            Text(
                                                              lang.S.of(context).downloadPDF,
                                                              style: kTextStyle.copyWith(color: kTitleColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  child: Center(
                                                    child: Container(
                                                        height: 18,
                                                        width: 18,
                                                        alignment: Alignment.centerRight,
                                                        child: const Icon(
                                                          Icons.more_vert_sharp,
                                                          size: 18,
                                                        )),
                                                  ),
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
                            ],
                          )
                        : noDataFoundImage(text: lang.S.of(context).noReportFound),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: DataTable(
                    //     headingRowColor: MaterialStateProperty.all(kLitGreyColor),
                    //     showBottomBorder: false,
                    //     columnSpacing: 0.0,
                    //     columns: [
                    //       DataColumn(
                    //         label: Text(
                    //           'S.L',
                    //           style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Date', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text(
                    //           'Invoice',
                    //           style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Name', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Payment Type', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Payable', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Paid', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Due', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       DataColumn(
                    //         label: Text('Status', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                    //       ),
                    //       const DataColumn(
                    //         label: Icon(FeatherIcons.settings, color: kGreyTextColor),
                    //       ),
                    //     ],
                    //     rows: List.generate(
                    //       reTransaction.length,
                    //       (index) => DataRow(cells: [
                    //         DataCell(
                    //           Text((index + 1).toString()),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].purchaseDate.substring(0, 10), style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].invoiceNumber, style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].customerName, style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].paymentType.toString(), style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].totalDue.toString(), style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].payDueAmount.toString(), style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].dueAmountAfterPay.toString(), style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           GestureDetector(
                    //               onTap: () {
                    //                 DueInvoice(
                    //                   dueTransactionModel: reTransaction[index],
                    //                   personalInformationModel: profile.value!,
                    //                 ).launch(context);
                    //               },
                    //               child: Text(reTransaction[index].isPaid! ? 'Fully Paid' : "Still Unpaid",
                    //                   style: kTextStyle.copyWith(color: kGreyTextColor))),
                    //         ),
                    //         DataCell(
                    //           PopupMenuButton(
                    //             icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                    //             padding: EdgeInsets.zero,
                    //             itemBuilder: (BuildContext bc) => [
                    //               PopupMenuItem(
                    //                 child: GestureDetector(
                    //                   onTap: () {
                    //                     DueInvoice(
                    //                       dueTransactionModel: reTransaction[index],
                    //                       personalInformationModel: profile.value!,
                    //                     ).launch(context);
                    //                   },
                    //                   child: Row(
                    //                     children: [
                    //                       const Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                    //                       const SizedBox(width: 4.0),
                    //                       Text(
                    //                         'Print',
                    //                         style: kTextStyle.copyWith(color: kTitleColor),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //             onSelected: (value) {
                    //               Navigator.pushNamed(context, '$value');
                    //             },
                    //           ),
                    //         ),
                    //       ]),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
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
    });
  }
}
