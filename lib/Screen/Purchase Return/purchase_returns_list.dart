// ignore_for_file: unused_result

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import 'package:salespro_admin/model/product_model.dart';
import 'package:salespro_admin/model/purchase_transation_model.dart';
import '../../PDF/print_pdf.dart';
import '../../Provider/customer_provider.dart';
import '../../Provider/daily_transaction_provider.dart';
import '../../Provider/due_transaction_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/purchase_returns_provider.dart';
import '../../Provider/purchase_transaction_single.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../model/daily_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class PurchaseReturn extends StatefulWidget {
  const PurchaseReturn({super.key});

  static const String route = '/purchase_Return';

  @override
  State<PurchaseReturn> createState() => _PurchaseReturnState();
}

class _PurchaseReturnState extends State<PurchaseReturn> {
  Future<void> saleReturn({required PurchaseTransactionModel purchase, required WidgetRef consumerRef, required BuildContext context}) async {
    try {
      EasyLoading.show(status: 'Loading...', dismissOnTap: false);

      ///_________Push_on_Sale_return_dataBase____________________________________________________________________________
      DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Purchase Return");
      await ref.push().set(purchase.toJson());

      ///________________delete_From_Sale_transaction______________________________________________________________________
      String? key;
      await FirebaseDatabase.instance.ref(await getUserID()).child('Purchase Transition').orderByKey().get().then((value) {
        for (var element in value.children) {
          final t = PurchaseTransactionModel.fromJson(jsonDecode(jsonEncode(element.value)));
          if (purchase.invoiceNumber == t.invoiceNumber) {
            key = element.key;
          }
        }
      });
      await FirebaseDatabase.instance.ref(await getUserID()).child('Purchase Transition').child(key!).remove();

      ///__________StockMange_________________________________________________________________________________
      final stockRef = FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

      for (var element in purchase.productList!) {
        var data = await stockRef.orderByChild('productCode').equalTo(element.productCode).once();
        final data2 = jsonDecode(jsonEncode(data.snapshot.children.first.value));

        var data1 = await stockRef.child('${data.snapshot.children.first.key}/productStock').get();
        int stock = int.parse(data1.value.toString());
        int remainStock = stock - (int.tryParse(element.productStock) ?? 0);

        stockRef.child(data.snapshot.children.first.key!).update({'productStock': '$remainStock'});

        ///________Update_Serial_Number____________________________________________________

        if (element.serialNumber.isNotEmpty) {
          ProductModel p = ProductModel.fromJson(data2);
          final newList = p.serialNumber.where((item) => !element.serialNumber.contains(item)).toList();

          // List<dynamic> result = productOldSerialList.where((item) => !element.serialNumber!.contains(item)).toList();
          stockRef.child(data.snapshot.children.first.key!).update({
            'serialNumber': newList.map((e) => e).toList(),
            // 'serialNumber': p.serialNumber.where((item) => !element.serialNumber.contains(item)).toList(),
          });
        }
      }

      ///________daily_transactionModel_________________________________________________________________________

      DailyTransactionModel dailyTransaction = DailyTransactionModel(
          name: purchase.customerName,
          date: purchase.purchaseDate,
          type: 'Purchase Return',
          total: purchase.totalAmount!.toDouble(),
          paymentIn: purchase.totalAmount!.toDouble() - purchase.dueAmount!.toDouble(),
          paymentOut: 0,
          remainingBalance: purchase.totalAmount!.toDouble() - purchase.dueAmount!.toDouble(),
          id: purchase.invoiceNumber,
          purchaseTransactionModel: purchase);
      postDailyTransaction(dailyTransactionModel: dailyTransaction);

      ///_________DueUpdate___________________________________________________________________________________
      if (purchase.customerName != 'Guest') {
        final dueUpdateRef = FirebaseDatabase.instance.ref('${await getUserID()}/Customers/');
        // String? key;
        final customerQuery = dueUpdateRef.orderByChild('phoneNumber').equalTo(purchase.customerPhone);
        final customerSnapshot = await customerQuery.once();

        var data1 = await dueUpdateRef.child('${customerSnapshot.snapshot.children.first.key}/due').get();
        int previousDue = data1.value.toString().toInt();

        int totalDue = previousDue - purchase.dueAmount!.toInt();
        dueUpdateRef.child(customerSnapshot.snapshot.children.first.key!).update({'due': '$totalDue'});
      }

      consumerRef.refresh(allCustomerProvider);
      consumerRef.refresh(buyerCustomerProvider);
      consumerRef.refresh(purchaseTransitionProvider);
      consumerRef.refresh(purchaseTransitionProviderSIngle);
      consumerRef.refresh(dueTransactionProvider);
      consumerRef.refresh(profileDetailsProvider);
      consumerRef.refresh(dailyTransactionProvider);
      consumerRef.refresh(productProvider);

      EasyLoading.showSuccess('Successfully Done');

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
              AsyncValue<List<PurchaseTransactionModel>> transactionReport = ref.watch(purchaseReturnProvider);
              final profile = ref.watch(profileDetailsProvider);
              return transactionReport.when(data: (mainTransaction) {
                final reMainTransaction = mainTransaction.reversed.toList();
                List<dynamic> showAbleSaleTransactions = [];
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
                        subManu: 'Purchase Return',
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
                                          'Purchase Return',
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
                                        // const SizedBox(width: 20),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     const PurchaseReturnHistory().launch(context);
                                        //   },
                                        //   child: Container(
                                        //     height: 37,
                                        //     width: 100,
                                        //     decoration: const BoxDecoration(
                                        //       borderRadius: BorderRadius.all(Radius.circular(8)),
                                        //       color: kBlueTextColor,
                                        //     ),
                                        //     child: Center(
                                        //         child: Text(
                                        //       lang.S.of(context).reports,
                                        //       style: const TextStyle(color: Colors.white),
                                        //     )),
                                        //   ),
                                        // )
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
                                                    const SizedBox(width: 50, child: Text('S.L')),
                                                    SizedBox(width: 80, child: Text(lang.S.of(context).date)),
                                                    SizedBox(width: 50, child: Text(lang.S.of(context).invoice)),
                                                    SizedBox(width: 180, child: Text(lang.S.of(context).partyName)),
                                                    SizedBox(width: 100, child: Text(lang.S.of(context).partyType)),
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
                                                                width: 83,
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
                                                                  showAbleSaleTransactions[index].isPaid! ? 'Paid' : "Due",
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
                                                                            await GeneratePdfAndPrint().printPurchaseReturnInvoice(
                                                                                personalInformationModel: profile.value!,
                                                                                purchaseTransactionModel: showAbleSaleTransactions[index]);
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
                                                                      //       showDialog(
                                                                      //           barrierDismissible: false,
                                                                      //           context: context,
                                                                      //           builder: (BuildContext dialogContext) {
                                                                      //             return Center(
                                                                      //               child: Container(
                                                                      //                 decoration: const BoxDecoration(
                                                                      //                   color: Colors.white,
                                                                      //                   borderRadius: BorderRadius.all(
                                                                      //                     Radius.circular(15),
                                                                      //                   ),
                                                                      //                 ),
                                                                      //                 child: Padding(
                                                                      //                   padding: const EdgeInsets.all(20.0),
                                                                      //                   child: Column(
                                                                      //                     mainAxisSize: MainAxisSize.min,
                                                                      //                     crossAxisAlignment: CrossAxisAlignment.center,
                                                                      //                     mainAxisAlignment: MainAxisAlignment.center,
                                                                      //                     children: [
                                                                      //                       const Text(
                                                                      //                         'Are you want to return this purchase?',
                                                                      //                         style: TextStyle(fontSize: 22),
                                                                      //                       ),
                                                                      //                       const SizedBox(height: 30),
                                                                      //                       Row(
                                                                      //                         mainAxisAlignment: MainAxisAlignment.center,
                                                                      //                         mainAxisSize: MainAxisSize.min,
                                                                      //                         children: [
                                                                      //                           GestureDetector(
                                                                      //                             child: Container(
                                                                      //                               width: 130,
                                                                      //                               height: 50,
                                                                      //                               decoration: const BoxDecoration(
                                                                      //                                 color: Colors.red,
                                                                      //                                 borderRadius: BorderRadius.all(
                                                                      //                                   Radius.circular(15),
                                                                      //                                 ),
                                                                      //                               ),
                                                                      //                               child: Center(
                                                                      //                                 child: Text(
                                                                      //                                   lang.S.of(context).no,
                                                                      //                                   style: const TextStyle(color: Colors.white),
                                                                      //                                 ),
                                                                      //                               ),
                                                                      //                             ),
                                                                      //                             onTap: () {
                                                                      //                               Navigator.pop(dialogContext);
                                                                      //                               Navigator.pop(bc);
                                                                      //                             },
                                                                      //                           ),
                                                                      //                           const SizedBox(width: 30),
                                                                      //                           GestureDetector(
                                                                      //                             child: Container(
                                                                      //                               width: 130,
                                                                      //                               height: 50,
                                                                      //                               decoration: const BoxDecoration(
                                                                      //                                 color: Colors.green,
                                                                      //                                 borderRadius: BorderRadius.all(
                                                                      //                                   Radius.circular(15),
                                                                      //                                 ),
                                                                      //                               ),
                                                                      //                               child: Center(
                                                                      //                                 child: Text(
                                                                      //                                   lang.S.of(context).yesReturn,
                                                                      //                                   style: const TextStyle(color: Colors.white),
                                                                      //                                 ),
                                                                      //                               ),
                                                                      //                             ),
                                                                      //                             onTap: () async {
                                                                      //                               await saleReturn(
                                                                      //                                 purchase: showAbleSaleTransactions[index],
                                                                      //                                 consumerRef: ref,
                                                                      //                                 context: dialogContext,
                                                                      //                               );
                                                                      //                               Navigator.pop(dialogContext);
                                                                      //                             },
                                                                      //                           ),
                                                                      //                         ],
                                                                      //                       )
                                                                      //                     ],
                                                                      //                   ),
                                                                      //                 ),
                                                                      //               ),
                                                                      //             );
                                                                      //           });
                                                                      //     },
                                                                      //     child: Row(
                                                                      //       children: [
                                                                      //         const Icon(Icons.assignment_return, size: 18.0, color: kTitleColor),
                                                                      //         const SizedBox(width: 4.0),
                                                                      //         Text(
                                                                      //           'Purchase Return',
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
