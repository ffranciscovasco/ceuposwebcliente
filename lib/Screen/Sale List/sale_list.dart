import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/customer_provider.dart';
import 'package:salespro_admin/Provider/daily_transaction_provider.dart';
import 'package:salespro_admin/Screen/Sale%20List/sale_edit.dart';
import 'package:salespro_admin/delete_invoice_functions.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../PDF/print_pdf.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../model/product_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Sales Return/sales_return_screen.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class SaleList extends StatefulWidget {
  const SaleList({super.key});

  static const String route = '/saleList';

  @override
  State<SaleList> createState() => _SaleListState();
}

class _SaleListState extends State<SaleList> {
  String searchItem = '';
  ScrollController mainScroll = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kDarkWhite,
        body: Scrollbar(
          controller: mainScroll,
          child: SingleChildScrollView(
            controller: mainScroll,
            scrollDirection: Axis.horizontal,
            child: Consumer(builder: (_, consuearRef, watch) {
              AsyncValue<List<SaleTransactionModel>> transactionReport = consuearRef.watch(transitionProvider);
              final profile = consuearRef.watch(profileDetailsProvider);
              return transactionReport.when(data: (mainTransaction) {
                final reMainTransaction = mainTransaction.reversed.toList();
                List<SaleTransactionModel> showAbleSaleTransactions = [];
                for (var element in reMainTransaction) {
                  if (searchItem != '' &&
                      (element.customerName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) ||
                          element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()))) {
                    showAbleSaleTransactions.add(element);
                  } else if (searchItem == '') {
                    showAbleSaleTransactions.add(element);
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: SideBarWidget(
                        index: 1,
                        subManu: 'Sale List',
                        isTab: false,
                      ),
                    ),
                    Container(
                      // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                      width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                      decoration: const BoxDecoration(color: kDarkWhite),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //_______________________________top_bar____________________________
                                const TopBar(),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              lang.S.of(context).saleList,
                                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
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
                                                  contentPadding: const EdgeInsets.all(8.0),
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
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Divider(
                                          thickness: 1.0,
                                          color: kGreyTextColor.withOpacity(0.2),
                                        ),

                                        ///_______sale_List_____________________________________________________

                                        const SizedBox(height: 20.0),
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
                                                        SizedBox(width: 82, child: Text(lang.S.of(context).date)),
                                                        SizedBox(width: 50, child: Text(lang.S.of(context).invoice)),
                                                        SizedBox(width: 180, child: Text(lang.S.of(context).partyName)),
                                                        SizedBox(width: 100, child: Text(lang.S.of(context).paymentType)),
                                                        SizedBox(width: 70, child: Text(lang.S.of(context).amount)),
                                                        SizedBox(width: 70, child: Text(lang.S.of(context).due)),
                                                        SizedBox(width: 50, child: Text(lang.S.of(context).status)),
                                                        const SizedBox(width: 30, child: Icon(FeatherIcons.settings)),
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
                                                                    width: 82,
                                                                    child: Text(
                                                                      showAbleSaleTransactions[index].purchaseDate.substring(0, 10),
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 2,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
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
                                                                    width: 180,
                                                                    child: Text(
                                                                      showAbleSaleTransactions[index].customerName,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Party Type______________________________________________

                                                                  SizedBox(
                                                                    width: 100,
                                                                    child: Text(
                                                                      showAbleSaleTransactions[index].paymentType.toString(),
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Amount____________________________________________________
                                                                  SizedBox(
                                                                    width: 70,
                                                                    child: Text(
                                                                      myFormat.format(double.tryParse(showAbleSaleTransactions[index].totalAmount.toString()) ?? 0),
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Due____________________________________________________

                                                                  SizedBox(
                                                                    width: 70,
                                                                    child: Text(
                                                                      myFormat.format(double.tryParse(showAbleSaleTransactions[index].dueAmount.toString()) ?? 0),
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Due____________________________________________________

                                                                  SizedBox(
                                                                    width: 50,
                                                                    child: Text(
                                                                      showAbleSaleTransactions[index].isPaid! ? 'Pago' : "Devido",
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///_______________actions_________________________________________________
                                                                  SizedBox(
                                                                    width: 30,
                                                                    child: Theme(
                                                                      data: ThemeData(
                                                                          highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                                      child: PopupMenuButton(
                                                                        surfaceTintColor: Colors.white,
                                                                        padding: EdgeInsets.zero,
                                                                        itemBuilder: (BuildContext bc) => [
                                                                          PopupMenuItem(
                                                                            child: GestureDetector(
                                                                              onTap: () async {
                                                                                await GeneratePdfAndPrint().printSaleInvoice(
                                                                                    personalInformationModel: profile.value!,
                                                                                    saleTransactionModel: showAbleSaleTransactions[index]);
                                                                                // SaleInvoice(
                                                                                //   isPosScreen: false,
                                                                                //   transitionModel: showAbleSaleTransactions[index],
                                                                                //   personalInformationModel: profile.value!,
                                                                                // ).launch(context);
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
                                                                              onTap: () {
                                                                                SaleEdit(
                                                                                  transitionModel: showAbleSaleTransactions[index],
                                                                                  personalInformationModel: profile.value!,
                                                                                  isPosScreen: false,
                                                                                  popUpContext: bc,
                                                                                ).launch(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  const Icon(FeatherIcons.edit3, size: 18.0, color: kTitleColor),
                                                                                  const SizedBox(width: 4.0),
                                                                                  Text(
                                                                                    lang.S.of(context).edit,
                                                                                    style: kTextStyle.copyWith(color: kTitleColor),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          ///________Sale List Delete_______________________________
                                                                          PopupMenuItem(
                                                                            child: GestureDetector(
                                                                              onTap: () => showDialog(
                                                                                  context: context,
                                                                                  builder: (context2) => AlertDialog(
                                                                                        title: const Text('Tem certeza de que deseja excluir esta venda?'),
                                                                                        content: const Text(
                                                                                          'A venda será excluída e todos os dados sobre esta venda serão excluídos.Tem certeza de excluir esta?',
                                                                                          maxLines: 5,
                                                                                        ),
                                                                                        actions: [
                                                                                          const Text('Voltar').onTap(() => Navigator.pop(context2)),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(20.0),
                                                                                            child: const Text('Sim, excluir para sempre').onTap(() async {
                                                                                              EasyLoading.show();

                                                                                              DeleteInvoice delete = DeleteInvoice();

                                                                                              await delete.editStockAndSerial(
                                                                                                  saleTransactionModel: showAbleSaleTransactions[index]);

                                                                                              await delete.customerDueUpdate(
                                                                                                due: showAbleSaleTransactions[index].dueAmount ?? 0,
                                                                                                phone: showAbleSaleTransactions[index].customerPhone,
                                                                                              );
                                                                                              await delete.updateFromShopRemainBalance(
                                                                                                paidAmount: (showAbleSaleTransactions[index].totalAmount ?? 0) -
                                                                                                    (showAbleSaleTransactions[index].dueAmount ?? 0),
                                                                                                isFromPurchase: false,
                                                                                              );
                                                                                              await delete.deleteDailyTransaction(
                                                                                                  invoice: showAbleSaleTransactions[index].invoiceNumber,
                                                                                                  status: 'Sale',
                                                                                                  field: "saleTransactionModel");
                                                                                              DatabaseReference ref = FirebaseDatabase.instance.ref(
                                                                                                  "${await getUserID()}/Sales Transition/${showAbleSaleTransactions[index].key}");

                                                                                              await ref.remove();
                                                                                              consuearRef.refresh(transitionProvider);
                                                                                              consuearRef.refresh(productProvider);
                                                                                              consuearRef.refresh(allCustomerProvider);
                                                                                              consuearRef.refresh(profileDetailsProvider);
                                                                                              consuearRef.refresh(dailyTransactionProvider);
                                                                                              EasyLoading.showSuccess('Done');
                                                                                              // ignore: use_build_context_synchronously
                                                                                              Navigator.pop(context2);
                                                                                              Navigator.pop(bc);
                                                                                            }),
                                                                                          ),
                                                                                        ],
                                                                                      )),
                                                                              child: Row(
                                                                                children: [
                                                                                  const Icon(
                                                                                    Icons.delete,
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 10.0,
                                                                                  ),
                                                                                  Text(
                                                                                    'Apagar',
                                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          ///____Sales_Return________________________________________
                                                                          PopupMenuItem(
                                                                            child: GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => SalesReturnScreen(
                                                                                        saleTransactionModel: showAbleSaleTransactions[index],
                                                                                      ),
                                                                                    ));
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  const Icon(Icons.assignment_return, size: 18.0, color: kTitleColor),
                                                                                  const SizedBox(width: 4.0),
                                                                                  Text(
                                                                                    lang.S.of(context).saleReturn,
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
                                                  ),
                                                ],
                                              )
                                            : EmptyWidget(title: lang.S.of(context).noSaleTransaactionFound)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
                          ],
                        ),
                      ),
                    )
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
        ),
      ),
    );
  }
}
