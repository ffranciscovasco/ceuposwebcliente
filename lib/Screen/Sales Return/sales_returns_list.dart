// ignore_for_file: unused_result

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Sales%20Return/sales_return_screen.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../PDF/print_pdf.dart';
import '../../Provider/customer_provider.dart';
import '../../Provider/daily_transaction_provider.dart';
import '../../Provider/due_transaction_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/sales_returns_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../model/daily_transaction_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class SalesReturn extends StatefulWidget {
  const SalesReturn({super.key});

  static const String route = '/sales_Return';

  @override
  State<SalesReturn> createState() => _SalesReturnState();
}

class _SalesReturnState extends State<SalesReturn> {
  void saleReturn({required SaleTransactionModel salesModel, required WidgetRef consumerRef, required BuildContext context}) async {
    try {
      EasyLoading.show(status: 'Processando...', dismissOnTap: false);

      ///_________Push_on_Sale_return_dataBase____________________________________________________________________________
      DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Sales Return");
      await ref.push().set(salesModel.toJson());

      ///________________delete_From_Sale_transaction______________________________________________________________________
      String? key;
      await FirebaseDatabase.instance.ref(await getUserID()).child('Sales Transition').orderByKey().get().then((value) {
        for (var element in value.children) {
          final t = SaleTransactionModel.fromJson(jsonDecode(jsonEncode(element.value)));
          if (salesModel.invoiceNumber == t.invoiceNumber) {
            key = element.key;
          }
        }
      });
      await FirebaseDatabase.instance.ref(await getUserID()).child('Sales Transition').child(key!).remove();

      ///__________StockMange_________________________________________________________________________________
      final stockRef = FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

      for (var element in salesModel.productList!) {
        var data = await stockRef.orderByChild('productCode').equalTo(element.productId).once();
        final data2 = jsonDecode(jsonEncode(data.snapshot.value));
        String productPath = data.snapshot.value.toString().substring(1, 21);

        var data1 = await stockRef.child('$productPath/productStock').get();
        num stock = num.parse(data1.value.toString());
        num remainStock = stock + element.quantity;

        stockRef.child(productPath).update({'productStock': '$remainStock'});

        ///________Update_Serial_Number____________________________________________________

        if (element.serialNumber!.isNotEmpty) {
          var productOldSerialList = data2[productPath]['serialNumber'] + element.serialNumber;

          // List<dynamic> result = productOldSerialList.where((item) => !element.serialNumber!.contains(item)).toList();
          stockRef.child(productPath).update({
            'serialNumber': productOldSerialList.map((e) => e).toList(),
          });
        }
      }

      ///________daily_transactionModel_________________________________________________________________________

      DailyTransactionModel dailyTransaction = DailyTransactionModel(
        name: salesModel.customerName,
        date: salesModel.purchaseDate,
        type: 'Sale Return',
        total: salesModel.totalAmount!.toDouble(),
        paymentIn: 0,
        paymentOut: salesModel.totalAmount!.toDouble() - salesModel.dueAmount!.toDouble(),
        remainingBalance: salesModel.totalAmount!.toDouble() - salesModel.dueAmount!.toDouble(),
        id: salesModel.invoiceNumber,
        saleTransactionModel: salesModel,
      );
      postDailyTransaction(dailyTransactionModel: dailyTransaction);

      ///_________DueUpdate___________________________________________________________________________________
      if (salesModel.customerName != 'Guest') {
        final dueUpdateRef = FirebaseDatabase.instance.ref('${await getUserID()}/Customers/');
        String? key;

        await FirebaseDatabase.instance.ref(await getUserID()).child('Customers').orderByKey().get().then((value) {
          for (var element in value.children) {
            var data = jsonDecode(jsonEncode(element.value));
            if (data['phoneNumber'] == salesModel.customerPhone) {
              key = element.key;
            }
          }
        });
        var data1 = await dueUpdateRef.child('$key/due').get();
        int previousDue = data1.value.toString().toInt();

        int totalDue = previousDue - salesModel.dueAmount!.toInt();
        dueUpdateRef.child(key!).update({'due': '$totalDue'});
      }

      consumerRef.refresh(allCustomerProvider);
      consumerRef.refresh(buyerCustomerProvider);
      consumerRef.refresh(transitionProvider);
      consumerRef.refresh(productProvider);
      consumerRef.refresh(purchaseTransitionProvider);
      consumerRef.refresh(dueTransactionProvider);
      consumerRef.refresh(profileDetailsProvider);
      consumerRef.refresh(dailyTransactionProvider);

      EasyLoading.showSuccess('Operação realizada com sucesso.');

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  ScrollController mainScroll = ScrollController();
  String searchItem = '';

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
            child: Consumer(builder: (_, ref, watch) {
              AsyncValue<List<SaleTransactionModel>> transactionReport = ref.watch(saleReturnProvider);
              final profile = ref.watch(profileDetailsProvider);
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
                        subManu: 'Sale Return',
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
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          lang.S.of(context).saleReturn,
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
                                                    SizedBox(width: 100, child: Text('Método de Pagamento')),
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
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
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
                                                                  showAbleSaleTransactions[index].dueAmount.toString(),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Due____________________________________________________

                                                              SizedBox(
                                                                width: 50,
                                                                child: Text(
                                                                  showAbleSaleTransactions[index].isPaid! ? 'Pago' : "Devendo",
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
                                                                            await GeneratePdfAndPrint().printSaleReturnInvoice(
                                                                                personalInformationModel: profile.value!, saleTransactionModel: showAbleSaleTransactions[index]);
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
                                                                      // PopupMenuItem(
                                                                      //   child: GestureDetector(
                                                                      //     onTap: () {
                                                                      //       Navigator.push(
                                                                      //           context,
                                                                      //           MaterialPageRoute(
                                                                      //             builder: (context) => SalesReturnScreen(
                                                                      //               saleTransactionModel: showAbleSaleTransactions[index],
                                                                      //             ),
                                                                      //           ));
                                                                      //       // showDialog(
                                                                      //       //     barrierDismissible: false,
                                                                      //       //     context: context,
                                                                      //       //     builder: (BuildContext dialogContext) {
                                                                      //       //       return Center(
                                                                      //       //         child: Container(
                                                                      //       //           decoration: const BoxDecoration(
                                                                      //       //             color: Colors.white,
                                                                      //       //             borderRadius: BorderRadius.all(
                                                                      //       //               Radius.circular(15),
                                                                      //       //             ),
                                                                      //       //           ),
                                                                      //       //           child: Padding(
                                                                      //       //             padding: const EdgeInsets.all(20.0),
                                                                      //       //             child: Column(
                                                                      //       //               mainAxisSize: MainAxisSize.min,
                                                                      //       //               crossAxisAlignment: CrossAxisAlignment.center,
                                                                      //       //               mainAxisAlignment: MainAxisAlignment.center,
                                                                      //       //               children: [
                                                                      //       //                 Text(
                                                                      //       //                   lang.S.of(context).areYouWantToReturnThisSale,
                                                                      //       //                   style: const TextStyle(fontSize: 22),
                                                                      //       //                 ),
                                                                      //       //                 const SizedBox(height: 30),
                                                                      //       //                 Row(
                                                                      //       //                   mainAxisAlignment: MainAxisAlignment.center,
                                                                      //       //                   mainAxisSize: MainAxisSize.min,
                                                                      //       //                   children: [
                                                                      //       //                     GestureDetector(
                                                                      //       //                       child: Container(
                                                                      //       //                         width: 130,
                                                                      //       //                         height: 50,
                                                                      //       //                         decoration: const BoxDecoration(
                                                                      //       //                           color: Colors.red,
                                                                      //       //                           borderRadius: BorderRadius.all(
                                                                      //       //                             Radius.circular(15),
                                                                      //       //                           ),
                                                                      //       //                         ),
                                                                      //       //                         child: Center(
                                                                      //       //                           child: Text(
                                                                      //       //                             lang.S.of(context).no,
                                                                      //       //                             style: TextStyle(color: Colors.white),
                                                                      //       //                           ),
                                                                      //       //                         ),
                                                                      //       //                       ),
                                                                      //       //                       onTap: () {
                                                                      //       //                         Navigator.pop(dialogContext);
                                                                      //       //                         Navigator.pop(bc);
                                                                      //       //                       },
                                                                      //       //                     ),
                                                                      //       //                     const SizedBox(width: 30),
                                                                      //       //                     GestureDetector(
                                                                      //       //                       child: Container(
                                                                      //       //                         width: 130,
                                                                      //       //                         height: 50,
                                                                      //       //                         decoration: const BoxDecoration(
                                                                      //       //                           color: Colors.green,
                                                                      //       //                           borderRadius: BorderRadius.all(
                                                                      //       //                             Radius.circular(15),
                                                                      //       //                           ),
                                                                      //       //                         ),
                                                                      //       //                         child: Center(
                                                                      //       //                           child: Text(
                                                                      //       //                             lang.S.of(context).yesReturn,
                                                                      //       //                             style: const TextStyle(color: Colors.white),
                                                                      //       //                           ),
                                                                      //       //                         ),
                                                                      //       //                       ),
                                                                      //       //                       onTap: () {
                                                                      //       //                         Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReturnScreen(),));
                                                                      //       //                         // saleReturn(
                                                                      //       //                         //   salesModel: showAbleSaleTransactions[index],
                                                                      //       //                         //   consumerRef: ref,
                                                                      //       //                         //   context: dialogContext,
                                                                      //       //                         // );
                                                                      //       //                         Navigator.pop(dialogContext);
                                                                      //       //                       },
                                                                      //       //                     ),
                                                                      //       //                   ],
                                                                      //       //                 )
                                                                      //       //               ],
                                                                      //       //             ),
                                                                      //       //           ),
                                                                      //       //         ),
                                                                      //       //       );
                                                                      //       //     });
                                                                      //     },
                                                                      //     child: Row(
                                                                      //       children: [
                                                                      //         const Icon(Icons.assignment_return, size: 18.0, color: kTitleColor),
                                                                      //         const SizedBox(width: 4.0),
                                                                      //         Text(
                                                                      //           lang.S.of(context).saleReturn,
                                                                      //           style: kTextStyle.copyWith(color: kTitleColor),
                                                                      //         ),
                                                                      //       ],
                                                                      //     ),
                                                                      //   ),
                                                                      // ),
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
